import AuthenticationServices
import CommonCrypto
import Foundation

public typealias LoginResultHandler = (Result<User, LoginError>) -> Void

public struct ClientConfiguration {
    /// Issuer identifier for identifier provider
    public let issuer: String
    /// URL of identity provider
    public let serverURL: URL
    /// Registered client id
    public let clientId: String
    /// Registered redirect URI
    public let redirectURI: URL
    
    public enum Environment: String {
        case proCom = "https://login.schibsted.com"
        case proFi = "https://login.schibsted.fi"
        case proNo = "https://payment.schibsted.no"
        case pre = "https://identity-pre.schibsted.com"
    }
    
    public init(environment: Environment, clientId: String, redirectURI: URL) {
        self.init(serverURL: URL(string: environment.rawValue)!,
                  clientId: clientId,
                  redirectURI: redirectURI)
    }
    
    public init(serverURL: URL, clientId: String, redirectURI: URL) {
        self.serverURL = serverURL
        self.issuer = serverURL.absoluteString
        self.clientId = clientId
        self.redirectURI = redirectURI
    }
}

public struct SessionStorageConfig {
    let accessGroup: String?
    let legacyAccessGroup: String?
    
    public init(accessGroup: String? = nil, legacyAccessGroup: String? = nil) {
        self.accessGroup = accessGroup
        self.legacyAccessGroup = legacyAccessGroup
    }
}

// Default implementation of `ASWebAuthenticationPresentationContextProviding` for the ASWebAuthenticationSession.
@available(iOS 12.0, *)
public class ASWebAuthSessionContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}

/// Represents a client registered with Schibsted account
public class Client {
    public let configuration: ClientConfiguration
    
    internal static let authStateKey = "AuthState"
    private static let keychainServiceName = "com.schibsted.account"
    private static let defaultScopeValues = ["openid", "offline_access"]
    
    internal let sessionStorage: SessionStorage
    internal let httpClient: HTTPClient
    internal let tokenHandler: TokenHandler
    internal let schibstedAccountAPI: SchibstedAccountAPI
    
    private let stateStorage: StateStorage
    
    public convenience init(configuration: ClientConfiguration, httpClient: HTTPClient = HTTPClientWithURLSession()) {
        self.init(configuration: configuration,
                  sessionStorage: KeychainSessionStorage(service: Client.keychainServiceName),
                  stateStorage: StateStorage(),
                  httpClient: httpClient,
                  jwks: RemoteJWKS(jwksURI: configuration.serverURL.appendingPathComponent("/oauth/jwks"), httpClient: httpClient))
    }
    
    public convenience init(configuration: ClientConfiguration, sessionStorageConfig: SessionStorageConfig, httpClient: HTTPClient = HTTPClientWithURLSession()) {
        let legacySessionStorage = LegacyKeychainSessionStorage(accessGroup: sessionStorageConfig.legacyAccessGroup)
        let sessionStorage = MigratingKeychainCompatStorage(from: legacySessionStorage, to: KeychainSessionStorage(service: Client.keychainServiceName, accessGroup: sessionStorageConfig.accessGroup))
        self.init(configuration: configuration,
                  sessionStorage: sessionStorage,
                  stateStorage: StateStorage(),
                  httpClient: httpClient,
                  jwks: RemoteJWKS(jwksURI: configuration.serverURL.appendingPathComponent("/oauth/jwks"), httpClient: httpClient))
    }

    internal convenience init(configuration: ClientConfiguration, sessionStorage: SessionStorage, stateStorage: StateStorage, httpClient: HTTPClient = HTTPClientWithURLSession()) {
        self.init(configuration: configuration,
                  sessionStorage: sessionStorage,
                  stateStorage: stateStorage,
                  httpClient: httpClient,
                  jwks: RemoteJWKS(jwksURI: configuration.serverURL.appendingPathComponent("/oauth/jwks"), httpClient: httpClient))
    }
    
    internal init(configuration: ClientConfiguration, sessionStorage: SessionStorage, stateStorage: StateStorage, httpClient: HTTPClient, jwks: JWKS) {
        self.configuration = configuration
        self.sessionStorage = sessionStorage
        self.stateStorage = stateStorage
        self.httpClient = httpClient
        self.tokenHandler = TokenHandler(configuration: configuration, httpClient: httpClient, jwks: jwks)
        self.schibstedAccountAPI = SchibstedAccountAPI(baseURL: configuration.serverURL)
    }

    /// Resume any previously logged-in user session
    public func resumeLastLoggedInUser() -> User? {
        let stored = sessionStorage.get(forClientId: configuration.clientId)
        guard let session = stored else {
            return nil
        }
        
        return User(client: self, session: session)
    }
    
    private func getMostRecentSession() -> UserSession? {
        sessionStorage.getAll()
            .sorted { $0.updatedAt > $1.updatedAt }
            .first
    }
    
    @available(iOS 12.0, *)
    private func createWebAuthenticationSession(withMFA: MFAType? = nil, extraScopeValues: Set<String> = [], completion: @escaping LoginResultHandler) -> ASWebAuthenticationSession {
        let clientScheme = configuration.redirectURI.scheme
        guard let url = loginURL(withMFA: withMFA, extraScopeValues: extraScopeValues) else {
            preconditionFailure("Couldn't create loginURL")
        }
        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: clientScheme) { callbackURL, error in
            guard let url = callbackURL else {
                if case ASWebAuthenticationSessionError.canceledLogin? = error {
                    SchibstedAccountLogger.instance.debug("Login flow was cancelled")
                    completion(.failure(.canceled))
                } else {
                    SchibstedAccountLogger.instance.error("Login flow error: \(error)")
                    completion(.failure(.unexpectedError(message: "ASWebAuthenticationSession failed: \(error)")))
                }
                return
            }

            self.handleAuthenticationResponse(url: url, completion: completion)
        }
        return session
    }
    
    /**
     Start login flow
     
     - parameter withMFA: Optional MFA verification to prompt the user with
     - parameter extraScopeValues: Any additional scope values to request
        By default `openid` and `offline_access` will always be included as scope values.
     - parameter completion: callback that receives the login result
     */
    @available(iOS 12.0, *)
    public func login(withMFA: MFAType? = nil, extraScopeValues: Set<String> = [], completion: @escaping LoginResultHandler) {
        let session = getLoginSession(withMFA: withMFA, extraScopeValues: extraScopeValues, completion: completion)
        session.start()
    }

    /**
     Start login flow
     
     This method must be used for devices with iOS 13 and up.
     - parameter withMFA: Optional MFA verification to prompt the user with
     - parameter extraScopeValues: Any additional scope values to request
        By default `openid` and `offline_access` will always be included as scope values.
     - parameter withSSO: whether cookies should be shared to enable single-sign on (defaults to true)
     - parameter completion: callback that receives the login result
     */
    @available(iOS 13.0, *)
    public func login(withMFA: MFAType? = nil, extraScopeValues: Set<String> = [], withSSO: Bool = true, completion: @escaping LoginResultHandler) {
        let contextProvider = ASWebAuthSessionContextProvider()
        let session = getLoginSession(contextProvider: contextProvider, withMFA: withMFA, extraScopeValues: extraScopeValues, withSSO: withSSO, completion: completion)
        session.start()
    }

    /**
     Get web authentication session
     
     - parameter withMFA: Optional MFA verification to prompt the user with
     - parameter extraScopeValues: Any additional scope values to request
        By default `openid` and `offline_access` will always be included as scope values.
     - parameter completion: callback that receives the login result
     - returns Web authentication session to start for the login flows
     */
    @available(iOS 12.0, *)
    public func getLoginSession(withMFA: MFAType? = nil, extraScopeValues: Set<String> = [], completion: @escaping LoginResultHandler) -> ASWebAuthenticationSession {
        return createWebAuthenticationSession(withMFA: withMFA, extraScopeValues: extraScopeValues, completion: completion)
    }
    
    /**
     Get web authentication session
     
     This method must be used for devices with iOS 13 and up.
     - parameter contextProvider: Delegate to provide presentation context for the `ASWebAuthenticationSession`
     - parameter withMFA: Optional MFA verification to prompt the user with
     - parameter extraScopeValues: Any additional scope values to request
        By default `openid` and `offline_access` will always be included as scope values.
     - parameter withSSO: whether cookies should be shared to enable single-sign on (defaults to true)
     - parameter completion: callback that receives the login result
     - returns Web authentication session to start for the login flows
     */
    @available(iOS 13.0, *)
    public func getLoginSession(contextProvider: ASWebAuthenticationPresentationContextProviding, withMFA: MFAType? = nil, extraScopeValues: Set<String> = [], withSSO: Bool = true, completion: @escaping LoginResultHandler) -> ASWebAuthenticationSession {
        let session = createWebAuthenticationSession(withMFA: withMFA, extraScopeValues: extraScopeValues, completion: completion)
        session.presentationContextProvider = contextProvider
        session.prefersEphemeralWebBrowserSession = !withSSO
        
        return session
    }
    
    internal func loginURL(withMFA: MFAType? = nil, extraScopeValues: Set<String> = []) -> URL? {
        let state = randomString(length: 10)
        let nonce = randomString(length: 10)
        let codeVerifier = randomString(length: 60)
        let authState = AuthState(state: state, nonce: nonce, codeVerifier: codeVerifier, mfa: withMFA)

        if !stateStorage.setValue(authState, forKey: type(of: self).authStateKey) {
            SchibstedAccountLogger.instance.error("Failed to store login state")
            return nil;
        }

        let scopes = extraScopeValues.union(Client.defaultScopeValues)
        let scopeString = scopes.joined(separator: " ")
        let codeChallenge = computeCodeChallenge(from: codeVerifier)

        var authRequestParams = [
            URLQueryItem(name: "client_id", value: configuration.clientId),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI.absoluteString),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: scopeString),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "nonce", value: nonce),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
        ]
        if let mfa = withMFA {
            authRequestParams.append(URLQueryItem(name: "acr_values", value: mfa.rawValue))
        } else {
            // Only add this if no MFA is specified to avoid prompting user unnecessarily
            authRequestParams.append(URLQueryItem(name: "prompt", value: "select_account"))
        }

        return makeURLWithQuery(
            forPath: "/oauth/authorize",
            queryItems: authRequestParams
        )
    }
    
    /**
     Call this with the full URL received as deep link to complete the login flow.
        
     This only needs to be used if manually starting the login flow using `getLoginSession`.
     Calling `login()` will handle this for you.
     
     - parameter url: full URL from received deep link upon completion of user authentication
     - parameter completion: callback that receives the login result
    */
    public func handleAuthenticationResponse(url: URL, completion: @escaping LoginResultHandler) {
        // Check if coming back after triggered web flow login
        guard let storedData: AuthState = stateStorage.value(forKey: type(of: self).authStateKey),
           let receivedState = url.valueOf(queryParameter: "state"),
           storedData.state == receivedState else {
                completion(.failure(.unsolicitedResponse))
                return
        }
        stateStorage.removeValue(forKey: type(of: self).authStateKey)

        if let error = url.valueOf(queryParameter: "error") {
            completion(.failure(.authenticationErrorResponse(error: OAuthError(error: error, errorDescription: url.valueOf(queryParameter: "error_description")))))
            return
        }
        
        guard let authCode = url.valueOf(queryParameter: "code") else {
            completion(.failure(.unexpectedError(message: "Missing authorization code from authentication response")))
            return
        }

        tokenHandler.makeTokenRequest(authCode: authCode, authState: storedData) {
            self.handleTokenRequestResult($0, completion: completion)
        }
    }

    private func handleTokenRequestResult(_ result: Result<TokenResult, TokenError>, completion: LoginResultHandler) {
        switch result {
        case .success(let tokenResult):
            let userSession = UserSession(clientId: self.configuration.clientId,
                                          userTokens: tokenResult.userTokens,
                                          updatedAt: Date())
            sessionStorage.store(userSession)
            let user = User(client: self, session: userSession)
            completion(.success(user))
        case .failure(.tokenRequestError(.errorResponse(_, let body))):
            SchibstedAccountLogger.instance.error("Failed to obtain tokens: \(body)")
            if let errorJSON = body,
               let oauthError = OAuthError.fromJSON(errorJSON) {
                completion(.failure(.tokenErrorResponse(error: oauthError)))
                return
            }

            completion(.failure(.unexpectedError(message: "Failed to obtain user tokens")))
        case .failure(.idTokenError(.missingExpectedAMRValue)):
            SchibstedAccountLogger.instance.error("MFA authentication failed")
            completion(.failure(.missingExpectedMFA))
        case .failure(let error):
            SchibstedAccountLogger.instance.error("Failed to obtain user tokens: \(error)")
            completion(.failure(.unexpectedError(message: "Failed to obtain user tokens")))
        }
    }

    private func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
    
    private func computeCodeChallenge(from codeVerifier: String) -> String {
        func base64url(data: Data) -> String {
            let base64url = data.base64EncodedString()
                .replacingOccurrences(of: "/", with: "_")
                .replacingOccurrences(of: "+", with: "-")
                .replacingOccurrences(of: "=", with: "")
            return base64url
        }

        func sha256(data: Data) -> Data {
            var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
            data.withUnsafeBytes {
                _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
            }
            return Data(hash)
        }

        return base64url(data: sha256(data: Data(codeVerifier.utf8)))
    }
    
    private func makeURLWithQuery(forPath path: String, queryItems: [URLQueryItem]) -> URL {
        let url = configuration.serverURL.appendingPathComponent(path)
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            preconditionFailure("Failed to create URLComponents from \(url)")
        }
        urlComponents.queryItems = queryItems

        guard let finalUrl = urlComponents.url else {
            preconditionFailure("Failed to create URL from \(urlComponents)")
        }
        return finalUrl
    }
}

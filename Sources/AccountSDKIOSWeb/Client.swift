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
public class ASWebAuthSessionContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}

/// Represents a client registered with Schibsted account
public class Client {
    let configuration: ClientConfiguration
    let urlBuilder: URLBuilder
    
    internal static let authStateKey = "AuthState"
    private static let keychainServiceName = "com.schibsted.account"

    internal let httpClient: HTTPClient
    internal let schibstedAccountAPI: SchibstedAccountAPI

    private let tokenHandler: TokenHandler
    private let stateStorage: StateStorage
    private let sessionStorage: SessionStorage

    private lazy var asWebAuthSession: ASWebAuthenticationSession? = nil
    
    public convenience init(configuration: ClientConfiguration, httpClient: HTTPClient = HTTPClientWithURLSession()) {
        self.init(configuration: configuration,
                  sessionStorage: KeychainSessionStorage(service: Client.keychainServiceName),
                  stateStorage: StateStorage(),
                  httpClient: httpClient,
                  jwks: RemoteJWKS(jwksURI: configuration.serverURL.appendingPathComponent("/oauth/jwks"), httpClient: httpClient))
    }
    
    /// Initializes the Client to support migration from Legacy SchibstedAccount SDK to new Schibsted account keychain storage using UserSession
    public convenience init(configuration: ClientConfiguration, sessionStorageConfig: SessionStorageConfig, httpClient: HTTPClient = HTTPClientWithURLSession()) {
        let legacySessionStorage = LegacyKeychainSessionStorage(accessGroup: sessionStorageConfig.legacyAccessGroup)
        let sessionStorage = MigratingKeychainCompatStorage(from: legacySessionStorage, to: KeychainSessionStorage(service: Client.keychainServiceName, accessGroup: sessionStorageConfig.accessGroup))
        self.init(configuration: configuration,
                  sessionStorage: sessionStorage,
                  stateStorage: StateStorage(),
                  httpClient: httpClient,
                  jwks: RemoteJWKS(jwksURI: configuration.serverURL.appendingPathComponent("/oauth/jwks"), httpClient: httpClient))
    }
    
    convenience init(configuration: ClientConfiguration, sessionStorage: SessionStorage, stateStorage: StateStorage, httpClient: HTTPClient = HTTPClientWithURLSession()) {
        self.init(configuration: configuration,
                  sessionStorage: sessionStorage,
                  stateStorage: stateStorage,
                  httpClient: httpClient,
                  jwks: RemoteJWKS(jwksURI: configuration.serverURL.appendingPathComponent("/oauth/jwks"), httpClient: httpClient))
    }
    
    init(configuration: ClientConfiguration, sessionStorage: SessionStorage, stateStorage: StateStorage, httpClient: HTTPClient, jwks: JWKS) {
        self.configuration = configuration
        self.sessionStorage = sessionStorage
        self.stateStorage = stateStorage
        self.httpClient = httpClient
        self.tokenHandler = TokenHandler(configuration: configuration, httpClient: httpClient, jwks: jwks)
        self.schibstedAccountAPI = SchibstedAccountAPI(baseURL: configuration.serverURL)
        self.urlBuilder = URLBuilder(configuration: configuration, stateStorage: stateStorage, authStateKey: Client.authStateKey)
    }

    
    
    private func getMostRecentSession() -> UserSession? {
        sessionStorage.getAll()
            .sorted { $0.updatedAt > $1.updatedAt }
            .first
    }

    private func createWebAuthenticationSession(withMFA: MFAType? = nil,
                                                loginHint: String?,
                                                extraScopeValues: Set<String> = [],
                                                completion: @escaping LoginResultHandler) -> ASWebAuthenticationSession {
        let clientScheme = configuration.redirectURI.scheme
        
        guard let url = urlBuilder.loginURL(withMFA: withMFA, loginHint: loginHint, extraScopeValues: extraScopeValues) else {
            preconditionFailure("Couldn't create loginURL")
        }
        
        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: clientScheme) { callbackURL, error in
            self.asWebAuthSession = nil
            guard let url = callbackURL else {
                if case ASWebAuthenticationSessionError.canceledLogin? = error {
                    SchibstedAccountLogger.instance.debug("Login flow was cancelled")
                    completion(.failure(.canceled))
                } else {
                    SchibstedAccountLogger.instance.error("Login flow error: \(String(describing: error))")
                    completion(.failure(.unexpectedError(message: "ASWebAuthenticationSession failed: \(String(describing: error))")))
                }
                return
            }

            self.handleAuthenticationResponse(url: url, completion: completion)
        }
        return session
    }
        
    func refreshTokens(for user: User, completion: @escaping (Result<UserTokens, RefreshTokenError>) -> Void) {
        guard let existingRefreshToken = user.tokens?.refreshToken else {
            SchibstedAccountLogger.instance.debug("No existing refresh token, skipping token refreh")
            completion(.failure(.noRefreshToken))
            return
        }

        // try to exchange refresh token for new token
        tokenHandler.makeTokenRequest(refreshToken: existingRefreshToken) { tokenRefreshResult in
            switch tokenRefreshResult {
            case .success(let tokenResponse):
                SchibstedAccountLogger.instance.debug("Successfully refreshed user tokens")
                guard let tokens = user.tokens else {
                    SchibstedAccountLogger.instance.info("User has logged-out during token refresh, discarding new tokens.")
                    completion(.failure(.unexpectedError(error: LoginStateError.notLoggedIn)))
                    return
                }
                let refreshToken = tokenResponse.refresh_token ?? tokens.refreshToken
                let userTokens = UserTokens(accessToken: tokenResponse.access_token,
                                            refreshToken: refreshToken,
                                            idToken: tokens.idToken,
                                            idTokenClaims: tokens.idTokenClaims)
                user.tokens = userTokens
                
                let userSession = UserSession(clientId: self.configuration.clientId,
                                              userTokens: userTokens,
                                              updatedAt: Date())
                self.sessionStorage.store(userSession)
                completion(.success(userTokens))
            case .failure(let error):
                SchibstedAccountLogger.instance.error("Failed to refresh user tokens")
                completion(.failure(.refreshRequestFailed(error: error)))
            }
        }
    }

    private func handleTokenRequestResult(_ result: Result<TokenResult, TokenError>, completion: LoginResultHandler) {
        switch result {
        case .success(let tokenResult):
            let userSession = UserSession(clientId: self.configuration.clientId,
                                          userTokens: tokenResult.userTokens,
                                          updatedAt: Date())
            sessionStorage.store(userSession)
            let user = User(client: self, tokens: tokenResult.userTokens)
            completion(.success(user))
        case .failure(.tokenRequestError(.errorResponse(_, let body))):
            SchibstedAccountLogger.instance.error("Failed to obtain tokens: \(String(describing: body))")
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
    
    func destroySession() {
        sessionStorage.remove(forClientId: configuration.clientId)
    }
    
}

extension Client {
    
    // MARK: - Public
    
    /// Resume any previously logged-in user session
    public func resumeLastLoggedInUser() -> User? {
        let stored = sessionStorage.get(forClientId: configuration.clientId)
        guard let session = stored else {
            return nil
        }
        
        return User(client: self, tokens: session.userTokens)
    }
 
    /**
     Get web authentication session
     
     - parameter withMFA: Optional MFA verification to prompt the user with
     - parameter extraScopeValues: Any additional scope values to request
        By default `openid` and `offline_access` will always be included as scope values.
     - parameter completion: callback that receives the login result
     - returns Web authentication session to start for the login flows
     */
    public func getLoginSession(withMFA: MFAType? = nil,
                                loginHint: String? = nil,
                                extraScopeValues: Set<String> = [],
                                completion: @escaping LoginResultHandler) -> ASWebAuthenticationSession {
        return createWebAuthenticationSession(withMFA: withMFA, loginHint: loginHint, extraScopeValues: extraScopeValues, completion: completion)
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
    public func getLoginSession(contextProvider: ASWebAuthenticationPresentationContextProviding,
                                withMFA: MFAType? = nil,
                                loginHint: String? = nil,
                                extraScopeValues: Set<String> = [],
                                withSSO: Bool = true, completion: @escaping LoginResultHandler) -> ASWebAuthenticationSession {
        
        let session = createWebAuthenticationSession(withMFA: withMFA, loginHint: loginHint, extraScopeValues: extraScopeValues, completion: completion)
        session.presentationContextProvider = contextProvider
        session.prefersEphemeralWebBrowserSession = !withSSO
        
        return session
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
}

struct URLBuilder {
    
    let configuration: ClientConfiguration
    let defaultScopeValues = ["openid", "offline_access"]
    let stateStorage: StateStorage
    let authStateKey: String
    
    func loginURL(withMFA: MFAType? = nil,
                  loginHint: String? = nil,
                  extraScopeValues: Set<String> = []) -> URL? {
        let state = randomString(length: 10)
        let nonce = randomString(length: 10)
        let codeVerifier = randomString(length: 60)
        let authState = AuthState(state: state, nonce: nonce, codeVerifier: codeVerifier, mfa: withMFA)

        if !stateStorage.setValue(authState, forKey: authStateKey) {
            SchibstedAccountLogger.instance.error("Failed to store login state")
            return nil;
        }

        let scopes = extraScopeValues.union(defaultScopeValues)
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
        
        if let loginHint = loginHint { authRequestParams.append(URLQueryItem(name: "login_hint", value: loginHint)) }
        
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
    
    private func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
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
}

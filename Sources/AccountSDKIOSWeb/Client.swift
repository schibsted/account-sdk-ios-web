import AuthenticationServices
import CommonCrypto
import Foundation

public struct ClientConfiguration {
    public let issuer: String
    public let serverURL: URL
    public let clientId: String
    public let redirectURI: URL
    
    public enum Environment: String {
        case proCom = "https://login.schibsted.com"
        case proNo = "https://payment.schibsted.no"
        case pre = "https://identity-pre.schibsted.com"
    }
    
    public init(environment: Environment, clientId: String, redirectURI: URL) {
        self.init(serverURL: URL(string: environment.rawValue)!, // TODO handle without forceful unwrap?
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

internal struct WebFlowData: Codable {
    let state: String
    let nonce: String
    let codeVerifier: String
    let mfa: MFAType?
}

public enum MFAType: String, Codable {
    case password = "password"
    case otp = "otp"
    case sms = "sms"
}

public struct SessionStorageConfig {
    let accessGroup: String?
    let legacyAccessGroup: String?
    
    public init(accessGroup: String? = nil, legacyAccessGroup: String? = nil) {
        self.accessGroup = accessGroup
        self.legacyAccessGroup = legacyAccessGroup
    }
}

@available(iOS 12.0, *)
public class ASWebAuthSessionContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}

public class Client {
    public let configuration: ClientConfiguration
    
    internal static let webFlowLoginStateKey = "WebFlowLoginState"
    private static let keychainServiceName = "com.schibsted.account"
    private static let defaultScopeValues = ["openid", "offline_access"]
    
    internal let sessionStorage: SessionStorage
    internal let httpClient: HTTPClient
    internal let tokenHandler: TokenHandler
    
    private let stateStorage: StateStorage
    private let schibstedAccountAPI: SchibstedAccountAPI
    
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

    public func resumeLastLoggedInUser() -> User? {
        let stored = sessionStorage.get(forClientId: configuration.clientId)
        guard let session = stored else {
            return nil
        }
        
        return User(client: self, session: session)
    }
    
    public func simplifiedLoginData(presenter: @escaping (SimplifiedLoginData?) -> Void) {
        guard let mostRecentSession = getMostRecentSession() else {
            presenter(nil)
            return
        }

        let user = User(client: self, session: mostRecentSession)
        schibstedAccountAPI.userProfile(for: user) { result in
            switch result {
            case .success(let userProfile):
                if let email = userProfile.email,
                   let range = email.range(of: "@", options: .backwards) {
                    let displayName = String(email[...email.index(before: range.lowerBound)])
                    presenter(SimplifiedLoginData(displayName: displayName, client: mostRecentSession.clientId))
                }
            default:
                // TODO log error to fetch user profile data
                presenter(nil)
            }
        }
    }
    
    public func performSimplifiedLogin(completion: @escaping (Result<User, LoginError>) -> Void) {
        guard let mostRecentSession = getMostRecentSession() else {
            // TODO add log message
            completion(.failure(.unexpectedError(message: "No user sessions found")))
            return
        }

        // TODO verify client id is not already in session, should be logged as warn/error as then session should have been resumable

        // TODO this only works for clients belonging to the same merchant
        schibstedAccountAPI.codeExchange(for: User(client: self, session: mostRecentSession), clientId: configuration.clientId) { result in
            switch result {
            case .success(let result):
                let idTokenValidationContext = IdTokenValidationContext(issuer: self.configuration.issuer, clientId: self.configuration.clientId)
                self.tokenHandler.makeTokenRequest(authCode: result.code, idTokenValidationContext: idTokenValidationContext) { self.handleTokenRequestResult($0, completion: completion)}
            case .failure(_):
                // TODO log error
                completion(.failure(.unexpectedError(message: "Failed to obtain exchange code")))
            }
        }
    }
    
    private func getMostRecentSession() -> UserSession? {
        sessionStorage.getAll()
            .sorted { $0.updatedAt > $1.updatedAt }
            .first
    }
    
    @available(iOS 12.0, *)
    private func createWebAuthenticationSession(withMFA: MFAType? = nil, extraScopeValues: Set<String> = [], completion: @escaping (Result<User, LoginError>) -> Void) -> ASWebAuthenticationSession {
        let clientScheme = configuration.redirectURI.scheme
        guard let url = loginURL(withMFA: withMFA, extraScopeValues: extraScopeValues) else {
            preconditionFailure("Couldn't create loginURL")
        }
        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: clientScheme) { callbackURL, error in
            guard let url = callbackURL else {
                // TODO log error
                if case ASWebAuthenticationSessionError.canceledLogin? = error {
                    completion(.failure(.canceled))
                } else {
                    completion(.failure(.unexpectedError(message: "ASWebAuthenticationSession failed: \(error)")))
                }
                return
            }

            self.handleAuthenticationResponse(url: url, completion: completion)
        }
        return session
    }
    
    @available(iOS 12.0, *)
    public func login(withMFA: MFAType? = nil, extraScopeValues: Set<String> = [], completion: @escaping (Result<User, LoginError>) -> Void) {
        let session = getLoginSession(withMFA: withMFA, extraScopeValues: extraScopeValues, completion: completion)
        session.start()
    }
    
    @available(iOS 13.0, *)
    public func login(withMFA: MFAType? = nil, extraScopeValues: Set<String> = [], withSSO: Bool = true, completion: @escaping (Result<User, LoginError>) -> Void) {
        let contextProvider = ASWebAuthSessionContextProvider()
        let session = getLoginSession(contextProvider: contextProvider, withMFA: withMFA, extraScopeValues: extraScopeValues, withSSO: withSSO, completion: completion)
        session.start()
    }
    
    @available(iOS 12.0, *)
    public func getLoginSession(withMFA: MFAType? = nil, extraScopeValues: Set<String> = [], completion: @escaping (Result<User, LoginError>) -> Void) -> ASWebAuthenticationSession {
        return createWebAuthenticationSession(withMFA: withMFA, extraScopeValues: extraScopeValues, completion: completion)
    }
    
    @available(iOS 13.0, *)
    public func getLoginSession(contextProvider: ASWebAuthenticationPresentationContextProviding, withMFA: MFAType? = nil, extraScopeValues: Set<String> = [], withSSO: Bool = true, completion: @escaping (Result<User, LoginError>) -> Void) -> ASWebAuthenticationSession {
        let session = createWebAuthenticationSession(withMFA: withMFA, extraScopeValues: extraScopeValues, completion: completion)
        session.presentationContextProvider = contextProvider
        session.prefersEphemeralWebBrowserSession = !withSSO
        
        return session
    }
    
    public func loginURL(withMFA: MFAType? = nil, extraScopeValues: Set<String> = []) -> URL? {
        let state = randomString(length: 10)
        let nonce = randomString(length: 10)
        let codeVerifier = randomString(length: 60)
        let webFlowData = WebFlowData(state: state, nonce: nonce, codeVerifier: codeVerifier, mfa: withMFA)

        if !stateStorage.setValue(webFlowData, forKey: type(of: self).webFlowLoginStateKey) {
            // TODO log error to store state
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
    
    public func handleAuthenticationResponse(url: URL, completion: @escaping (Result<User, LoginError>) -> Void) {
        // Check if coming back after triggered web flow login
        guard let storedData: WebFlowData = stateStorage.value(forKey: type(of: self).webFlowLoginStateKey),
           let receivedState = url.valueOf(queryParameter: "state"),
           storedData.state == receivedState else {
                completion(.failure(.unsolicitedResponse))
                return
        }
        stateStorage.removeValue(forKey: type(of: self).webFlowLoginStateKey)

        if let error = url.valueOf(queryParameter: "error") {
            completion(.failure(.authenticationErrorResponse(error: OAuthError(error: error, errorDescription: url.valueOf(queryParameter: "error_description")))))
            return
        }
        
        guard let authCode = url.valueOf(queryParameter: "code") else {
            completion(.failure(.unexpectedError(message: "Missing authorization code from authentication response")))
            return
        }

        let idTokenValidationContext = IdTokenValidationContext(issuer: configuration.issuer,
                                                                clientId: configuration.clientId,
                                                                nonce: storedData.nonce,
                                                                expectedAMR: storedData.mfa?.rawValue)
        tokenHandler.makeTokenRequest(authCode: authCode,
                                      codeVerifier: storedData.codeVerifier,
                                      idTokenValidationContext: idTokenValidationContext) {
            self.handleTokenRequestResult($0, completion: completion)
        }
    }

    private func handleTokenRequestResult(_ result: Result<TokenResult, TokenError>, completion: (Result<User, LoginError>) -> Void) {
        switch result {
        case .success(let tokenResult):
            print(tokenResult) // TODO
            let userSession = UserSession(clientId: self.configuration.clientId,
                                          userTokens: UserTokens(accessToken: tokenResult.accessToken, refreshToken: tokenResult.refreshToken, idToken: tokenResult.idToken, idTokenClaims: tokenResult.idTokenClaims),
                                          updatedAt: Date())
            sessionStorage.store(userSession)
            let user = User(client: self, session: userSession)
            completion(.success(user))
        case .failure(.tokenRequestError(.errorResponse(_, let body))):
            if let errorJSON = body,
               let oauthError = OAuthError.fromJSON(errorJSON) {
                completion(.failure(.tokenErrorResponse(error: oauthError)))
                return
            }
            
            // TODO log error
            completion(.failure(.unexpectedError(message: "Failed to obtain user tokens")))
        case .failure(.idTokenError(.missingExpectedAMRValue)):
            // TODO log error
            completion(.failure(.missingExpectedMFA))
        case .failure(_):
            // TODO log error
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

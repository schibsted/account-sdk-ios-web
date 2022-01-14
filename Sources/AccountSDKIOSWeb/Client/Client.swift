import AuthenticationServices
import Foundation

public typealias LoginResultHandler = (Result<User, LoginError>) -> Void

public struct SessionStorageConfig {
    let legacyClientId: String
    let legacyClientSecret: String
    let accessGroup: String?
    let legacyAccessGroup: String?
    
    public init(legacyClientID: String, legacyClientSecret: String, accessGroup: String? = nil, legacyAccessGroup: String? = nil) {
        self.legacyClientId = legacyClientID
        self.accessGroup = accessGroup
        self.legacyAccessGroup = legacyAccessGroup
        self.legacyClientSecret = legacyClientSecret
    }
}

// Default implementation of `ASWebAuthenticationPresentationContextProviding` for the ASWebAuthenticationSession.
public class ASWebAuthSessionContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}

/// Represents a client registered with Schibsted account
public class Client: CustomStringConvertible {
    let configuration: ClientConfiguration
    
    static let authStateKey = "AuthState"
    static let keychainServiceName = "com.schibsted.account"

    let httpClient: HTTPClient
    let schibstedAccountAPI: SchibstedAccountAPI

    private let urlBuilder: URLBuilder
    private let tokenHandler: TokenHandler
    private let stateStorage: StateStorage
    private var sessionStorage: SessionStorage

    /**
     Initializes the Client with given configuration
     
     - parameter configuration: Client configuration object
     - parameter appIdentifierPrefix: Optional AppIdentifierPrefix (Apple team ID). When provided, SDK switches to shared keychain and Simplified Login feature can be used
     - parameter httpClient: Optional custom HTTPClient
     */
    public convenience init(configuration: ClientConfiguration, appIdentifierPrefix: String? = nil, httpClient: HTTPClient? = nil) {
        let chttpClient = httpClient ?? HTTPClientWithURLSession()
        let jwks = RemoteJWKS(jwksURI: configuration.serverURL.appendingPathComponent("/oauth/jwks"), httpClient: chttpClient)
        let tokenHandler = TokenHandler(configuration: configuration, httpClient: chttpClient, jwks: jwks)
        let sessionKeychainStorage = SharedKeychainSessionStorageFactory().makeKeychain(clientId: configuration.clientId, service: Client.keychainServiceName, accessGroup: nil, appIdentifierPrefix: appIdentifierPrefix)

        self.init(configuration: configuration,
                  sessionStorage: sessionKeychainStorage,
                  stateStorage: StateStorage(),
                  httpClient: chttpClient,
                  jwks: jwks,
                  tokenHandler: tokenHandler)
    }
    
    /// Initializes the Client to support migration from Legacy SchibstedAccount SDK to new Schibsted account keychain storage using UserSession
    public convenience init(configuration: ClientConfiguration, sessionStorageConfig: SessionStorageConfig, httpClient: HTTPClient? = nil) {
        let chttpClient = httpClient ?? HTTPClientWithURLSession()
        
        let legacySessionStorage = LegacyKeychainSessionStorage(accessGroup: sessionStorageConfig.legacyAccessGroup)
        let newSessionStorage = KeychainSessionStorage(service: Client.keychainServiceName, accessGroup: sessionStorageConfig.accessGroup)
        
        let legacyClientConfiguration = ClientConfiguration(env: configuration.env,
                                                            serverURL: configuration.serverURL,
                                                            sessionServiceURL: configuration.sessionServiceURL,
                                                            clientId: sessionStorageConfig.legacyClientId,
                                                            redirectURI: URL(string: "http://")!) // TODO: Handle url
        let jwks = RemoteJWKS(jwksURI: configuration.serverURL.appendingPathComponent("/oauth/jwks"), httpClient: chttpClient)
        let tokenHandler = TokenHandler(configuration: configuration, httpClient: chttpClient, jwks: jwks)
        let stateStorage = StateStorage()
        
        // Initializing LegacyClient with all the same properties as regular client. Except for the configuration.
        // TODO: MigratingKeychainCompatStorage needs a legacyClient. Client needs a MigratingKeychainCompatStorage. Untangle
        let legacyClient = Client(configuration: legacyClientConfiguration,
                                  sessionStorage:  newSessionStorage,
                                  stateStorage: stateStorage,
                                  httpClient: chttpClient,
                                  jwks: jwks,
                                  tokenHandler: tokenHandler)
        let sessionStorage = MigratingKeychainCompatStorage(from: legacySessionStorage,
                                                            to: newSessionStorage,
                                                            legacyClient: legacyClient,
                                                            legacyClientSecret: sessionStorageConfig.legacyClientSecret,
                                                            makeTokenRequest: { authCode, authState, completion in tokenHandler.makeTokenRequest(authCode: authCode, authState: authState, completion: completion)})
        
        self.init(configuration: configuration,
                  sessionStorage: sessionStorage,
                  stateStorage: stateStorage,
                  httpClient: chttpClient,
                  jwks: jwks,
                  tokenHandler: tokenHandler)
    }
    
    init(configuration: ClientConfiguration, sessionStorage: SessionStorage, stateStorage: StateStorage, httpClient: HTTPClient, jwks: JWKS, tokenHandler: TokenHandler) {
        self.configuration = configuration
        self.sessionStorage = sessionStorage
        self.stateStorage = stateStorage
        self.httpClient = httpClient
        self.tokenHandler = tokenHandler
        self.schibstedAccountAPI = SchibstedAccountAPI(baseURL: configuration.serverURL, sessionServiceURL: configuration.sessionServiceURL)
        self.urlBuilder = URLBuilder(configuration: configuration)
    }

    func makeTokenRequest(authCode: String, authState: AuthState?, completion: @escaping (Result<TokenResult, TokenError>) -> Void) {
        self.tokenHandler.makeTokenRequest(authCode: authCode, authState: authState, completion: completion)
    }
       
    /// The state parameter is used to protect against XSRF. Your application generates a random string and send it to the authorization server using the state parameter. The authorization server send back the state parameter.
    private func storeAuthState(withMFA: MFAType?) -> AuthState {
        let authState = AuthState(mfa: withMFA)
        
        guard stateStorage.setValue(authState, forKey: Client.authStateKey) else {
            SchibstedAccountLogger.instance.error("Failed to store login state")
            preconditionFailure("Couln't store login state")
        }
        
        return authState
    }
    
    func createWebAuthenticationSession(withMFA: MFAType? = nil,
                                        loginHint: String? = nil,
                                        assertion: String? = nil,
                                        extraScopeValues: Set<String> = [],
                                        completion: @escaping LoginResultHandler) -> ASWebAuthenticationSession {
        
        let clientScheme = configuration.redirectURI.scheme
        let authState = storeAuthState(withMFA: withMFA)
        let authRequest = URLBuilder.AuthorizationRequest(loginHint: loginHint, assertion: assertion, extraScopeValues: extraScopeValues)
        
        guard let url = self.urlBuilder.loginURL(authRequest: authRequest, authState: authState) else {
            preconditionFailure("Couldn't create loginURL")
        }
        
        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: clientScheme) { callbackURL, error in
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
                self.sessionStorage.store(userSession, accessGroup: nil) { result in
                    switch result {
                    case .success():
                        completion(.success(userTokens))
                    case .failure(let error):
                        completion(.failure(.unexpectedError(error: error)))
                    }
                }
            case .failure(let error):
                SchibstedAccountLogger.instance.error("Failed to refresh user tokens")
                completion(.failure(.refreshRequestFailed(error: error)))
            }
        }
    }

    private func handleTokenRequestResult(_ result: Result<TokenResult, TokenError>, completion: @escaping LoginResultHandler) {
        switch result {
        case .success(let tokenResult):
            let userSession = UserSession(clientId: self.configuration.clientId,
                                          userTokens: tokenResult.userTokens,
                                          updatedAt: Date())
            sessionStorage.store(userSession, accessGroup: nil) { output in
                switch output {
                case .success():
                    let user = User(client: self, tokens: tokenResult.userTokens)
                    completion(.success(user))
                case .failure(let error):
                    completion(.failure(.unexpectedError(message: error.localizedDescription)))
                }
            }
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
    
    // used only for getting latest session from shared keychain
    func getLatestSharedSession() -> UserSession? {
        guard sessionStorage.accessGroup != nil else {
            return nil
        }
        return sessionStorage.getLatestSession()
    }
}

extension Client {
    
    // MARK: - Public
    
    /// Resume any previously logged-in user session
    public func resumeLastLoggedInUser(completion: @escaping (User?) -> Void) {
        sessionStorage.get(forClientId: configuration.clientId) { storedSession in
            guard let session = storedSession else {
                completion(nil)
                return
            }
            
            completion(User(client: self, tokens: session.userTokens))
        }
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
                                withSSO: Bool = true,
                                completion: @escaping LoginResultHandler) -> ASWebAuthenticationSession {
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
    
    public var description: String {
        return "Client(\(configuration.clientId))"
    }
}

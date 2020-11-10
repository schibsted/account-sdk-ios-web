import CommonCrypto
import Foundation

public struct ClientConfiguration {
    public let serverURL: URL
    public let clientId: String
    internal let clientSecret: String
    public let redirectURI: URL
    
    public enum Environment: String {
        case proCom = "https://login.schibsted.com"
        case proNo = "https://payment.schibsted.no"
        case pre = "https://identity-pre.schibsted.com"
    }
    
    public init(environment: Environment, clientId: String, clientSecret: String, redirectURI: URL) {
        self.init(serverURL: URL(string: environment.rawValue)!, // TODO handle without forceful unwrap?
                  clientId: clientId,
                  clientSecret: clientSecret,
                  redirectURI: redirectURI)
    }
    
    public init(serverURL: URL, clientId: String, clientSecret: String, redirectURI: URL) {
        self.serverURL = serverURL
        self.clientId = clientId
        self.clientSecret = clientSecret
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

public class Client {
    public let configuration: ClientConfiguration
    
    internal static let webFlowLoginStateKey = "WebFlowLoginState"
    private static let keychainServiceName = "com.schibsted.account"
    
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
    
    public func simplifiedLoginData() -> SimplifiedLoginData? {
        guard let mostRecentSession = getMostRecentSession() else {
            return nil
        }

        return SimplifiedLoginData(uuid: mostRecentSession.userTokens.idTokenClaims.sub, client: mostRecentSession.clientId)
    }
    
    public func performSimplifiedLogin(completion: @escaping (Result<User, LoginError>) -> Void) {
        guard let mostRecentSession = getMostRecentSession() else {
            // TODO add log message
            completion(.failure(.unexpectedError(message: "No user sessions found")))
            return
        }

        // TODO verify client id is not already in session, should be logged as warn/error as then session should have been resumable

        // TODO this only works for clients belonging to the same merchant
        schibstedAccountAPI.oauthExchange(for: User(client: self, session: mostRecentSession), clientId: configuration.clientId) { result in
            switch result {
            case .success(let result):
                self.tokenHandler.makeTokenRequest(authCode: result.code, idTokenValidationContext: IdTokenValidationContext()) { self.handleTokenRequestResult($0, completion: completion)}
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
    
    public func loginURL(withMFA: MFAType? = nil, extraScopeValues: Set<String> = []) -> URL? {
        let state = randomString(length: 10)
        let nonce = randomString(length: 10)
        let codeVerifier = randomString(length: 60)
        let webFlowData = WebFlowData(state: state, nonce: nonce, codeVerifier: codeVerifier, mfa: withMFA)

        if !stateStorage.setValue(webFlowData, forKey: type(of: self).webFlowLoginStateKey) {
            // TODO log error to store state
            return nil;
        }

        var scopes = Set(extraScopeValues)
        scopes.insert("openid")
        let scopeString = scopes.joined(separator: " ")

        var authRequestParams = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: scopeString),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "nonce", value: nonce),
            URLQueryItem(name: "code_challenge", value: codeChallenge(from: codeVerifier)),
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

        let idTokenValidationContext = IdTokenValidationContext(nonce: storedData.nonce, expectedAMR: storedData.mfa?.rawValue)
        tokenHandler.makeTokenRequest(authCode: authCode, idTokenValidationContext: idTokenValidationContext) { self.handleTokenRequestResult($0, completion: completion)}
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
    
    private func codeChallenge(from codeVerifier: String) -> String {
        func base64url(data: Data) -> String {
            let base64url = data.base64EncodedString()
                .replacingOccurrences(of: "/", with: "_")
                .replacingOccurrences(of: "+", with: "-")
                .replacingOccurrences(of: "=", with: "")
            return base64url
        }

        func sha256(data: Data) -> Data {
            var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
            var mutableData = data
            _ = CC_SHA256(&mutableData, CC_LONG(mutableData.count), &hash)
            return Data(hash)
        }

        return base64url(data: sha256(data: Data(codeVerifier.utf8)))
    }
    
    private func makeURLWithQuery(forPath path: String, queryItems: [URLQueryItem]) -> URL {
        let url = configuration.serverURL.appendingPathComponent(path)
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            preconditionFailure("Failed to create URLComponents from \(url)")
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.clientId),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI.absoluteString),
        ]
        urlComponents.queryItems?.append(contentsOf: queryItems)
        guard let finalUrl = urlComponents.url else {
            preconditionFailure("Failed to create URL from \(urlComponents)")
        }

        return finalUrl
    }
}

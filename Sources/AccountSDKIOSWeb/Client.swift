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
    let codeVerifier: String
}

public class Client {
    public let configuration: ClientConfiguration
    
    internal static let webFlowLoginStateKey = "WebFlowLoginState"
    
    private let httpClient: HTTPClient
    private let tokenHandler: TokenHandler
    private let schibstedAccountAPI: SchibstedAccountAPI
    
    public convenience init(configuration: ClientConfiguration, httpClient: HTTPClient = HTTPClientWithURLSession()) {
        self.init(configuration: configuration,
                  httpClient: httpClient,
                  jwks: RemoteJWKS(jwksURI: configuration.serverURL.appendingPathComponent("/oauth/jwks"), httpClient: httpClient))
    }
    
    internal init(configuration: ClientConfiguration, httpClient: HTTPClient, jwks: JWKS) {
        self.configuration = configuration
        self.httpClient = httpClient
        self.tokenHandler = TokenHandler(configuration: configuration, httpClient: httpClient, jwks: jwks)
        self.schibstedAccountAPI = SchibstedAccountAPI(baseURL: configuration.serverURL, httpClient: httpClient)
    }

    public func resumeLastLoggedInUser() -> User? {
        let stored = DefaultSessionStorage.get(forClientId: configuration.clientId)
        guard let session = stored else {
            return nil
        }
        
        return User(session: session)
    }
    
    public func simplifiedLoginData() -> SimplifiedLoginData? {
        let allSessions = DefaultSessionStorage.getAll()
        if allSessions.count < 1 {
            return nil
        }

        let mostRecentSession = allSessions[0]
        return SimplifiedLoginData(uuid: mostRecentSession.userTokens.idTokenClaims.sub, clients: allSessions.map { $0.clientId })
    }
    
    public func performSimplifiedLogin(completion: @escaping (Result<User, LoginError>) -> Void) {
        let allSessions = DefaultSessionStorage.getAll()
        guard allSessions.count > 0 else {
            // TODO add log message
            completion(.failure(.unexpectedError(message: "No user sessions found")))
            return
        }
        
        let mostRecentSession = allSessions[0]
        
        // TODO verify client id is not already in session, should be logged as warn/error as then session should have been resumable

        // TODO this only works for clients belonging to the same merchant
        schibstedAccountAPI.oauthExchange(userAccessToken: mostRecentSession.userTokens.accessToken, clientId: configuration.clientId) { result in
            switch result {
            case .success(let result):
                self.tokenHandler.makeTokenRequest(authCode: result.code) { self.handleTokenRequestResult($0, completion: completion)}
            case .failure(_):
                // TODO log error
                completion(.failure(.unexpectedError(message: "Failed to obtain exchange code")))
            }
        }
    }
    
    public func loginURL(extraScopeValues: Set<String> = []) -> URL? {
        let state = randomString(length: 10)
        let codeVerifier = randomString(length: 60)
        let webFlowData = WebFlowData(state: state, codeVerifier: codeVerifier)

        if !DefaultStorage.setValue(webFlowData, forKey: type(of: self).webFlowLoginStateKey) {
            // TODO log error to store state
            return nil;
        }

        var scopes = Set(extraScopeValues)
        scopes.insert("openid")
        let scopeString = scopes.joined(separator: " ")
        let authRequestParams = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "prompt", value: "select_account"),
            URLQueryItem(name: "scope", value: scopeString),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "nonce", value: randomString(length: 10)),
            URLQueryItem(name: "code_challenge", value: codeChallenge(from: codeVerifier)),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
        ]

        return makeURLWithQuery(
            forPath: "/oauth/authorize",
            queryItems: authRequestParams
        )
    }
    
    public func handleAuthenticationResponse(url: URL, completion: @escaping (Result<User, LoginError>) -> Void) {
        // Check if coming back after triggered web flow login
        guard let storedData: WebFlowData = DefaultStorage.value(forKey: type(of: self).webFlowLoginStateKey),
           let receivedState = url.valueOf(queryParameter: "state"),
           storedData.state == receivedState else {
                completion(.failure(.unsolicitedResponse))
                return
        }

        if let error = url.valueOf(queryParameter: "error") {
            completion(.failure(.authenticationErrorResponse(error: OAuthError(error: error, errorDescription: url.valueOf(queryParameter: "error_description")))))
            return
        }
        
        guard let authCode = url.valueOf(queryParameter: "code") else {
            completion(.failure(.unexpectedError(message: "Missing authorization code from authentication response")))
            return
        }

        tokenHandler.makeTokenRequest(authCode: authCode) { self.handleTokenRequestResult($0, completion: completion)}
    }

    private func handleTokenRequestResult(_ result: Result<TokenResult, TokenError>, completion: (Result<User, LoginError>) -> Void) {
        switch result {
        case .success(let tokenResult):
            print(tokenResult) // TODO
            let user = User(clientId: self.configuration.clientId, accessToken: tokenResult.accessToken, refreshToken: tokenResult.refreshToken, idToken: tokenResult.idToken, idTokenClaims: tokenResult.idTokenClaims)
            user.persist()
            completion(.success(user))
        case .failure(.tokenRequestError(.errorResponse(_, let body))):
            if let errorJSON = body,
               let oauthError = OAuthError.fromJSON(errorJSON) {
                completion(.failure(.tokenErrorResponse(error: oauthError)))
                return
            }
            
            // TODO log error
            completion(.failure(.unexpectedError(message: "Failed to obtain user tokens")))
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

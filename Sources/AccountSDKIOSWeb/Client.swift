import CommonCrypto
import Foundation

public struct ClientConfiguration {
    public let serverURL: URL
    public let clientID: String
    internal let clientSecret: String
    public let redirectURI: URL
    
    public enum Environment: String {
        case proCom = "https://login.schibsted.com"
        case proNo = "https://payment.schibsted.no"
        case pre = "https://identity-pre.schibsted.com"
    }
    
    public init(environment: Environment, clientID: String, clientSecret: String, redirectURI: URL) {
        self.init(serverURL: URL(string: environment.rawValue)!, // TODO handle without forceful unwrap?
                  clientID: clientID,
                  clientSecret: clientSecret,
                  redirectURI: redirectURI)
    }
    
    public init(serverURL: URL, clientID: String, clientSecret: String, redirectURI: URL) {
        self.serverURL = serverURL
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.redirectURI = redirectURI
    }
}

internal struct WebFlowData: Codable {
    let state: String
    let codeVerifier: String
    let shouldPersistUser: Bool
}

public class Client {
    internal static let webFlowLoginStateKey = "WebFlowLoginState"
    
    private let configuration: ClientConfiguration
    private let httpClient: HTTPClient
    private let tokenHandler: TokenHandler
    
    public init(configuration: ClientConfiguration, httpClient: HTTPClient = HTTPClientWithURLSession()) {
        self.configuration = configuration
        self.httpClient = httpClient
        self.tokenHandler = TokenHandler(configuration: configuration, httpClient: httpClient)
    }
    
    public func loginURL(shouldPersistUser: Bool, scopes: [String]? = nil) -> URL? {
        let state = randomString(length: 10)
        let codeVerifier = randomString(length: 60)
        let webFlowData = WebFlowData(state: state, codeVerifier: codeVerifier, shouldPersistUser: shouldPersistUser)

        if !DefaultStorage.setValue(webFlowData, forKey: type(of: self).webFlowLoginStateKey) {
            // TODO log error to store state
            return nil;
        }
        
        let scopeString = scopes.map { $0.joined(separator: " ") } ?? "openid"
        let authRequestParams = [
            URLQueryItem(name: "response_type", value: "code"),
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

        tokenHandler.makeTokenRequest(authCode: authCode) { (result: Result<TokenResponse, HTTPError>) -> Void in
            switch result {
            case .success(let tokenResponse):
                print(tokenResponse) // TODO
                // TODO store tokens in secure storage
                completion(.success(User()))
            case .failure(.errorResponse(_, let body)):
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
            URLQueryItem(name: "client_id", value: configuration.clientID),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI.absoluteString),
        ]
        urlComponents.queryItems?.append(contentsOf: queryItems)
        guard let finalUrl = urlComponents.url else {
            preconditionFailure("Failed to create URL from \(urlComponents)")
        }

        return finalUrl
    }
}

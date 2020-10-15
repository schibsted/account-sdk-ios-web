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

private struct WebFlowData: Codable {
    let state: String
    let codeVerifier: String
    let shouldPersistUser: Bool
}

public class Client {
    private static let webFlowLoginStateKey = "WebFlowLoginState"
    
    private let configuration: ClientConfiguration
    
    public init(configuration: ClientConfiguration) {
        self.configuration = configuration
    }
    
    public func loginURL(shouldPersistUser: Bool, scopes: [String]? = nil) -> URL? {
        let state = randomString(length: 10)
        let codeVerifier = randomString(length: 60)
        let webFlowData = WebFlowData(state:state, codeVerifier: codeVerifier, shouldPersistUser: shouldPersistUser)

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
        guard var urlComponents = URLComponents(url: configuration.serverURL, resolvingAgainstBaseURL: true) else {
            preconditionFailure("Failed to create URLComponents from \(configuration.serverURL)")
        }
        urlComponents.path = path
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.clientID),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI.absoluteString),
        ]
        urlComponents.queryItems?.append(contentsOf: queryItems)
        guard let url = urlComponents.url else {
            preconditionFailure("Failed to create URL from \(urlComponents)")
        }

        return url
    }
}

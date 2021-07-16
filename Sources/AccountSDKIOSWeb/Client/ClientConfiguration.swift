
import Foundation

public struct ClientConfiguration {
    /// Issuer identifier for identifier provider
    public let issuer: String
    /// URL of identity provider
    public let serverURL: URL
    /// Registered client id
    public var clientId: String
    /// Registered redirect URI
    public var redirectURI: URL
    
    public enum Environment: String {
        case proCom = "https://login.schibsted.com"
        case proFi = "https://login.schibsted.fi"
        case proNo = "https://payment.schibsted.no"
        case pre = "https://identity-pre.schibsted.com"
    }
    
    /**
     Generate URL for Schibsted account pages.
     */
    public var accountPagesURL: URL {
        let url = serverURL.appendingPathComponent("/account/summary")
        return url
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

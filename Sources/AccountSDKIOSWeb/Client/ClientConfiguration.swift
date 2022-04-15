import Foundation

public struct ClientConfiguration {
    /// Issuer identifier for identifier provider
    public let issuer: String
    /// URL of identity provider
    public let serverURL: URL
    /// URL of session service
    public let sessionServiceURL: URL
    /// Registered client id
    public var clientId: String
    /// Registered redirect URI
    public var redirectURI: URL

    public var env: Environment

    public enum Environment: String {
        case proCom = "https://login.schibsted.com"
        case proFi = "https://login.schibsted.fi"
        case proNo = "https://payment.schibsted.no"
        case pre = "https://identity-pre.schibsted.com"
        case proDk = "https://login.schibsted.dk"

        var sessionService: String {
            let sessionServiceStr: String
            switch self {
            case .proCom:
                sessionServiceStr = "https://session-service.login.schibsted.com"
            case .proFi:
                sessionServiceStr = "https://session-service.login.schibsted.fi"
            case .proNo:
                sessionServiceStr = "https://session-service.payment.schibsted.no"
            case .pre:
                sessionServiceStr = "https://session-service.identity-pre.schibsted.com"
            case .proDk:
                sessionServiceStr = "https://session-service.login.schibsted.dk"
            }
            return sessionServiceStr
        }
    }

    /**
     Generate URL for Schibsted account pages.
     */
    public var accountPagesURL: URL {
        let url = serverURL.appendingPathComponent("/account/summary")
        return url
    }

    public init(environment: Environment, clientId: String, redirectURI: URL) {
        self.init(env: environment,
                  serverURL: URL(string: environment.rawValue)!,
                  sessionServiceURL: URL(string: environment.sessionService)!,
                  clientId: clientId,
                  redirectURI: redirectURI)
    }

    init(env: Environment,serverURL: URL, sessionServiceURL: URL, clientId: String, redirectURI: URL) {
        self.env = env
        self.serverURL = serverURL
        self.sessionServiceURL = sessionServiceURL
        self.issuer = serverURL.absoluteString
        self.clientId = clientId
        self.redirectURI = redirectURI
    }
}

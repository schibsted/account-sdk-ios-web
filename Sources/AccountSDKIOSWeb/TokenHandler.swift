import Foundation


internal struct TokenResponse: Codable, Equatable, CustomStringConvertible {
    let access_token: String
    let refresh_token: String?
    let id_token: String?
    let scope: String?
    let expires_in: Int
    
    var description: String {
        return "TokenResponse("
            + "access_token: \(removeSignature(fromToken: access_token)),\n"
            + "refresh_token: \(removeSignature(fromToken: refresh_token)),\n"
            + "id_token: \(removeSignature(fromToken: id_token)),\n"
            + "scope: \(scope ?? ""),\n"
            + "expires_in: \(expires_in))"
        
    }
    
    private func removeSignature(fromToken token: String?) -> String {
        guard let value = token else {
            return ""
        }
        let split = value.components(separatedBy: ".")
        
        if split.count < 2 {
            let tokenPrefix = token?.prefix(3) ?? ""
            return "\(tokenPrefix)..."
        }

        return "\(split[0]).\(split[1])"
    }
}

internal class TokenHandler {
    private let configuration: ClientConfiguration
    private let httpClient: HTTPClient
    
    init(configuration: ClientConfiguration, httpClient: HTTPClient) {
        self.configuration = configuration
        self.httpClient = httpClient
    }
    func makeTokenRequest(authCode: String, completion: @escaping (Result<TokenResponse, HTTPError>) -> Void) {
        let url = configuration.serverURL.appendingPathComponent("/oauth/token")
        let parameters = [
            "grant_type": "authorization_code",
            "code": authCode,
            "redirect_uri": configuration.redirectURI.absoluteString
        ]

        guard let request = HTTPUtil.formURLEncode(parameters: parameters) else {
            preconditionFailure("Failed to create token request")
        }
        
        httpClient.post(url: url, body: request, contentType: HTTPUtil.xWWWFormURLEncodedContentType, authorization: HTTPUtil.basicAuth(username: configuration.clientID, password: configuration.clientSecret), completion: completion)
    }
}

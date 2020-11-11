import Foundation

internal struct SchibstedAccountAPIResponse<T: Codable>: Codable {
    let data: T
}

struct OAuthCodeExchangeResponse: Codable {
    let code: String
}

public struct UserProfileResponse: Codable {
    public var givenName: String? = nil
    public var familyName: String? = nil
    public var displayName: String? = nil
    public var email: String? = nil
    public var phoneNumber: String? = nil
}

public class SchibstedAccountAPI {
    // TODO add custom User-Agent header identifying SDK version to all requests
    
    private let baseURL: URL

    init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    internal func oauthExchange(for user: User, clientId: String, completion: @escaping (Result<OAuthCodeExchangeResponse, HTTPError>) -> Void) {
        let url = baseURL.appendingPathComponent("/api/2/oauth/exchange")
        let parameters = [
            "type": "code",
            "clientId": clientId
        ]
        guard let requestBody = HTTPUtil.formURLEncode(parameters: parameters) else {
            preconditionFailure("Failed to create OAuth token exchange request")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(HTTPUtil.xWWWFormURLEncodedContentType, forHTTPHeaderField: "Content-Type")
        request.httpBody = requestBody

        user.withAuthentication(request: request) {
            completion(self.unpackResponse($0))
        }
    }
    
    internal func tokenRequest(with httpClient: HTTPClient, parameters: [String: String], authorization: String, completion: @escaping (Result<TokenResponse, HTTPError>) -> Void) {
        let url = baseURL.appendingPathComponent("/oauth/token")
        guard let requestBody = HTTPUtil.formURLEncode(parameters: parameters) else {
            preconditionFailure("Failed to create token request")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(HTTPUtil.xWWWFormURLEncodedContentType, forHTTPHeaderField: "Content-Type")
        request.setValue(authorization , forHTTPHeaderField: "Authorization")
        request.httpBody = requestBody
        
        httpClient.execute(request: request, completion: completion)
    }

    public func userProfile(for user: User, completion: @escaping (Result<UserProfileResponse, HTTPError>) -> Void) {
        let url = baseURL.appendingPathComponent("/api/2/user/\(user.uuid)")
        let request = URLRequest(url: url)
        user.withAuthentication(request: request) {
            completion(self.unpackResponse($0))
        }
    }
    
    private func unpackResponse<T>(_ response: Result<SchibstedAccountAPIResponse<T>, HTTPError>) -> Result<T, HTTPError> {
        switch response {
        case .success(let result):
            return .success(result.data)
        case .failure(let error):
            return .failure(error)
        }
    }
}

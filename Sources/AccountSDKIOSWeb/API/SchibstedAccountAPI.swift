import Foundation
import UIKit

struct UserAgent {
    private static let deviceInfo = UIDevice.current
    static let value = "AccountSDKIOSWeb/\(sdkVersion) (\(deviceInfo.model); \(deviceInfo.systemName) \(deviceInfo.systemVersion))"
}

public class SchibstedAccountAPI {   
    private let baseURL: URL

    init(baseURL: URL) {
        self.baseURL = baseURL
    }

    internal static func addingSDKHeaders(to request: URLRequest) -> URLRequest {
        var requestWithHeaders = request
        requestWithHeaders.addValue(UserAgent.value, forHTTPHeaderField: "User-Agent")
        return requestWithHeaders
    }

    internal func codeExchange(for user: User, clientId: String, completion: @escaping (Result<CodeExchangeResponse, HTTPError>) -> Void) {
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

        user.withAuthentication(request: SchibstedAccountAPI.addingSDKHeaders(to: request)) {
            completion(self.unpackResponse($0))
        }
    }
    
    internal func sessionExchange(for user: User, clientId: String, redirectURI: String, completion: @escaping (Result<SessionExchangeResponse, HTTPError>) -> Void) {
        let url = baseURL.appendingPathComponent("/api/2/oauth/exchange")
        let parameters = [
            "type": "session",
            "clientId": clientId,
            "redirectUri": redirectURI
        ]
        guard let requestBody = HTTPUtil.formURLEncode(parameters: parameters) else {
            preconditionFailure("Failed to create OAuth token exchange request")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(HTTPUtil.xWWWFormURLEncodedContentType, forHTTPHeaderField: "Content-Type")
        request.httpBody = requestBody

        user.withAuthentication(request: SchibstedAccountAPI.addingSDKHeaders(to: request)) {
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
        
        httpClient.execute(request: SchibstedAccountAPI.addingSDKHeaders(to: request), completion: completion)
    }

    public func userProfile(for user: User, completion: @escaping (Result<UserProfileResponse, HTTPError>) -> Void) {
        let url = baseURL.appendingPathComponent("/api/2/user/\(user.uuid)")
        let request = URLRequest(url: url)
        user.withAuthentication(request: SchibstedAccountAPI.addingSDKHeaders(to: request)) {
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

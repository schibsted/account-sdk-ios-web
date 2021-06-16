import Foundation
import UIKit

class SchibstedAccountAPI {
    
    private enum UserAgent {
        private static let deviceInfo = UIDevice.current
        static let value = "AccountSDKIOSWeb/\(sdkVersion) (\(deviceInfo.model); \(deviceInfo.systemName) \(deviceInfo.systemVersion))"
    }
    
    private let baseURL: URL
    private let retryPolicy = APIRetryPolicy()

    init(baseURL: URL) {
        self.baseURL = baseURL
    }

    internal static func addingSDKHeaders(to request: URLRequest) -> URLRequest {
        var requestWithHeaders = request
        requestWithHeaders.addValue(UserAgent.value, forHTTPHeaderField: "User-Agent")
        return requestWithHeaders
    }
    
    internal func sessionExchange(for user: User, clientId: String, redirectURI: String, completion: @escaping HTTPResultHandler<SessionExchangeResponse>) {
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

    internal func tokenRequest(with httpClient: HTTPClient, parameters: [String: String], completion: @escaping HTTPResultHandler<TokenResponse>) {
        let url = baseURL.appendingPathComponent("/oauth/token")
        guard let requestBody = HTTPUtil.formURLEncode(parameters: parameters) else {
            preconditionFailure("Failed to create token request")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(HTTPUtil.xWWWFormURLEncodedContentType, forHTTPHeaderField: "Content-Type")
        request.setValue("v1", forHTTPHeaderField: "X-OIDC")
        request.httpBody = requestBody
        
        httpClient.execute(request: SchibstedAccountAPI.addingSDKHeaders(to: request),
                           withRetryPolicy: retryPolicy,
                           completion: completion)
    }

    // TODO: IS THIS NEEDED TO BE PUBLIC? TORI USES USER.fetchProfileData()
    func userProfile(for user: User, completion: @escaping HTTPResultHandler<UserProfileResponse>) {
        guard let userUuid = user.uuid else {
            completion(.failure(.unexpectedError(underlying: LoginStateError.notLoggedIn)))
            return
        }
        let url = baseURL.appendingPathComponent("/api/2/user/\(userUuid)")
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

import Foundation
import UIKit

enum RequestBuilder {
    case codeExchange(clientId: String)
    case oldSDKRefreshToken(oldSDKRefreshToken: String)

    func asRequest(baseURL: URL) -> URLRequest {
        switch self {
        case .codeExchange(clientId: let clientId): return exchangeRequest(baseURL: baseURL, clientId: clientId)
        case .oldSDKRefreshToken(oldSDKRefreshToken: let refreshToken): return buildOldSDKRefreshTokenRequest(baseURL: baseURL, oldSDKRefreshToken: refreshToken)
        }
    }
    
    func exchangeRequest(baseURL: URL, clientId: String) -> URLRequest {
        let url = baseURL.appendingPathComponent("/api/2/oauth/exchange")
        let parameters = [
            "type": "code",
            "clientId": clientId
        ]
        guard let requestBody = HTTPUtil.formURLEncode(parameters: parameters) else {
            preconditionFailure("Failed to create code exchange request")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(HTTPUtil.xWWWFormURLEncodedContentType, forHTTPHeaderField: "Content-Type")
        request.httpBody = requestBody
        return request
    }
    
    func buildOldSDKRefreshTokenRequest(baseURL: URL, oldSDKRefreshToken: String) -> URLRequest {
        let url = baseURL.appendingPathComponent("/oauth/token")
        let parameters = [
            "grant_type": "refresh_token",
            "refresh_token": oldSDKRefreshToken
        ]
        guard let requestBody = HTTPUtil.formURLEncode(parameters: parameters) else {
            preconditionFailure("Failed to create token request")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(HTTPUtil.xWWWFormURLEncodedContentType, forHTTPHeaderField: "Content-Type")
        request.setValue("v1", forHTTPHeaderField: "X-OIDC")
        request.httpBody = requestBody
        return request
    }

}

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

    static func addingSDKHeaders(to request: URLRequest) -> URLRequest {
        var requestWithHeaders = request
        requestWithHeaders.addValue(UserAgent.value, forHTTPHeaderField: "User-Agent")
        return requestWithHeaders
    }
    
    func sessionExchange(for user: User, clientId: String, redirectURI: String, completion: @escaping HTTPResultHandler<SessionExchangeResponse>) {
        let url = baseURL.appendingPathComponent("/api/2/oauth/exchange")
        let parameters = [
            "type": "session",
            "clientId": clientId,
            "redirectUri": redirectURI
        ]
        guard let requestBody = HTTPUtil.formURLEncode(parameters: parameters) else {
            preconditionFailure("Failed to create session exchange request")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(HTTPUtil.xWWWFormURLEncodedContentType, forHTTPHeaderField: "Content-Type")
        request.httpBody = requestBody

        user.withAuthentication(request: SchibstedAccountAPI.addingSDKHeaders(to: request)) {
            completion(self.unpackResponse($0))
        }
    }
    
    func codeExchange(for user: User, clientId: String, completion: @escaping HTTPResultHandler<CodeExchangeResponse>) {
        let request = RequestBuilder.codeExchange(clientId: clientId).asRequest(baseURL: baseURL)

        user.withAuthentication(request: SchibstedAccountAPI.addingSDKHeaders(to: request)) {
            completion(self.unpackResponse($0))
        }
    }

    func tokenRequest(with httpClient: HTTPClient, parameters: [String: String], completion: @escaping HTTPResultHandler<TokenResponse>) {
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
    
    /// API endpoint called with New SDK clientID, and oldSDKAccesstoken
    func oldSDKCodeExchange(with httpClient: HTTPClient, clientId: String, oldSDKAccessToken: String, completion: @escaping HTTPResultHandler<SchibstedAccountAPIResponse<CodeExchangeResponse>> ) {
        let codeExchangeRequest = RequestBuilder.codeExchange(clientId: clientId).asRequest(baseURL: baseURL)
        let authenticatedRequest = authenticatedBearerRequest(codeExchangeRequest, token: oldSDKAccessToken)
        httpClient.execute(request: SchibstedAccountAPI.addingSDKHeaders(to: authenticatedRequest),
                           withRetryPolicy: retryPolicy,
                           completion: completion)
    }
    
    /// API endpoint called with old SDK clientID and old SDK Client secret, and old SDK refreshToken
    func oldSDKRefresh(with httpClient: HTTPClient, refreshToken: String, clientId: String, clientSecret: String, completion: @escaping HTTPResultHandler<TokenResponse> ) {
        let request = RequestBuilder.oldSDKRefreshToken(oldSDKRefreshToken: refreshToken).asRequest(baseURL: baseURL)
        let authenticatedRequest = authenticatedBasicRequest(request, legacyClientId: clientId, legacyClientSecret: clientSecret)
        httpClient.execute(request: SchibstedAccountAPI.addingSDKHeaders(to: authenticatedRequest),
                           withRetryPolicy: retryPolicy,
                           completion: completion)
    }
}

// MARK: Helper functions used for API endpoints from legacy SDK

fileprivate func authenticatedBearerRequest(_ request: URLRequest, token: String) -> URLRequest {
    var requestCopy = request
    requestCopy.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    return requestCopy
}

fileprivate func authenticatedBasicRequest(_ request: URLRequest, legacyClientId: String, legacyClientSecret: String) -> URLRequest {
    var requestCopy = request
    
    let loginString = encode(legacyClientId: legacyClientId, legacyClientSecret: legacyClientSecret)
    requestCopy.setValue("Basic " + loginString, forHTTPHeaderField: "Authorization")
    return requestCopy
}

fileprivate func encode(legacyClientId: String, legacyClientSecret: String) -> String {
    let loginString = String(format: "%@:%@", legacyClientId, legacyClientSecret)
    let loginData = loginString.data(using: String.Encoding.utf8)!
    let base64LoginString = loginData.base64EncodedString()
    return base64LoginString
}

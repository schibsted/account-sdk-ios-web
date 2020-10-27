import Foundation

private struct SchibstedAccountAPIResponse<T: Codable>: Codable {
    let data: T
}

struct OAuthCodeExchangeResponse: Codable {
    let code: String
}

public class SchibstedAccountAPI {
    // TODO add custom User-Agent header identifying SDK version to all requests
    
    private let baseURL: URL
    private let httpClient: HTTPClient


    init(baseURL: URL, httpClient: HTTPClient = HTTPClientWithURLSession()) {
        self.baseURL = baseURL
        self.httpClient = httpClient
    }
    
    internal func oauthExchange(userAccessToken: String, clientId: String, completion: @escaping (Result<OAuthCodeExchangeResponse, HTTPError>) -> Void) {
        let url = baseURL.appendingPathComponent("/api/2/oauth/exchange")
        let parameters = [
            "type": "code",
            "clientId": clientId
        ]
        
        guard let request = HTTPUtil.formURLEncode(parameters: parameters) else {
            preconditionFailure("Failed to create OAuth token exchange request")
        }

        httpClient.post(url: url,
                        body: request,
                        contentType: HTTPUtil.xWWWFormURLEncodedContentType,
                        authorization: "Bearer \(userAccessToken)") {
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

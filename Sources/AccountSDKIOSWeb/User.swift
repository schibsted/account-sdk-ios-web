import Foundation

public class User: Equatable {
    private let client: Client

    private var accessToken: String
    private var refreshToken: String?
    private let idToken: String
    private let idTokenClaims: IdTokenClaims
    
    public let uuid: String
    
    init(client: Client, accessToken: String, refreshToken: String?, idToken: String, idTokenClaims: IdTokenClaims) {
        self.client = client

        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.idToken = idToken

        self.idTokenClaims = idTokenClaims
        self.uuid = idTokenClaims.sub
    }
    
    convenience init(client: Client, session: UserSession) {
        self.init(client: client,
                  accessToken: session.userTokens.accessToken,
                  refreshToken: session.userTokens.refreshToken,
                  idToken: session.userTokens.idToken,
                  idTokenClaims: session.userTokens.idTokenClaims)
    }
    
    public func logout() {
        client.sessionStorage.remove(forClientId: client.configuration.clientId)
    }
    
    public func webSessionURL(clientId: String, redirectURI: String, completion: @escaping (Result<URL, HTTPError>) -> Void) {
        let api = SchibstedAccountAPI.init(baseURL: client.configuration.serverURL)
        api.sessionExchange(for: self, clientId: clientId, redirectURI: redirectURI) { result in
            switch result {
            case .success(let response):
                let url = self.client.configuration.serverURL.appendingPathComponent("/session/\(response.code)")
                completion(.success(url))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public static func == (lhs: User, rhs: User) -> Bool {
        return lhs.uuid == rhs.uuid
            && lhs.client.configuration.clientId == rhs.client.configuration.clientId
            && lhs.accessToken == rhs.accessToken
            && lhs.refreshToken == rhs.refreshToken
            && lhs.idToken == rhs.idToken
            && lhs.idTokenClaims == rhs.idTokenClaims
    }
}

extension User {
    /** Perform a request with user access token as Bearer token in Authorization header.
     *
     *  If the initial request fails with a 401, a refresh token request is made to get a new access token and the request will be retried with the new token if successful.
     */
    func withAuthentication<T: Decodable>(request: URLRequest, withRetryPolicy: RetryPolicy = NoRetries.policy, completion: @escaping (Result<T, HTTPError>) -> Void) {
        makeRequest(request: request) { (requestResult: Result<T, HTTPError>) in
            switch requestResult {
            case .failure(.errorResponse(let code, let body)):
                // 401 might indicate expired access token
                if code == 401 {
                    guard let existingRefreshToken = self.refreshToken else {
                        // TODO log info about no refresh token
                        completion(requestResult)
                        return
                    }

                    // try to exchange refresh token for new token
                    self.client.tokenHandler.makeTokenRequest(refreshToken: existingRefreshToken) { tokenRefreshResult in
                        switch tokenRefreshResult {
                        case .success(let tokenResponse):
                            // TODO log info about successful token refresh
                            // TODO handle ID Token in refresh token response?
                            self.accessToken = tokenResponse.access_token
                            if let newRefreshToken = tokenResponse.refresh_token {
                                self.refreshToken = newRefreshToken
                            }
                        
                            // retry the request with fresh tokens
                            self.makeRequest(request: request, completion: completion)
                        default:
                            // TODO log error about token refresh
                            completion(requestResult)
                        }
                    }
                } else {
                    completion(.failure(.errorResponse(code: code, body: body)))
                }
            default:
                completion(requestResult)
            }
        }
    }
    
    private func makeRequest<T: Decodable>(request: URLRequest, completion: @escaping (Result<T, HTTPError>) -> Void) {
        var requestCopy = request
        requestCopy.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        client.httpClient.execute(request: requestCopy, completion: completion)
    }
}

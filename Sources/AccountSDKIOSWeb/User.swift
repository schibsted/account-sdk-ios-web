import Foundation

/// Representation of logged-in user.
public class User: Equatable {
    private let client: Client

    private var accessToken: String
    private var refreshToken: String?
    private let idToken: String
    private let idTokenClaims: IdTokenClaims
    
    /// User UUID
    public let uuid: String
    /// User integer id (as string)
    public let userId: String
    
    init(client: Client, accessToken: String, refreshToken: String?, idToken: String, idTokenClaims: IdTokenClaims) {
        self.client = client

        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.idToken = idToken

        self.idTokenClaims = idTokenClaims
        self.uuid = idTokenClaims.sub
        self.userId = idTokenClaims.userId
    }
    
    convenience init(client: Client, session: UserSession) {
        self.init(client: client,
                  accessToken: session.userTokens.accessToken,
                  refreshToken: session.userTokens.refreshToken,
                  idToken: session.userTokens.idToken,
                  idTokenClaims: session.userTokens.idTokenClaims)
    }
    
    /**
     Log user out
     
     Will remove stored session, including all user tokens.
     */
    public func logout() {
        client.sessionStorage.remove(forClientId: client.configuration.clientId)
    }
    
    /**
     Generate URL with embedded one-time code for creating a web session for the current user.

     - parameter clientId: which client to get the code on behalf of, e.g. client id for associated web application
     - parameter redirectURI: where to redirect the user after the session has been created
     - parameter completion: callback that receives the URL or an error in case of failure
     */
    public func webSessionURL(clientId: String, redirectURI: String, completion: @escaping HTTPResultHandler<URL>) {
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
    
    /// Fetch user profile data
    public func fetchProfileData(completion: @escaping HTTPResultHandler<UserProfileResponse>) {
        client.schibstedAccountAPI.userProfile(for: self, completion: completion)
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
    /**
     Perform a request with user access token as Bearer token in Authorization header.
     
     If the initial request fails with a 401, a refresh token request is made to get a new access token and the request will be retried with the new token if successful.
     
     - parameter request: request to perform with authentication using user tokens
     - parameter withRetryPolicy: optional rety policy for the HTTP request (defaults to not retrying)
     - parameter completion: callback that receives the HTTP response or an error in case of failure
     */
    func withAuthentication<T: Decodable>(request: URLRequest, withRetryPolicy: RetryPolicy = NoRetries.policy, completion: @escaping HTTPResultHandler<T>) {
        makeRequest(request: request) { (requestResult: Result<T, HTTPError>) in
            switch requestResult {
            case .failure(.errorResponse(let code, let body)):
                // 401 might indicate expired access token
                if code == 401 {
                    guard let existingRefreshToken = self.refreshToken else {
                        SchibstedAccountLogger.instance.debug("No existing refresh token, skipping token refreh")
                        completion(requestResult)
                        return
                    }

                    // try to exchange refresh token for new token
                    self.client.tokenHandler.makeTokenRequest(refreshToken: existingRefreshToken) { tokenRefreshResult in
                        switch tokenRefreshResult {
                        case .success(let tokenResponse):
                            SchibstedAccountLogger.instance.debug("Successfully refresh user tokens")
                            self.accessToken = tokenResponse.access_token
                            if let newRefreshToken = tokenResponse.refresh_token {
                                self.refreshToken = newRefreshToken
                            }
                        
                            // retry the request with fresh tokens
                            self.makeRequest(request: request, completion: completion)
                        default:
                            SchibstedAccountLogger.instance.error("Failed to refresh user tokens")
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
    
    private func makeRequest<T: Decodable>(request: URLRequest, completion: @escaping HTTPResultHandler<T>) {
        var requestCopy = request
        requestCopy.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        client.httpClient.execute(request: requestCopy, completion: completion)
    }
}

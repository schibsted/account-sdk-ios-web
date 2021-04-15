import Foundation

/// Representation of logged-in user.
public class User: Equatable {
    private let client: Client
    internal var tokens: UserTokens

    /// User UUID
    public let uuid: String

    /// User integer id (as string)
    public let userId: String
    
    internal init(client: Client, tokens: UserTokens) {
        self.client = client
        self.tokens = tokens
        
        self.uuid = tokens.idTokenClaims.sub
        self.userId = tokens.idTokenClaims.userId
    }
    
    /**
     Log user out
     
     Will remove stored session, including all user tokens.
     */
    public func logout() {
        client.destroySession()
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
    
    /**
     Generate URL for Schibsted account pages.
     */
    public func accountPagesURL() -> URL {
        let url = client.configuration.serverURL.appendingPathComponent("/account/summary")
        return url
    }
    
    /// Fetch user profile data
    public func fetchProfileData(completion: @escaping HTTPResultHandler<UserProfileResponse>) {
        client.schibstedAccountAPI.userProfile(for: self, completion: completion)
    }
        
    public static func == (lhs: User, rhs: User) -> Bool {
        return lhs.uuid == rhs.uuid
            && lhs.client.configuration.clientId == rhs.client.configuration.clientId
            && lhs.tokens == rhs.tokens
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
    public func withAuthentication<T: Decodable>(request: URLRequest, withRetryPolicy: RetryPolicy = NoRetries.policy, completion: @escaping HTTPResultHandler<T>) {
        makeRequest(request: request) { (requestResult: Result<T, HTTPError>) in
            switch requestResult {
            case .failure(.errorResponse(let code, let body)):
                // 401 might indicate expired access token
                if code == 401 {
                    self.client.refreshTokens(for: self) { result in
                        switch result {
                        case .success(_):
                            // retry the request with fresh tokens
                            self.makeRequest(request: request, completion: completion)
                        case .failure(_):
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
        requestCopy.setValue("Bearer \(tokens.accessToken)", forHTTPHeaderField: "Authorization")
        client.httpClient.execute(request: requestCopy, completion: completion)
    }
}

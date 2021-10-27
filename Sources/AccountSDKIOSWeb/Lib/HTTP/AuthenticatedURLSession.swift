import Foundation

/// AuthenticatedURLSession wraps a User to allow Bearer authenticated requests and the use of URLSessionDataTask
public final class AuthenticatedURLSession {
    private let user: User
    private let urlSession: URLSession
    private var refreshTokenDataTask: URLSessionDataTask?

    public init(user: User, configuration: URLSessionConfiguration) {
        self.user = user
        self.urlSession = URLSession(configuration: configuration)
    }

    public func dataTask(with request: URLRequest) -> URLSessionDataTask {
        return dataTask(with: request) { _, _, _ in }
    }

    /**
     Creates a task that retrieves the contents of a URL based on the specified URL request object, and calls a handler upon completion. The request will be authenticated and the request will refresh on 401 failure.

     - parameter request: A URL request object that will be authenticated.
     - parameter completionHandler: The completion handler to call when the load request is complete.
     
     */
    public func dataTask(with request: URLRequest,
                         completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let user = self.user
        let request = authenticatedRequest(request, tokens: user.tokens)
        return urlSession.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.isError else {
                completionHandler(data, response, error)
                return
            }

            // 401 might indicate expired access token
            guard httpResponse.statusCode == 401 else {
                completionHandler(data, response, error)
                return
            }

            user.refreshTokens { result in
                completionHandler(data, response, error)
            }
        }
    }
}

private func authenticatedRequest(_ request: URLRequest, tokens: UserTokens?) -> URLRequest {
    var requestCopy = request
    if let bearer = tokens?.accessToken {
        requestCopy.setValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")
    }
    return requestCopy
}

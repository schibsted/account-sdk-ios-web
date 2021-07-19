import Foundation

public final class AuthenticatedURLSession {
    private let user: User
    private let urlSession: URLSession
    private var refreshTokenDataTask: URLSessionDataTask?
    private let dispatchSemaphore = DispatchSemaphore(value: 1)

    public init(user: User, configuration: URLSessionConfiguration) {
        self.user = user
        self.urlSession = URLSession(configuration: configuration)
    }

    public func dataTask(with url: URL) -> URLSessionDataTask {
        return dataTask(with: URLRequest(url: url))
    }

    public func dataTask(with url: URL,
                         completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let request = URLRequest(url: url)
        return dataTask(with: request, completionHandler: completionHandler)
    }

    public func dataTask(with request: URLRequest) -> URLSessionDataTask {
        return dataTask(with: request) { _, _, _ in }
    }

    public func dataTask(with request: URLRequest,
                         completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let user = self.user
        let request = authenticatedRequest(request, tokens: user.tokens)
        return urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.isError else {
                completionHandler(data, response, error)
                return
            }

            // 401 might indicate expired access token
            guard httpResponse.statusCode == 401 else {
                completionHandler(data, response, error)
                return
            }

            self?.dispatchSemaphore.wait()
            user.refreshTokens { result in
                self?.dispatchSemaphore.signal()

                switch result {
                case .success(let tokens):
                    let requestWithRefreshedTokens = authenticatedRequest(request, tokens: tokens)
                    self?.refreshTokenDataTask = self?.urlSession.dataTask(
                        with: requestWithRefreshedTokens,
                        completionHandler: completionHandler
                    )
                    self?.refreshTokenDataTask?.resume()
                case .failure(.refreshRequestFailed(.errorResponse(_, let body))):
                    guard User.shouldLogout(tokenResponseBody: body) else {
                        completionHandler(data, response, error)
                        return
                    }

                    SchibstedAccountLogger.instance.info("Invalid refresh token, logging user out")
                    user.logout()
                    completionHandler(data, response, error)
                case .failure(_):
                    completionHandler(data, response, error)
                }
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

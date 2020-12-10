import Foundation

public enum HTTPError: Error {
    case errorResponse(code: Int, body: String?)
    case unexpectedError(underlying: Error)
    case noData
}

public protocol HTTPClient {
    func execute<T: Decodable>(request: URLRequest, withRetryPolicy: RetryPolicy, completion: @escaping (Result<T, HTTPError>) -> Void)
}

extension HTTPClient {
    func execute<T: Decodable>(request: URLRequest, withRetryPolicy: RetryPolicy = NoRetries.policy, completion: @escaping (Result<T, HTTPError>) -> Void) {
        execute(request: request, withRetryPolicy: withRetryPolicy, completion: completion)
    }
}

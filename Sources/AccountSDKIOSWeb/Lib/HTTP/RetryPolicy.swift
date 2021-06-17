import Foundation

public protocol RetryPolicy {
    func shouldRetry(for: HTTPError) -> Bool
    func numRetries(for: URLRequest) -> Int
}

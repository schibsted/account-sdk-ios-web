import Foundation

class NoRetries: RetryPolicy {
    private init() {}

    public static let policy = NoRetries()

    public func shouldRetry(for: HTTPError) -> Bool {
        return false
    }

    func numRetries(for: URLRequest) -> Int {
        return 0
    }
}

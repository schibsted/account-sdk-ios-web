import Foundation

public protocol RetryPolicy {
    func shouldRetry(for: HTTPError) -> Bool
    func numRetries(for: URLRequest) -> Int
}

public class NoRetries: RetryPolicy {
    private init() {}
    
    public static let policy = NoRetries()
    
    public func shouldRetry(for: HTTPError) -> Bool {
        return false
    }
    
    public func numRetries(for: URLRequest) -> Int {
        return 0
    }
}

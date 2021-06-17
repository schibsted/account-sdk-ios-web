import Foundation

class APIRetryPolicy: RetryPolicy {
    func shouldRetry(for error: HTTPError) -> Bool {
        switch error {
        case .errorResponse(code: let code, body: _):
            // retry in case of intermittent service failure
            if code >= 500 && code < 600 {
                return true
            }
        case .unexpectedError(underlying: _):
            // retry in case of intermittent connection problem
            return true
        case .noData:
            return false
        }

        return false
    }
    
    func numRetries(for: URLRequest) -> Int {
        return 1
    }
}

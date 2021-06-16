import Foundation

public enum RefreshTokenError: Error {
    case noRefreshToken
    case refreshRequestFailed(error: HTTPError)
    case unexpectedError(error: Error)
}

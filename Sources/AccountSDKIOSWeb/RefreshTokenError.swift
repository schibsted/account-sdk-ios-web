import Foundation

public enum RefreshTokenError: Error {
    case noRefreshToken
    case refreshRequestFailed(error: HTTPError)
}

import Foundation

public enum HTTPError: Error {
    case errorResponse(code: Int, body: String?)
    case unexpectedError(underlying: Error)
    case noData
}

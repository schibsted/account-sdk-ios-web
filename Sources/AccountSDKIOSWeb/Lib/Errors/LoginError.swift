import Foundation

public struct OAuthError: Codable, Equatable {
    let error: String
    let errorDescription: String?
    
    private static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    static func fromJSON(_ json: String) -> OAuthError? {
        return json.data(using: .utf8).flatMap { try? jsonDecoder.decode(OAuthError.self, from: $0) }
    }
}

public enum LoginError: Error, Equatable {
    /// Authentication response not related to any outstanding authentication request was received
    case unsolicitedResponse
    /// The authentication failed
    case authenticationErrorResponse(error: OAuthError)
    /// Request to obtain user tokens failed
    case tokenErrorResponse(error: OAuthError)
    /// The user did not complete the requested MFA method(s)
    case missingExpectedMFA
    /// The login flow was cancelled by the user
    case canceled
    /// Previous session in progress
    case previousSessionInProgress
    /// An unexpected error occurred
    case unexpectedError(message: String)
}

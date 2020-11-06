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
    case unsolicitedResponse
    case authenticationErrorResponse(error: OAuthError)
    case tokenErrorResponse(error: OAuthError)
    case missingExpectedMFA
    case unexpectedError(message: String)
}

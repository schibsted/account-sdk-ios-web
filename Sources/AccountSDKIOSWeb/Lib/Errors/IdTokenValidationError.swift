import Foundation

public enum IdTokenValidationError: Error, Equatable {
    case signatureValidationError(SignatureValidationError)
    case failedToDecodePayload
    case missingIdToken
    case invalidNonce
    case missingExpectedAMRValue
    case invalidIssuer
    case invalidAudience
    case expired
}

import Foundation

public enum SignatureValidationError: Error {
    case invalidJWS
    case unknownKeyId
    case noKeyId
    case unsupportedKeyType
    case unspecifiedAlgorithm
    case invalidSignature
}

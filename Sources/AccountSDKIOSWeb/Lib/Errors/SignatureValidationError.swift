//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

public enum SignatureValidationError: Error {
    case invalidJWS
    case unknownKeyId
    case noKeyId
    case unsupportedKeyType
    case unspecifiedAlgorithm
    case invalidSignature
}

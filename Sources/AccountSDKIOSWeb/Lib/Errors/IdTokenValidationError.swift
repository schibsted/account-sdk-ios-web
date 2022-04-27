//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

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

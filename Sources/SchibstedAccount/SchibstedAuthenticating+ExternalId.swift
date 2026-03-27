// 
// Copyright © 2026 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation
internal import CryptoKit

public extension SchibstedAuthenticating {
    /// Gets the external identifier (`externalId`) for the authenticated user.
    ///
    /// - parameters:
    ///   - pairId: Merchant-scoped using a pairwise identifier (See `SchibstedAuthenticatorUserProfile.pairId`)
    ///   - externalParty: The external party for which the identifier will be used.
    ///   - suffix: An optional suffix.
    /// - returns: The external identifier.
    func externalId(
        pairId: String,
        externalParty: String,
        suffix: String? = nil
    ) -> String {
        Data(
            [pairId, externalParty, suffix]
                .compactMap { $0 }
                .joined(separator: ":")
                .utf8
        )
        .sha256()
        .map { String(format: "%02x", $0) }
        .joined()
    }
}

private extension Data {
    func sha256() -> Data {
        Data(SHA256.hash(data: self))
    }
}

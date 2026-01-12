// 
// Copyright © 2026 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

@testable import SchibstedAccount

extension UserTokens {
    static func fake(
        userUUID: String = UUID().uuidString,
        expiration: Date = Date(timeIntervalSinceNow: 600)
    ) -> UserTokens {
        UserTokens(
            accessToken: UUID().uuidString,
            refreshToken: UUID().uuidString,
            idTokenClaims: IdTokenClaims(
                iss: "iss",
                sub: "\(userUUID)",
                userId: "userId",
                aud: [],
                exp: 0,
                nonce: nil,
                amr: nil
            ),
            expiration: expiration
        )
    }
}

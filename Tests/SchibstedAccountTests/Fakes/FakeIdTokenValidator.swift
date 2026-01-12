// 
// Copyright © 2026 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

@testable import SchibstedAccount

struct FakeIdTokenValidator: IdTokenValidating {
    let userUUID: String

    func validate(
        idToken: String?,
        jwks: any JWKS,
        issuer: String,
        clientId: String,
        nonce: String?,
        expectedAMR: String?
    ) async throws -> IdTokenClaims {
        IdTokenClaims(
            iss: "iss",
            sub: "\(userUUID)",
            userId: "userId",
            aud: ["aud"],
            exp: Date().timeIntervalSinceNow + 3600,
            nonce: "nonce",
            amr: ["amr"]
        )
    }
}

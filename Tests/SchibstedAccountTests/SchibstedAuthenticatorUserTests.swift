// 
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Testing

@testable import SchibstedAccount

@Suite
struct SchibstedAuthenticatorUserTests {
    private let tokens = UserTokens.fake()

    @Test
    func userId() {
        let user = SchibstedAuthenticatorUser(
            tokens: tokens,
            sdrn: "sdrn:schibsted:user:userId"
        )
        #expect(user.userId == tokens.idTokenClaims.userId)
    }

    @Test
    func uuid() {
        let user = SchibstedAuthenticatorUser(
            tokens: tokens,
            sdrn: "sdrn:schibsted:user:userId"
        )
        #expect(user.uuid == tokens.idTokenClaims.sub)
    }
}

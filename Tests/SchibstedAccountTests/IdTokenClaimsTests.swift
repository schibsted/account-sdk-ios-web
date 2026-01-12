// 
// Copyright © 2026 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Testing
import Foundation

@testable import SchibstedAccount

@Suite
struct IdTokenClaimsTests {
    @Test(arguments: [plainTextAUD, arrayAUD])
    func deserialize(json: String) throws {
        let data = Data(json.utf8)
        let decoder = JSONDecoder()

        let idTokenClaims = try decoder.decode(IdTokenClaims.self, from: data)

        #expect(idTokenClaims.iss == "iss")
        #expect(idTokenClaims.sub == "sub")
        #expect(idTokenClaims.userId == "userId")
        #expect(idTokenClaims.aud == ["aud"])
        #expect(idTokenClaims.exp == 42)
        #expect(idTokenClaims.nonce == "nonce")
        #expect(idTokenClaims.amr == ["amr"])
    }

    private static let plainTextAUD = """
    {
        "iss": "iss",
        "sub": "sub",
        "legacy_user_id": "userId",
        "aud": "aud",
        "exp": 42,
        "nonce": "nonce",
        "amr": ["amr"]
    }
    """

    private static let arrayAUD = """
    {
        "iss": "iss",
        "sub": "sub",
        "legacy_user_id": "userId",
        "aud": ["aud"],
        "exp": 42,
        "nonce": "nonce",
        "amr": ["amr"]
    }
    """
}

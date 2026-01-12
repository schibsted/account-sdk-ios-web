// 
// Copyright © 2026 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Security
import Testing

@preconcurrency import JOSESwift

@testable import SchibstedAccount

struct FakeJWKS: JWKS {
    nonisolated(unsafe) let key: SecKey

    init(key: SecKey) {
        self.key = key
    }

    init() throws {
        self.key = try SecKey.jwk()
    }

    func getKey(id keyId: String) async throws -> JWK? {
        let publicKey = try #require(SecKeyCopyPublicKey(key))
        return try RSAPublicKey(publicKey: publicKey)
    }
}

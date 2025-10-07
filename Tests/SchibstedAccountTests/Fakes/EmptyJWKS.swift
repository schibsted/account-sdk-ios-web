// 
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

@testable import SchibstedAccount

@preconcurrency import JOSESwift

struct EmptyJWKS: JWKS {
    func getKey(id keyId: String) async throws -> JWK? {
        nil
    }
}

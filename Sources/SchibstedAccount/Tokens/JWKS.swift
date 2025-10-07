// 
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

@preconcurrency import JOSESwift

/// JSON Web Key Set
protocol JWKS: Sendable {
    /// Gets a JWK from a Json Web Key Set.
    ///
    /// - parameter id: The key identifier.
    /// - returns: The found JWK or `nil` if the key could not be found in the JWKS.
    func getKey(id keyId: String) async throws -> JWK?
}

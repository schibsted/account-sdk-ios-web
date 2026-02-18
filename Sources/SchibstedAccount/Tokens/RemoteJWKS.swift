//
// Copyright © 2026 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

internal import Foundation

@preconcurrency internal import JOSESwift

/// Fetches and caches a public JWKS key pair that can be used used for [local token introspection](https://docs.schibsted.io/schibsted-account/guides/token-introspection/#local-token-introspection).
actor RemoteJWKS: JWKS {
    private let environment: SchibstedAuthenticatorEnvironment
    private let urlSession: URLSessionType
    private var cache: [String: JWK] = [:]

    init(
        environment: SchibstedAuthenticatorEnvironment,
        urlSession: URLSessionType
    ) {
        self.environment = environment
        self.urlSession = urlSession
    }

    func getKey(id keyId: String) async throws -> JWK? {
        if let key = cache[keyId] {
            return key
        }

        struct JWKSResponse: Codable {
            struct RSAJWK: Codable {
                let kid: String
                let e: String
                let n: String
            }

            let keys: [RSAJWK]
        }

        let request = URLRequest(url: environment.jwksURL)
        let jwks: JWKSResponse = try await urlSession.data(for: request)

        for keyData in jwks.keys {
            cache[keyData.kid] = RSAPublicKey(
                modulus: keyData.n,
                exponent: keyData.e
            )
        }

        return cache[keyId]
    }
}

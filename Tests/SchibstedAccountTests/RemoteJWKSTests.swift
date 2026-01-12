//
// Copyright © 2026 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Testing
import Foundation
@preconcurrency import JOSESwift

@testable import SchibstedAccount

@Suite
struct RemoteJWKSTests {
    private let urlSession = FakeURLSession()

    @Test(arguments: [
        SchibstedAuthenticatorEnvironment.sweden,
        SchibstedAuthenticatorEnvironment.norway,
        SchibstedAuthenticatorEnvironment.finland,
        SchibstedAuthenticatorEnvironment.pre
    ])
    func getKey(environment: SchibstedAuthenticatorEnvironment) async throws {
        let json = """
        {
            "keys": [
                {
                    "alg": "RS256",
                    "kty": "RSA",
                    "use": "sig",
                    "n": "yeNlzlub94YgerT030codqEztjfU",
                    "e": "AQAB",
                    "kid": "NjVBRjY5MDlCMUIwNzU4RTA2",
                },
                {
                    "alg": "RS256",
                    "kty": "RSA",
                    "use": "sig",
                    "n": "kjAWtYfPHDzz_sPCT1Axz6isZdf3",
                    "e": "BQSP",
                    "kid": "DQ4QzQ2MDAyQjVDNjk1RTM2Qg",
                }
            ]
        }
        """

        try await confirmation(expectedCount: 1) { confirmation in
            urlSession.data = { _ in
                confirmation()
                return (Data(json.utf8), HTTPURLResponse())
            }

            let jwks: JWKS = RemoteJWKS(environment: environment, urlSession: urlSession)

            // Will trigger a network request
            let jwk1 = try #require(await jwks.getKey(id: "NjVBRjY5MDlCMUIwNzU4RTA2"))
            #expect(jwk1.parameters == [
                "e": "AQAB",
                "kty": "RSA",
                "n": "yeNlzlub94YgerT030codqEztjfU"
            ])

            // Will be fetched from the cache
            let jwk2 = try #require(await jwks.getKey(id: "DQ4QzQ2MDAyQjVDNjk1RTM2Qg"))
            #expect(jwk2.parameters == [
                "e": "BQSP",
                "kty": "RSA",
                "n": "kjAWtYfPHDzz_sPCT1Axz6isZdf3"
            ])
        }
    }
}

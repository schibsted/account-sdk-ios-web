// 
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Testing
import Security
import Foundation

@preconcurrency import JOSESwift

@testable import SchibstedAccount

@Suite
struct IdTokenValidatorTests {
    private let expiration = Date().timeIntervalSince1970 + 3600
    private let clientId = "a70ed9c041334b712c599a526"
    private let issuer = "https://login.schibsted.com"
    private let sub = "userUUID"
    private let userId = "12345689"
    private let nonce = "nonce"
    private let amr = "eid"
    private let idTokenValidator = IdTokenValidator()

    @Test
    func validToken() async throws {
        let jwks = try FakeJWKS()
        let jws = try jws(key: jwks.key, claims: validClaims())

        let idTokenClaims = try await idTokenValidator.validate(
            idToken: jws.compactSerializedString,
            jwks: jwks,
            issuer: issuer,
            clientId: clientId,
            nonce: nonce,
            expectedAMR: amr
        )

        #expect(idTokenClaims.iss == issuer)
        #expect(idTokenClaims.sub == sub)
        #expect(idTokenClaims.userId == userId)
        #expect(idTokenClaims.aud == [clientId])
        #expect(idTokenClaims.exp == expiration)
        #expect(idTokenClaims.nonce == nonce)
        #expect(idTokenClaims.amr == [amr])
    }

    @Test
    func missingIdToken() async throws {
        let jwks = try FakeJWKS()

        await #expect(throws: IdTokenValidationError.missingIdToken) {
            _ = try await idTokenValidator.validate(
                idToken: nil,
                jwks: jwks,
                issuer: issuer,
                clientId: clientId,
                nonce: nonce,
                expectedAMR: amr
            )
        }
    }

    @Test
    func missingExpectedAMRValue() async throws {
        await #expect(throws: IdTokenValidationError.missingExpectedAMRValue) {
            try await validate(
                claims: """
                {
                    "iss": "\(issuer)",
                    "sub": "\(sub)",
                    "legacy_user_id": "\(userId)",
                    "aud": "\(clientId)",
                    "exp": \(expiration),
                    "nonce": "\(nonce)"
                }
                """
            )
        }
    }

    @Test
    func invalidNonce() async throws {
        await #expect(throws: IdTokenValidationError.invalidNonce) {
            try await validate(
                claims: """
                {
                    "iss": "\(issuer)",
                    "sub": "\(sub)",
                    "legacy_user_id": "\(userId)",
                    "aud": "\(clientId)",
                    "exp": \(expiration),
                    "amr": ["\(amr)"]
                }
                """
            )
        }
    }

    @Test
    func failedToDecodePayload() async throws {
        await #expect(throws: DecodingError.self) {
            try await validate(
                claims: """
                {
                    "iss": "\(issuer)",
                    "sub": "\(sub)",
                    "legacy_user_id": "\(userId)",
                    "aud": "\(clientId)",
                    "nonce": "\(nonce)",
                    "amr": ["\(amr)"]
                }
                """
            )
        }
    }

    @Test
    func invalidIssuer() async throws {
        await #expect(throws: IdTokenValidationError.invalidIssuer) {
            try await validate(
                claims: """
                {
                    "iss": "invalidIssuer",
                    "sub": "\(sub)",
                    "legacy_user_id": "\(userId)",
                    "aud": "\(clientId)",
                    "exp": \(expiration),
                    "nonce": "\(nonce)",
                    "amr": ["\(amr)"]
                }
                """
            )
        }
    }

    @Test
    func invalidAudience() async throws {
        await #expect(throws: IdTokenValidationError.invalidAudience) {
            try await validate(
                claims: """
                {
                    "iss": "\(issuer)",
                    "sub": "\(sub)",
                    "legacy_user_id": "\(userId)",
                    "aud": "invalidAudience",
                    "exp": \(expiration),
                    "nonce": "\(nonce)",
                    "amr": ["\(amr)"]
                }
                """
            )
        }
    }

    @Test
    func expired() async throws {
        await #expect(throws: IdTokenValidationError.expired) {
            try await validate(
                claims: """
                {
                    "iss": "\(issuer)",
                    "sub": "\(sub)",
                    "legacy_user_id": "\(userId)",
                    "aud": "\(clientId)",
                    "exp": \(Date().timeIntervalSince1970 - 3600),
                    "nonce": "\(nonce)",
                    "amr": ["\(amr)"]
                }
                """
            )
        }
    }

    @Test
    func unknownKeyId() async throws {
        await #expect(throws: SignatureValidationError.unknownKeyId) {
            let key = try SecKey.jwk()
            let jws = try jws(key: key, claims: validClaims())
            let jwks = EmptyJWKS()

            _ = try await idTokenValidator.validate(
                idToken: jws.compactSerializedString,
                jwks: jwks,
                issuer: issuer,
                clientId: clientId,
                nonce: nonce,
                expectedAMR: amr
            )
        }
    }

    private func validate(claims: String) async throws {
        let jwks = try FakeJWKS()
        let jws = try jws(key: jwks.key, claims: claims)

        _ = try await idTokenValidator.validate(
            idToken: jws.compactSerializedString,
            jwks: jwks,
            issuer: issuer,
            clientId: clientId,
            nonce: nonce,
            expectedAMR: amr
        )
    }

    private func jws(key: SecKey, claims: String) throws -> JWS {
        let algorithm = SignatureAlgorithm.RS256
        var header = JWSHeader(algorithm: algorithm)
        header.kid = "test key"

        let payload = Payload(Data(claims.utf8))
        let signer = Signer(signatureAlgorithm: algorithm, key: key)!

        return try JWS(header: header, payload: payload, signer: signer)
    }

    private func validClaims() -> String {
        """
        {
            "iss": "\(issuer)",
            "sub": "\(sub)",
            "legacy_user_id": "\(userId)",
            "aud": "\(clientId)",
            "exp": \(expiration),
            "nonce": "\(nonce)",
            "amr": ["\(amr)"]
        }
        """
    }
}

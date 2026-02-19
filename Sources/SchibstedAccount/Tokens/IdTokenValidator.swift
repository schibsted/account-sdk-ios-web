//
// Copyright © 2026 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

internal import Foundation
internal import Logging
@preconcurrency internal import JOSESwift

protocol IdTokenValidating: Sendable {
    /// ID Token Validation.
    ///
    /// See https://openid.net/specs/openid-connect-core-1_0.html#IDTokenValidation
    func validate(
        idToken: String?,
        jwks: JWKS,
        issuer: String,
        clientId: String,
        nonce: String?,
        expectedAMR: String?
    ) async throws -> IdTokenClaims
}

struct IdTokenValidator: IdTokenValidating {
    private let logger = Logger(label: "IdTokenValidator")

    func validate(
        idToken: String?,
        jwks: JWKS,
        issuer: String,
        clientId: String,
        nonce: String?,
        expectedAMR: String?
    ) async throws -> IdTokenClaims {
        guard let idToken else {
            throw IdTokenValidationError.missingIdToken
        }

        // Verify signature using local token introspection
        let payload = try await verifySignature(of: idToken, withKeys: jwks)

        let claims = try JSONDecoder().decode(IdTokenClaims.self, from: payload)

        /// Verify the issuer match
        guard claims.iss.removeTrailingSlash() == issuer.removeTrailingSlash() else {
            logger.error("Invalid issuer in the ID Token Claims. Found \(claims.iss.removeTrailingSlash()), expected \(issuer.removeTrailingSlash())")
            throw IdTokenValidationError.invalidIssuer
        }

        /// Verify the audience contains our client id
        guard claims.aud.contains(clientId) else {
            logger.error("Couldn't find the client id '\(clientId)' in the ID Token Claims audiences [\(claims.aud.joined(separator: ","))]")
            throw IdTokenValidationError.invalidAudience
        }

        /// Verify the token have not expired
        let now = Date()
        let exp = Date(timeIntervalSince1970: claims.exp)
        guard exp > now else {
            logger.error("ID Token Claims have expired. Expiration date: \(claims.exp), Current time: \(now)")
            throw IdTokenValidationError.expired
        }

        /// Verify the nonce match (to guard against reply attacks)
        guard claims.nonce == nonce else {
            logger.error("ID Token nonce mismatch. Found \(claims.nonce ?? "<nil>"), expected \(nonce ?? "<nil>")")
            throw IdTokenValidationError.invalidNonce
        }

        /// Verify the authentication methods reference matches (used for multi-factor authentication)
        guard verifyAMR(claims.amr, value: expectedAMR) else {
            logger.error("ID Token AMR mismatch. [\((claims.amr ?? []).joined(separator: ","))] does not contain '\(expectedAMR ?? "<nil>")'.")
            throw IdTokenValidationError.missingExpectedAMRValue
        }

        return claims
    }

    /// Verify the JWS using local token introspection
    private func verifySignature(
        of serialisedJWS: String,
        withKeys jwks: JWKS
    ) async throws -> Data {
        let jws = try JWS(compactSerialization: serialisedJWS)

        guard let keyId = jws.header.kid else {
            logger.error("JWS missing key identifier.")
            throw SignatureValidationError.noKeyId
        }

        guard let algorithm = jws.header.algorithm else {
            logger.error("JWS missing algorithm.")
            throw SignatureValidationError.unspecifiedAlgorithm
        }

        // Retrieve a valid public key we can use for local token instrospection
        let jwk = try await jwks.getKey(id: keyId)

        guard let jwk else {
            logger.error("Unable to find public key for introspection for key identifier: '\(keyId)'.")
            throw SignatureValidationError.unknownKeyId
        }

        guard let publicKey = jwk.toSecKey() else {
            logger.error("Unsupported key type '\(jwk.keyType)'.")
            throw SignatureValidationError.unsupportedKeyType
        }

        guard let verifier = Verifier(signatureAlgorithm: algorithm, key: publicKey) else {
            logger.error("Unsupported signature algorithm \(algorithm).")
            throw SignatureValidationError.unsupportedSignatureAlgorithm
        }

        // Perform local token instrospection
        do {
            let validatedJWS = try jws.validate(using: verifier)
            return validatedJWS.payload.data()
        } catch {
            logger.error("Local introspection failed. Error: \(error).")
            throw error
        }
    }

    private func verifyAMR(_ values: [String]?, value: String?) -> Bool {
        guard let value else {
            return true
        }

        guard let values else {
            return false
        }

        // pre-eids contains the country, so we map them to the global eid for AMR validation
        if MultifactorAuthentication.PreBankId(rawValue: value) != nil {
            return values.contains(MultifactorAuthentication.bankId.rawValue)
        } else {
            return values.contains(value)
        }
    }
}

enum IdTokenValidationError: Error, Equatable {
    case missingIdToken
    case invalidNonce
    case missingExpectedAMRValue
    case invalidIssuer
    case invalidAudience
    case expired
}

enum SignatureValidationError: Error {
    case unknownKeyId
    case noKeyId
    case unsupportedKeyType
    case unsupportedSignatureAlgorithm
    case unspecifiedAlgorithm
}

private extension JWK {
    func toSecKey() -> SecKey? {
        if let key = self as? RSAPublicKey, let converted = try? key.converted(to: SecKey.self) {
            return converted
        } else if let key = self as? ECPublicKey, let converted = try? key.converted(to: SecKey.self) {
            return converted
        } else {
            return nil
        }
    }
}

//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation
import JOSESwift

internal extension JWK {
    func toSecKey() -> SecKey? {
        if let key = self as? RSAPublicKey,
           let converted = try? key.converted(to: SecKey.self) {
            return converted
        } else if let key = self as? ECPublicKey,
                  let converted = try? key.converted(to: SecKey.self) {
            return converted
        }

        return nil
    }
}

internal enum JOSEUtil {
    internal static func verifySignature(of serialisedJWS: String,
                                         withKeys jwks: JWKS,
                                         completion: @escaping (Result<Data, SignatureValidationError>) -> Void) {
        guard let jws = try? JWS(compactSerialization: serialisedJWS) else {
            completion(.failure(.invalidJWS))
            return
        }

        guard let keyId = jws.header.kid else {
            completion(.failure(.noKeyId))
            return
        }

        guard let algorithm = jws.header.algorithm else {
            completion(.failure(.unspecifiedAlgorithm))
            return
        }

        jwks.getKey(withId: keyId) { jwk in
            guard let key = jwk else {
                completion(.failure(.unknownKeyId))
                return
            }

            guard let publicKey = key.toSecKey(),
                  let verifier = Verifier(signatureAlgorithm: algorithm, key: publicKey) else {
                completion(.failure(.unsupportedKeyType))
                return
            }

            do {
                let payload = try jws.validate(using: verifier).payload
                completion(.success(payload.data()))
            } catch {
                SchibstedAccountLogger.instance.debug("Failed to verify JWS signature: \(error)")
                completion(.failure(.invalidSignature))
            }
        }
    }
}

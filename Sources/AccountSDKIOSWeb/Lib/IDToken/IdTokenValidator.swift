//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

internal struct IdTokenValidationContext {
    let issuer: String
    let clientId: String
    var nonce: String?
    var expectedAMR: String?
}

internal enum IdTokenValidator {
    static func validate(idToken: String,
                         jwks: JWKS,
                         context: IdTokenValidationContext,
                         completion: @escaping (Result<IdTokenClaims, IdTokenValidationError>) -> Void) {
        JOSEUtil.verifySignature(of: idToken, withKeys: jwks) { result in
            switch result {
            case .success(let payload):
                guard let claims = try? JSONDecoder().decode(IdTokenClaims.self, from: payload) else {
                    completion(.failure(.failedToDecodePayload))
                    return
                }

              // ID Token Validation according to
              // https://openid.net/specs/openid-connect-core-1_0.html#IDTokenValidation

                guard removeTrailingSlash(from: claims.iss) == removeTrailingSlash(from: context.issuer) else {
                    completion(.failure(.invalidIssuer))
                    return
                }

                guard claims.aud.contains(context.clientId) else {
                    completion(.failure(.invalidAudience))
                    return
                }

                let now = Date().timeIntervalSince1970
                guard claims.exp > now else {
                    completion(.failure(.expired))
                    return
                }

                guard claims.nonce == context.nonce else {
                    completion(.failure(.invalidNonce))
                    return
                }

                guard IdTokenValidator.contains(claims.amr, value: context.expectedAMR) else {
                    SchibstedAccountLogger.instance
                        .info("Requested AMR values were not fulfilled: \(String(describing: claims.amr)) != \(String(describing: context.expectedAMR))")
                    completion(.failure(.missingExpectedAMRValue))
                    return
                }

                completion(.success(claims))
            case .failure(let error):
                completion(.failure(.signatureValidationError(error)))
            }
        }
    }

    private static func contains(_ values: [String]?, value: String?) -> Bool {
        guard var value = value else {
            return true
        }

        if PreEidType(rawValue: value) != nil {
            value = MFAType.eid.rawValue
        }

        if let values = values {
            return values.contains(value)
        }

        return false
    }

    private static func removeTrailingSlash(from: String) -> String {
        if from.last == "/" {
            return String(from.dropLast())
        }

        return from
    }
}

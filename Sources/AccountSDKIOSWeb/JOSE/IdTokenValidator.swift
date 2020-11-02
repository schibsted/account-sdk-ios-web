import Foundation

internal struct IdTokenValidationContext {
    let jwks: JWKS
}

public enum IdTokenValidationError: Error {
    case signatureValidationError(SignatureValidationError)
    case failedToDecodePayload
    case missingIdToken
}

internal struct IdTokenValidator {
    static func validate(idToken: String, context: IdTokenValidationContext, completion: @escaping (Result<IdTokenClaims, IdTokenValidationError>) -> Void) {
        JOSEUtil.verifySignature(of: idToken, withKeys: context.jwks) { result in
            switch result {
            case .success(let payload):
                guard let claims = try? JSONDecoder().decode(IdTokenClaims.self, from: payload) else {
                    completion(.failure(.failedToDecodePayload))
                    return
                }
                /* TODO implement full ID Token Validation according to https://openid.net/specs/openid-connect-core-1_0.html#IDTokenValidation:
                    iss, aud, exp, nonce
                 */
                completion(.success(claims))
            case .failure(let error):
                completion(.failure(.signatureValidationError(error)))
            }
        }
    }
}

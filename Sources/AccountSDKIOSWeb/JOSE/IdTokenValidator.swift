import Foundation

internal struct IdTokenValidationContext {
    var nonce: String? = nil
    var expectedAMR: String? = nil
}

public enum IdTokenValidationError: Error, Equatable {
    case signatureValidationError(SignatureValidationError)
    case failedToDecodePayload
    case missingIdToken
    case invalidNonce
    case missingExpectedAMRValue
}

internal struct IdTokenValidator {
    static func validate(idToken: String, jwks: JWKS, context: IdTokenValidationContext, completion: @escaping (Result<IdTokenClaims, IdTokenValidationError>) -> Void) {
        JOSEUtil.verifySignature(of: idToken, withKeys: jwks) { result in
            switch result {
            case .success(let payload):
                guard let claims = try? JSONDecoder().decode(IdTokenClaims.self, from: payload) else {
                    completion(.failure(.failedToDecodePayload))
                    return
                }
                /* TODO implement full ID Token Validation according to https://openid.net/specs/openid-connect-core-1_0.html#IDTokenValidation:
                    iss, aud, exp, nonce
                 */
                guard claims.nonce == context.nonce else {
                    completion(.failure(.invalidNonce))
                    return
                }
                
                guard IdTokenValidator.contains(claims.amr, value: context.expectedAMR) else {
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
        guard let value = value else {
            return true
        }

        if let values = values {
            return values.contains(value)
        }
        
        return false
    }
}

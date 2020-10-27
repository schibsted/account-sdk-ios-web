import Foundation
import JOSESwift

internal enum IdTokenValidationError: Error {
    case signatureValidationError(SignatureValidationError)
    case failedToDecodePayload
    case missingIdToken
}

internal enum TokenError: Error {
    case tokenRequestError(HTTPError)
    case idTokenError(IdTokenValidationError)
}

public struct IdTokenClaims: Codable, Equatable {
    let sub: String
    // TODO add other claims
}

internal struct TokenResult: CustomStringConvertible {
    let accessToken: String
    let refreshToken: String?
    let idToken: String
    let idTokenClaims: IdTokenClaims
    let scope: String?
    let expiresIn: Int
    
    var description: String {
        return "TokenResult("
            + "accessToken: \(removeSignature(fromToken: accessToken)),\n"
            + "refreshToken: \(removeSignature(fromToken: refreshToken)),\n"
            + "idToken: \(removeSignature(fromToken: idToken)),\n"
            + "idToken: \(idTokenClaims),\n"
            + "scope: \(scope ?? ""),\n"
            + "expiresIn: \(expiresIn))"
        
    }
}

internal struct TokenResponse: Codable, Equatable, CustomStringConvertible {
    let access_token: String
    let refresh_token: String?
    let id_token: String?
    let scope: String?
    let expires_in: Int
    
    var description: String {
        return "TokenResponse("
            + "access_token: \(removeSignature(fromToken: access_token)),\n"
            + "refresh_token: \(removeSignature(fromToken: refresh_token)),\n"
            + "id_token: \(removeSignature(fromToken: id_token)),\n"
            + "scope: \(scope ?? ""),\n"
            + "expires_in: \(expires_in))"
        
    }
}

func removeSignature(fromToken token: String?) -> String {
    guard let value = token else {
        return ""
    }

    let split = value.components(separatedBy: ".")

    if split.count < 2 {
        let tokenPrefix = token?.prefix(3) ?? ""
        return "\(tokenPrefix)..."
    }

    return "\(split[0]).\(split[1])"
}

internal class TokenHandler {
    private let configuration: ClientConfiguration
    private let httpClient: HTTPClient
    private let jwks: JWKS
    
    init(configuration: ClientConfiguration, httpClient: HTTPClient, jwks: JWKS) {
        self.configuration = configuration
        self.httpClient = httpClient
        self.jwks = jwks
    }
    func makeTokenRequest(authCode: String, completion: @escaping (Result<TokenResult, TokenError>) -> Void) {
        let url = configuration.serverURL.appendingPathComponent("/oauth/token")
        let parameters = [
            "grant_type": "authorization_code",
            "code": authCode,
            "redirect_uri": configuration.redirectURI.absoluteString
        ]

        guard let request = HTTPUtil.formURLEncode(parameters: parameters) else {
            preconditionFailure("Failed to create token request")
        }
        
        httpClient.post(url: url, body: request, contentType: HTTPUtil.xWWWFormURLEncodedContentType, authorization: HTTPUtil.basicAuth(username: configuration.clientId, password: configuration.clientSecret)) { (result: Result<TokenResponse, HTTPError>) -> Void in
            switch result {
            case .success(let tokenResponse):
                guard let idToken = tokenResponse.id_token else {
                    completion(.failure(.idTokenError(.missingIdToken)))
                    return
                }

                self.validateIdToken(idToken: idToken) { result in
                    switch result {
                    case .success(let claims):
                        let tokenResult = TokenResult(accessToken: tokenResponse.access_token,
                                                      refreshToken: tokenResponse.refresh_token,
                                                      idToken: idToken,
                                                      idTokenClaims: claims,
                                                      scope: tokenResponse.scope,
                                                      expiresIn: tokenResponse.expires_in)
                        completion(.success(tokenResult))
                        return
                    case .failure(let idTokenValidationError):
                        completion(.failure(.idTokenError(idTokenValidationError)))
                    }
                }
            case .failure(let httpError):
                completion(.failure(.tokenRequestError(httpError)))
                return
            }
            
        }
    }
    
    private func validateIdToken(idToken: String, completion: @escaping (Result<IdTokenClaims, IdTokenValidationError>) -> Void) {
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
                completion(.success(claims))
            case .failure(let error):
                completion(.failure(.signatureValidationError(error)))
            }
        }
    }
}

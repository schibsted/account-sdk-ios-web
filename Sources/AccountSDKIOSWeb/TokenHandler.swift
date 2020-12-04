import Foundation
import JOSESwift

internal enum TokenError: Error {
    case tokenRequestError(HTTPError)
    case idTokenError(IdTokenValidationError)
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
    private let schibstedAccountAPI: SchibstedAccountAPI
    let jwks: JWKS
    
    init(configuration: ClientConfiguration, httpClient: HTTPClient, jwks: JWKS) {
        self.configuration = configuration
        self.httpClient = httpClient
        self.schibstedAccountAPI = SchibstedAccountAPI(baseURL: configuration.serverURL)
        self.jwks = jwks
    }

    func makeTokenRequest(authCode: String, idTokenValidationContext: IdTokenValidationContext, completion: @escaping (Result<TokenResult, TokenError>) -> Void) {
        tokenRequest(parameters: [
            "grant_type": "authorization_code",
            "code": authCode,
            "redirect_uri": configuration.redirectURI.absoluteString
        ]) { result in
            switch result {
            case .success(let tokenResponse):
                guard let idToken = tokenResponse.id_token else {
                    completion(.failure(.idTokenError(.missingIdToken)))
                    return
                }

                IdTokenValidator.validate(idToken: idToken, jwks: self.jwks, context: idTokenValidationContext) { result in
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
    
    func makeTokenRequest(refreshToken: String, scope: String? = nil, completion: @escaping (Result<TokenResponse, HTTPError>) -> Void) {
        var parameters = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken,
        ]
        scope.map { parameters["scope"] = $0 }

        tokenRequest(parameters: parameters, completion: completion)
    }
    
    internal func tokenRequest(parameters: [String: String], completion: @escaping (Result<TokenResponse, HTTPError>) -> Void) {
        let credentials = HTTPUtil.basicAuth(username: configuration.clientId, password: configuration.clientSecret)
        schibstedAccountAPI.tokenRequest(with: httpClient, parameters: parameters, authorization: credentials, completion: completion)
    }
}

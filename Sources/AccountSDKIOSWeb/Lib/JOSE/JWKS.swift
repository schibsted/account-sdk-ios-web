//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation
import JOSESwift

struct RSAJWK: Codable {
    // swiftlint:disable identifier_name
    let kid: String
    let kty: String
    let e: String
    let n: String
    let alg: String?
    let use: String?
    // swiftlint:enable identifier_name
}

struct JWKSResponse: Codable {
    let keys: [AccountSDKIOSWeb.RSAJWK]
}

protocol JWKS {
    @MainActor
    func getKey(withId: String, completion: @escaping (JWK?) -> Void)
}

final class RemoteJWKS: JWKS {
    private let jwksURI: URL
    private let httpClient: HTTPClient
    private let cache: Cache<JWK>

    convenience init(jwksURI: URL, httpClient: HTTPClient) {
        self.init(jwksURI: jwksURI, httpClient: httpClient, cache: Cache())
    }

    internal init(jwksURI: URL, httpClient: HTTPClient, cache: Cache<JWK>) {
        self.jwksURI = jwksURI
        self.httpClient = httpClient
        self.cache = cache
    }

    @MainActor
    func getKey(withId keyId: String, completion: @escaping (JWK?) -> Void) {
        if let cachedKey = cache.object(forKey: keyId) {
            completion(cachedKey)
            return
        }

        fetchJWKS(keyId: keyId, completion: completion)
    }

    @MainActor
    private func fetchJWKS(keyId: String, completion: @escaping (JWK?) -> Void) {
        let request = URLRequest(url: jwksURI)
        httpClient.execute(request: SchibstedAccountAPI.addingSDKHeaders(to: request)) { (result: Result<JWKSResponse, HTTPError>) in
            switch result {
            case .success(let jwks):
                for keyData in jwks.keys {
                    let jwk = RSAPublicKey(modulus: keyData.n, exponent: keyData.e)
                    self.cache.setObject(jwk, forKey: keyData.kid)
                }

                completion(self.cache.object(forKey: keyId))
            case .failure:
                SchibstedAccountLogger.instance.error("Failed to fetch JWKS")
                completion(nil)
            }
        }
    }
}

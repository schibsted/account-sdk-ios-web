import Foundation
import JOSESwift

internal struct RSAJWK: Codable {
    let kid: String
    let kty: String
    let e: String
    let n: String
    let alg: String?
    let use: String?
}

internal struct JWKSResponse: Codable {
    let keys: [AccountSDKIOSWeb.RSAJWK]
}

private class JWKCacheWrapper {
    let jwk: JWK
    
    init(jwk: JWK) {
        self.jwk = jwk
    }
}

internal protocol JWKS {
    func getKey(withId: String, completion: @escaping (JWK?) -> Void)
}

internal class RemoteJWKS: JWKS {
    private let jwksURI: URL
    private let httpClient: HTTPClient
    private let cache = NSCache<NSString, JWKCacheWrapper>()

    init(jwksURI: URL, httpClient: HTTPClient) {
        self.jwksURI = jwksURI
        self.httpClient = httpClient
    }

    func getKey(withId keyId: String, completion: @escaping (JWK?) -> Void) {
        if let cachedKey = cache.object(forKey: keyId as NSString) {
            completion(cachedKey.jwk)
            return
        }
        
        fetchJWKS(keyId: keyId, completion: completion)
    }
    
    private func fetchJWKS(keyId: String, completion: @escaping (JWK?) -> Void) {
        httpClient.get(url: jwksURI) { (result: Result<JWKSResponse, HTTPError>) -> Void in
            switch result {
            case .success(let jwks):
                for keyData in jwks.keys {
                    let jwk = RSAPublicKey(modulus: keyData.n, exponent: keyData.e)
                    self.cache.setObject(JWKCacheWrapper(jwk: jwk), forKey: keyData.kid as NSString)
                }
                
                completion(self.cache.object(forKey: keyId as NSString)?.jwk)
            case .failure:
                // TODO log error
                completion(nil)
            }
        }
    }
}

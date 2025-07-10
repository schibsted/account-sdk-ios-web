//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import XCTest
import JOSESwift
import Cuckoo

@testable import AccountSDKIOSWeb

private class DictionaryCache<V>: Cache<V> {
    private var cache: [String: V] = [:]
    
    override func object(forKey: String) -> V? {
        return cache[forKey]
    }
    
    override func setObject(_ object: V, forKey: String) {
        cache[forKey] = object
    }
}

final class RemoteJWKSTests: XCTestCase {
    private let jwksURI = URL(staticString: "https://example.com/jwks")
    private let testJWK = RSAPublicKey(modulus: "aaa", exponent: "bbb")

    @MainActor
    func testGetKeyReturnsAlreadyCachedKey() {
        let keyId = "test key"
        let cache = DictionaryCache<JWK>()
        cache.setObject(testJWK, forKey: keyId)

        let mockHTTPClient = MockHTTPClient()
        let jwks = RemoteJWKS(jwksURI: jwksURI, httpClient: mockHTTPClient, cache: cache)
        
        Await.until { done in
            jwks.getKey(withId: keyId) { cachedJwk in
                XCTAssertEqual(cachedJwk!.keyType, self.testJWK.keyType)
                XCTAssertEqual(cachedJwk!.parameters, self.testJWK.parameters)
                
                let closureMatcher: ParameterMatcher<HTTPResultHandler<JWKSResponse>> = ParameterMatcher()
                verify(mockHTTPClient, times(0)).execute(request: any(), withRetryPolicy: any(), completion: closureMatcher)
                
                done()
            }
        }
    }

    @MainActor
    func testGetKeyFetchesJWKSForUnknownKeyId() {
        let keyId = "test key"
       
        let mockHTTPClient = MockHTTPClient()
        stub(mockHTTPClient) { mock in
            let jwksResponse = JWKSResponse(keys: [RSAJWK(kid: keyId, kty: "RSA", e: testJWK.exponent, n: testJWK.modulus, alg: "RS256", use: "sig")])
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: ParameterMatcher()))
                .then { _, _, completion in
                    completion(.success(jwksResponse))
                }
        }
        
        let jwks = RemoteJWKS(jwksURI: jwksURI, httpClient: mockHTTPClient, cache: DictionaryCache())
        Await.until { done in
            jwks.getKey(withId: keyId) { fetchedJwk in
                XCTAssertEqual(fetchedJwk!.keyType, self.testJWK.keyType)
                XCTAssertEqual(fetchedJwk!.parameters, self.testJWK.parameters)
                done()
            }
        }
    }

    @MainActor
    func testGetKeyHandlesMissingKeyId() {
        let mockHTTPClient = MockHTTPClient()
        stub(mockHTTPClient) { mock in
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: ParameterMatcher()))
                .then { _, _, completion in
                    completion(.success(JWKSResponse(keys: [])))
                }
        }
        
        let jwks = RemoteJWKS(jwksURI: jwksURI, httpClient: mockHTTPClient, cache: DictionaryCache())
        Await.until { done in
            jwks.getKey(withId: "keyId") { jwk in
                XCTAssertNil(jwk)
                done()
            }
        }
    }
}

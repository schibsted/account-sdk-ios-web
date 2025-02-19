//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import XCTest
import JOSESwift
@testable import AccountSDKIOSWeb

final class JOSEUtilTests: XCTestCase {
    private static let keyId = "test key"
    private static var jwsUtil: JWSUtil!
    private static var jwks: JWKS!
    
    override class func setUp() {
        jwsUtil = JWSUtil()
        jwks = StaticJWKS(keyId: keyId, rsaPublicKey: jwsUtil.publicKey)
    }
    
    func testVerifySignatureValidJWS() {
        let payload = "test data".data(using: .utf8)!
        let jws = JOSEUtilTests.jwsUtil.createJWS(payload: payload, keyId: JOSEUtilTests.keyId)

        Await.until { done in
            JOSEUtil.verifySignature(of: jws, withKeys: JOSEUtilTests.jwks!) { result in
                XCTAssertEqual(result, .success(payload))
                done()
            }
        }
    }
    
    func testVerifySignatureHandlesMalformedJWS() {
        Await.until { done in
            JOSEUtil.verifySignature(of: "not a jws", withKeys: JOSEUtilTests.jwks!) { result in
                XCTAssertEqual(result, .failure(.invalidJWS))
                done()
            }
        }
    }
    
    func testVerifySignatureHandlesInvalidSignature() {
        let jws = JOSEUtilTests.jwsUtil.createJWS(payload: Data(), keyId: JOSEUtilTests.keyId)
        let jwsComponents = jws.components(separatedBy: ".")
        let invalidSignature = "invalid_signature".data(using: .utf8)!.base64EncodedString()
        let jwsWithInvalidSignature = "\(jwsComponents[0]).\(jwsComponents[1]).\(invalidSignature)"

        Await.until { done in
            JOSEUtil.verifySignature(of: jwsWithInvalidSignature, withKeys: JOSEUtilTests.jwks!) { result in
                XCTAssertEqual(result, .failure(.invalidSignature))
                done()
            }
        }
    }
    
    func testVerifySignatureHandlesJWSWithoutKeyId() {
        let jws = JOSEUtilTests.jwsUtil.createJWS(payload: Data(), keyId: nil)

        Await.until { done in
            JOSEUtil.verifySignature(of: jws, withKeys: JOSEUtilTests.jwks!) { result in
                XCTAssertEqual(result, .failure(.noKeyId))
                done()
            }
        }
    }

    func testVerifySignatureHandlesUnknownKeyId() {
        let jws = JOSEUtilTests.jwsUtil.createJWS(payload: Data(), keyId: "unknown")

        Await.until { done in
            JOSEUtil.verifySignature(of: jws, withKeys: JOSEUtilTests.jwks!) { result in
                XCTAssertEqual(result, .failure(.unknownKeyId))
                done()
            }
        }
    }
    
    func testVerifySignatureHandlesUnsupportedKeyType() {
        let jws = JOSEUtilTests.jwsUtil.createJWS(payload: Data(), keyId: JOSEUtilTests.keyId)
       
        let ecKey = ECPublicKey(crv: .P256, x: "aaa", y: "bbb")
        Await.until { done in
            JOSEUtil.verifySignature(of: jws, withKeys: StaticJWKS(keyId: JOSEUtilTests.keyId, jwk: ecKey)) { result in
                XCTAssertEqual(result, .failure(.unsupportedKeyType))
                done()
            }
        }
    }
}

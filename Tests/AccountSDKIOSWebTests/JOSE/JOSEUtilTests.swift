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
        
        let callbackExpectation = expectation(description: "Returns verified payload to callback")
        JOSEUtil.verifySignature(of: jws, withKeys: JOSEUtilTests.jwks!) { result in
            XCTAssertEqual(result, .success(payload))

            callbackExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testVerifySignatureHandlesMalformedJWS() {
        let callbackExpectation = expectation(description: "Returns error to callback")
        JOSEUtil.verifySignature(of: "not a jws", withKeys: JOSEUtilTests.jwks!) { result in
            XCTAssertEqual(result, .failure(.invalidJWS))
            
            callbackExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testVerifySignatureHandlesInvalidSignature() {
        let jws = JOSEUtilTests.jwsUtil.createJWS(payload: Data(), keyId: JOSEUtilTests.keyId)
        let jwsComponents = jws.components(separatedBy: ".")
        let invalidSignature = "invalid_signature".data(using: .utf8)!.base64EncodedString()
        let jwsWithInvalidSignature = "\(jwsComponents[0]).\(jwsComponents[1]).\(invalidSignature)"

        let callbackExpectation = expectation(description: "Returns error to callback")
        JOSEUtil.verifySignature(of: jwsWithInvalidSignature, withKeys: JOSEUtilTests.jwks!) { result in
            XCTAssertEqual(result, .failure(.invalidSignature))
            
            callbackExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testVerifySignatureHandlesJWSWithoutKeyId() {
        let jws = JOSEUtilTests.jwsUtil.createJWS(payload: Data(), keyId: nil)

        let callbackExpectation = expectation(description: "Returns error to callback")
        
        JOSEUtil.verifySignature(of: jws, withKeys: JOSEUtilTests.jwks!) { result in
            XCTAssertEqual(result, .failure(.noKeyId))
            
            callbackExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

    func testVerifySignatureHandlesUnknownKeyId() {
        let jws = JOSEUtilTests.jwsUtil.createJWS(payload: Data(), keyId: "unknown")

        let callbackExpectation = expectation(description: "Returns error to callback")
        
        JOSEUtil.verifySignature(of: jws, withKeys: JOSEUtilTests.jwks!) { result in
            XCTAssertEqual(result, .failure(.unknownKeyId))
            
            callbackExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testVerifySignatureHandlesUnsupportedKeyType() {
        let jws = JOSEUtilTests.jwsUtil.createJWS(payload: Data(), keyId: JOSEUtilTests.keyId)

        let callbackExpectation = expectation(description: "Returns error to callback")
        
        let ecKey = ECPublicKey(crv: .P256, x: "aaa", y: "bbb")
        JOSEUtil.verifySignature(of: jws, withKeys: StaticJWKS(keyId: JOSEUtilTests.keyId, jwk: ecKey)) { result in
            XCTAssertEqual(result, .failure(.unsupportedKeyType))
            
            callbackExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
}

import XCTest
import JOSESwift
@testable import AccountSDKIOSWeb

final class IdTokenValidatorTests: XCTestCase {
    private static let keyId = "test key"
    private static var jwsUtil: JWSUtil!
    
    override class func setUp() {
        jwsUtil = JWSUtil()
    }
    
    func testAcceptsExpectedAMRValue() {
        let amrValue = "test_amr"
        let jwks = StaticJWKS(keyId: IdTokenValidatorTests.keyId, rsaPublicKey: IdTokenValidatorTests.jwsUtil.publicKey)
        let context = IdTokenValidationContext(expectedAMR: amrValue)
        
        let callbackExpectation = expectation(description: "Returns validated claims to callback closure")

        let claims = IdTokenClaims(sub: "userUuid", nonce: nil, amr: [amrValue, "other_value"])
        IdTokenValidator.validate(idToken: IdTokenValidatorTests.jwsUtil.createIdToken(claims: claims, keyId: IdTokenValidatorTests.keyId), jwks: jwks, context: context) { result in
            XCTAssertEqual(result, .success(claims))
            callbackExpectation.fulfill()
        }

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

    func testRejectMissingExpectedAMRInIdTokenWithoutAMR() {
        let jwks = StaticJWKS(keyId: IdTokenValidatorTests.keyId, rsaPublicKey: IdTokenValidatorTests.jwsUtil.publicKey)
        let context = IdTokenValidationContext(expectedAMR: "someValue")
        
        for amr in [nil, [], ["value1", "value2"]] {
            let callbackExpectation = expectation(description: "Returns error to callback closure")

            let claims = IdTokenClaims(sub: "userUuid", nonce: nil, amr: amr)
            IdTokenValidator.validate(idToken: IdTokenValidatorTests.jwsUtil.createIdToken(claims: claims, keyId: IdTokenValidatorTests.keyId), jwks: jwks, context: context) { result in
                XCTAssertEqual(result, .failure(.missingExpectedAMRValue))
                callbackExpectation.fulfill()
            }

            waitForExpectations(timeout: 1) { error in
                if let error = error {
                    XCTFail("waitForExpectationsWithTimeout errored: \(error)")
                }
            }
        }
    }
    
    func testRejectsMismatchingNonce() {
        let jwks = StaticJWKS(keyId: IdTokenValidatorTests.keyId, rsaPublicKey: IdTokenValidatorTests.jwsUtil.publicKey)
        let context = IdTokenValidationContext(nonce: "expected_nonce")

        for nonce in [nil, "mismatching"] {
            let callbackExpectation = expectation(description: "Returns error to callback closure")

            let claims = IdTokenClaims(sub: "userUuid",  nonce: nonce, amr: nil)
            IdTokenValidator.validate(idToken: IdTokenValidatorTests.jwsUtil.createIdToken(claims: claims, keyId: IdTokenValidatorTests.keyId), jwks: jwks, context: context) { result in
                XCTAssertEqual(result, .failure(.invalidNonce))
                callbackExpectation.fulfill()
            }

            waitForExpectations(timeout: 1) { error in
                if let error = error {
                    XCTFail("waitForExpectationsWithTimeout errored: \(error)")
                }
            }
        }
    }
    
    func testAcceptsExpectedNonce() {
        let nonce = "testNonce"
        let jwks = StaticJWKS(keyId: IdTokenValidatorTests.keyId, rsaPublicKey: IdTokenValidatorTests.jwsUtil.publicKey)
        let context = IdTokenValidationContext(nonce: nonce)
        
        let callbackExpectation = expectation(description: "Returns validated claims to callback closure")

        let claims = IdTokenClaims(sub: "userUuid", nonce: nonce, amr: nil)
        IdTokenValidator.validate(idToken: IdTokenValidatorTests.jwsUtil.createIdToken(claims: claims, keyId: IdTokenValidatorTests.keyId), jwks: jwks, context: context) { result in
            XCTAssertEqual(result, .success(claims))
            callbackExpectation.fulfill()
        }

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
}

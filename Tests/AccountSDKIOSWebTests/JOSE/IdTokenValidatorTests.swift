import XCTest
import JOSESwift
@testable import AccountSDKIOSWeb

final class IdTokenValidatorTests: XCTestCase {
    private static let keyId = "test key"
    private static var jwsUtil: JWSUtil!
    
    override class func setUp() {
        jwsUtil = JWSUtil()
    }

    func testRejectMissingExpectedAMRInIdTokenWithoutAMR() {
        let jwks = StaticJWKS(keyId: IdTokenValidatorTests.keyId, rsaPublicKey: IdTokenValidatorTests.jwsUtil.publicKey)
        let context = IdTokenValidationContext(jwks: jwks, expectedAMR: "someValue")
        
        for amr in [nil, [], ["value1", "value2"]] {
            let callbackExpectation = expectation(description: "Returns error to callback closure")

            let claims = IdTokenClaims(sub: "userUuid", amr: amr)
            IdTokenValidator.validate(idToken: IdTokenValidatorTests.jwsUtil.createIdToken(claims: claims, keyId: IdTokenValidatorTests.keyId), context: context) { result in
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
}

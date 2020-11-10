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

        let claims = IdTokenClaims(sub: "userUuid", nonce: nil, amr: [amrValue, "other_value"])
        Await.until { done in
            IdTokenValidator.validate(idToken: IdTokenValidatorTests.jwsUtil.createIdToken(claims: claims, keyId: IdTokenValidatorTests.keyId), jwks: jwks, context: context) { result in
                XCTAssertEqual(result, .success(claims))
                done()
            }
        }
    }

    func testRejectMissingExpectedAMRInIdTokenWithoutAMR() {
        let jwks = StaticJWKS(keyId: IdTokenValidatorTests.keyId, rsaPublicKey: IdTokenValidatorTests.jwsUtil.publicKey)
        let context = IdTokenValidationContext(expectedAMR: "someValue")

        for amr in [nil, [], ["value1", "value2"]] {
            let claims = IdTokenClaims(sub: "userUuid", nonce: nil, amr: amr)
            Await.until { done in
                IdTokenValidator.validate(idToken: IdTokenValidatorTests.jwsUtil.createIdToken(claims: claims, keyId: IdTokenValidatorTests.keyId), jwks: jwks, context: context) { result in
                    XCTAssertEqual(result, .failure(.missingExpectedAMRValue))
                    done()
                }
            }
        }
    }
    
    func testRejectsMismatchingNonce() {
        let jwks = StaticJWKS(keyId: IdTokenValidatorTests.keyId, rsaPublicKey: IdTokenValidatorTests.jwsUtil.publicKey)
        let context = IdTokenValidationContext(nonce: "expected_nonce")

        for nonce in [nil, "mismatching"] {
            let claims = IdTokenClaims(sub: "userUuid",  nonce: nonce, amr: nil)
            Await.until { done in
                IdTokenValidator.validate(idToken: IdTokenValidatorTests.jwsUtil.createIdToken(claims: claims, keyId: IdTokenValidatorTests.keyId), jwks: jwks, context: context) { result in
                    XCTAssertEqual(result, .failure(.invalidNonce))
                    done()
                }
            }
        }
    }
    
    func testAcceptsExpectedNonce() {
        let nonce = "testNonce"
        let jwks = StaticJWKS(keyId: IdTokenValidatorTests.keyId, rsaPublicKey: IdTokenValidatorTests.jwsUtil.publicKey)
        let context = IdTokenValidationContext(nonce: nonce)

        let claims = IdTokenClaims(sub: "userUuid", nonce: nonce, amr: nil)
        Await.until { done in
            IdTokenValidator.validate(idToken: IdTokenValidatorTests.jwsUtil.createIdToken(claims: claims, keyId: IdTokenValidatorTests.keyId), jwks: jwks, context: context) { result in
                XCTAssertEqual(result, .success(claims))
                done()
            }
        }
    }
}

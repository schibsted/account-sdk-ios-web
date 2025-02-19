//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import XCTest
import JOSESwift
@testable import AccountSDKIOSWeb

final class IdTokenValidatorTests: XCTestCase {
    private static let keyId = "test key"
    private static var jwks: JWKS!
    
    override class func setUp() {
        jwks = StaticJWKS(keyId: IdTokenValidatorTests.keyId, rsaPublicKey: Fixtures.jwsUtil.publicKey)
    }
    
    static func createSignedIdToken(claims: IdTokenClaims) -> String {
        return Fixtures.jwsUtil.createIdToken(claims: claims, keyId: IdTokenValidatorTests.keyId)
    }
    
    func testAcceptsValidWithoutAMR() {
        let context = IdTokenValidationContext.from(expectedClaims: Fixtures.idTokenClaims)

        let signedIdToken = IdTokenValidatorTests.createSignedIdToken(claims: Fixtures.idTokenClaims)
        Await.until { done in
            IdTokenValidator.validate(idToken: signedIdToken, jwks: IdTokenValidatorTests.jwks, context: context) { result in
                XCTAssertEqual(result, .success(Fixtures.idTokenClaims))
                done()
            }
        }
    }

    func testAcceptsValidWithExpectedAMRValue() {
        let expectedAMRValue = "test_value"
        let claims = Fixtures.idTokenClaims.copy(amr: OptionalValue([expectedAMRValue, "other_value"]))
        let context = IdTokenValidationContext.from(expectedClaims: claims).copy(expectedAMR: OptionalValue(expectedAMRValue))

        let signedIdToken = IdTokenValidatorTests.createSignedIdToken(claims: claims)
        Await.until { done in
            IdTokenValidator.validate(idToken: signedIdToken, jwks: IdTokenValidatorTests.jwks, context: context) { result in
                XCTAssertEqual(result, .success(claims))
                done()
            }
        }
    }

    func testRejectMissingExpectedAMRInIdTokenWithoutAMR() {
        let context = IdTokenValidationContext.from(expectedClaims: Fixtures.idTokenClaims).copy(expectedAMR: OptionalValue("someValue"))

        for amr in [nil, [], ["value1", "value2"]] {
            let claims = Fixtures.idTokenClaims.copy(amr: OptionalValue(amr))
            let signedIdToken = IdTokenValidatorTests.createSignedIdToken(claims: claims)
            Await.until { done in
                IdTokenValidator.validate(idToken: signedIdToken, jwks: IdTokenValidatorTests.jwks, context: context) { result in
                    XCTAssertEqual(result, .failure(.missingExpectedAMRValue))
                    done()
                }
            }
        }
    }
    
    func testAcceptsDefaultAmrResponseForEidValues() {
        let expectedAMRValue = "eid-se"
        let claims = Fixtures.idTokenClaims.copy(amr: OptionalValue([expectedAMRValue, "other_value"]))
        let context = IdTokenValidationContext.from(expectedClaims: claims)

        let recievedClaims = Fixtures.idTokenClaims.copy(amr: OptionalValue(["eid", "other_value"]))
        let signedIdToken = IdTokenValidatorTests.createSignedIdToken(claims: recievedClaims)

        Await.until { done in
            IdTokenValidator.validate(idToken: signedIdToken, jwks: IdTokenValidatorTests.jwks, context: context) { result in
                XCTAssertEqual(result, .success(recievedClaims))
                done()
            }
        }
    }

    func testRejectsMismatchingNonce() {
        let context = IdTokenValidationContext.from(expectedClaims: Fixtures.idTokenClaims)

        for nonce in [nil, "mismatching"] {
            let claims = Fixtures.idTokenClaims.copy(nonce: OptionalValue(nonce))
            let signedIdToken = IdTokenValidatorTests.createSignedIdToken(claims: claims)
            Await.until { done in
                IdTokenValidator.validate(idToken: signedIdToken, jwks: IdTokenValidatorTests.jwks, context: context) { result in
                    XCTAssertEqual(result, .failure(.invalidNonce))
                    done()
                }
            }
        }
    }

    func testRejectsIncorrectIssuer() {
        let claims = Fixtures.idTokenClaims.copy(iss: "https://issuer.example.com")
        let context = IdTokenValidationContext.from(expectedClaims: claims).copy(issuer: "https://other.example.com")
        
        let signedIdToken = IdTokenValidatorTests.createSignedIdToken(claims: claims)
        Await.until { done in
            IdTokenValidator.validate(idToken: signedIdToken, jwks: IdTokenValidatorTests.jwks, context: context) { result in
                XCTAssertEqual(result, .failure(.invalidIssuer))
                done()
            }
        }
    }
    
    func testAcceptsIssuerWithTrailingSlash() {
        let issuer = "https://issuer.example.com"
        let issuerWithTrailingSlash = issuer + "/"
        let testData = [
            (Fixtures.idTokenClaims.copy(iss: issuer), issuer),
            (Fixtures.idTokenClaims.copy(iss: issuer), issuerWithTrailingSlash),
            (Fixtures.idTokenClaims.copy(iss: issuerWithTrailingSlash), issuer),
            (Fixtures.idTokenClaims.copy(iss: issuerWithTrailingSlash), issuerWithTrailingSlash),
        ]
        
        for (claims, expectedIssuer) in testData {
            let context = IdTokenValidationContext.from(expectedClaims: claims).copy(issuer: expectedIssuer)
            let signedIdToken = IdTokenValidatorTests.createSignedIdToken(claims: claims)
            Await.until { done in
                IdTokenValidator.validate(idToken: signedIdToken, jwks: IdTokenValidatorTests.jwks, context: context) { result in
                    XCTAssertEqual(result, .success(claims))
                    done()
                }
            }
        }
    }
    
    func testRejectsAudienceClaimWithoutExpectedClientId() {
        let context = IdTokenValidationContext.from(expectedClaims: Fixtures.idTokenClaims).copy(clientId: "other_client")
        
        let signedIdToken = IdTokenValidatorTests.createSignedIdToken(claims: Fixtures.idTokenClaims)
        Await.until { done in
            IdTokenValidator.validate(idToken: signedIdToken, jwks: IdTokenValidatorTests.jwks, context: context) { result in
                XCTAssertEqual(result, .failure(.invalidAudience))
                done()
            }
        }
    }
    
    func testRejectsExpiredIdToken() {
        let context = IdTokenValidationContext.from(expectedClaims: Fixtures.idTokenClaims)

        let now = Date().timeIntervalSince1970
        let signedIdToken = IdTokenValidatorTests.createSignedIdToken(claims: Fixtures.idTokenClaims.copy(exp: now - 100))
        Await.until { done in
            IdTokenValidator.validate(idToken: signedIdToken, jwks: IdTokenValidatorTests.jwks, context: context) { result in
                XCTAssertEqual(result, .failure(.expired))
                done()
            }
        }
    }
}

extension IdTokenValidationContext {
    static func from(expectedClaims claims: IdTokenClaims) -> IdTokenValidationContext {
        return IdTokenValidationContext(issuer: claims.iss,
                                        clientId: claims.aud[0],
                                        nonce: claims.nonce,
                                        expectedAMR: claims.amr.map { $0[0] } ?? nil)
    }

    func copy(issuer: String? = nil, clientId: String? = nil, nonce: OptionalValue<String>? = nil, expectedAMR: OptionalValue<String>? = nil) -> IdTokenValidationContext {
        return IdTokenValidationContext(issuer: issuer ?? self.issuer,
                                        clientId: clientId ?? self.clientId,
                                        nonce: nonce.map { $0.value } ?? self.nonce,
                                        expectedAMR: expectedAMR.map { $0.value } ?? self.expectedAMR)
    }
}

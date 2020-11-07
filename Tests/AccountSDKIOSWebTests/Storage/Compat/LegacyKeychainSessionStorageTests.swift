import XCTest
import Cuckoo
@testable import AccountSDKIOSWeb

final class LegacyKeychainSessionStorageTests: XCTestCase {
    private static var jwsUtil: JWSUtil!
    
    override class func setUp() {
        jwsUtil = JWSUtil()
    }
    
    func testGetWithoutLegacyTokenData() {
        let mockTokenStorage = MockLegacyKeychainTokenStorage()
        stub(mockTokenStorage) { mock in
            when(mock.get()).thenReturn([])
        }
        
        XCTAssertNil(LegacyKeychainSessionStorage(storage: mockTokenStorage).get(forClientId: "testClient"))
    }
    
    func testGetLegacyTokenDataMappedToUserSession() throws {
        let clientId = "client1"
        let sub = "userUuid"
        let iat: Double = 1000
        let nonce = "testNonce"
        let legacyTokenData = try createLegacyTokenData(clientId: clientId, sub: sub, iat: iat, nonce: nonce)

        let mockTokenStorage = MockLegacyKeychainTokenStorage()
        stub(mockTokenStorage) { mock in
            when(mock.get()).thenReturn([legacyTokenData])
        }

        let result = LegacyKeychainSessionStorage(storage: mockTokenStorage).get(forClientId: clientId)
        XCTAssertEqual(result?.clientId, clientId)
        XCTAssertEqual(result?.updatedAt, Date(timeIntervalSince1970: iat))
        XCTAssertEqual(result?.userTokens.accessToken, legacyTokenData.accessToken)
        XCTAssertEqual(result?.userTokens.idToken, legacyTokenData.idToken)
        XCTAssertEqual(result?.userTokens.refreshToken, legacyTokenData.refreshToken)
        XCTAssertEqual(result?.userTokens.idTokenClaims, IdTokenClaims(sub: sub, nonce: nonce, amr: nil))
    }
    
    func testGetReturnsNewestTokens() throws {
        let clientId = "client1"
        let oldestTokenData = try createLegacyTokenData(clientId: clientId, sub: "user1", iat: 1, nonce: "nonce1")
        let newestTokenData = try createLegacyTokenData(clientId: clientId, sub: "user1", iat: 10, nonce: "nonce2")

        let mockTokenStorage = MockLegacyKeychainTokenStorage()
        stub(mockTokenStorage) { mock in
            when(mock.get()).thenReturn([oldestTokenData, newestTokenData])
        }

        let result = LegacyKeychainSessionStorage(storage: mockTokenStorage).get(forClientId: clientId)
        XCTAssertEqual(result?.clientId, clientId)
        XCTAssertEqual(result?.updatedAt, Date(timeIntervalSince1970: 10))
        XCTAssertEqual(result?.userTokens.accessToken, newestTokenData.accessToken)
        XCTAssertEqual(result?.userTokens.idToken, newestTokenData.idToken)
        XCTAssertEqual(result?.userTokens.refreshToken, newestTokenData.refreshToken)
        XCTAssertEqual(result?.userTokens.idTokenClaims, IdTokenClaims(sub: "user1", nonce: "nonce2", amr: nil))
    }
    
    func testGetDiscardsTokenForOtherClient() throws {
        let legacyTokenData = try createLegacyTokenData(clientId: "client1", sub: "userUuid", iat: 10, nonce: "testNonce")
        let mockTokenStorage = MockLegacyKeychainTokenStorage()
        stub(mockTokenStorage) { mock in
            when(mock.get()).thenReturn([legacyTokenData])
        }

        XCTAssertNil(LegacyKeychainSessionStorage(storage: mockTokenStorage).get(forClientId: "otherClient"))
    }
    
    private func createLegacyTokenData(clientId: String, sub: String, iat: Double, nonce: String) throws -> LegacyTokenData {
        let accessTokenData = try JSONSerialization.data(withJSONObject: ["client_id": clientId])
        let accessToken = LegacyKeychainSessionStorageTests.jwsUtil.createJWS(payload: accessTokenData, keyId: "testKeyId")

        let idTokenData = try JSONSerialization.data(withJSONObject: ["sub": sub, "iat": iat, "nonce": nonce])
        let idToken = LegacyKeychainSessionStorageTests.jwsUtil.createJWS(payload: idTokenData, keyId: "testKeyId")

        return LegacyTokenData(accessToken: accessToken, refreshToken: "refreshToken1", idToken: idToken)
    }
}

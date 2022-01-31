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
        let legacyTokenData = try createLegacyTokenData(clientId: clientId)

        let mockTokenStorage = MockLegacyKeychainTokenStorage()
        stub(mockTokenStorage) { mock in
            when(mock.get()).thenReturn([legacyTokenData])
        }

        let result = LegacyKeychainSessionStorage(storage: mockTokenStorage).get(forClientId: clientId)
        XCTAssertEqual(result?.clientId, clientId)
        XCTAssertEqual(result?.accessToken, legacyTokenData.accessToken)
        XCTAssertEqual(result?.refreshToken, legacyTokenData.refreshToken)
    }
    
    func testGetReturnsNewestTokens() throws {
        let clientId = "client1"
        let oldestTokenData = try createLegacyTokenData(clientId: clientId)
        let newestTokenData = try createLegacyTokenData(clientId: clientId)

        let mockTokenStorage = MockLegacyKeychainTokenStorage()
        stub(mockTokenStorage) { mock in
            when(mock.get()).thenReturn([oldestTokenData, newestTokenData])
        }

        let result = LegacyKeychainSessionStorage(storage: mockTokenStorage).get(forClientId: clientId)
        XCTAssertEqual(result?.clientId, clientId)
        XCTAssertEqual(result?.accessToken, newestTokenData.accessToken)
        XCTAssertEqual(result?.refreshToken, newestTokenData.refreshToken)
    }
    
    func testGetDiscardsTokenForOtherClient() throws {
        let legacyTokenData = try createLegacyTokenData(clientId: "client1")
        let mockTokenStorage = MockLegacyKeychainTokenStorage()
        stub(mockTokenStorage) { mock in
            when(mock.get()).thenReturn([legacyTokenData])
        }

        XCTAssertNil(LegacyKeychainSessionStorage(storage: mockTokenStorage).get(forClientId: "otherClient"))
    }
    
    private func createLegacyTokenData(clientId: String) throws -> LegacyTokenData {
        let accessTokenData = try JSONSerialization.data(withJSONObject: ["client_id": clientId])
        let accessToken = LegacyKeychainSessionStorageTests.jwsUtil.createJWS(payload: accessTokenData, keyId: "testKeyId")

        return LegacyTokenData(accessToken: accessToken, refreshToken: "refreshToken1")
    }
}

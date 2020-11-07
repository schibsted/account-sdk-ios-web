import XCTest
import Cuckoo
@testable import AccountSDKIOSWeb

final class LegacyKeychainSessionStorageTests: XCTestCase {
    func testGetWithoutLegacyTokenData() {
        let mockTokenStorage = MockLegacyKeychainTokenStorage()
        stub(mockTokenStorage) { mock in
            when(mock.get()).thenReturn([])
        }
        
        XCTAssertNil(LegacyKeychainSessionStorage(storage: mockTokenStorage).get())
    }
    
    func testGetLegacyTokenData() {
        let tokenData = LegacyTokenData(accessToken: "accessToken1", refreshToken: "refreshToken1", idToken: "idToken1")
        let mockTokenStorage = MockLegacyKeychainTokenStorage()
        stub(mockTokenStorage) { mock in
            when(mock.get()).thenReturn([tokenData])
        }
        
        XCTAssertEqual(LegacyKeychainSessionStorage(storage: mockTokenStorage).get(), tokenData)
    }
}

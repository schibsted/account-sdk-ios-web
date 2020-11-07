import XCTest
@testable import AccountSDKIOSWeb

final class LegacyKeychainTokenStorageTests: XCTestCase {
    let defaultQuery: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: "swift.keychain.service",
        kSecAttrAccount as String: "SchibstedID"
    ]

    override func tearDown() {
        SecItemDelete(defaultQuery as CFDictionary)
    }
    
    func testNoExistingLegacyData() {
        let keychainStorage = LegacyKeychainTokenStorage()
        XCTAssertEqual(keychainStorage.get(), [])
    }

    func testIncorrectlySerialisedData() {
        var query: [String: Any] = defaultQuery
        query[kSecValueData as String] = "invalid_data".data(using: .utf8)
        SecItemAdd(query as CFDictionary, nil)

        let keychainStorage = LegacyKeychainTokenStorage()
        XCTAssertEqual(keychainStorage.get(), [])
    }
    
    func testSerialisedInvalidData() {
        var query: [String: Any] = defaultQuery
        query[kSecValueData as String] = NSKeyedArchiver.archivedData(withRootObject: ["key": "value"])
        SecItemAdd(query as CFDictionary, nil)

        let keychainStorage = LegacyKeychainTokenStorage()
        XCTAssertEqual(keychainStorage.get(), [])
    }
    
    func testExistingLegacyData() {
        let tokens = [
            "accessToken1": [
                "refresh_token": "refreshToken1",
                "id_token": "idToken1"
            ],
            "accessToken2": [
                "refresh_token": "refreshToken2",
                "id_token": "idToken2"
            ]
        ]
        let data = NSKeyedArchiver.archivedData(withRootObject: ["logged_in_users": tokens])
        var query: [String: Any] = defaultQuery
        query[kSecValueData as String] = data
        SecItemAdd(query as CFDictionary, nil)

        XCTAssertEqual(LegacyKeychainTokenStorage().get(), [
            LegacyTokenData(accessToken: "accessToken1", refreshToken: "refreshToken1", idToken: "idToken1"),
            LegacyTokenData(accessToken: "accessToken2", refreshToken: "refreshToken2", idToken: "idToken2"),
        ])
    }
    
    func testExistingLegacyDataWithoutRefreshTokenIsIgnored() {
        let tokens = [
            "accessToken1": [
                "refresh_token": "refreshToken1",
                "id_token": "idToken1"
            ],
            "accessToken2": [
                "id_token": "idToken2"
            ]
        ]
        let data = NSKeyedArchiver.archivedData(withRootObject: ["logged_in_users": tokens])
        var query: [String: Any] = defaultQuery
        query[kSecValueData as String] = data
        SecItemAdd(query as CFDictionary, nil)

        XCTAssertEqual(LegacyKeychainTokenStorage().get(), [
            LegacyTokenData(accessToken: "accessToken1", refreshToken: "refreshToken1", idToken: "idToken1")
        ])
    }
    
    func testExistingLegacyDataWithoutIdTokenIsIgnored() {
        let tokens = [
            "accessToken1": [
                "refresh_token": "refreshToken1",
                "id_token": "idToken1"
            ],
            "accessToken2": [
                "refresh_token": "refreshToken2"
            ]
        ]
        let data = NSKeyedArchiver.archivedData(withRootObject: ["logged_in_users": tokens])
        var query: [String: Any] = defaultQuery
        query[kSecValueData as String] = data
        SecItemAdd(query as CFDictionary, nil)

        XCTAssertEqual(LegacyKeychainTokenStorage().get(), [
            LegacyTokenData(accessToken: "accessToken1", refreshToken: "refreshToken1", idToken: "idToken1")
        ])
    }
    
    func testRemove() {
        let tokens = [
            "accessToken1": [
                "refresh_token": "refreshToken1",
                "id_token": "idToken1"
            ]
        ]
        let data = NSKeyedArchiver.archivedData(withRootObject: ["logged_in_users": tokens])
        var query: [String: Any] = defaultQuery
        query[kSecValueData as String] = data
        SecItemAdd(query as CFDictionary, nil)

        let keychainStorage = LegacyKeychainTokenStorage()
        XCTAssertEqual(LegacyKeychainTokenStorage().get(), [
            LegacyTokenData(accessToken: "accessToken1", refreshToken: "refreshToken1", idToken: "idToken1")
        ])
        keychainStorage.remove()
        XCTAssertEqual(keychainStorage.get(), [])
    }
}

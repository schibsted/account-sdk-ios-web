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
        query[kSecValueData as String] = try? NSKeyedArchiver.archivedData(withRootObject: ["key": "value"], requiringSecureCoding: false)
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
        let data = try? NSKeyedArchiver.archivedData(withRootObject: ["logged_in_users": tokens], requiringSecureCoding: false)
        var query: [String: Any] = defaultQuery
        query[kSecValueData as String] = data
        SecItemAdd(query as CFDictionary, nil)

        let tokenDataArray = LegacyKeychainTokenStorage().get()
        XCTAssertEqual(tokenDataArray.count, 2)
        XCTAssertTrue(tokenDataArray.contains(LegacyTokenData(accessToken: "accessToken2", refreshToken: "refreshToken2", idToken: "idToken2")))
        XCTAssertTrue(tokenDataArray.contains(LegacyTokenData(accessToken: "accessToken1", refreshToken: "refreshToken1", idToken: "idToken1")))
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
        let data = try? NSKeyedArchiver.archivedData(withRootObject: ["logged_in_users": tokens], requiringSecureCoding: false)
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
        let data = try? NSKeyedArchiver.archivedData(withRootObject: ["logged_in_users": tokens], requiringSecureCoding: false)
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
        let data = try? NSKeyedArchiver.archivedData(withRootObject: ["logged_in_users": tokens], requiringSecureCoding: false)
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
    
    func testSettingLegacyToken() {
        
        let tokenDictionary: [String : Any] = [
            "accessToken": "foo",
            "refreshToken": "bar",
            "idToken": [
                "string": "foo-bar"
            ],
            "userID": "foobar"
        ]
        
        guard let data = try? JSONSerialization.data(withJSONObject: tokenDictionary, options: []) else {
            XCTFail("Cannot serialize test input")
            return
        }
        
        let keychainStorage = LegacyKeychainTokenStorage()
        do {
            try keychainStorage.set(legacySDKtokenData: data)
        } catch (let error) {
            XCTFail("Cannot set legacy token data in keychain \(error.localizedDescription)")
        }
        
        XCTAssertEqual(LegacyKeychainTokenStorage().get(), [
            LegacyTokenData(accessToken: "foo", refreshToken: "bar", idToken: "foo-bar")
        ])
    }
    
    func testSettingIncorrectLegacyToken() {
        
        let tokenDictionary: [String : Any] = [
            "accessToken": "foo",
            "refreshToken": "bar",
            "userID": "foobar"
        ]
        
        guard let data = try? JSONSerialization.data(withJSONObject: tokenDictionary, options: []) else {
            XCTFail("Cannot serialize test input")
            return
        }
        
        let keychainStorage = LegacyKeychainTokenStorage()
        do {
            try keychainStorage.set(legacySDKtokenData: data)
        } catch (let error) {
            XCTAssertEqual(KeychainStorageError.storeError, error as! KeychainStorageError)
        }
    }
}

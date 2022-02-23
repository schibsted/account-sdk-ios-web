import XCTest
@testable import AccountSDKIOSWeb

final class LegacyKeychainTokenStorageTests: XCTestCase {
    
    var keychainMock: KeychainStoring?
    let accountString = "SchibstedID"
    
    override func setUp() {
        self.keychainMock = KeychainStorageMock()
    }
    
    func testNoExistingLegacyData() {
        let keychainStorage = LegacyKeychainTokenStorage(keychain: keychainMock!)
        XCTAssertEqual(keychainStorage.get(), [])
    }

    func testIncorrectlySerialisedData() {
        let testData = "invalid_data".data(using: .utf8)
        try? self.keychainMock!.setValue(testData!, forAccount: nil, accessGroup: nil)
        XCTAssertEqual(self.keychainMock!.getAll().count, 1)

        let keychainStorage = LegacyKeychainTokenStorage(keychain: keychainMock!)
        XCTAssertEqual(keychainStorage.get(), [])
    }
    
    func testSerialisedInvalidData() {
        let testData = try? NSKeyedArchiver.archivedData(withRootObject: ["key": "value"], requiringSecureCoding: false)
        try? self.keychainMock!.setValue(testData!, forAccount: nil, accessGroup: nil)
        XCTAssertEqual(self.keychainMock!.getAll().count, 1)
        
        let keychainStorage = LegacyKeychainTokenStorage(keychain: keychainMock!)
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
        try? self.keychainMock!.setValue(data!, forAccount: accountString, accessGroup: nil)
        XCTAssertEqual(self.keychainMock!.getAll().count, 1)

        let tokenDataArray = LegacyKeychainTokenStorage(keychain: keychainMock!).get()
        XCTAssertEqual(tokenDataArray.count, 2)
        XCTAssertTrue(tokenDataArray.contains(LegacyTokenData(accessToken: "accessToken2", refreshToken: "refreshToken2")))
        XCTAssertTrue(tokenDataArray.contains(LegacyTokenData(accessToken: "accessToken1", refreshToken: "refreshToken1")))
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
        try? self.keychainMock!.setValue(data!, forAccount: accountString, accessGroup: nil)
        XCTAssertEqual(self.keychainMock!.getAll().count, 1)

        XCTAssertEqual(LegacyKeychainTokenStorage(keychain: keychainMock!).get(), [
            LegacyTokenData(accessToken: "accessToken1", refreshToken: "refreshToken1")
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
        try? self.keychainMock!.setValue(data!, forAccount: accountString, accessGroup: nil)
        XCTAssertEqual(self.keychainMock!.getAll().count, 1)

        let keychainStorage = LegacyKeychainTokenStorage(keychain: keychainMock!)
        XCTAssertEqual(keychainStorage.get(), [
            LegacyTokenData(accessToken: "accessToken1", refreshToken: "refreshToken1")
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
            
            let keychainStorage = LegacyKeychainTokenStorage(keychain: keychainMock!)
            do {
                try keychainStorage.set(legacySDKtokenData: data)
            } catch (let error) {
                XCTFail("Cannot set legacy token data in keychain \(error.localizedDescription)")
            }
            
            XCTAssertEqual(keychainStorage.get(), [
                LegacyTokenData(accessToken: "foo", refreshToken: "bar")
            ])
        }
        
        func testSettingIncorrectLegacyToken() {
            
            let tokenDictionary: [String : Any] = [
                "accessToken": "foo",
                "refreshToken": "bar",
                "userID": "foobar"
            ]
            
            let expectation = self.expectation(description: "Saving token with incorrect format throws KeychainStorageError")
            
            guard let data = try? JSONSerialization.data(withJSONObject: tokenDictionary, options: []) else {
                XCTFail("Cannot serialize test input")
                return
            }
            
            let keychainStorage = LegacyKeychainTokenStorage(keychain: keychainMock!)
            do {
                try keychainStorage.set(legacySDKtokenData: data)
            } catch (let error) {
                XCTAssertEqual(KeychainStorageError.storeError(reason: .invalidData), error as! KeychainStorageError)
                expectation.fulfill()
            }
            self.waitForExpectations(timeout: 0.5, handler: nil)
        }
}

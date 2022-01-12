import XCTest
import Cuckoo
@testable import AccountSDKIOSWeb

final class SharedKeychainSessionStorageFactoryTests: XCTestCase {
    
    let accessGroup = "com.foo.bar"
    let sharedAccessGroup = "AZWSDFGHIJ.com.schibsted.simplifiedLogin"
    
    func testReturnsAppKeychainWhenNoAppIdentifierIsProvided() {
        let keychain = SharedKeychainSessionStorageFactory().makeKeychain(clientId: "client_id", service: "service_name", accessGroup: nil, appIdentifierPrefix: nil)
        
        XCTAssertEqual(keychain.accessGroup, nil)
    }
    
    func testReturnsAppKeychainWhenEntitlementIsMissing() {
        let keychain = SharedKeychainSessionStorageFactory().makeKeychain(clientId: "client_id", service: "service_name", accessGroup: accessGroup, appIdentifierPrefix: "AZWSDFGHIJ")
        
        XCTAssertEqual(keychain.accessGroup, accessGroup)
    }
    
    func testReturnsSharedKeychainWhenEntitlementExist() {
        let keychainSessionStorageMock = MockKeychainSessionStorage(service: "service_name", accessGroup: sharedAccessGroup)
        stub(keychainSessionStorageMock) { mock in
            when(mock.checkEntitlements()).then { _ in
                return Data()
            }
            when(mock.getAll()).then { _ in
                return []
            }
        }
        
        let keychain = SharedKeychainSessionStorageFactory(keychain: nil, sharedKeychain: keychainSessionStorageMock).makeKeychain(clientId: "client_id", service: "service_name", accessGroup: accessGroup, appIdentifierPrefix: "AZWSDFGHIJ")
        
        XCTAssertIdentical(keychain, keychainSessionStorageMock)
        verify(keychainSessionStorageMock).checkEntitlements()
    }
    
    func testReturnsSharedKeychainWithoutMigrationWhenNonEmpty() {
        let userSession = UserSession(clientId: "client_id", userTokens: Fixtures.userTokens, updatedAt: Date())
        let sharedKeychainSessionStorageMock = MockKeychainSessionStorage(service: "service_name", accessGroup: sharedAccessGroup)
        stub(sharedKeychainSessionStorageMock) { mock in
            when(mock.checkEntitlements()).then { _ in
                return Data()
            }
            when(mock.getAll()).then { _ in
                return [userSession]
            }
        }
        let keychainSessionStorageMock = MockKeychainSessionStorage(service: "service_name", accessGroup: accessGroup)
        stub(keychainSessionStorageMock) { mock in
            when(mock.get(forClientId: "client_id", completion: anyClosure()))
                .then { _, completion in
                    completion(userSession)
                }
        }
        
        let keychain = SharedKeychainSessionStorageFactory(keychain: keychainSessionStorageMock, sharedKeychain: sharedKeychainSessionStorageMock).makeKeychain(clientId: "client_id", service: "service_name", accessGroup: accessGroup, appIdentifierPrefix: "AZWSDFGHIJ")
        
        XCTAssertIdentical(keychain, sharedKeychainSessionStorageMock)
        verify(sharedKeychainSessionStorageMock).checkEntitlements()
        verify(sharedKeychainSessionStorageMock).getAll()
        verify(sharedKeychainSessionStorageMock, never()).store(any(), accessGroup: sharedAccessGroup, completion: anyClosure())
    }
    
    func testReturnsSharedKeychainWithUpdatedAccessGroupForItem() {
        let userSession = UserSession(clientId: "client_id", userTokens: Fixtures.userTokens, updatedAt: Date())
        let sharedKeychainSessionStorageMock = MockKeychainSessionStorage(service: "service_name", accessGroup: sharedAccessGroup)
        stub(sharedKeychainSessionStorageMock) { mock in
            when(mock.checkEntitlements()).then { _ in
                return Data()
            }
            when(mock.store(any(), accessGroup: sharedAccessGroup, completion: anyClosure()))
                .then { _, _, completion in
                    completion(.success())
                }
            when(mock.getAll()).then { _ in
                return []
            }
        }
        let keychainSessionStorageMock = MockKeychainSessionStorage(service: "service_name", accessGroup: accessGroup)
        stub(keychainSessionStorageMock) { mock in
            when(mock.get(forClientId: "client_id", completion: anyClosure()))
                .then { _, completion in
                    completion(userSession)
                }
        }
        
        let keychain = SharedKeychainSessionStorageFactory(keychain: keychainSessionStorageMock, sharedKeychain: sharedKeychainSessionStorageMock).makeKeychain(clientId: "client_id", service: "service_name", accessGroup: accessGroup, appIdentifierPrefix: "AZWSDFGHIJ")
        
        XCTAssertIdentical(keychain, sharedKeychainSessionStorageMock)
        verify(sharedKeychainSessionStorageMock).checkEntitlements()
        verify(sharedKeychainSessionStorageMock).store(any(), accessGroup: sharedAccessGroup, completion: anyClosure())
        verify(keychainSessionStorageMock).get(forClientId: "client_id", completion: anyClosure())
    }
    
}

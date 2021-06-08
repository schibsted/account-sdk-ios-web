import XCTest
import Cuckoo
@testable import AccountSDKIOSWeb

final class MigratingKeychainCompatStorageTests: XCTestCase {
    func testStoreOnlyWritesToNewStorage() {
        let userSession = UserSession(clientId: "client1", userTokens: Fixtures.userTokens, updatedAt: Date())
        
        let legacyStorage = MockLegacyKeychainSessionStorage()
        let newStorage = MockKeychainSessionStorage(service: "test")
        stub(newStorage) { mock in
            when(mock.store(equal(to: userSession))).thenDoNothing()
        }

        let migratingStorage = MigratingKeychainCompatStorage(from: legacyStorage, to: newStorage)
        migratingStorage.store(userSession)

        verify(newStorage).store(equal(to: userSession))
        verifyNoMoreInteractions(legacyStorage)
    }

    func testGetAllOnlyReadsNewStorage() {
        let userSession = UserSession(clientId: "client1", userTokens: Fixtures.userTokens, updatedAt: Date())

        let legacyStorage = MockLegacyKeychainSessionStorage()
        let newStorage = MockKeychainSessionStorage(service: "test")
        stub(newStorage) { mock in
            when(mock.getAll()).thenReturn([userSession])
        }

        let migratingStorage = MigratingKeychainCompatStorage(from: legacyStorage, to: newStorage)
        migratingStorage.getAll()

        verify(newStorage).getAll()
        verifyNoMoreInteractions(legacyStorage)
    }
    
    func testRemoveOnlyRemovesFromNewStorage() {
        let clientId = "client1"

        let legacyStorage = MockLegacyKeychainSessionStorage()
        let newStorage = MockKeychainSessionStorage(service: "test")
        stub(newStorage) { mock in
            when(mock.remove(forClientId: equal(to: clientId))).thenDoNothing()
        }

        let migratingStorage = MigratingKeychainCompatStorage(from: legacyStorage, to: newStorage)
        migratingStorage.remove(forClientId: clientId)

        verify(newStorage).remove(forClientId: equal(to: clientId))
        verifyNoMoreInteractions(legacyStorage)
    }

    func testGetPrefersNewStorage() {
        let clientId = "client1"
        let userSession = UserSession(clientId: clientId, userTokens: Fixtures.userTokens, updatedAt: Date())

        let legacyStorage = MockLegacyKeychainSessionStorage()
        let newStorage = MockKeychainSessionStorage(service: "test")
        stub(newStorage) { mock in
            when(mock.get(forClientId: equal(to: clientId))).thenReturn(userSession)
        }

        let migratingStorage = MigratingKeychainCompatStorage(from: legacyStorage, to: newStorage)
        XCTAssertEqual(migratingStorage.get(forClientId: clientId), userSession)

        verify(newStorage).get(forClientId: equal(to: clientId))
        verifyNoMoreInteractions(legacyStorage)
    }

    func testGetMigratesExistingLegacySession() {
        let clientId = "client1"
        let legacyUserSession = UserSession(clientId: clientId, userTokens: Fixtures.userTokens, updatedAt: Date())

        let legacyStorage = MockLegacyKeychainSessionStorage()
        stub(legacyStorage) { mock in
            when(mock.get(forClientId: equal(to: clientId))).thenReturn(legacyUserSession)
            when(mock.remove()).thenDoNothing()
        }
        let newStorage = MockKeychainSessionStorage(service: "test")
        stub(newStorage) { mock in
            when(mock.get(forClientId: equal(to: clientId))).thenReturn(nil)
            when(mock.store(equal(to: legacyUserSession))).thenDoNothing()
        }

        let migratingStorage = MigratingKeychainCompatStorage(from: legacyStorage, to: newStorage)
        XCTAssertEqual(migratingStorage.get(forClientId: clientId), legacyUserSession)

        verify(newStorage).get(forClientId: equal(to: clientId))
        verify(legacyStorage).get(forClientId: equal(to: clientId))
        verify(newStorage).store(equal(to: legacyUserSession))
        verify(legacyStorage).remove()
    }

    func testGetReturnsNilIfNoSessionExists() {
        let clientId = "client1"

        let legacyStorage = MockLegacyKeychainSessionStorage()
        stub(legacyStorage) { mock in
            when(mock.get(forClientId: equal(to: clientId))).thenReturn(nil)
        }
        let newStorage = MockKeychainSessionStorage(service: "test")
        stub(newStorage) { mock in
            when(mock.get(forClientId: equal(to: clientId))).thenReturn(nil)
        }

        let migratingStorage = MigratingKeychainCompatStorage(from: legacyStorage, to: newStorage)
        XCTAssertNil(migratingStorage.get(forClientId: clientId))

        verify(newStorage).get(forClientId: equal(to: clientId))
        verify(legacyStorage).get(forClientId: clientId)
    }
}

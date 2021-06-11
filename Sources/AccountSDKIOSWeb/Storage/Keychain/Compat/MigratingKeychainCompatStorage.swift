import Foundation

class MigratingKeychainCompatStorage: SessionStorage {
    private let newStorage: KeychainSessionStorage
    private let legacyStorage: LegacyKeychainSessionStorage

    init(from: LegacyKeychainSessionStorage, to: KeychainSessionStorage) {
        self.newStorage = to
        self.legacyStorage = from
    }
    
    func store(_ value: UserSession) {
        // only delegate to new storage; no need to store in legacy storage
        newStorage.store(value)
    }
    
    func get(forClientId: String) -> UserSession? {
        // try new storage first
        if let session = newStorage.get(forClientId: forClientId) {
            return session
        }

        // if no existing session found, look in legacy storage
        guard let legacySession = legacyStorage.get(forClientId: forClientId) else {
            return nil
        }

        newStorage.store(legacySession)
        legacyStorage.remove()

        return legacySession
    }
    
    func getAll() -> [UserSession] {
        // only delegate to new storage; this functionality is not supported by legacyStorage
        return newStorage.getAll()
    }
    
    func remove(forClientId: String) {
        // only delegate to new storage; data should have already been removed from legacy storage during migration
        newStorage.remove(forClientId: forClientId)
    }
}


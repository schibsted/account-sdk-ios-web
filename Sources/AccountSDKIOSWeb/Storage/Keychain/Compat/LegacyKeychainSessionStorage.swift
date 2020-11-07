import Foundation

class LegacyKeychainSessionStorage {
    private let storage: LegacyKeychainTokenStorage
    
    init(storage: LegacyKeychainTokenStorage) {
        self.storage = storage
    }

    func get() -> LegacyTokenData? {
        // TODO return the newest token (based on 'iat' claim in ID Token) instead?
        // TODO ensure tokens are for the expected client?
        return storage.get().first
    }
}

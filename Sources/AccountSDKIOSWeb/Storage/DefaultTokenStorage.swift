import Foundation

internal struct DefaultTokenStorage {
    static var storage: TokenStorage = KeychainTokenStorage(service: "com.schibsted.account")
    
    static func store(_ value: StoredUserTokens) {
        storage.store(value)
    }
    
    static func get() -> StoredUserTokens? {
        return storage.get()
    }
    
    static func remove() {
        storage.remove()
    }
}

internal class KeychainTokenStorage: TokenStorage {
    private let keychain: KeychainStorage
    
    init(service: String) {
        self.keychain = KeychainStorage(forService: service)
    }
    
    func store(_ value: StoredUserTokens) {
        guard let tokenData = try? JSONEncoder().encode(value) else {
             fatalError("Failed to JSON encode user tokens for storage")
        }
        
        keychain.addValue(tokenData)
    }

    func get() -> StoredUserTokens? {
        guard let data = keychain.getValue(),
              let tokenData = try? JSONDecoder().decode(StoredUserTokens.self, from: data) else {
            return nil
        }
        return tokenData
    }

    func remove() {
        keychain.removeValue()
    }
}

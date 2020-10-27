import Foundation

internal struct DefaultSessionStorage {
    static var storage: SessionStorage = KeychainSessionStorage(service: "com.schibsted.account")
    
    static func store(_ value: UserSession) {
        storage.store(value)
    }
    
    static func get(forClientId: String) -> UserSession? {
        return storage.get(forClientId: forClientId)
    }
    
    /** Returns all user sessions, sorted with most recent session first.
     */
    static func getAll() -> [UserSession] {
        return storage.getAll().sorted { $0.updatedAt > $1.updatedAt }
    }
    
    static func remove(forClientId: String) {
        storage.remove(forClientId: forClientId)
    }
}

internal class KeychainSessionStorage: SessionStorage {
    private let keychain: KeychainStorage
    
    init(service: String) {
        self.keychain = KeychainStorage(forService: service)
    }
    
    func store(_ value: UserSession) {
        guard let tokenData = try? JSONEncoder().encode(value) else {
             fatalError("Failed to JSON encode user tokens for storage")
        }
        
        keychain.addValue(tokenData, forAccount: value.clientId)
    }

    func get(forClientId: String) -> UserSession? {
        guard let data = keychain.getValue(forAccount: forClientId),
              let tokenData = try? JSONDecoder().decode(UserSession.self, from: data) else {
            return nil
        }
        return tokenData
    }
    
    func getAll() -> [UserSession] {
        let data = keychain.getAll()
        return data.compactMap { try? JSONDecoder().decode(UserSession.self, from: $0) }
    }

    func remove(forClientId: String) {
        keychain.removeValue(forAccount: forClientId)
    }
}

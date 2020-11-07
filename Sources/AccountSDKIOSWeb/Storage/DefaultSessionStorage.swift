import Foundation

public struct DefaultSessionStorage {
    static var storage: SessionStorage = KeychainSessionStorage(service: "com.schibsted.account")
    
    public static func useAccessGroup(_ accessGroup: String) {
        storage = KeychainSessionStorage(service: "com.schibsted.account", accessGroup: accessGroup)
    }
    
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


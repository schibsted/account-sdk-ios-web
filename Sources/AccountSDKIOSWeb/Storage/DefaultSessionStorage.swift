import Foundation

public struct DefaultSessionStorage {
    private static let service = "com.schibsted.account"
    static var storage: SessionStorage = KeychainSessionStorage(service: service)
    
    public static func useAccessGroup(_ accessGroup: String) {
        storage = KeychainSessionStorage(service: service, accessGroup: accessGroup)
    }
    
    public static func withLegacyCompat(legacyAccessGroup: String? = nil, newAccessGroup: String? = nil) {
        storage = MigratingKeychainCompatStorage(from: LegacyKeychainSessionStorage(storage: LegacyKeychainTokenStorage(accessGroup: legacyAccessGroup)),
                                                 to: KeychainSessionStorage(service: service, accessGroup: newAccessGroup))
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


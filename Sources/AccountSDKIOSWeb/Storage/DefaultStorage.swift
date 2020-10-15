import Foundation

internal struct DefaultStorage {
    static var storage: Storage = UserDefaultsStorage(UserDefaults.standard)
    
    static func setValue<T : Codable> (_ value: T?, forKey key: String) -> Bool {
        if let encoded = try? JSONEncoder().encode(value) {
            storage.setValue(encoded, forKey: key)
            return true
        }

        return false
    }

    static func value<T : Codable>(forKey key: String) -> T? {
        if let storedData = storage.value(forKey: key) as? Data,
           let deserialised = try? JSONDecoder().decode(T.self, from: storedData) {
            return deserialised
        }

        return nil;
    }
    
    static func removeValue(forKey key: String) {
        storage.removeValue(forKey: key)
    }   
}

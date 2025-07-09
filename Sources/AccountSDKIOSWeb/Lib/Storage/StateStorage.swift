//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

final class StateStorage: Sendable {
    private let storage: Storage

    init(storage: Storage = UserDefaultsStorage(UserDefaults.standard)) {
        self.storage = storage
    }

    func setValue<T: Codable> (_ value: T?, forKey key: String) -> Bool {
        if let encoded = try? JSONEncoder().encode(value) {
            storage.setValue(encoded, forKey: key)
            return true
        }

        return false
    }

    func value<T: Codable>(forKey key: String) -> T? {
        if let storedData = storage.value(forKey: key),
           let deserialised = try? JSONDecoder().decode(T.self, from: storedData) {
            return deserialised
        }

        return nil
    }

    func removeValue(forKey key: String) {
        storage.removeValue(forKey: key)
    }
}

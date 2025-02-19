//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

internal struct UserDefaultsStorage: Storage {
    static let keyPrefix = "com.schibsted.account"
    private let storage: UserDefaults

    init(_ storage: UserDefaults) {
        self.storage = storage
    }

    func setValue(_ value: Data, forKey key: String) {
        storage.setValue(value, forKey: type(of: self).addPrefix(toKey: key))
    }

    func value(forKey key: String) -> Data? {
        return storage.value(forKey: type(of: self).addPrefix(toKey: key)) as? Data
    }

    func removeValue(forKey key: String) {
        storage.removeObject(forKey: type(of: self).addPrefix(toKey: key))
    }

    internal static func addPrefix(toKey key: String) -> String {
        return [keyPrefix, key].joined(separator: ".")
    }
}

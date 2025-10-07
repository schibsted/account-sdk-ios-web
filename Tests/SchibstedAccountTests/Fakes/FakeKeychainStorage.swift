// 
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

@testable import SchibstedAccount

final class FakeKeychainStorage: KeychainStoring, @unchecked Sendable {
    var values: [String: Any] = [:]

    func getValue(forAccount account: String?) throws(KeychainStorageError) -> Data? {
        guard let account else { return nil }
        return values[account] as? Data
    }

    func getAll(forAccount account: String?) throws(KeychainStorageError) -> [Data]? {
        Array(values.values) as? [Data]
    }

    func setValue(_ value: Data, forAccount account: String?) throws(KeychainStorageError) {
        guard let account else { return }
        values[account] = value
    }

    func removeValue(forAccount account: String?) throws(KeychainStorageError) {
        guard let account else { return }
        values.removeValue(forKey: account)
    }
}

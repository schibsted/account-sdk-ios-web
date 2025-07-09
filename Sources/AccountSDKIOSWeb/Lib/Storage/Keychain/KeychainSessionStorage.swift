//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

class KeychainSessionStorage: SessionStorage, @unchecked Sendable {
    var accessGroup: String? {
        return keychain.accessGroup
    }

    private let keychain: KeychainStorage

    init(service: String, accessGroup: String? = nil) {
        self.keychain = KeychainStorage(forService: service, accessGroup: accessGroup)
    }

    func store(_ value: UserSession, accessGroup: String? = nil) throws {
        guard let tokenData = try? JSONEncoder().encode(value) else {
            SchibstedAccountLogger.instance.error("\(KeychainStorageError.itemEncodingError.localizedDescription)")
            throw KeychainStorageError.itemEncodingError
        }
        do {
            try keychain.setValue(tokenData, forAccount: value.clientId, accessGroup: accessGroup)
        } catch {
            SchibstedAccountLogger.instance.error("\(error.localizedDescription)")
            throw error
        }
    }

    func get(forClientId: String) -> UserSession? {
        do {
            if let data = try keychain.getValue(forAccount: forClientId) {
                let tokenData = try JSONDecoder().decode(UserSession.self, from: data)
                return tokenData
            } else {
                return nil
            }
        } catch {
            SchibstedAccountLogger.instance.error("\(error.localizedDescription)")
            return nil
        }
    }

    func getAll() -> [UserSession] {
        let data = keychain.getAll()
        return data.compactMap { try? JSONDecoder().decode(UserSession.self, from: $0) }
    }

    func remove(forClientId: String) {
        do {
            try keychain.removeValue(forAccount: forClientId)
        } catch {
            SchibstedAccountLogger.instance.error("\(error.localizedDescription)")
        }
    }

    func checkEntitlements() throws -> Data? {
        try keychain.getValue(forAccount: "test_string")
    }
}

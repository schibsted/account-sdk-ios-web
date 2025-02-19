//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

struct SharedKeychainSessionStorageFactory {

    static let sharedKeychainGroup = "com.schibsted.simplifiedLogin"
    private var keychain: KeychainSessionStorage?
    private var sharedKeychain: KeychainSessionStorage?

    init(keychain: KeychainSessionStorage? = nil, sharedKeychain: KeychainSessionStorage? = nil) {
        self.keychain = keychain
        self.sharedKeychain = sharedKeychain
    }

    func makeKeychain(clientId: String,
                      service: String,
                      accessGroup: String? = nil,
                      appIdentifierPrefix: String? = nil) -> KeychainSessionStorage {

        let keychain = self.keychain ?? KeychainSessionStorage(service: service, accessGroup: accessGroup)

        guard let appIdentifierPrefix = appIdentifierPrefix else {
            SchibstedAccountLogger.instance.debug("Return regular keychain when appIdentifierPrefix is not provided")
            return keychain
        }

        let sharedKeychainAccessGroup = "\(appIdentifierPrefix).\(Self.sharedKeychainGroup)"

        let sharedKeychain = self.sharedKeychain ??
        KeychainSessionStorage(service: service, accessGroup: sharedKeychainAccessGroup)

        // check if correct entitlements are added to the app
        do {
            _ = try sharedKeychain.checkEntitlements()
        } catch let error {
            guard let keychainError = error as? KeychainStorageError, keychainError != .entitlementMissing else {
                SchibstedAccountLogger.instance.debug("Return regular keychain when entitlements are missing")
                return keychain
            }
        }

        let clientSessionInSharedKeychain = sharedKeychain.getAll()
            .filter { $0.clientId == clientId }

        guard clientSessionInSharedKeychain.isEmpty else {
            SchibstedAccountLogger.instance
                .debug("Session for clientId already exists in shared keychain. Return shared keychain")
            return sharedKeychain
        }

        // update accessGroup for clientId entry
        let userSession = keychain.get(forClientId: clientId)
        guard let userSession else {
            return sharedKeychain
        }

        keychain.remove(forClientId: clientId)

        do {
            try sharedKeychain.store(userSession, accessGroup: sharedKeychainAccessGroup)
            SchibstedAccountLogger.instance.debug("Session successfully migrated to a shared keychain")
            return sharedKeychain
        } catch {
            try? keychain.store(userSession, accessGroup: nil) // roll back
            SchibstedAccountLogger.instance.error("Cannot store data to shared keychain with error \(error.localizedDescription)")
        }

        return keychain
    }
}

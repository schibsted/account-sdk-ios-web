//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

extension Client {

    public enum AppTransfer {
        case preTransfer(_ clientId: String, _ accessGroup: String?)
        case postTransfer(accessGroup: String?, completion: (Result<Void, Error>) -> Void)
        case clear

        // swiftlint:disable nesting
        public enum AppTransferError: Error {
            case userSessionNotFound
        }

        public func setup(for key: String) throws {
            switch self {
            case .preTransfer(let clientId, let accessGroup):
                try Client.storeOnDevice(clientId: clientId, key: key, accessGroup: accessGroup)
            case .postTransfer(let accessGroup, let completion):
                Client.loadFromDeviceToKeychain(key: key, accessGroup: accessGroup, completion: completion)
            case .clear:
                Client.clearStoredUserOnDevice(key: keyPrefix + key)
            }
        }
    }

    private static let keyPrefix = "new-sdk-app-transfer-"

    private static func storeOnDevice(clientId: String, key: String, accessGroup: String?) throws {
        do {

            let keychain = KeychainStorage(forService: Client.keychainServiceName, accessGroup: accessGroup)
            guard let data = try keychain.getValue(forAccount: clientId) else { throw AppTransfer.AppTransferError.userSessionNotFound }

            let tokenData = try JSONDecoder().decode(UserSession.self, from: data)
            let encoded = try JSONEncoder().encode(tokenData)

            UserDefaults.standard.set(encoded, forKey: Client.keyPrefix + key)
            UserDefaults.standard.synchronize()
        } catch {
            throw error
        }
    }

    private static func loadFromDeviceToKeychain(key: String, accessGroup: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        let key = Client.keyPrefix + key
        guard let tokenData = UserDefaults.standard.object(forKey: key) as? Data else {
            completion( .failure(AppTransfer.AppTransferError.userSessionNotFound))
            return
        }

        do {
            let decodedTokenData = try JSONDecoder().decode(UserSession.self, from: tokenData)
            let keychain = KeychainSessionStorage(service: Client.keychainServiceName, accessGroup: accessGroup)
            keychain.store(decodedTokenData) { result in
                switch result {
                case .success:
                    Client.clearStoredUserOnDevice(key: key)
                    completion(.success())
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } catch {
            SchibstedAccountLogger.instance.info("Failed from to storeFromDeviceToKeychain: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }

    private static func clearStoredUserOnDevice(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

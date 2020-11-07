import Foundation

struct LegacyTokenData: Equatable {
    let accessToken: String
    let refreshToken: String
    let idToken: String
}

class LegacyKeychainTokenStorage {
    private let service = "swift.keychain.service"
    private let account = "SchibstedID"
    
    private let keychain: KeychainStorage

    init(accessGroup: String? = nil) {
        keychain = KeychainStorage(forService: service, accessGroup: accessGroup)
    }

    /**
     == Keychain JSON structure ==
        "logged_in_users": {
            <access_token>: { refresh_token: <string>, id_token: <string>, user_id: <string> }
            <access_token>: { refresh_token: <string>, id_token: <string>, user_id: <string> }
            ...
            <access_token>: { refresh_token: <string>, id_token: <string>, user_id: <string> }
        }
    */
    func get() -> [LegacyTokenData] {
        let maybeData = keychain.getValue(forAccount: account)
        guard let data = maybeData else {
            return []
        }

        guard let deserialised = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: Any] else {
            // TODO log failed to deserialise data
            return []
        }

        guard let parsed = deserialised["logged_in_users"] as? [String: [String: Any]] else {
            // TODO log failed to parse data
            return []
        }

        let storedTokens: [LegacyTokenData] = parsed.compactMap { (accessToken, data) in
            guard let refreshToken = data["refresh_token"] as? String,
                  let idToken = data["id_token"] as? String else {
                return nil
            }
            return LegacyTokenData(accessToken: accessToken, refreshToken: refreshToken, idToken: idToken)
        }

        return storedTokens
    }
    
    func remove() {
        keychain.removeValue(forAccount: account)
    }
}

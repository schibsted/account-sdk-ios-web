import Foundation

internal struct LegacyTokenData: Equatable, Codable {
    let accessToken: String
    let refreshToken: String
}

internal struct LegacyUserSession: Codable, Equatable {
    let clientId: String
    let accessToken: String
    let refreshToken: String
    let updatedAt: Date
}

class LegacyKeychainTokenStorage {
    private let service = "swift.keychain.service"
    private let account = "SchibstedID"
    enum KeychainKey {
        static let refreshToken = "refresh_token"
        static let idToken = "id_token"
        static let loggedInUsers = "logged_in_users"
        static let userID = "user_id"
    }
    
    private let keychain: KeychainStoring

    init(accessGroup: String? = nil) {
        keychain = KeychainStorage(forService: service, accessGroup: accessGroup)
    }
    
    // Now just for test purposes (proper dependency injection in the future)
    init(keychain: KeychainStoring) {
        self.keychain = keychain
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
        let maybeData: Data?
        do {
            maybeData = try keychain.getValue(forAccount: account)
        } catch {
            SchibstedAccountLogger.instance.error("\(error.localizedDescription)")
            return []
        }
        
        guard let data = maybeData else {
            return []
        }
        
        guard let deserialised = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String: Any] else {
            SchibstedAccountLogger.instance.error("Failed to deserialise legacy keychain data")
            return []
        }
        
        guard let parsed = deserialised[Self.KeychainKey.loggedInUsers] as? [String: [String: Any]] else {
            SchibstedAccountLogger.instance.error("Failed to parse legacy keychain data")
            return []
        }
        
        let storedTokens: [LegacyTokenData] = parsed.compactMap { (accessToken, data) in
            guard let refreshToken = data[Self.KeychainKey.refreshToken] as? String else {
                return nil
            }
            return LegacyTokenData(accessToken: accessToken, refreshToken: refreshToken)
        }
        
        return storedTokens
    }
    
    /**
     == LegacySDKtokenData  data structure ==
        {
        "idToken":{
            "string":<idToken>
        },
        "refreshToken":<refreshToken>,
        "accessToken":<accessToken
        "userID":<userID>
        }
     */
    func set(legacySDKtokenData: Data) throws {
        let json = try JSONSerialization.jsonObject(with: legacySDKtokenData, options: [])
        guard let dict = json as? [String: Any],
              let accessToken = dict["accessToken"] as? String,
              let refreshToken = dict["refreshToken"] as? String,
              let idTokenDict = dict["idToken"] as? [String: Any],
              let idToken = idTokenDict["string"] as? String,
              let userId = dict["userID"] as? String else {
                  throw KeychainStorageError.storeError(reason: .invalidData)
        }
        
        // Build as Legacy Keychain JSON structure
        var loggedInUsers: [String: [String: String]] = [:]
        let loggedInUser: [String: String] = [Self.KeychainKey.refreshToken: refreshToken,
                                              Self.KeychainKey.idToken: idToken,
                                              Self.KeychainKey.userID: userId]
        loggedInUsers[accessToken] = loggedInUser
        let keychainData = [Self.KeychainKey.loggedInUsers: loggedInUsers]
        
        let data = try NSKeyedArchiver.archivedData(withRootObject: keychainData, requiringSecureCoding: true)
        try keychain.setValue(data, forAccount: account, accessGroup: nil)
    }
    
    func remove() {
        do {
            try keychain.removeValue(forAccount: account)
        } catch {
            SchibstedAccountLogger.instance.error("\(error.localizedDescription)")
        }
    }
}

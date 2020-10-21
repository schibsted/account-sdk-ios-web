import Foundation
import Security

internal struct StoredUserTokens: Codable {
    let clientId: String
    let accessToken: String
    let refreshToken: String?
    let idToken: String
    let idTokenClaims: IdTokenClaims
}

internal struct TokenStorage {
    private static let service = "com.schibsted.account"
    private static let keychain = KeychainStorage(forService: service)
    
    static func store(_ value: StoredUserTokens) {
        guard let tokenData = try? JSONEncoder().encode(value) else {
             fatalError("Failed to JSON encode user tokens for storage")
        }
        
        keychain.addValue(tokenData)
    }

    static func get() -> StoredUserTokens? {
        guard let data = keychain.getValue(),
              let tokenData = try? JSONDecoder().decode(StoredUserTokens.self, from: data) else {
            return nil
        }
        return tokenData
    }

    static func remove() {
        keychain.removeValue()
    }
}

private class KeychainStorage {
    private let service: String

    init(forService: String) {
        self.service = forService
    }
    func addValue(_ value: Data) {
        // TODO delete possibly existing value first or create separate update function?

        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: service,
                                    kSecValueData as String: value]
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecDuplicateItem || status == errSecSuccess else {
            fatalError("Unable to store the secret")
        }
    }

    func getValue() -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecReturnData as String: true
        ]

        var extractedData: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &extractedData)
        
        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess else {
            fatalError("Unable to retrieve the secret")
        }

        return extractedData as? Data
    }

    func removeValue() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
        ]
        
        let result = SecItemDelete(query as CFDictionary)
        guard result == errSecSuccess || result == errSecItemNotFound else {
            fatalError("Unable to delete the secret")
        }
    }
}

import Foundation
import Security

protocol KeychainStoring {
    func setValue(_ value: Data, forAccount: String?, accessGroup: String?) throws
    func getValue(forAccount: String?) throws -> Data?
    func getAll() -> [Data]
    func removeValue(forAccount: String?) throws
}

class KeychainStorage: KeychainStoring {
    private let service: String
    let accessGroup: String?

    init(forService: String, accessGroup: String? = nil) {
        self.service = forService
        self.accessGroup = accessGroup
    }

    func setValue(_ value: Data, forAccount: String?, accessGroup: String? = nil) throws {
        let status: OSStatus

        if try getValue(forAccount: forAccount) == nil {
            var query = itemQuery(forAccount: forAccount)
            query[kSecValueData as String] = value
            query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
            status = SecItemAdd(query as CFDictionary, nil)
        } else {
            let searchQuery = itemQuery(forAccount: forAccount, returnData: false)
            var updateQuery: [String: Any] = [kSecValueData as String: value]
            updateQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
            if let accessGroup = accessGroup {
                updateQuery[kSecAttrAccessGroup as String] = accessGroup
            }
            status = SecItemUpdate(searchQuery as CFDictionary, updateQuery as CFDictionary)
        }

        guard status == errSecSuccess else {
            SchibstedAccountLogger.instance.error("KeychainStorage error: \(status)")
            throw KeychainStorageError.storeError(reason: .keychainError(status: status))
        }
    }

    func getValue(forAccount: String?) throws -> Data? {
        return try get(query: itemQuery(forAccount: forAccount)) as? Data
    }

    func getAll() -> [Data] {
        var query: [String: Any] = itemQuery(forAccount: nil)
        query[kSecMatchLimit as String] = kSecMatchLimitAll

        guard let items = try? get(query: query) else {
            return []
        }

        let result = items as! [Data?]
        return result.compactMap { $0 }
    }

    private func itemQuery(forAccount: String?, returnData: Bool = true) -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        accessGroup.map { query[kSecAttrAccessGroup as String] = $0 }
        forAccount.map { query[kSecAttrAccount as String] = $0 }

        if returnData {
            query[kSecReturnData as String] = true
        }

        return query
    }

    private func get(query: [String: Any]) throws -> AnyObject? {
        var extractedData: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &extractedData)

        if status == errSecItemNotFound {
            return nil
        }

        if status == errSecMissingEntitlement {
            SchibstedAccountLogger.instance
                .error("KeychainStorager error: \(KeychainStorageError.entitlementMissing.localizedDescription)")
            throw KeychainStorageError.entitlementMissing
        }

        guard status == errSecSuccess else {
            SchibstedAccountLogger.instance.error("KeychainStorage error: \(status)")
            throw KeychainStorageError.operationError
        }

        return extractedData
    }

    func removeValue(forAccount: String?) throws {
        let result = SecItemDelete(itemQuery(forAccount: forAccount, returnData: false) as CFDictionary)
        guard result == errSecSuccess || result == errSecItemNotFound else {
            SchibstedAccountLogger.instance.error("KeychainStorage error: \(result)")
            throw KeychainStorageError.deleteError
        }
    }
}

import Foundation
import Security

enum KeychainError: Error {
    case storeError
    case operationError
    case deleteError
}

extension KeychainError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .storeError:
            return NSLocalizedString("Unable to store the secret", comment: "")
        case .operationError:
            return NSLocalizedString("Unable to fulfill the keychain query", comment: "")
        case .deleteError:
            return NSLocalizedString("Unable to delete the secret", comment: "")
        }
    }
}

class KeychainStorage {
    private let service: String
    private let accessGroup: String?

    init(forService: String, accessGroup: String? = nil) {
        self.service = forService
        self.accessGroup = accessGroup
    }

    func setValue(_ value: Data, forAccount: String?) throws {
        let status: OSStatus
        
        if try getValue(forAccount: forAccount) == nil {
            var query = itemQuery(forAccount: forAccount)
            query[kSecValueData as String] = value
            status = SecItemAdd(query as CFDictionary, nil)
        } else {
            let searchQuery = itemQuery(forAccount: forAccount, returnData: false)
            let updateQuery: [String: Any] = [kSecValueData as String: value]
            status = SecItemUpdate(searchQuery as CFDictionary, updateQuery as CFDictionary)
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.storeError
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
            kSecAttrService as String: service,
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

        guard status == errSecSuccess else {
            throw KeychainError.operationError
        }

        return extractedData
    }

    func removeValue(forAccount: String?) throws {
        let result = SecItemDelete(itemQuery(forAccount: forAccount, returnData: false) as CFDictionary)
        guard result == errSecSuccess || result == errSecItemNotFound else {
            throw KeychainError.deleteError
        }
    }
}

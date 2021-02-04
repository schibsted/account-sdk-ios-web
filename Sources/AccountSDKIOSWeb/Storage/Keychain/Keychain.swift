import Foundation
import Security

class KeychainStorage {
    private let service: String
    private let accessGroup: String?

    init(forService: String, accessGroup: String? = nil) {
        self.service = forService
        self.accessGroup = accessGroup
    }

    func setValue(_ value: Data, forAccount: String?) {
        let status: OSStatus
        
        if getValue(forAccount: forAccount) == nil {
            var query = itemQuery(forAccount: forAccount)
            query[kSecValueData as String] = value
            status = SecItemAdd(query as CFDictionary, nil)
        } else {
            let searchQuery = itemQuery(forAccount: forAccount, returnData: false)
            let updateQuery: [String: Any] = [kSecValueData as String: value]
            status = SecItemUpdate(searchQuery as CFDictionary, updateQuery as CFDictionary)
        }
        
        guard status == errSecSuccess else {
            fatalError("Unable to store the secret")
        }
    }

    func getValue(forAccount: String?) -> Data? {
        return get(query: itemQuery(forAccount: forAccount)) as? Data
    }
    
    func getAll() -> [Data] {
        var query: [String: Any] = itemQuery(forAccount: nil)
        query[kSecMatchLimit as String] = kSecMatchLimitAll

        guard let items = get(query: query) else {
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

    private func get(query: [String: Any]) -> AnyObject? {
        var extractedData: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &extractedData)
        
        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess else {
            fatalError("Unable to fulfill the keychain query")
        }

        return extractedData
    }

    func removeValue(forAccount: String?) {       
        let result = SecItemDelete(itemQuery(forAccount: forAccount, returnData: false) as CFDictionary)
        guard result == errSecSuccess || result == errSecItemNotFound else {
            fatalError("Unable to delete the secret")
        }
    }
}

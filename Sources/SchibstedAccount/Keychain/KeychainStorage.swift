//
// Copyright © 2026 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

public import Foundation
internal import Security
internal import Logging

/// Keychain Storage.
public protocol KeychainStoring: Sendable {
    /// Gets a value for a given account name.
    /// - returns: The value as `Data` or `nil` if it could not be found.
    func getValue(forAccount account: String?) throws(KeychainStorageError) -> Data?

    /// Gets all values for a given account name.
    /// - returns: The values as `[Data]` or `nil` if no data could not be found.
    func getAll(forAccount account: String?) throws(KeychainStorageError) -> [Data]?

    /// Sets a value for a given account name.
    func setValue(_ value: Data, forAccount account: String?) throws(KeychainStorageError)

    /// Removes a value for a given account name.
    func removeValue(forAccount account: String?) throws(KeychainStorageError)
}

/// Keychain Storage.
public struct KeychainStorage: KeychainStoring {
    private let logger = Logger(label: "KeychainStorage")
    private let service: String
    private let accessGroup: String?
    private let operations: KeychainOperations

    /// Creates a new Keychain Storage instance.
    ///
    /// - parameters:
    ///   - service: The service used for looking up items.
    ///   - accessGroup: The access group used for looking up items.
    public init(forService service: String, accessGroup: String? = nil) {
        self.init(forService: service, accessGroup: accessGroup, operations: KeychainOperations())
    }

    init(forService service: String, accessGroup: String? = nil, operations: KeychainOperations) {
        self.service = service
        self.accessGroup = accessGroup
        self.operations = operations
    }

    public func getValue(forAccount account: String?) throws(KeychainStorageError) -> Data? {
        do {
            if let value = try get(query: itemQuery(account: account, accessGroup: accessGroup)) {
                // Check with access group first
                return value as? Data
            } else if let value = try get(query: itemQuery(account: account, accessGroup: nil)) {
                // Fallback to check without the access group
                return value as? Data
            } else {
                return nil
            }
        } catch {
            if let value = try get(query: itemQuery(account: account, accessGroup: nil)) {
                // Fallback to check without the access group
                return value as? Data
            } else {
                throw error
            }
        }
    }

    public func getAll(forAccount account: String?) throws(KeychainStorageError) -> [Data]? {
        do {
            var query = itemQuery(account: account, accessGroup: accessGroup)
            query[kSecMatchLimit as String] = kSecMatchLimitAll

            if let value = try get(query: query) {
                // Check with access group first
                return value as? [Data]
            } else if let value = try get(query: itemQuery(account: account, accessGroup: nil)) {
                // Fallback to check without the access group
                return value as? [Data]
            } else {
                return nil
            }
        } catch {
            var query = itemQuery(account: account, accessGroup: nil)
            query[kSecMatchLimit as String] = kSecMatchLimitAll

            if let value = try get(query: query) {
                // Fallback to check without the access group
                return value as? [Data]
            } else {
                throw error
            }
        }
    }

    public func setValue(_ value: Data, forAccount account: String?) throws(KeychainStorageError) {
        let status: OSStatus

        if try get(query: itemQuery(account: account, accessGroup: accessGroup)) == nil {
            var query = itemQuery(account: account, accessGroup: accessGroup)
            query[kSecValueData as String] = value
            status = operations.add(query as CFDictionary, nil)
        } else {
            let searchQuery = itemQuery(account: account, accessGroup: accessGroup, returnData: false)
            let updateQuery: [String: Any] = [kSecValueData as String: value]
            status = operations.update(searchQuery as CFDictionary, updateQuery as CFDictionary)
        }

        guard status == errSecSuccess else {
            logger.error("Failed set value in the keychain. Error: \(status.errorMessage ?? "") (\(status)).")
            throw KeychainStorageError.storeError(status)
        }
    }

    public func removeValue(forAccount account: String?) throws(KeychainStorageError) {
        let status = operations.delete(
            itemQuery(
                account: account,
                accessGroup: accessGroup,
                returnData: false
            ) as CFDictionary
        )
        guard status == errSecSuccess || status == errSecItemNotFound else {
            logger.error("Failed delete value from the keychain. Error: \(status.errorMessage ?? "") (\(status)).")
            throw KeychainStorageError.deleteError(status)
        }
    }

    private func itemQuery(
        account: String?,
        accessGroup: String?,
        returnData: Bool = true
    ) -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        accessGroup.map { query[kSecAttrAccessGroup as String] = $0 }
        account.map { query[kSecAttrAccount as String] = $0 }

        if returnData {
            query[kSecReturnData as String] = true
        }

        return query
    }

    private func get(query: [String: Any]) throws(KeychainStorageError) -> AnyObject? {
        var extractedData: AnyObject?
        let status = operations.copyMatching(query as CFDictionary, &extractedData)

        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess else {
            logger.error("Failed get value from the keychain. Error: \(status.errorMessage ?? "") (\(status)).")
            throw KeychainStorageError.operationError(status)
        }

        return extractedData
    }
}

/// Keychain Storage Errors.
public enum KeychainStorageError: Error {
    /// Failed to store value.
    case storeError(OSStatus)
    /// Failed to get value.
    case operationError(OSStatus)
    /// Failed to delete value.
    case deleteError(OSStatus)

    /// A message describing the error.
    public var errorDescription: String {
        let components = switch self {
        case .storeError(let status):
            ["Unable to store the secret.", status.errorMessage, status.codeMessage]
        case .operationError(let status):
            ["Unable to fulfill the keychain query.", status.errorMessage, status.codeMessage]
        case .deleteError(let status):
            ["Unable to delete the secret.", status.errorMessage, status.codeMessage]
        }
        return components.compactMap { $0 }.joined(separator: " ")
    }
}

private extension OSStatus {
    var codeMessage: String? {
        guard self != errSecSuccess else { return nil }
        return "(\(self))"
    }

    var errorMessage: String? {
        guard self != errSecSuccess else { return nil }
        return SecCopyErrorMessageString(self, nil) as String?
    }
}

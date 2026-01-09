// 
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation
import Testing

@testable import SchibstedAccount

@Suite
struct KeychainStorageTests {
    let clientId = "a70ed9c041334b712c599a526"
    let service = "com.schibsted.account"
    let accessGroup = "SC12H34.com.schibsted"

    @Test("should add new item to the keychain")
    func setValueShouldAddNewItem() async throws {
        try await confirmation { confirm in
            let keychainStorage = KeychainStorage(
                forService: service,
                accessGroup: accessGroup,
                operations: .mock(
                    add: { _, _ in
                        confirm()
                        return errSecSuccess
                    }
                )
            )

            try keychainStorage.setValue(Data("Hello World".utf8), forAccount: clientId)
        }
    }

    @Test
    func setValueShouldThrowOnError() async throws {
        let keychainStorage = KeychainStorage(
            forService: service,
            accessGroup: accessGroup,
            operations: .mock(
                add: { _, _ in
                    return errSecInvalidKeychain
                }
            )
        )

        #expect(throws: KeychainStorageError.self) {
            try keychainStorage.setValue(Data("Hello World".utf8), forAccount: clientId)
        }
    }

    @Test("should update existing item in the keychain")
    func setValueShouldUpdateExistingItem() async throws {
        try await confirmation { confirm in
            let keychainStorage = KeychainStorage(
                forService: service,
                accessGroup: accessGroup,
                operations: .mock(
                    update: { _, _ in
                        confirm()
                        return errSecSuccess
                    },
                    copyMatching: { _, result in
                        result?.pointee = Data("Hello".utf8) as NSData
                        return errSecSuccess
                    }
                )
            )

            try keychainStorage.setValue(Data("World".utf8), forAccount: clientId)
        }
    }

    @Test("should get all the items in the keychain")
    func getAll() async throws {
        let expectedItems = [
            Data("Hello".utf8),
            Data("World".utf8)
        ]

        let keychainStorage = KeychainStorage(
            forService: service,
            accessGroup: accessGroup,
            operations: .mock(
                copyMatching: { _, result in
                    result?.pointee = expectedItems as NSArray
                    return errSecSuccess
                }
            )
        )

        let items = try keychainStorage.getAll(forAccount: clientId)
        #expect(items == expectedItems)
    }

    @Test("should get all the items in the keychain, fallback to query without the accessGroup")
    func getAllFallbackWithoutAccessGroup() async throws {
        let expectedItems = [
            Data("Hello".utf8),
            Data("World".utf8)
        ]

        let keychainStorage = KeychainStorage(
            forService: service,
            accessGroup: accessGroup,
            operations: .mock(
                copyMatching: { query, result in
                    let query = query as Dictionary
                    if query[kSecAttrAccessGroup] == nil {
                        result?.pointee = expectedItems as NSArray
                    }
                    return errSecSuccess
                }
            )
        )

        let items = try keychainStorage.getAll(forAccount: clientId)
        #expect(items == expectedItems)
    }

    @Test
    func getAllFallbackWithoutAccessGroupWhenThrows() async throws {
        let expectedItems = [
            Data("Hello".utf8),
            Data("World".utf8)
        ]

        let keychainStorage = KeychainStorage(
            forService: service,
            accessGroup: accessGroup,
            operations: .mock(
                copyMatching: { query, result in
                    let query = query as Dictionary
                    if query[kSecAttrAccessGroup] == nil {
                        result?.pointee = expectedItems as NSArray
                        return errSecSuccess
                    } else {
                        return errSecNoSuchKeychain
                    }
                }
            )
        )

        let items = try keychainStorage.getAll(forAccount: clientId)
        #expect(items == expectedItems)
    }

    @Test
    func getAllQuery() async throws {
        nonisolated(unsafe) var query: [String: Any]?

        try await confirmation { confirmation in
            let keychainStorage = KeychainStorage(
                forService: service,
                accessGroup: accessGroup,
                operations: .mock(
                    copyMatching: { q, result in
                        query = q as? [String: Any]
                        confirmation()
                        result?.pointee = [] as NSArray
                        return errSecSuccess
                    }
                )
            )

            _ = try keychainStorage.getAll(forAccount: clientId)
        }

        #expect(query?[kSecMatchLimit as String] as? String == String(kSecMatchLimitAll))
        #expect(query?[kSecClass as String] as? String == String(kSecClassGenericPassword))
        #expect(query?[kSecAttrService as String] as? String == service)
        #expect(query?[kSecAttrAccessGroup as String] as? String == accessGroup)
        #expect(query?[kSecAttrAccount as String] as? String == clientId)
        #expect(query?[kSecReturnData as String] as? Bool == true)
    }

    @Test("should get an existing item from the keychain")
    func getValue() async throws {
        let expectedItem = Data("Hello World".utf8)

        let keychainStorage = KeychainStorage(
            forService: service,
            accessGroup: accessGroup,
            operations: .mock(
                copyMatching: { _, result in
                    result?.pointee = expectedItem as NSData
                    return errSecSuccess
                }
            )
        )

        let item = try keychainStorage.getValue(forAccount: clientId)
        #expect(item == expectedItem)
    }

    @Test
    func getValueQuery() async throws {
        nonisolated(unsafe) var query: [String: Any]?

        try await confirmation { confirmation in
            let keychainStorage = KeychainStorage(
                forService: service,
                accessGroup: accessGroup,
                operations: .mock(
                    copyMatching: { q, result in
                        query = q as? [String: Any]
                        result?.pointee = Data() as NSData
                        confirmation()
                        return errSecSuccess
                    }
                )
            )

            _ = try keychainStorage.getValue(forAccount: clientId)
        }

        #expect(query?[kSecMatchLimit as String] == nil)
        #expect(query?[kSecClass as String] as? String == String(kSecClassGenericPassword))
        #expect(query?[kSecAttrService as String] as? String == service)
        #expect(query?[kSecAttrAccessGroup as String] as? String == accessGroup)
        #expect(query?[kSecAttrAccount as String] as? String == clientId)
        #expect(query?[kSecReturnData as String] as? Bool == true)
    }

    @Test("errSecItemNotFound should be mapped to nil")
    func itemNotFound() async throws {
        let keychainStorage = KeychainStorage(
            forService: service,
            accessGroup: accessGroup,
            operations: .mock(
                copyMatching: { _, _ in
                    return errSecItemNotFound
                }
            )
        )

        let item = try keychainStorage.getValue(forAccount: clientId)
        #expect(item == nil)
    }

    @Test("error when copying should throw")
    func getValueShouldThrowOnError() async throws {
        let keychainStorage = KeychainStorage(
            forService: service,
            accessGroup: accessGroup,
            operations: .mock(
                copyMatching: { _, _ in
                    return errSecInvalidKeychain
                }
            )
        )

        #expect(throws: KeychainStorageError.self) {
            _ = try keychainStorage.getValue(forAccount: clientId)
        }
    }

    @Test("should get an existing item from the keychain, fallback to query without the accessGroup")
    func getValueFallbackWithoutAccessGroup() async throws {
        let expectedItem = Data("Hello World".utf8)

        let keychainStorage = KeychainStorage(
            forService: service,
            accessGroup: accessGroup,
            operations: .mock(
                copyMatching: { query, result in
                    let query = query as Dictionary
                    if query[kSecAttrAccessGroup] == nil {
                        result?.pointee = expectedItem as NSData
                    }
                    return errSecSuccess
                }
            )
        )

        let item = try keychainStorage.getValue(forAccount: clientId)
        #expect(item == expectedItem)
    }

    @Test
    func getValueFallbackWithoutAccessGroupWhenThrows() async throws {
        let expectedItem = Data("Hello World".utf8)

        let keychainStorage = KeychainStorage(
            forService: service,
            accessGroup: accessGroup,
            operations: .mock(
                copyMatching: { query, result in
                    let query = query as Dictionary
                    if query[kSecAttrAccessGroup] == nil {
                        result?.pointee = expectedItem as NSData
                        return errSecSuccess
                    } else {
                        return errSecNoSuchKeychain
                    }
                }
            )
        )

        let item = try keychainStorage.getValue(forAccount: clientId)
        #expect(item == expectedItem)
    }

    @Test
    func removeValue() async throws {
        nonisolated(unsafe) var query: [String: Any]?

        try await confirmation { confirmation in
            let keychainStorage = KeychainStorage(
                forService: service,
                accessGroup: accessGroup,
                operations: .mock(
                    delete: { q in
                        query = q as? [String: Any]
                        confirmation()
                        return errSecSuccess
                    }
                )
            )

            _ = try keychainStorage.removeValue(forAccount: clientId)
        }

        #expect(query?[kSecMatchLimit as String] == nil)
        #expect(query?[kSecClass as String] as? String == String(kSecClassGenericPassword))
        #expect(query?[kSecAttrService as String] as? String == service)
        #expect(query?[kSecAttrAccessGroup as String] as? String == accessGroup)
        #expect(query?[kSecAttrAccount as String] as? String == clientId)
        #expect(query?[kSecReturnData as String] == nil)
    }

    @Test
    func removeValueShouldHandleItemNotFound() async throws {
        let keychainStorage = KeychainStorage(
            forService: service,
            accessGroup: accessGroup,
            operations: .mock(
                delete: { _ in
                    return errSecItemNotFound
                }
            )
        )

        try keychainStorage.removeValue(forAccount: clientId)
    }

    @Test
    func removeValueShouldThrowOnError() async throws {
        let keychainStorage = KeychainStorage(
            forService: service,
            accessGroup: accessGroup,
            operations: .mock(
                delete: { _ in
                    return errSecInvalidKeychain
                }
            )
        )

        #expect(throws: KeychainStorageError.self) {
            try keychainStorage.removeValue(forAccount: clientId)
        }
    }
}

extension KeychainOperations {
    static func mock(
        add: @Sendable @escaping (CFDictionary, UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus = { _, _ in errSecSuccess },
        update: @Sendable @escaping (CFDictionary, CFDictionary) -> OSStatus = { _, _ in errSecSuccess },
        delete: @Sendable @escaping (CFDictionary) -> OSStatus = { _ in errSecSuccess },
        copyMatching: @Sendable @escaping (CFDictionary, UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus = { _, _ in errSecSuccess }
    ) -> KeychainOperations {
        KeychainOperations(add: add, update: update, delete: delete, copyMatching: copyMatching)
    }
}

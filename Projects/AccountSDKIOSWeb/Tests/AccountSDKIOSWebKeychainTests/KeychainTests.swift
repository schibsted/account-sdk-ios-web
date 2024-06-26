//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import XCTest
@testable import AccountSDKIOSWeb

final class KeychainTests: XCTestCase {
    func testSetGetValue() throws {
        let keychainStorage = KeychainStorage(forService: "testService")
        try keychainStorage.setValue("foo".data(using: .utf8)!, forAccount: "client1")
        let stored = try keychainStorage.getValue(forAccount: "client1")!
        XCTAssertEqual(String(data: stored, encoding: .utf8), "foo")
    }
    
    func testGetRemovedValue() throws {
        let keychainStorage = KeychainStorage(forService: "testService")
        try keychainStorage.setValue("foo".data(using: .utf8)!, forAccount: "client1")
        try keychainStorage.removeValue(forAccount: "client1")
        XCTAssertNil(try keychainStorage.getValue(forAccount: "client1"))
    }
    
    func testSetValueShouldOverwriteExistingValue() throws {
        let keychainStorage = KeychainStorage(forService: "testService")
        try keychainStorage.setValue("foo".data(using: .utf8)!, forAccount: "client1")
        try keychainStorage.setValue("bar".data(using: .utf8)!, forAccount: "client1")
        
        let stored = try keychainStorage.getValue(forAccount: "client1")!
        XCTAssertEqual(String(data: stored, encoding: .utf8), "bar")
    }
    
    func testGetAll() throws {
        let keychainStorage = KeychainStorage(forService: "testService")
        let v1 = "foo".data(using: .utf8)!
        let v2 = "bar".data(using: .utf8)!
        try keychainStorage.setValue(v1, forAccount: "client1")
        try keychainStorage.setValue(v2, forAccount: "client2")
        
        let all = keychainStorage.getAll()
        XCTAssertEqual(all.count, 2)
        XCTAssertTrue(all.contains(v1))
        XCTAssertTrue(all.contains(v2))
    }
}

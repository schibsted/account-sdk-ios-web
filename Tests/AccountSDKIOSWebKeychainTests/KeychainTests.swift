import XCTest
@testable import AccountSDKIOSWeb

final class KeychainTests: XCTestCase {
    func testSetGetValue() {
        let keychainStorage = KeychainStorage(forService: "testService")
        keychainStorage.setValue("foo".data(using: .utf8)!, forAccount: "client1")
        let stored = keychainStorage.getValue(forAccount: "client1")!
        XCTAssertEqual(String(data: stored, encoding: .utf8), "foo")
    }
    
    func testGetRemovedValue() {
        let keychainStorage = KeychainStorage(forService: "testService")
        keychainStorage.setValue("foo".data(using: .utf8)!, forAccount: "client1")
        keychainStorage.removeValue(forAccount: "client1")
        XCTAssertNil(keychainStorage.getValue(forAccount: "client1"))
    }
    
    func testSetValueShouldOverwriteExistingValue() {
        let keychainStorage = KeychainStorage(forService: "testService")
        keychainStorage.setValue("foo".data(using: .utf8)!, forAccount: "client1")
        keychainStorage.setValue("bar".data(using: .utf8)!, forAccount: "client1")
        
        let stored = keychainStorage.getValue(forAccount: "client1")!
        XCTAssertEqual(String(data: stored, encoding: .utf8), "bar")
    }
    
    func testGetAll() {
        let keychainStorage = KeychainStorage(forService: "testService")
        let v1 = "foo".data(using: .utf8)!
        let v2 = "bar".data(using: .utf8)!
        keychainStorage.setValue(v1, forAccount: "client1")
        keychainStorage.setValue(v2, forAccount: "client2")
        
        XCTAssertEqual(keychainStorage.getAll(), [v1, v2])
    }
}

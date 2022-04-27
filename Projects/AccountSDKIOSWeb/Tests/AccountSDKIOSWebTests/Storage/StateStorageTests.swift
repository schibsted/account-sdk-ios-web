//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import XCTest
import Cuckoo
@testable import AccountSDKIOSWeb

private struct TestData: Codable, Equatable {
    let key1: Float
    let key2: Bool
}

final class StateStorageTests: XCTestCase {
    func testSetValueEncodesValue() {
        let testData = TestData(key1: 1.0, key2: true)
        let key = "test key"
        
        let mockStorage = MockStorage()
        stub(mockStorage) { mock in
            when(mock.setValue(any(), forKey: key)).thenDoNothing()
        }
        XCTAssertTrue(StateStorage(storage: mockStorage).setValue(testData, forKey: key))
        
        let expectedData = try! JSONEncoder().encode(testData)
        verify(mockStorage).setValue(equal(to: expectedData), forKey: key)
    }
    
    func testSetValueReturnsFalseForValueFailingSerialisation() {
        // Float.infinity can't be JSON serialised by defult
        let testData = TestData(key1: Float.infinity, key2: true)

        XCTAssertFalse(StateStorage(storage: MockStorage()).setValue(testData, forKey: "test key"))
    }
    
    func testValueDecodesExistingValue() {
        let testData = TestData(key1: 1.0, key2: true)
        let key = "test key"
        
        let mockStorage = MockStorage()
        stub(mockStorage) { mock in
            let serialised = try? JSONEncoder().encode(testData)
            when(mock.value(forKey: key)).thenReturn(serialised)
        }
            
        let stored: TestData? = StateStorage(storage: mockStorage).value(forKey: key)
        XCTAssertEqual(stored, testData)
    }
    
    func testValueReturnNilForMissingValue() {
        let key = "test key"
        let mockStorage = MockStorage()
        stub(mockStorage) { mock in
            when(mock.value(forKey: "test key")).thenReturn(nil)
        }
        XCTAssertNil(StateStorage(storage: mockStorage).value(forKey: key) as TestData?)
    }
    
    func testValueReturnNilForValueThatFailsDeserialisation() {
        let key = "test key"
        let mockStorage = MockStorage()
        stub(mockStorage) { mock in
            when(mock.value(forKey: key)).thenReturn("plain string".data(using: .utf8))
        }
        XCTAssertNil(StateStorage(storage: mockStorage).value(forKey: key) as TestData?)
    }
}

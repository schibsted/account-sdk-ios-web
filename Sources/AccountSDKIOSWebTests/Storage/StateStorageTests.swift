//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation
import Testing
import Cuckoo

@testable import AccountSDKIOSWeb

private struct TestData: Codable, Equatable {
    let key1: Float
    let key2: Bool
}

@Suite
struct StateStorageTests {
    @Test(.disabled("unstable"))
    func testSetValueEncodesValue() {
        let testData = TestData(key1: 1.0, key2: true)
        let key = "test key"
        
        let mockStorage = MockStorage()
        stub(mockStorage) { mock in
            when(mock.setValue(any(), forKey: key)).thenDoNothing()
        }
        #expect(StateStorage(storage: mockStorage).setValue(testData, forKey: key) == true)

        let expectedData = try! JSONEncoder().encode(testData)
        verify(mockStorage).setValue(equal(to: expectedData), forKey: key)
    }

    @Test
    func testSetValueReturnsFalseForValueFailingSerialisation() {
        // Float.infinity can't be JSON serialised by defult
        let testData = TestData(key1: Float.infinity, key2: true)

        #expect(StateStorage(storage: MockStorage()).setValue(testData, forKey: "test key") == false)
    }

    @Test
    func testValueDecodesExistingValue() {
        let testData = TestData(key1: 1.0, key2: true)
        let key = "test key"
        
        let mockStorage = MockStorage()
        stub(mockStorage) { mock in
            let serialised = try? JSONEncoder().encode(testData)
            when(mock.value(forKey: key)).thenReturn(serialised)
        }
            
        let stored: TestData? = StateStorage(storage: mockStorage).value(forKey: key)
        #expect(stored == testData)
    }

    @Test
    func testValueReturnNilForMissingValue() {
        let key = "test key"
        let mockStorage = MockStorage()
        stub(mockStorage) { mock in
            when(mock.value(forKey: "test key")).thenReturn(nil)
        }
        #expect(StateStorage(storage: mockStorage).value(forKey: key) as TestData? == nil)
    }

    @Test
    func testValueReturnNilForValueThatFailsDeserialisation() {
        let key = "test key"
        let mockStorage = MockStorage()
        stub(mockStorage) { mock in
            when(mock.value(forKey: key)).thenReturn("plain string".data(using: .utf8))
        }
        #expect(StateStorage(storage: mockStorage).value(forKey: key) as TestData? == nil)
    }
}

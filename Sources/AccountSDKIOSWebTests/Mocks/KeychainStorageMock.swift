//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation
@testable import AccountSDKIOSWeb

class KeychainStorageMock: KeychainStoring {
    
    private var storedData: [String:Data] = [:]
    private var testKey = "test_key"
    
    func setValue(_ value: Data, forAccount: String?, accessGroup: String?) throws {
        if let forAccount = forAccount {
            storedData[forAccount] = value
        } else {
            storedData[testKey] = value
        }
    }
    
    func getValue(forAccount: String?) throws -> Data? {
        if let accountString = forAccount {
            if !accountString.isEmpty {
                return storedData[accountString]
            }
        }
        return storedData[testKey]
    }
    
    func getAll() -> [Data] {
        return Array(storedData.values)
    }
    
    func removeValue(forAccount: String?) throws {
        if let forAccount = forAccount {
            storedData.removeValue(forKey: forAccount)
        } else {
            storedData.removeValue(forKey: testKey)
        }
    }
    
}

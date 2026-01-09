// 
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

struct KeychainOperations: Sendable {
    var add: @Sendable (_ attributes: CFDictionary, _ result: UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus = {
        SecItemAdd($0, $1)
    }

    var update: @Sendable (_ query: CFDictionary, _ attributes: CFDictionary) -> OSStatus = {
        SecItemUpdate($0, $1)
    }

    var delete: @Sendable (_ query: CFDictionary) -> OSStatus = {
        SecItemDelete($0)
    }

    var copyMatching: @Sendable (_ query: CFDictionary, _ result: UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus = {
        SecItemCopyMatching($0, $1)
    }
}

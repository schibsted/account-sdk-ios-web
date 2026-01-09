// 
// Copyright © 2026 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation
import Testing

@testable import SchibstedAccount

@Suite
struct KeychainStorageErrorTests {
    @Test(arguments: [
        (errSecNoSuchKeychain, "Unable to store the secret. The specified keychain could not be found. (-25294)")
    ])
    func storeError(error: OSStatus, expectedDescription: String) {
        let error = KeychainStorageError.storeError(error)
        #expect(error.errorDescription == expectedDescription)
    }

    @Test(arguments: [
        (errSecNoSuchKeychain, "Unable to fulfill the keychain query. The specified keychain could not be found. (-25294)")
    ])
    func operationError(error: OSStatus, expectedDescription: String) {
        let error = KeychainStorageError.operationError(error)
        #expect(error.errorDescription == expectedDescription)
    }

    @Test(arguments: [
        (errSecNoSuchKeychain, "Unable to delete the secret. The specified keychain could not be found. (-25294)")
    ])
    func deleteError(error: OSStatus, expectedDescription: String) {
        let error = KeychainStorageError.deleteError(error)
        #expect(error.errorDescription == expectedDescription)
    }
}

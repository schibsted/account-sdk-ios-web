//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation
import Security

extension String {
    /// Generates a cryptographically secure random a-zA-Z0-9 string of a given length
    ///
    /// - parameter length: The random string length.
    /// - returns: A cryptographically secure random string, or nil if generation fails.
    public static func secureRandom(length: Int) -> String? {
        guard length > 0 else { return nil }

        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let lettersArray = Array(letters)
        let lettersCount = lettersArray.count

        var randomBytes = [UInt8](repeating: 0, count: length)
        let result = SecRandomCopyBytes(kSecRandomDefault, length, &randomBytes)

        guard result == errSecSuccess else { return nil }

        return String(randomBytes.map { byte in
            lettersArray[Int(byte) % lettersCount]
        })
    }

    func removeTrailingSlash() -> String {
        if self.last == "/" {
            return String(self.dropLast())
        }
        return self
    }
}

// 
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

/// Simplified Login Error.
public enum SimplifiedLoginError: Error, Sendable {
    /// Keychain operation failed.
    case keychainStorageError(KeychainStorageError)
    /// Decoding error.
    case decodingError(DecodingError)
    /// Simplified login failed.
    case simplifiedLoginFailed(Error)
}

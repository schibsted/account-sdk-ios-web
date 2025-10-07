// 
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

/// Network Errors.
public enum NetworkingError: Error {
    /// Decoding the response failed.
    case decodingError(DecodingError)
    /// The network request failed.
    case requestFailed(Error)
}

//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

extension JSONDecoder {
    /// Creates a new, reusable JSON decoder with the default formatting settings and decoding strategies.
    ///
    /// - parameter dateDecodingStrategy: The strategy used when decoding dates from part of a JSON object.
    convenience init(dateDecodingStrategy: DateDecodingStrategy) {
        self.init()
        self.dateDecodingStrategy = dateDecodingStrategy
    }
}

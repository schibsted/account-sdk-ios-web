//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

extension DateFormatter {
    /// Creates an DateFormatter instance.
    ///
    /// - parameter dateFormat: The date format string used by the receiver.
    convenience init(dateFormat: String) {
        self.init()
        self.dateFormat = dateFormat
    }
}

//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

internal protocol Storage {
    func setValue(_ value: Data, forKey key: String)
    func value(forKey key: String) -> Data?
    func removeValue(forKey key: String)
}

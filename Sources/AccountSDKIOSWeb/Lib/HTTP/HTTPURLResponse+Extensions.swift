//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

extension HTTPURLResponse {
    var isError: Bool {
        !(200...399).contains(statusCode)
    }
}

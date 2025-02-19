//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

public enum HTTPError: Error {
    case errorResponse(code: Int, body: String?)
    case unexpectedError(underlying: Error)
    case noData
}

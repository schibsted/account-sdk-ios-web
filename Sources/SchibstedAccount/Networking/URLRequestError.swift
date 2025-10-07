//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

enum URLRequestError: Error, CustomStringConvertible, Equatable {
    /// HTTP response status error (100...199 and 400...599)
    case httpStatus(Int, Data?, URL?)

    /// Localized string description of the status code
    var description: String {
        switch self {
        case let .httpStatus(statusCode, _, _):
            "\(HTTPURLResponse.localizedString(forStatusCode: statusCode)) (HTTP \(statusCode))"
        }
    }
}

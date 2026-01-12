//
// Copyright © 2026 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

enum URLRequestAuthorization {
    case basic(username: String, password: String)
    case bearer(token: String)

    var rawValue: String {
        switch self {
        case .basic(let username, let password):
            "Basic \(Data("\(username):\(password)".utf8).base64EncodedString())"
        case .bearer(let token):
            "Bearer \(token)"
        }
    }
}

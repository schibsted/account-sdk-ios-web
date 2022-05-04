//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

public enum RefreshTokenError: Error {
    case noRefreshToken
    case refreshRequestFailed(error: HTTPError)
    case unexpectedError(error: Error)
}

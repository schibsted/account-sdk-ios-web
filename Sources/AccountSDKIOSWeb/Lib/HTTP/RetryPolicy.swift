//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

public protocol RetryPolicy: Sendable {
    func shouldRetry(for: HTTPError) -> Bool
    func numRetries(for: URLRequest) -> Int
}

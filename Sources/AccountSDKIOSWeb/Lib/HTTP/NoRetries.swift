//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

final class NoRetries: RetryPolicy {
    private init() {}

    public static let policy = NoRetries()

    public func shouldRetry(for: HTTPError) -> Bool {
        return false
    }

    func numRetries(for: URLRequest) -> Int {
        return 0
    }
}

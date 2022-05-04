//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

public protocol RetryPolicy {
    func shouldRetry(for: HTTPError) -> Bool
    func numRetries(for: URLRequest) -> Int
}

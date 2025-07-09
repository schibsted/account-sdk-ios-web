//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

public typealias HTTPResultHandler<T> = @MainActor (Result<T, HTTPError>) -> Void

public protocol HTTPClient: Sendable {
    @MainActor
    func execute<T: Decodable>(request: URLRequest, withRetryPolicy: RetryPolicy, completion: @escaping HTTPResultHandler<T>)
}

extension HTTPClient {
    @MainActor
    func execute<T: Decodable>(request: URLRequest, withRetryPolicy: RetryPolicy = NoRetries.policy, completion: @escaping HTTPResultHandler<T>) {
        execute(request: request, withRetryPolicy: withRetryPolicy, completion: completion)
    }
}

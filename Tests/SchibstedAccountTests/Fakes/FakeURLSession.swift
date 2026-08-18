// 
// Copyright © 2026 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Testing
import Foundation

@testable import SchibstedAccount

final class FakeURLSession: URLSessionType, @unchecked Sendable {
    var data: (URLRequest) async throws -> (Data, URLResponse) = { _ in
        throw FakeError.notMocked
    }

    func data(
        from url: URL,
        delegate: (any URLSessionTaskDelegate)?
    ) async throws -> (Data, URLResponse) {
        try await data(for: URLRequest(url: url), delegate: delegate)
    }
    
    func data(
        for request: URLRequest,
        delegate: (any URLSessionTaskDelegate)?
    ) async throws -> (Data, URLResponse) {
        try await data(request)
    }

    func dataTask(
        with url: URL,
        completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void
    ) -> URLSessionDataTask {
        dataTask(with: URLRequest(url: url), completionHandler: completionHandler)
    }

    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void
    ) -> URLSessionDataTask {
        Task {
            do {
                let (data, response) = try await self.data(request)
                completionHandler(data, response, nil)
            } catch {
                completionHandler(nil, nil, error)
            }
        }
        return URLSession.shared.dataTask(with: request) { _, _, _ in }
    }
}

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
        return FakeURLSessionDataTask()
    }
}

private final class FakeURLSessionDataTask: URLSessionDataTask, @unchecked Sendable {
    // Enable this in Xcode 27
    // @diagnose(DeprecatedDeclaration, as: ignored)
    override init() {}
    override func resume() {}
    override func cancel() {}
}

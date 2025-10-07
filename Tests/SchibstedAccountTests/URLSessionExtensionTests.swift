// 
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Testing
import Foundation

@testable import SchibstedAccount

@Suite
struct URLSessionExtensionTests {
    private let urlSession = FakeURLSession()
    private let urlRequest = URLRequest(url: URL(string: "https://schibsted.com")!)

    @Test
    func data() async throws {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        try await confirmation { confirmation in
            urlSession.data = { request in
                let userAgent = try #require(request.allHTTPHeaderFields?["User-Agent"])
                #expect(userAgent.hasPrefix("SchibstedAccountSDKiOS/\(SchibstedAuthenticator.version)"))

                confirmation()

                let data = Data("""
                {
                    "foo": "hello",
                    "bar": 42,
                    "display_name": "Rincewind"
                }
                """.utf8)

                return (data, HTTPURLResponse())
            }

            let dummy: Dummy = try await urlSession.data(for: urlRequest, decoder: decoder)
            #expect(dummy.foo == "hello")
            #expect(dummy.bar == 42)
            #expect(dummy.displayName == "Rincewind")
        }
    }
}

private struct Dummy: Codable {
    let foo: String
    let bar: Int
    let displayName: String
}

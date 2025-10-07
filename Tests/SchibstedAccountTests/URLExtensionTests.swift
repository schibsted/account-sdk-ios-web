// 
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Testing
import Foundation

@testable import SchibstedAccount

@Suite
struct URLExtensionTests {
    private let url = URL(string: "https://schibsted.com?key1=value1&key2=value2&kEy3=value3")!

    @Test
    func queryItems() {
        #expect(url.queryItems == [
            URLQueryItem(name: "key1", value: "value1"),
            URLQueryItem(name: "key2", value: "value2"),
            URLQueryItem(name: "kEy3", value: "value3")
        ])
    }

    @Test(arguments: [
        ("key1", "value1"),
        ("key2", "value2"),
        ("KEY3", "value3")
    ])
    func subscriptQueryItem(
        queryItem: String,
        expectedValue: String
    ) {
        #expect(url[queryItem: queryItem] == expectedValue)
    }
}

// 
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//
	
import Testing
import Foundation

@testable import SchibstedAccount

@Suite
struct URLRequestExtensionTests {
    @Test(arguments: [
        (URLRequestAuthorization.basic(username: "rincewind", password: "ook!ook!"), "Basic cmluY2V3aW5kOm9vayFvb2sh"),
        (URLRequestAuthorization.bearer(token: "17D27638FC98"), "Bearer 17D27638FC98")
    ])
    func setAuthorization(
        authorization: URLRequestAuthorization,
        expectedAuthorization: String
    ) {
        var urlRequest = URLRequest(url: URL(string: "https://schibsted.com")!)
        urlRequest.setAuthorization(authorization)

        #expect(urlRequest.allHTTPHeaderFields?["Authorization"] == expectedAuthorization)
    }

    @Test(arguments: [
        ("Hej Världen", "Hej+V%C3%A4rlden"),
        ("Witaj świecie", "Witaj+%C5%9Bwiecie")
    ])
    func setFormURLEncoded(value: String, expectedValue: String) throws {
        let urlRequest = URLRequest(url: URL(string: "https://schibsted.com")!, parameters: ["value": value])
        let data = try #require(urlRequest.httpBody)

        let formEncoded = String(data: data, encoding: .utf8)
        #expect(formEncoded == "value=\(expectedValue)")
    }
}

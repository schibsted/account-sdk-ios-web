// 
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Testing
import Foundation

@testable import SchibstedAccount

@Suite
struct URLResponseExtensionTests {
    private let url = URL(string: "https://schibsted.com")!

    @Test
    func validate() throws {
        let data = Data()

        for statusCode in 100...199 {
            let urlResponse = try urlResponse(statusCode: statusCode)
            #expect(throws: URLRequestError.httpStatus(statusCode, data, url)) {
                try urlResponse.validate(data: data, url: url)
            }
        }

        for statusCode in 200...399 {
            let urlResponse = try urlResponse(statusCode: statusCode)
            try urlResponse.validate(data: data, url: url)
        }

        for statusCode in 400...599 {
            let urlResponse = try urlResponse(statusCode: statusCode)
            #expect(throws: URLRequestError.httpStatus(statusCode, data, url)) {
                try urlResponse.validate(data: data, url: url)
            }
        }
    }

    private func urlResponse(statusCode: Int) throws -> URLResponse {
        try #require(HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        ))
    }
}

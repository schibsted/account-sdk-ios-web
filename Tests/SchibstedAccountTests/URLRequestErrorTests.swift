// 
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Testing
import Foundation

@testable import SchibstedAccount

@Suite
struct URLRequestErrorTests {
    @Test(arguments: [
        401,
        402,
        403,
        404,
        500
    ])
    func description(statusCode: Int) {
        let localizedError = HTTPURLResponse.localizedString(forStatusCode: statusCode)
        let error = URLRequestError.httpStatus(statusCode, nil, nil)
        #expect("\(localizedError) (HTTP \(statusCode))" == error.description)
    }
}

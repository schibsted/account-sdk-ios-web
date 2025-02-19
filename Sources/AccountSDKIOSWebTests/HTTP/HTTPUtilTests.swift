//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import XCTest
@testable import AccountSDKIOSWeb

final class HTTPUtilTests: XCTestCase {
    func testFormEncodesProperly() {
        let encoded = HTTPUtil.formURLEncode(parameters: ["test1": "test value", "url": "https://example.com/test?key1=value1&key2=value2"])
        let result = String(data: encoded!, encoding: .utf8)!
        
        XCTAssertTrue(result.contains("test1=test+value"))
        XCTAssertTrue(result.contains("url=https%3A%2F%2Fexample.com%2Ftest%3Fkey1%3Dvalue1%26key2%3Dvalue2"))
    }
}

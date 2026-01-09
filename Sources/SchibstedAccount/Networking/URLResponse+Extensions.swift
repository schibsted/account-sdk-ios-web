//
// Copyright © 2026 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

extension URLResponse {
    /// Validates a HTTP response and throws an error if the response status code is not in the `200..<400` range
    ///
    /// - parameter data: The response data.
    /// - parameter url: The request URL.
    func validate(data: Data?, url: URL?) throws(URLRequestError) {
        let statusCode = (self as? HTTPURLResponse)?.statusCode
        if let statusCode, !(200..<400).contains(statusCode) {
            throw URLRequestError.httpStatus(statusCode, data, url)
        }
    }
}

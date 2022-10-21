//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

protocol URLSessionProtocol {
    typealias DataTaskResult = @Sendable (Data?, URLResponse?, Error?) -> Void

    func dataTask(with: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTask
}

extension URLSession: URLSessionProtocol {}

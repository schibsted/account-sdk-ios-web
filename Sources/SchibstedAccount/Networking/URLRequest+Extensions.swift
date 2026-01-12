//
// Copyright © 2026 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

extension URLRequest {
    init(
        url: URL,
        cachePolicy: CachePolicy = .useProtocolCachePolicy,
        timeInterval: TimeInterval = 60.0,
        parameters: [String: String]
    ) {
        self.init(url: url, cachePolicy: cachePolicy, timeoutInterval: timeInterval)
        httpShouldHandleCookies = false
        setFormURLEncoded(parameters: parameters)
    }

    mutating func setAuthorization(_ authorization: URLRequestAuthorization) {
        setValue(authorization.rawValue, forHTTPHeaderField: "Authorization")
    }

    /// Sets the sent message body of the request to a Form URL Encodes set of key-value pairs.
    private mutating func setFormURLEncoded(parameters: [String: String]) {
        guard !parameters.isEmpty else { return }

        func encode(_ value: String) -> String {
            let value = value.addingPercentEncoding(
                withAllowedCharacters: Self.formURLEncodedAllowedCharacters
            ) ?? value
            return value.replacingOccurrences(of: " ", with: "+")
        }

        // See https://url.spec.whatwg.org/#urlencoded-serializing

        setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let payload = parameters.map { key, value in
            let encodedKey = encode(key)
            let encodedValue = encode(value)
            return "\(encodedKey)=\(encodedValue)"
        }
        .joined(separator: "&")

        httpMethod = "POST"
        httpBody = payload.data(using: .utf8)
    }

    private static let formURLEncodedAllowedCharacters: CharacterSet = {
        let allowedCharacterSet = NSMutableCharacterSet.alphanumeric()
        allowedCharacterSet.addCharacters(in: "*-._ ")
        return allowedCharacterSet as CharacterSet
    }()
}

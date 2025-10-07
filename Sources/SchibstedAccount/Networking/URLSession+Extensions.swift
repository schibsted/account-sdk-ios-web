//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation
import UIKit

extension URLSessionType {
    /// Downloads the contents of a URL based on the specified URL request, validates the response,
    /// and deserializes the data, and then delivers the data asynchronously.
    ///
    /// - parameters:
    ///   - request: A URL request object that provides request-specific information such as the URL, cache policy, request type, and body data or body stream.
    ///   - decoder: A JSONDecoder used to deserialize the data.
    /// - returns: An asynchronously-delivered tuple that contains the URL contents as a Data instance, and a URLResponse.
    func data<Value: Decodable>(
        for request: URLRequest,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws(NetworkingError) -> Value {
        var request = request
        await request.addValue(SchibstedAuthenticator.userAgent, forHTTPHeaderField: "User-Agent")
        do {
            let (data, response) = try await data(for: request, delegate: nil)
            try response.validate(data: data, url: request.url)
            return try decoder.decode(Value.self, from: data)
        } catch let error as DecodingError {
            throw .decodingError(error)
        } catch {
            throw .requestFailed(error)
        }
    }
}

private extension SchibstedAuthenticator {
    @MainActor
    static let userAgent = "SchibstedAccountSDKiOS/\(SchibstedAuthenticator.version) (\(UIDevice.current.model); \(UIDevice.current.systemName) \(UIDevice.current.systemVersion))"
}

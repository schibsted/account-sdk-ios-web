//
// Copyright © 2026 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

public import Foundation

/// An object that coordinates a group of related, network data-transfer tasks.
public protocol URLSessionType: AnyObject, Sendable {
    /// Downloads the contents of a URL based on the specified URL request and delivers the data asynchronously.
    ///
    /// Use this method to wait until the session finishes transferring data and receive it in a single Data instance.
    ///
    /// - parameter request: A URL request object that provides request-specific information such as the URL, cache policy, request type, and body data or body stream.
    /// - parameter delegate: A delegate that receives life cycle and authentication challenge callbacks as the transfer progresses.
    /// - returns: An asynchronously-delivered tuple that contains the URL contents as a Data instance, and a URLResponse.
    func data(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse)

    /// Retrieves the contents of a URL and delivers the data asynchronously.
    ///
    /// Use this method to wait until the session finishes transferring data and receive it in a single Data instance.
    ///
    /// - parameter url: The URL to retrieve.
    /// - parameter delegate: A delegate that receives life cycle and authentication challenge callbacks as the transfer progresses.
    /// - returns: An asynchronously-delivered tuple that contains the URL contents as a Data instance, and a URLResponse.
    func data(from url: URL, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionType {}

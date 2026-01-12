//
// Copyright © 2026 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

/// A specialized URLSession that will refresh the stored access token
/// when encoutering a HTTP 401, and then replay the request with the updated token.
public final class AuthenticatedURLSession: URLSessionType {
    private nonisolated(unsafe) weak var authenticator: SchibstedAuthenticating?
    private let urlSession: URLSessionType
    private let refreshTokens: @MainActor () async throws -> Void

    init(
        authenticator: SchibstedAuthenticating,
        urlSession: URLSessionType,
        refreshTokens: @escaping @MainActor () async throws -> Void
    ) {
        self.authenticator = authenticator
        self.urlSession = urlSession
        self.refreshTokens = refreshTokens
    }

    public func data(
        from url: URL,
        delegate: URLSessionTaskDelegate? = nil
    ) async throws -> (Data, URLResponse) {
        try await data(for: URLRequest(url: url), delegate: delegate)
    }

    public func data(
        for request: URLRequest,
        delegate: URLSessionTaskDelegate? = nil
    ) async throws -> (Data, URLResponse) {
        // 1. Perform a preemptive check whether the access token has expired, and refresh the tokens if necessary.

        if let expiration = authenticator?.state.value.user?.tokens.expiration, expiration < .now {
            try await refreshTokens()
        }

        // 2. Authenticate the request (sets a Authorization header)

        var request = request
        switch authenticator?.state.value {
        case .loggedIn(let user):
            request.setAuthorization(.bearer(token: user.tokens.accessToken))
        default:
            return try await urlSession.data(for: request, delegate: delegate)
        }

        let (data, response) = try await urlSession.data(for: request, delegate: delegate)

        guard let httpResponse = response as? HTTPURLResponse else {
            return (data, response)
        }

        // 3. Refresh the tokens if we hit a HTTP 401

        guard httpResponse.statusCode == 401 else {
            return (data, response)
        }

        try await refreshTokens()

        // 4. Update the Authorization header with the fresh tokens

        if case .loggedIn(let user) = authenticator?.state.value {
            request.setAuthorization(.bearer(token: user.tokens.accessToken))
        }

        // 5. Retry the request

        return try await urlSession.data(for: request, delegate: delegate)
    }
}

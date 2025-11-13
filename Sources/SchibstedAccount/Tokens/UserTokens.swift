//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

/// User Tokens.
public struct UserTokens: Codable, Equatable, Sendable {
    /// The access token.
    internal let accessToken: String

    /// The refresh token.
    internal let refreshToken: String

    /// The id token claims.
    internal let idTokenClaims: IdTokenClaims

    internal let expiration: Date?

    /// Creates an UserTokens instance.
    ///
    /// - parameters:
    ///     - accessToken: The access token.
    ///     - refreshToken: Refresh token.
    ///     - idTokenClaims: ID token claims.
    ///     - expiration: Optional access token expiration.
    public init(
        accessToken: String,
        refreshToken: String,
        idTokenClaims: IdTokenClaims,
        expiration: Date?
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.idTokenClaims = idTokenClaims
        self.expiration = expiration
    }
}

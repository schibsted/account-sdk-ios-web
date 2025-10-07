//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

/// User Tokens.
public struct UserTokens: Codable, Equatable, Sendable {
    /// The access token.
    internal let accessToken: String

    /// The refresh token.
    internal let refreshToken: String

    /// The id token claims.
    internal let idTokenClaims: IdTokenClaims

    /// Creates an UserTokens instance.
    ///
    /// - parameter accessToken: The access token.
    /// - parameter refreshToken: Refresh token.
    /// - parameter idTokenClaims: ID token claims.
    public init(
        accessToken: String,
        refreshToken: String,
        idTokenClaims: IdTokenClaims
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.idTokenClaims = idTokenClaims
    }
}

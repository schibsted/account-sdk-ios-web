//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

/// Schibsted Authenticator Error.
public enum SchibstedAuthenticatorError: Error, Sendable {
    /// The login flow was cancelled by the user.
    case cancelled
    /// Previous session in progress.
    case previousSessionInProgress
    /// No login session to complete
    case noLoginSessionToComplete
    /// Authentication response not related to any outstanding authentication request was received.
    case unsolicitedResponse
    /// Invalid redirectURI scheme
    case invalidRedirectURIScheme
    /// Invalid Auth State
    case invalidAuthState
    /// The `ASWebAuthenticationSession` didn't return a valid URL, but also didn't any error.
    case missingURL
    /// The `code` was missing from the URL response.
    case missingCode
    /// The user was not logged in.
    case notLoggedIn
    /// Failed to get the user profile.
    case userProfileFailure(Error)
    /// Failed to refresh tokens.
    case refreshTokenFailed(RefreshTokenError)
    /// OAuth failure.
    case oauth(OAuthError)
    /// Login failed.
    case loginFailed(Error)
}

/// Refresh Token Error.
public enum RefreshTokenError: Error {
    /// Token could not be refreshed as the user is logged out.
    case userIsLoggedOut
    /// Token could not be refreshed due to an unexpected error.
    case other(Error)
}

/// OAuth Error.
public struct OAuthError: Error, Equatable, Sendable, Codable {
    /// Error code.
    public let error: String
    /// Error description.
    public let description: String?
}

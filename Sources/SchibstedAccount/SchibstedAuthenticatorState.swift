//
// Copyright © 2026 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

/// Schibsted Authenticator State.
public enum SchibstedAuthenticatorState: Sendable, Equatable {
    /// User is logged out
    case loggedOut
    /// User is logging in
    case loggingIn
    /// User is logged in
    case loggedIn(SchibstedAuthenticatorUser)

    /// Gets a value whether the user is logging in
    ///
    /// - returns: `true` if the user is logging in; otherwise `false`
    var isLoggingIn: Bool {
        switch self {
        case .loggingIn: true
        default: false
        }
    }

    /// Gets a value whether the user is logged in
    ///
    /// - returns: `true` if the user is logged in; otherwise `false`
    var isLoggedIn: Bool {
        switch self {
        case .loggedIn: true
        default: false
        }
    }

    /// Gets the logged in user
    ///
    /// - returns: The logged in user, if logged in; otherwise `nil`.
    var user: SchibstedAuthenticatorUser? {
        switch self {
        case .loggedIn(let user): user
        default: nil
        }
    }
}

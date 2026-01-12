//
// Copyright © 2026 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

/// Schibsted Account User.
public struct SchibstedAuthenticatorUser: Codable, Equatable, Sendable, CustomStringConvertible {
    /// The user tokens.
    internal let tokens: UserTokens

    /// User SDRN.
    public let sdrn: String

    /// Legacy User ID.
    public var userId: String { tokens.idTokenClaims.userId }

    /// User UUID.
    public var uuid: String { tokens.idTokenClaims.sub }

    /// Creates an SchibstedAuthenticatorUser instance.
    ///
    /// - parameter tokens: The user tokens.
    /// - parameter sdrn: The user SDRN.
    public init(
        tokens: UserTokens,
        sdrn: String
    ) {
        self.tokens = tokens
        self.sdrn = sdrn
    }

    public var description: String {
        sdrn
    }
}

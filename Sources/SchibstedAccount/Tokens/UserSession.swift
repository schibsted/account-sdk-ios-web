//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

/// The User Session which is saved to the keychain.
public struct UserSession: Codable, Equatable, Sendable {
    /// The user tokens.
    internal let userTokens: UserTokens

    /// When the tokens were last updated.
    internal let updatedAt: Date

    /// Creates an UserSession instance.
    ///
    /// - parameter userTokens: The user tokens.
    /// - parameter updatedAt: When the tokens were last updated.
    public init(
        userTokens: UserTokens,
        updatedAt: Date
    ) {
        self.userTokens = userTokens
        self.updatedAt = updatedAt
    }
}

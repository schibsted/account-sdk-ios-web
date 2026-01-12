// 
// Copyright © 2026 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

@testable import SchibstedAccount

extension SchibstedAuthenticatorUserProfile {
    static let withName = SchibstedAuthenticatorUserProfile(
        uuid: UUID(),
        userId: "12345789",
        email: "rincewind@unseen-university.am",
        displayName: "Rincewind the Wizzard",
        name: .init(
            givenName: "Rincewind",
            familyName: "Wizzard"
        )
    )

    static let withoutName = SchibstedAuthenticatorUserProfile(
        uuid: UUID(),
        userId: "12345789",
        email: "rincewind@unseen-university.am",
        displayName: "Rincewind the Wizzard"
    )
}

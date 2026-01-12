// 
// Copyright © 2026 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Testing

@testable import SchibstedAccount

@Suite
struct MultifactorAuthenticationTests {
    @Test(arguments: [
        (MultifactorAuthentication.password, "password"),
        (MultifactorAuthentication.oneTimeCode, "otp"),
        (MultifactorAuthentication.sms, "sms"),
        (MultifactorAuthentication.bankId, "eid"),
        (MultifactorAuthentication.preBankId(.fi), "eid-fi"),
        (MultifactorAuthentication.preBankId(.no), "eid-no"),
        (MultifactorAuthentication.preBankId(.se), "eid-se")
    ])
    func rawValue(mfa: MultifactorAuthentication, expectedRawValue: String) {
        #expect(mfa.rawValue == expectedRawValue)
    }
}

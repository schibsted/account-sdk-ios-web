// 
// Copyright © 2026 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation
import SchibstedAccount

final class FakeSchibstedAuthenticatorTracker: SchibstedAuthenticatorTracking, @unchecked Sendable {
    var trackedSimplifiedLoginPresented = false
    func trackSimplifiedLoginPresented() async {
        trackedSimplifiedLoginPresented = true
    }

    var trackedSimplifiedLoginDismissed = false
    func trackSimplifiedLoginDismissed() async {
        trackedSimplifiedLoginDismissed = true
    }

    var trackedSimplifiedLoginContinueAs = false
    func trackSimplifiedLoginContinueAs(xDomainId: UUID?) async {
        trackedSimplifiedLoginContinueAs = true
    }

    var trackedSimplifiedLoginSwitchAccount = false
    func trackSimplifiedLoginSwitchAccount(xDomainId: UUID?) async {
        trackedSimplifiedLoginSwitchAccount = true
    }

    var trackedSimplifiedLoginContinueWithoutLogin = false
    func trackSimplifiedLoginContinueWithoutLogin() async {
        trackedSimplifiedLoginContinueWithoutLogin = true
    }

    var trackedSimplifiedLoginOpenedPrivacyPolicy = false
    func trackSimplifiedLoginOpenedPrivacyPolicy() async {
        trackedSimplifiedLoginOpenedPrivacyPolicy = true
    }
}

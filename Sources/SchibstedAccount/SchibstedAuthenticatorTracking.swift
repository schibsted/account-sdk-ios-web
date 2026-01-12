// 
// Copyright © 2026 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

/// Tracking delegate for the Schibsted Authenticator.
public protocol SchibstedAuthenticatorTracking: AnyObject, Sendable {
    /// Called when a login session is started.
    ///
    /// - parameter xDomainId: The session ID used for origin tracking of the login session.
    /// - parameter multifactorAuthentication: Optional multi-factor authentication.
    func trackLoginStarted(
        xDomainId: UUID?,
        multifactorAuthentication: MultifactorAuthentication?
    ) async

    /// Called when a login session failed.
    ///
    /// - parameter xDomainId: The session ID used for origin tracking of the login session.
    /// - parameter error: The reason the login failed.
    func trackLoginFailed(
        xDomainId: UUID?,
        error: SchibstedAuthenticatorError
    ) async

#if os(iOS)
    /// Called when the simplified login view is presented.
    func trackSimplifiedLoginPresented() async

    /// Called when the simplified login view is dismissed.
    func trackSimplifiedLoginDismissed() async

    /// Called user clicks 'continue as' from the simplified login view.
    ///
    /// - parameter xDomainId: The session ID used for origin tracking of the login session.
    func trackSimplifiedLoginContinueAs(xDomainId: UUID?) async

    /// Called user clicks 'not you' from the simplified login view.
    ///
    /// - parameter xDomainId: The session ID used for origin tracking of the login session.
    func trackSimplifiedLoginSwitchAccount(xDomainId: UUID?) async

    /// Called user clicks 'continue without logging-in' from the simplified login view.
    func trackSimplifiedLoginContinueWithoutLogin() async

    /// Called user opens the privacy policy from from the simplified login view.
    func trackSimplifiedLoginOpenedPrivacyPolicy() async
#endif
}

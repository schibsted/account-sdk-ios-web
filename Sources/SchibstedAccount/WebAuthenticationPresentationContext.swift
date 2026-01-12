//
// Copyright © 2026 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

#if os(iOS)

import Foundation
import AuthenticationServices

/// Provides context to target where in an application's UI the authorization view should be shown.
@MainActor
public class WebAuthenticationPresentationContext: NSObject, ASWebAuthenticationPresentationContextProviding {
    /// Return the ASPresentationAnchor in the closest proximity to where a user
    /// interacted with your app to trigger authentication.
    ///
    /// If starting an ASWebAuthenticationSession on first launch, use the application's main window.
    ///
    /// - parameter session: The session requesting a presentation anchor.
    /// - returns: The `ASPresentationAnchor` most closely associated with the UI used to trigger authentication.
    @MainActor
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        ASPresentationAnchor()
    }
}

#endif

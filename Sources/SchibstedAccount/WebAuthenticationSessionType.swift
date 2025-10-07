// 
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import AuthenticationServices

/// A session that an app uses to authenticate a user through a web service.
protocol WebAuthenticationSessionType {
#if os(iOS)
    /// A delegate that provides a display context in which the system can present an authentication session to the user.
    var presentationContextProvider: ASWebAuthenticationPresentationContextProviding? { get set }

    /// A Boolean value that indicates whether the session should ask the browser for a private authentication session.
    var prefersEphemeralWebBrowserSession: Bool { get set }
#endif

    /// Starts a web authentication session.
    /// - returns: A Boolean value indicating whether the web authentication session started successfully.
    @discardableResult
    func start() -> Bool
}

extension ASWebAuthenticationSession: WebAuthenticationSessionType {}

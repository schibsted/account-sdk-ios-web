// 
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import AuthenticationServices

/// A session that an app uses to authenticate a user through a web service.
protocol WebAuthenticationSessionType {
#if os(iOS)
    var completionHandler: (URL?, (any Error)?) -> Void { get }

    /// A delegate that provides a display context in which the system can present an authentication session to the user.
    var presentationContextProvider: ASWebAuthenticationPresentationContextProviding? { get set }

    /// A Boolean value that indicates whether the session should ask the browser for a private authentication session.
    var prefersEphemeralWebBrowserSession: Bool { get set }
#endif

    /// Starts a web authentication session.
    /// - returns: A Boolean value indicating whether the web authentication session started successfully.
    @discardableResult
    func start() -> Bool

#if os(iOS)
    /// Cancels a web authentication session.
    ///
    /// If the view controller is already presented to load the webpage for authentication, it will be dismissed.
    /// Calling cancel on an already canceled session will have no effect.
    func cancel()
#endif
}

final class WebAuthenticationSession: ASWebAuthenticationSession, WebAuthenticationSessionType {
    let completionHandler: (URL?, (any Error)?) -> Void

    @available(iOS 17.4, tvOS 17.4, *)
    override init(
        url URL: URL,
        callback: ASWebAuthenticationSession.Callback,
        completionHandler: @escaping ASWebAuthenticationSession.CompletionHandler
    ) {
        self.completionHandler = completionHandler
        super.init(
            url: URL,
            callback: callback,
            completionHandler: completionHandler
        )
    }

    override init(
        url URL: URL,
        callbackURLScheme: String?,
        completionHandler: @escaping ASWebAuthenticationSession.CompletionHandler
    ) {
        self.completionHandler = completionHandler
        super.init(
            url: URL,
            callbackURLScheme: callbackURLScheme,
            completionHandler: completionHandler
        )
    }
}

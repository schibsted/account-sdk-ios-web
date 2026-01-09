// 
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import AuthenticationServices

/// Provides a ``WebAuthenticationSession`` that is used to authenticate a user through a web service.
protocol WebAuthenticationSessionProviding: Sendable {
#if os(iOS)
    /// Creates a web authentication session instance.
    ///
    /// - parameter url: A URL with the http or https scheme pointing to the authentication webpage.
    /// - parameter callbackURLScheme: The custom URL scheme that the app expects in the callback URL.
    /// - parameter completionHandler: A completion handler the session calls when it completes successfully, or when the user cancels the session.
    func session(
        url: URL,
        callbackURLScheme: String,
        completionHandler: @escaping (URL?, (any Error)?) -> Void
    ) -> WebAuthenticationSessionType
#endif
}

struct WebAuthenticationSessionProvider: WebAuthenticationSessionProviding {
#if os(iOS)
    func session(
        url: URL,
        callbackURLScheme: String,
        completionHandler: @escaping (URL?, (any Error)?) -> Void
    ) -> WebAuthenticationSessionType {
        if #available(iOS 17.4, *) {
            WebAuthenticationSession(
                url: url,
                callback: .customScheme(callbackURLScheme),
                completionHandler: completionHandler
            )
        } else {
            WebAuthenticationSession(
                url: url,
                callbackURLScheme: callbackURLScheme,
                completionHandler: completionHandler
            )
        }
    }
#endif
}

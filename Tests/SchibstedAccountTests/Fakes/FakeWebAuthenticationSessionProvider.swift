// 
// Copyright © 2026 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import AuthenticationServices

@testable import SchibstedAccount

final class FakeWebAuthenticationSessionProvider: WebAuthenticationSessionProviding, @unchecked Sendable {
    var session: FakeWebAuthenticationSession?

    var createSession: (URL, String, @escaping (URL?, (any Error)?) -> Void) -> FakeWebAuthenticationSession = {
        FakeWebAuthenticationSession(
            url: $0,
            callbackURLScheme: $1,
            completionHandler: $2
        )
    }

    func session(
        url: URL,
        callbackURLScheme: String,
        completionHandler: @escaping (URL?, (any Error)?) -> Void
    ) -> any WebAuthenticationSessionType {
        let session = createSession(url, callbackURLScheme, completionHandler)
        self.session = session
        return session
    }
}

final class FakeWebAuthenticationSession: WebAuthenticationSessionType {
#if os(iOS)
    var presentationContextProvider: ASWebAuthenticationPresentationContextProviding?
    var prefersEphemeralWebBrowserSession = false
#endif

    let url: URL
    let callbackURLScheme: String
    let completionHandler: (URL?, (any Error)?) -> Void

    init(
        url: URL,
        callbackURLScheme: String,
        completionHandler: @escaping (URL?, (any Error)?) -> Void
    ) {
        self.url = url
        self.callbackURLScheme = callbackURLScheme
        self.completionHandler = completionHandler
    }

    var didStart: () -> Bool = { true }

    func start() -> Bool {
        didStart()
    }

    var didCancel = false

    func cancel() {
        didCancel = true
    }
}

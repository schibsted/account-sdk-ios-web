// 
// Copyright © 2026 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

#if os(iOS)

import Testing
import AuthenticationServices
@testable import SchibstedAccount

@Suite
@MainActor
struct WebAuthenticationSessionProviderTests {
    let provider = WebAuthenticationSessionProvider()

    @Test
    func sessionForURL() async throws {
        let code = UUID().uuidString
        let completionURL = URL(string: "a70ed9c041334b712c599a526:/login?code=\(code)")
        await confirmation { confirmation in
            let session = provider.session(
                url: URL(string: "a70ed9c041334b712c599a526:/login")!,
                callbackURLScheme: "a70ed9c041334b712c599a526",
                completionHandler: { url, _ in
                    if url == completionURL {
                        confirmation()
                    }
                }
            )
            session.completionHandler(completionURL, nil)
        }
    }
}

#endif

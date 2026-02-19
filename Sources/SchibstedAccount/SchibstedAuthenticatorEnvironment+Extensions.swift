//
// Copyright © 2026 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

internal import Foundation

extension SchibstedAuthenticatorEnvironment {
    private var oauthURL: URL {
        serverURL.appendingPathComponent("oauth")
    }

    var jwksURL: URL {
        oauthURL.appendingPathComponent("jwks")
    }

    var authorizeURL: URL {
        oauthURL.appendingPathComponent("authorize")
    }

    var tokenURL: URL {
        oauthURL.appendingPathComponent("token")
    }

    var exchangeURL: URL {
        serverURL
            .appendingPathComponent("api")
            .appendingPathComponent("2")
            .appendingPathComponent("oauth")
            .appendingPathComponent("exchange")
    }

    func userProfileURL(userUUID: String) -> URL {
        serverURL
            .appendingPathComponent("api")
            .appendingPathComponent("2")
            .appendingPathComponent("user")
            .appendingPathComponent(userUUID)
    }

    func webSessionURL(code: String) -> URL {
        serverURL
            .appendingPathComponent("session")
            .appendingPathComponent(code)
    }

    var sessionServiceURL: URL {
        switch self {
        case .sweden:
            URL(string: "https://session-service.login.schibsted.com")!
        case .norway:
            URL(string: "https://session-service.payment.schibsted.no")!
        case .finland:
            URL(string: "https://session-service.login.schibsted.fi")!
        case .pre:
            URL(string: "https://session-service.identity-pre.schibsted.com")!
        }
    }

    var userContextFromTokenURL: URL {
        sessionServiceURL.appendingPathComponent("user-context-from-token")
    }

    var assertionForSimplifiedLoginURL: URL {
        serverURL
            .appendingPathComponent("api")
            .appendingPathComponent("2")
            .appendingPathComponent("user")
            .appendingPathComponent("auth")
            .appendingPathComponent("token")
    }

    var frontendJwtURL: URL {
        sessionServiceURL.appendingPathComponent("frontend-jwt")
    }
}

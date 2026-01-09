//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Testing
import Foundation
import Combine

@testable import SchibstedAccount

@Suite(.serialized)
@MainActor
struct SchibstedAuthenticatorTests {
    private nonisolated static let issuer = "https://login.schibsted.com"
    private nonisolated static let userId = "12345689"
    private nonisolated static let clientId = "a70ed9c041334b712c599a526"
    private nonisolated static let userUUID = UUID().uuidString
    private nonisolated static let expiration = Date().timeIntervalSince1970 + 3600
    private nonisolated static let userTokens = UserTokens(
        accessToken: UUID().uuidString,
        refreshToken: UUID().uuidString,
        idTokenClaims: IdTokenClaims(
            iss: "\(issuer)",
            sub: "\(userUUID)",
            userId: "\(userId)",
            aud: [clientId],
            exp: expiration,
            nonce: nil,
            amr: nil
        ),
        expiration: Date(timeIntervalSinceNow: 600)
    )

    private let keychainStorage = FakeKeychainStorage()
    private let idTokenValidator = FakeIdTokenValidator(userUUID: Self.userUUID)
    private let urlSession = FakeURLSession()
    private let encoder = JSONEncoder()
    private let tracker = FakeSchibstedAuthenticatorTracker()

    @Test("should load user from keychain")
    func loadUserFromKeychain() async throws {
        try addUserToKeychain()

        let authenticator = try authenticator()

        #expect(authenticator.state.value.isLoggedIn)
    }

#if os(iOS)
    @Test("Login with presentation context")
    func loginWithPresentationContextProvider() async throws {
        let code = UUID().uuidString
        let webAuthenticationSessionProvider = FakeWebAuthenticationSessionProvider()

        webAuthenticationSessionProvider.createSession = {
            let session = FakeWebAuthenticationSession(
                url: $0,
                callbackURLScheme: $1,
                completionHandler: $2
            )
            session.didStart = {
                session.completionHandler(
                    session.url.appending(queryItems: [URLQueryItem(name: "code", value: code)]),
                    nil
                )
                return true
            }
            return session
        }

        let authenticator = try authenticator(
            webAuthenticationSessionProvider: webAuthenticationSessionProvider
        )

        try await authenticator.login(
            presentationContextProvider: WebAuthenticationPresentationContext()
        )

        #expect(authenticator.state.value.isLoggedIn)
        #expect(tracker.trackedLoginStarted)
    }

    @Test("Login with presentation context failed")
    func loginWithPresentationContextProviderFailed() async throws {
        let webAuthenticationSessionProvider = FakeWebAuthenticationSessionProvider()

        webAuthenticationSessionProvider.createSession = {
            let session = FakeWebAuthenticationSession(
                url: $0,
                callbackURLScheme: $1,
                completionHandler: $2
            )
            session.didStart = {
                session.completionHandler(nil, FakeError.failure)
                return true
            }
            return session
        }

        let authenticator = try authenticator(
            webAuthenticationSessionProvider: webAuthenticationSessionProvider
        )

        await #expect(throws: SchibstedAuthenticatorError.self) {
            try await authenticator.login(
                presentationContextProvider: WebAuthenticationPresentationContext()
            )
        }

        #expect(!authenticator.state.value.isLoggedIn)
        #expect(tracker.trackedLoginStarted)
        #expect(tracker.trackedLoginFailed)
    }

    @Test("Complete login from URL")
    func completeLoginFromURL() async throws {
        let code = UUID().uuidString
        var authenticator: SchibstedAuthenticator?

        let webAuthenticationSessionProvider = FakeWebAuthenticationSessionProvider()
        webAuthenticationSessionProvider.createSession = { url, callbackURLScheme, completionHandler in
            Task {
                let state = url.queryItems?.first { $0.name == "state" }
                try await authenticator?.completeLoginFromURL(
                    URL(string: "\(Self.clientId):/login?code=\(code)&state=\(state?.value ?? "")")!
                )
            }
            return FakeWebAuthenticationSession(
                url: url,
                callbackURLScheme: callbackURLScheme,
                completionHandler: completionHandler
            )
        }

        authenticator = try self.authenticator(
            webAuthenticationSessionProvider: webAuthenticationSessionProvider
        )

        try await authenticator?.login(
            presentationContextProvider: WebAuthenticationPresentationContext()
        )

        #expect(authenticator?.state.value.isLoggedIn == true)
        #expect(webAuthenticationSessionProvider.session?.didCancel == true)
    }
#endif

    @Test("Login with code")
    func loginWithCode() async throws {
        let code = UUID().uuidString
        let codeVerifier = try #require(String.secureRandom(length: 60))
        let authenticator = try authenticator()

        try await authenticator.login(
            code: code,
            codeVerifier: codeVerifier,
            xDomainId: nil
        )

        #expect(authenticator.state.value.isLoggedIn)
        #expect(tracker.trackedLoginStarted)
    }

    @Test("Login with code failed")
    func loginWithCodeFailed() async throws {
        let code = UUID().uuidString
        let codeVerifier = try #require(String.secureRandom(length: 60))
        let authenticator = try authenticator()

        urlSession.data = { _ in
            throw FakeError.failure
        }

        await #expect(throws: SchibstedAuthenticatorError.self) {
            try await authenticator.login(
                code: code,
                codeVerifier: codeVerifier,
                xDomainId: nil
            )
        }

        #expect(!authenticator.state.value.isLoggedIn)
        #expect(tracker.trackedLoginStarted)
        #expect(tracker.trackedLoginFailed)
    }

    @Test("Request a web-session URL")
    func webSessionURL() async throws {
        let authenticator = try authenticator()

        let url = try await authenticator.webSessionURL()

        #expect(url.absoluteString == "https://login.schibsted.com/session/abcd1234")
    }

    @Test("Request a one time code")
    func oneTimeCode() async throws {
        let authenticator = try authenticator()

        let code = try await authenticator.oneTimeCode()

        #expect(code == "abcd1234")
    }

    @Test("should return a URLSession that authenticate all requests")
    func authenticatedURLSession() async throws {
        try addUserToKeychain()

        let authenticator = try authenticator()

        try await confirmation { confirmation in
            self.urlSession.data = { request in
                #expect(request.allHTTPHeaderFields?["Authorization"] == "Bearer \(Self.userTokens.accessToken)")
                confirmation()
                return (Data(), HTTPURLResponse())
            }

            let urlSession = authenticator.authenticatedURLSession()
            _ = try await urlSession.data(for: URLRequest(url: URL(string: "https://www.schibsted.com")!), delegate: nil)
        }
    }

    @Test
    func frontendJWT() async throws {
        try addUserToKeychain()
        let authenticator = try authenticator()

        let frontendJWT = try await authenticator.frontendJWT()

        #expect(frontendJWT == "id_jwt_value")
    }

    @Test("Logout")
    func logout() async throws {
        try addUserToKeychain()

        let authenticator = try authenticator()
        try authenticator.logout()

        #expect(authenticator.state.value.isLoggedIn == false)
    }

    @Test("User Profile")
    func userProfile() async throws {
        try addUserToKeychain()

        let authenticator = try authenticator()
        let userProfile = try await authenticator.userProfile()

        #expect(userProfile.uuid.uuidString == Self.userUUID)
        #expect(userProfile.userId == Self.userId)
        #expect(userProfile.displayName == "Rincewind")
    }

#if os(iOS)
    @Test
    func requestSimplifiedLogin() async throws {
        try addUserToKeychain()

        let authenticator = try authenticator()

        _ = try await authenticator.requestSimplifiedLogin()
    }

    @Test
    func assertionForSimplifiedLogin() async throws {
        try addUserToKeychain()

        let authenticator = try authenticator()

        let assertion = try await authenticator.assertionForSimplifiedLogin()

        #expect(assertion == "simplified-login-assertion")
    }
#endif

    private func addUserToKeychain() throws {
        let userSession = UserSession(
            userTokens: Self.userTokens,
            updatedAt: Date()
        )

        keychainStorage.values[Self.clientId] = try encoder.encode(userSession)
    }

    private func authenticator(
        webAuthenticationSessionProvider: WebAuthenticationSessionProviding = FakeWebAuthenticationSessionProvider()
    ) throws -> SchibstedAuthenticator {
        let jws = try SecKey.jws(claims: """
        {
            "iss": "\(Self.issuer)",
            "sub": "\(Self.userUUID)",
            "legacy_user_id": "\(Self.userId)",
            "aud": "\(Self.clientId)",
            "exp": \(Self.expiration),
            "nonce": "nonce",
            "amr": ["amr"]
        }
        """)

        let environment = SchibstedAuthenticatorEnvironment.sweden

        urlSession.data = { request in
            guard let url = request.url else {
                throw FakeError.notMocked
            }

            let data = if url == environment.userProfileURL(userUUID: Self.userUUID) {
                Data("""
                {
                    "data": {
                        "uuid": "\(Self.userUUID)",
                        "userId": "\(Self.userId)",
                        "displayName": "Rincewind",
                    }
                }
                """.utf8)
            } else if url == environment.tokenURL {
                Data("""
                {
                    "access_token": "\(UUID().uuidString)",
                    "refresh_token": "\(UUID().uuidString)",
                    "id_token": "\(jws.compactSerializedString)",
                    "scope": "openid offline_access",
                    "expires_in": 600
                }
                """.utf8)
            } else if url == environment.exchangeURL {
                Data("""
                {
                    "data": {
                        "code": "abcd1234"
                    }
                }
                """.utf8)
            } else if url == environment.frontendJwtURL {
                Data("""
                {
                    "id_jwt": "id_jwt_value"
                }
                """.utf8)
            } else if url == environment.userContextFromTokenURL {
                Data("""
                {
                    "identifier": "identifier",
                    "display_text": "Rincewind",
                    "client_name": "UU"
                }
                """.utf8)
            } else if url == environment.assertionForSimplifiedLoginURL {
                Data("""
                {
                    "data": {
                        "assertion": "simplified-login-assertion"
                    }
                }
                """.utf8)
            } else {
                throw FakeError.notMocked
            }

            return (data, HTTPURLResponse())
        }

        let authenticator = SchibstedAuthenticator(
            environment: .sweden,
            clientId: Self.clientId,
            redirectURI: URL(string: "\(Self.clientId):/login")!,
            webAuthenticationSessionProvider: webAuthenticationSessionProvider,
            idTokenValidator: idTokenValidator,
            keychainStorage: keychainStorage,
            jwks: try FakeJWKS(),
            urlSession: urlSession
        )

        authenticator.tracking = tracker

        return authenticator
    }
}

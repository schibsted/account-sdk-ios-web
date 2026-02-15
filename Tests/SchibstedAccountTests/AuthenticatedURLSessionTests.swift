// 
// Copyright © 2026 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Testing
import Foundation

@testable import SchibstedAccount

@Suite
@MainActor
struct AuthenticatedURLSessionTests {
    @Test("should retry when the response status code is HTTP 401")
    func retryWhenUnauthorized() async throws {
        let urlSession = FakeURLSession()
        let keychainStorage = FakeKeychainStorage()
        let clientId = "a70ed9c041334b712c599a526"

        let userUUID = UUID().uuidString
        let userTokens = UserTokens.fake(userUUID: userUUID)
        let userSession = UserSession(
            userTokens: userTokens,
            updatedAt: Date()
        )

        let encoder = JSONEncoder()
        keychainStorage.values[clientId] = try encoder.encode(userSession)

        let authenticator = SchibstedAuthenticator(
            environment: .sweden,
            clientId: clientId,
            redirectURI: URL(string: "\(clientId):/login")!,
            webAuthenticationSessionProvider: FakeWebAuthenticationSessionProvider(),
            idTokenValidator: FakeIdTokenValidator(userUUID: userUUID),
            keychainStorage: keychainStorage,
            jwks: try FakeJWKS(),
            urlSession: urlSession
        )

        let authenticatedURLSession = authenticator.authenticatedURLSession()
        let refreshToken = userTokens.refreshToken
        let requestURL = URL(string: "https://login.schibsted.com")!
        let oldUser = try #require(authenticator.state.value.user)

        var count: Int = 0
        try await confirmation(expectedCount: 2) { confirmation in
            urlSession.data = { request in
                guard let url = request.url else {
                    return (Data(), HTTPURLResponse())
                }

                if url == requestURL {
                    confirmation()
                }

                if url == authenticator.environment.tokenURL {
                    let httpBodyData = try #require(request.httpBody)
                    let httpBodyParameters = try #require(String(data: httpBodyData, encoding: .utf8))
                    let parameters = httpBodyParameters.components(separatedBy: "&")

                    #expect(parameters.contains("grant_type=refresh_token"))
                    #expect(parameters.contains("refresh_token=\(refreshToken)"))
                    #expect(parameters.contains("client_id=\(clientId)"))

                    let data = Data("""
                    {
                        "access_token": "\(UUID().uuidString)",
                        "refresh_token": "\(UUID().uuidString)",
                        "expires_in": 600
                    }
                    """.utf8)

                    return (data, HTTPURLResponse())
                }

                // swiftlint:disable:next empty_count
                if count == 0 {
                    count += 1
                    return (
                        Data(),
                        HTTPURLResponse(
                            url: url,
                            statusCode: 401,
                            httpVersion: "HTTP/1.0",
                            headerFields: nil
                        )!
                    )
                } else {
                    return (Data(), HTTPURLResponse())
                }
            }

            _ = try await authenticatedURLSession.data(
                for: URLRequest(url: requestURL)
            )
        }

        let updatedUser = try #require(authenticator.state.value.user)

        #expect(oldUser.tokens.accessToken != updatedUser.tokens.accessToken)
    }

    @Test("should retry when the access token have expired")
    func retryWhenExpired() async throws {
        let urlSession = FakeURLSession()
        let keychainStorage = FakeKeychainStorage()
        let clientId = "a70ed9c041334b712c599a526"

        let userUUID = UUID().uuidString
        let userTokens = UserTokens.fake(
            userUUID: userUUID,
            expiration: Date(timeIntervalSinceNow: -10)
        )
        let userSession = UserSession(
            userTokens: userTokens,
            updatedAt: Date()
        )

        let encoder = JSONEncoder()
        keychainStorage.values[clientId] = try encoder.encode(userSession)

        let authenticator = SchibstedAuthenticator(
            environment: .sweden,
            clientId: clientId,
            redirectURI: URL(string: "\(clientId):/login")!,
            webAuthenticationSessionProvider: FakeWebAuthenticationSessionProvider(),
            idTokenValidator: FakeIdTokenValidator(userUUID: userUUID),
            keychainStorage: keychainStorage,
            jwks: try FakeJWKS(),
            urlSession: urlSession
        )

        let authenticatedURLSession = authenticator.authenticatedURLSession()
        let refreshToken = userTokens.refreshToken
        let requestURL = URL(string: "https://login.schibsted.com")!
        let oldUser = try #require(authenticator.state.value.user)

        try await confirmation { confirmation in
            urlSession.data = { request in
                guard let url = request.url else {
                    return (Data(), HTTPURLResponse())
                }

                if url == requestURL {
                    confirmation()
                }

                if url == authenticator.environment.tokenURL {
                    let httpBodyData = try #require(request.httpBody)
                    let httpBodyParameters = try #require(String(data: httpBodyData, encoding: .utf8))
                    let parameters = httpBodyParameters.components(separatedBy: "&")

                    #expect(parameters.contains("grant_type=refresh_token"))
                    #expect(parameters.contains("refresh_token=\(refreshToken)"))
                    #expect(parameters.contains("client_id=\(clientId)"))

                    let data = Data("""
                    {
                        "access_token": "\(UUID().uuidString)",
                        "refresh_token": "\(UUID().uuidString)",
                        "expires_in": 600
                    }
                    """.utf8)

                    return (data, HTTPURLResponse())
                }

                return (Data(), HTTPURLResponse())
            }

            _ = try await authenticatedURLSession.data(
                for: URLRequest(url: requestURL)
            )
        }

        let updatedUser = try #require(authenticator.state.value.user)

        #expect(oldUser.tokens.accessToken != updatedUser.tokens.accessToken)
    }

    @Test("retry should fail if the user logs out during token refresh")
    func retryDuringLogout() async throws {
        let urlSession = FakeURLSession()
        let keychainStorage = FakeKeychainStorage()
        let clientId = "a70ed9c041334b712c599a526"

        let userUUID = UUID().uuidString
        let userTokens = UserTokens.fake(
            userUUID: userUUID,
            expiration: Date(timeIntervalSinceNow: -10)
        )
        let userSession = UserSession(
            userTokens: userTokens,
            updatedAt: Date()
        )

        let encoder = JSONEncoder()
        keychainStorage.values[clientId] = try encoder.encode(userSession)

        let authenticator = SchibstedAuthenticator(
            environment: .sweden,
            clientId: clientId,
            redirectURI: URL(string: "\(clientId):/login")!,
            webAuthenticationSessionProvider: FakeWebAuthenticationSessionProvider(),
            idTokenValidator: FakeIdTokenValidator(userUUID: userUUID),
            keychainStorage: keychainStorage,
            jwks: try FakeJWKS(),
            urlSession: urlSession
        )

        let authenticatedURLSession = authenticator.authenticatedURLSession()
        let requestURL = URL(string: "https://login.schibsted.com")!

        do {
            try await confirmation(expectedCount: 0) { confirmation in
                urlSession.data = { request in
                    guard let url = request.url else {
                        return (Data(), HTTPURLResponse())
                    }

                    if url == requestURL {
                        confirmation()
                    }

                    if url == authenticator.environment.tokenURL {
                        try authenticator.logout()

                        let data = Data("""
                        {
                            "access_token": "\(UUID().uuidString)",
                            "refresh_token": "\(UUID().uuidString)",
                            "expires_in": 600
                        }
                        """.utf8)

                        return (data, HTTPURLResponse())
                    }

                    return (Data(), HTTPURLResponse())
                }

                _ = try await authenticatedURLSession.data(
                    for: URLRequest(url: requestURL)
                )
            }
        } catch (SchibstedAuthenticatorError.refreshTokenFailed(.userIsLoggedOut)) {
            #expect(authenticator.state.value.user == nil)
        } catch {
            Issue.record(error)
        }
    }

    @Test("user should be logged out if the refreshing the tokens returns a invalid_grant")
    func logoutOnInvalidGrant() async throws {
        let urlSession = FakeURLSession()
        let keychainStorage = FakeKeychainStorage()
        let clientId = "a70ed9c041334b712c599a526"

        let userUUID = UUID().uuidString
        let userTokens = UserTokens.fake(
            userUUID: userUUID,
            expiration: Date(timeIntervalSinceNow: -10)
        )
        let userSession = UserSession(
            userTokens: userTokens,
            updatedAt: Date()
        )

        let encoder = JSONEncoder()
        keychainStorage.values[clientId] = try encoder.encode(userSession)

        let authenticator = SchibstedAuthenticator(
            environment: .sweden,
            clientId: clientId,
            redirectURI: URL(string: "\(clientId):/login")!,
            webAuthenticationSessionProvider: FakeWebAuthenticationSessionProvider(),
            idTokenValidator: FakeIdTokenValidator(userUUID: userUUID),
            keychainStorage: keychainStorage,
            jwks: try FakeJWKS(),
            urlSession: urlSession
        )

        let authenticatedURLSession = authenticator.authenticatedURLSession()
        let requestURL = URL(string: "https://login.schibsted.com")!

        do {
            try await confirmation(expectedCount: 0) { confirmation in
                urlSession.data = { request in
                    guard let url = request.url else {
                        return (Data(), HTTPURLResponse())
                    }

                    if url == requestURL {
                        confirmation()
                    }

                    if url == authenticator.environment.tokenURL {
                        throw URLRequestError.httpStatus(
                            400,
                            try JSONEncoder().encode(OAuthError(error: "invalid_grant", description: nil)),
                            nil
                        )
                    }

                    return (Data(), HTTPURLResponse())
                }

                _ = try await authenticatedURLSession.data(
                    for: URLRequest(url: requestURL)
                )
            }
        } catch (NetworkingError.requestFailed(URLRequestError.httpStatus)) {
            #expect(authenticator.state.value.user == nil)
            #expect(authenticator.state.value == .loggedOut)
        } catch {
            Issue.record(error)
        }
    }
}

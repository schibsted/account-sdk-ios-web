// 
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation
import AuthenticationServices
import Testing

@testable import SchibstedAccount

final class FakeSchibstedAuthenticator: SchibstedAuthenticating {
    let state = CurrentValueProperty<SchibstedAuthenticatorState>(.loggedOut)
    let environment: SchibstedAuthenticatorEnvironment
    let clientId: String
    let redirectURI: URL
    let urlSession: URLSessionType

    nonisolated(unsafe) weak var tracking: SchibstedAuthenticatorTracking?

    init(
        environment: SchibstedAuthenticatorEnvironment,
        clientId: String,
        redirectURI: URL,
        urlSession: URLSessionType
    ) {
        self.environment = environment
        self.clientId = clientId
        self.redirectURI = redirectURI
        self.urlSession = urlSession
    }

#if os(iOS)
    var didLogin: @MainActor (
        _ presentationContextProvider: any ASWebAuthenticationPresentationContextProviding,
        _ prefersEphemeralWebBrowserSession: Bool,
        _ multifactorAuthentication: MultifactorAuthentication?,
        _ assertion: String?,
        _ xDomainId: UUID?
    ) async throws -> SchibstedAuthenticatorUser = { _, _, _, _, _ in
        throw FakeError.notMocked
    }

    func login(
        presentationContextProvider: any ASWebAuthenticationPresentationContextProviding,
        prefersEphemeralWebBrowserSession: Bool,
        multifactorAuthentication: MultifactorAuthentication?,
        assertion: String?,
        xDomainId: UUID?
    ) async throws(SchibstedAuthenticatorError) -> SchibstedAuthenticatorUser {
        do {
            return try await didLogin(
                presentationContextProvider,
                prefersEphemeralWebBrowserSession,
                multifactorAuthentication,
                assertion,
                xDomainId
            )
        } catch {
            throw .loginFailed(error)
        }
    }

    func completeLoginFromURL(_ url: URL) async throws(SchibstedAuthenticatorError) {
        throw SchibstedAuthenticatorError.loginFailed(FakeError.notMocked)
    }
#endif

    func login(
        code: String,
        codeVerifier: String,
        xDomainId: UUID?
    ) async throws(SchibstedAuthenticatorError) -> SchibstedAuthenticatorUser {
        throw SchibstedAuthenticatorError.loginFailed(FakeError.notMocked)
    }

    func logout() throws(KeychainStorageError) {
        throw KeychainStorageError.storeError(-1)
    }

    @discardableResult
    func userProfile() async throws(SchibstedAuthenticatorError) -> SchibstedAuthenticatorUserProfile {
        throw SchibstedAuthenticatorError.userProfileFailure(FakeError.notMocked)
    }

    func webSessionURL() async throws(NetworkingError) -> URL {
        throw NetworkingError.requestFailed(FakeError.notMocked)
    }
    
    func oneTimeCode() async throws(NetworkingError) -> String {
        throw NetworkingError.requestFailed(FakeError.notMocked)
    }
    
    func frontendJWT() async throws(NetworkingError) -> String {
        throw NetworkingError.requestFailed(FakeError.notMocked)
    }
    
    func authenticatedURLSession() -> AuthenticatedURLSession {
        AuthenticatedURLSession(
            authenticator: self,
            urlSession: urlSession,
            refreshTokens: { [weak self] in
                try self?.refreshTokens()
            }
        )
    }

    private func refreshTokens() throws {
        throw FakeError.notMocked
    }

#if os(iOS)
    func requestSimplifiedLogin() async throws(SimplifiedLoginError) -> SimplifiedLoginView? {
        throw .simplifiedLoginFailed(FakeError.notMocked)
    }

    let simplifiedLoginAssertion = UUID().uuidString

    func assertionForSimplifiedLogin() async throws(SimplifiedLoginError) -> String? {
        return simplifiedLoginAssertion
    }
#endif
}

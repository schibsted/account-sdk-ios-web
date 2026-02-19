//
// Copyright © 2026 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

public import AuthenticationServices

/// Schibsted Authenticator.
@MainActor
public protocol SchibstedAuthenticating: AnyObject, Sendable {
    /// The current state of the authenticator.
    nonisolated var state: CurrentValueProperty<SchibstedAuthenticatorState> { get }
    /// The authenticator environment.
    nonisolated var environment: SchibstedAuthenticatorEnvironment { get }
    /// The authenticator client identifier.
    nonisolated var clientId: String { get }
    /// The authenticator redirect URI.
    nonisolated var redirectURI: URL { get }

    /// Optional tracking handler.
    nonisolated var tracking: SchibstedAuthenticatorTracking? { get set }

#if os(iOS)
    /// Login using a `ASWebAuthenticationSession`.
    ///
    /// - parameters:
    ///   - presentationContextProvider: A delegate that provides a display context in which the system can present an authentication session to the user.
    ///   - prefersEphemeralWebBrowserSession: A Boolean value that indicates whether the session should ask the browser for a private authentication session.
    ///   - multifactorAuthentication: Optional multi-factor authentication.
    ///   - assertion: A string value used to share identity and security details across different security domains.
    ///   - xDomainId: The session ID used for origin tracking of the login session.
    /// - returns: The logged in user if the login was success; otherwise throws an error.
    @discardableResult
    func login(
        presentationContextProvider: ASWebAuthenticationPresentationContextProviding,
        prefersEphemeralWebBrowserSession: Bool,
        multifactorAuthentication: MultifactorAuthentication?,
        assertion: String?,
        xDomainId: UUID?
    ) async throws(SchibstedAuthenticatorError) -> SchibstedAuthenticatorUser

    /// Completes the login with a deep link URL.
    ///
    /// - parameter url: Full URL from received from the deep link.
    /// - throws: If there was no login to complete, throws an error.
    func completeLoginFromURL(_ url: URL) async throws(SchibstedAuthenticatorError)
#elseif os(tvOS)
    /// Login using a one-time code.
    ///
    /// - parameters:
    ///   - code: A one-time code for logging in.
    ///   - codeVerifier: Proof Key for Code Exchange (PKCE).
    ///   - xDomainId: The session ID used for origin tracking of the login session.
    /// - returns: The logged in user if the login was success; otherwise throws an error.
    @discardableResult
    func login(
        code: String,
        codeVerifier: String,
        xDomainId: UUID?
    ) async throws(SchibstedAuthenticatorError) -> SchibstedAuthenticatorUser
#endif

    /// Logs out the user
    ///
    /// - throws: If the user was not logged in, throws an error
    func logout() throws(KeychainStorageError)

    /// Gets the user profile of the logged-in user.
    ///
    /// - returns: The updated user profile.
    @discardableResult
    func userProfile() async throws(SchibstedAuthenticatorError) -> SchibstedAuthenticatorUserProfile

    /// Gets a web session URL.
    ///
    /// - returns: Web session URL for the default `clientId` and `redirectURI`.
    func webSessionURL() async throws(NetworkingError) -> URL

    /// Gets a web session URL for a given `clientId` and `redirectURI`.
    ///
    /// - parameters:
    ///   - clientId: The client id
    ///   - redirectURI: The redirect URI.
    /// - returns: Web session URL for the provided `clientId` and `redirectURI`.
    func webSessionURL(
        clientId: String,
        redirectURI: URL
    ) async throws(NetworkingError) -> URL

    /// Gets a one-time code.
    func oneTimeCode() async throws(NetworkingError) -> String

    /// Gets a `frontend-jwt` token.
    func frontendJWT() async throws(NetworkingError) -> String

    /// Gets a authenticated URLSession.
    ///
    /// - SeeAlso: ``AuthenticatedURLSession``
    func authenticatedURLSession() -> AuthenticatedURLSession

#if os(iOS)
    /// Requests simplified login
    ///
    /// - returns: A ``SimplifiedLoginView`` view that can be presented directly in SwiftUI or using a `UIHostingController`.
    func requestSimplifiedLogin() async throws(SimplifiedLoginError) -> SimplifiedLoginView?

    /// Gets a assertion (string) used to share identity and security details for simplified login.
    func assertionForSimplifiedLogin() async throws(SimplifiedLoginError) -> String?
#endif
}

#if os(iOS)
public extension SchibstedAuthenticating {
    /// Login using a `ASWebAuthenticationSession`.
    ///
    /// - parameters:
    ///   - presentationContextProvider: A delegate that provides a display context in which the system can present an authentication session to the user.
    ///   - multifactorAuthentication: Optional multi-factor authentication.
    ///   - assertion: A string value used to share identity and security details across different security domains.
    ///   - xDomainId: The session ID used for origin tracking of the login session.
    /// - returns: The logged in user if the login was success; otherwise throws an error.
    @discardableResult
    func login(
        presentationContextProvider: ASWebAuthenticationPresentationContextProviding,
        multifactorAuthentication: MultifactorAuthentication? = nil,
        assertion: String? = nil,
        xDomainId: UUID? = nil
    ) async throws(SchibstedAuthenticatorError) -> SchibstedAuthenticatorUser {
        try await login(
            presentationContextProvider: presentationContextProvider,
            prefersEphemeralWebBrowserSession: false,
            multifactorAuthentication: multifactorAuthentication,
            assertion: assertion,
            xDomainId: xDomainId
        )
    }
}
#endif

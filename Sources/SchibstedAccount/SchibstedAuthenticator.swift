//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import AuthenticationServices
import CryptoKit
import JOSESwift
import Logging

/// Schibsted Authenticator.
public final class SchibstedAuthenticator: SchibstedAuthenticating {
    private let logger = Logger(label: "SchibstedAuthenticator")
    private let urlSession: URLSessionType
    private let jwks: JWKS
    private let webAuthenticationSessionProvider: WebAuthenticationSessionProviding
    private let idTokenValidator: IdTokenValidating
    private let keychainStorage: KeychainStoring
    private var session: WebAuthenticationSessionType?

#if os(iOS)
    private var presentationContextProvider: ASWebAuthenticationPresentationContextProviding?
#endif

    public let environment: SchibstedAuthenticatorEnvironment
    public let clientId: String
    public let redirectURI: URL
    public let state: CurrentValueProperty<SchibstedAuthenticatorState>

    public nonisolated(unsafe) weak var tracking: SchibstedAuthenticatorTracking?

    /// Creates a new Schibsted Authenticator instance.
    ///
    /// - parameters:
    ///   - environment: The environment.
    ///   - clientId: The client id.
    ///   - appIdentifierPrefix: The app identifier prefixed used for keychain sharing / simplified login.
    ///   - redirectURI: The redirect URI.
    public nonisolated convenience init(
        environment: SchibstedAuthenticatorEnvironment,
        clientId: String,
        appIdentifierPrefix: String? = nil,
        redirectURI: URL
    ) {
        self.init(
            environment: environment,
            clientId: clientId,
            redirectURI: redirectURI,
            keychainStorage: KeychainStorage(
                forService: "com.schibsted.account",
                accessGroup: appIdentifierPrefix.map {
                    "\($0).com.schibsted.simplifiedLogin"
                }
            )
        )
    }

    /// Creates a new Schibsted Authenticator instance.
    ///
    /// - parameters:
    ///   - environment: The environment.
    ///   - clientId: The client id.
    ///   - redirectURI: The redirect URI.
    ///   - keychainStorage: The keychain storage.
    public nonisolated convenience init(
        environment: SchibstedAuthenticatorEnvironment,
        clientId: String,
        redirectURI: URL,
        keychainStorage: KeychainStoring
    ) {
        self.init(
            environment: environment,
            clientId: clientId,
            redirectURI: redirectURI,
            webAuthenticationSessionProvider: WebAuthenticationSessionProvider(),
            idTokenValidator: IdTokenValidator(),
            keychainStorage: keychainStorage,
            jwks: RemoteJWKS(
                environment: environment,
                urlSession: URLSession.shared
            ),
            urlSession: URLSession.shared
        )
    }

    nonisolated init(
        environment: SchibstedAuthenticatorEnvironment,
        clientId: String,
        redirectURI: URL,
        webAuthenticationSessionProvider: WebAuthenticationSessionProviding,
        idTokenValidator: IdTokenValidating,
        keychainStorage: KeychainStoring,
        jwks: JWKS,
        urlSession: URLSessionType
    ) {
        self.environment = environment
        self.clientId = clientId
        self.redirectURI = redirectURI
        self.webAuthenticationSessionProvider = webAuthenticationSessionProvider
        self.idTokenValidator = idTokenValidator
        self.keychainStorage = keychainStorage
        self.jwks = jwks
        self.urlSession = urlSession

        do {
            guard let data = try keychainStorage.getValue(forAccount: clientId) else {
                state = CurrentValueProperty(.loggedOut)
                return
            }

            let session = try JSONDecoder().decode(UserSession.self, from: data)
            let user = SchibstedAuthenticatorUser(
                tokens: session.userTokens,
                sdrn: environment.sdrn(userId: session.userTokens.idTokenClaims.userId)
            )

            state = CurrentValueProperty(.loggedIn(user))

            logger.debug("Loaded user '\(user)' from the keychain")
        } catch let error as KeychainStorageError {
            logger.error("Failed to load the stored tokens from the keychain. Error: \(error)")
            state = CurrentValueProperty(.loggedOut)
        } catch {
            logger.error("Failed to decode the stored tokens. Error: \(error)")
            state = CurrentValueProperty(.loggedOut)
        }
    }

#if os(iOS)
    @discardableResult
    public func login(
        presentationContextProvider: ASWebAuthenticationPresentationContextProviding,
        prefersEphemeralWebBrowserSession: Bool,
        multifactorAuthentication: MultifactorAuthentication?,
        assertion: String?,
        xDomainId: UUID?
    ) async throws(SchibstedAuthenticatorError) -> SchibstedAuthenticatorUser {
        guard !state.value.isLoggingIn else {
            logger.warning("Unable to login. User is already in the process of logging in.")
            throw .previousSessionInProgress
        }

        guard let callbackURLScheme = redirectURI.scheme else {
            logger.error("Unable to login. Redirect URI '\(redirectURI)' is missing a scheme.")
            throw .invalidRedirectURIScheme
        }

        state.value = .loggingIn

        guard let authState = AuthState(
            multifactorAuthentication: multifactorAuthentication
        ) else {
            throw .invalidAuthState
        }

        await tracking?.trackLoginStarted(
            xDomainId: xDomainId,
            multifactorAuthentication: multifactorAuthentication
        )

        let (url, error) = await withCheckedContinuation { continuation in
            var session = webAuthenticationSessionProvider.session(
                url: .login(
                    environment: environment,
                    clientId: clientId,
                    redirectURI: redirectURI,
                    authState: authState,
                    assertion: assertion,
                    xDomainId: xDomainId
                ),
                callbackURLScheme: callbackURLScheme,
                completionHandler: {
                    continuation.resume(returning: ($0, $1))
                }
            )

            session.presentationContextProvider = presentationContextProvider
            session.prefersEphemeralWebBrowserSession = prefersEphemeralWebBrowserSession
            session.start()

            // Keep a reference to the presentationContextProvider in case the caller didn't
            self.presentationContextProvider = presentationContextProvider

            // Keep a reference to the session until the callback completes
            self.session = session

            logger.info("Started login session")
        }

        // we have the url and/or error, so we can discard the presentationContextProvider and session
        self.presentationContextProvider = nil
        self.session = nil

        if case ASWebAuthenticationSessionError.canceledLogin? = error {
            logger.warning("User cancelled login.")
            state.value = .loggedOut
            await tracking?.trackLoginFailed(xDomainId: xDomainId, error: .cancelled)
            throw .cancelled
        }

        guard let url else {
            logger.error("Failed to login. Error: \(error.map { "\($0)" } ?? "<nil>")")
            state.value = .loggedOut
            if let error {
                await tracking?.trackLoginFailed(xDomainId: xDomainId, error: .loginFailed(error))
                throw .loginFailed(error)
            } else {
                throw .missingURL
            }
        }

        do {
            let tokens = try await getTokens(from: url, authState: authState)
            let user = SchibstedAuthenticatorUser(
                tokens: tokens,
                sdrn: environment.sdrn(userId: tokens.idTokenClaims.userId)
            )

            try storeUserInKeychain(user)
            logger.info("Stored user '\(user)' in the keychain")

            state.value = .loggedIn(user)
            logger.info("Login completed, user '\(user)' is now logged in")

            return user
        } catch {
            logger.error("Failed to login. Error: \(error)")
            state.value = .loggedOut
            await tracking?.trackLoginFailed(xDomainId: xDomainId, error: .loginFailed(error))
            throw .loginFailed(error)
        }
    }
#endif

    @discardableResult
    public func login(
        code: String,
        codeVerifier: String,
        xDomainId: UUID?
    ) async throws(SchibstedAuthenticatorError) -> SchibstedAuthenticatorUser {
        do {
            await tracking?.trackLoginStarted(
                xDomainId: xDomainId,
                multifactorAuthentication: nil
            )

            let tokens = try await getTokens(
                code: code,
                codeVerifier: codeVerifier
            )
            let user = SchibstedAuthenticatorUser(
                tokens: tokens,
                sdrn: environment.sdrn(userId: tokens.idTokenClaims.userId)
            )

            try storeUserInKeychain(user)
            logger.info("Stored user '\(user)' in the keychain")

            state.value = .loggedIn(user)
            logger.info("Login completed, user '\(user)' is now logged in")

            return user
        } catch {
            logger.error("Failed to login. Error: \(error)")
            state.value = .loggedOut

            await tracking?.trackLoginFailed(
                xDomainId: xDomainId,
                error: .cancelled
            )

            throw .loginFailed(error)
        }
    }

    public func logout() throws(KeychainStorageError) {
        logger.info("Logging out")
        do {
            try keychainStorage.removeValue(forAccount: clientId)
        } catch {
            logger.error("Failed to logout, unable to remove value from keychain")
            throw error
        }
        state.value = .loggedOut
    }

    @discardableResult
    public func userProfile() async throws(SchibstedAuthenticatorError) -> SchibstedAuthenticatorUserProfile {
        do {
            return try await getUserProfile(.withAuthenticatedURLSession)
        } catch {
            throw SchibstedAuthenticatorError.userProfileFailure(error)
        }
    }

    public func webSessionURL() async throws(NetworkingError) -> URL {
        let url = environment.exchangeURL

        let parameters = [
            "type": "session",
            "clientId": clientId,
            "redirectUri": redirectURI.absoluteString
        ]

        let request = URLRequest(url: url, parameters: parameters)

        struct Container: Codable {
            struct Response: Codable {
                let code: String
            }

            let data: Response
        }

        let authenticatedURLSession = authenticatedURLSession()
        let container: Container = try await authenticatedURLSession.data(for: request)

        return environment.webSessionURL(code: container.data.code)
    }

    public func oneTimeCode() async throws(NetworkingError) -> String {
        let url = environment.exchangeURL
        let parameters = [
            "type": "code",
            "clientId": clientId
        ]

        let request = URLRequest(url: url, parameters: parameters)

        struct Container: Codable {
            struct Response: Codable {
                let code: String
            }

            let data: Response
        }

        let authenticatedURLSession = authenticatedURLSession()
        let container: Container = try await authenticatedURLSession.data(for: request)
        return container.data.code
    }

    public func authenticatedURLSession() -> AuthenticatedURLSession {
        AuthenticatedURLSession(
            authenticator: self,
            urlSession: urlSession,
            refreshTokens: { [weak self] in
                try await self?.refreshTokens()
            }
        )
    }

    public func frontendJWT() async throws(NetworkingError) -> String {
        var request = URLRequest(url: environment.frontendJwtURL)
        request.httpShouldHandleCookies = false
        request.httpMethod = "GET"

        struct Response: Codable {
            enum CodingKeys: String, CodingKey {
                case jwt = "id_jwt"
            }
            let jwt: String
        }

        let authenticatedURLSession = authenticatedURLSession()
        let response: Response = try await authenticatedURLSession.data(for: request)
        return response.jwt
    }

#if os(iOS)
    public func requestSimplifiedLogin() async throws(SimplifiedLoginError) -> SimplifiedLoginView? {
        do {
            guard let user = try getSharedUser(),
                  let context = try await getSharedUserContext(tokens: user.tokens) else {
                return nil
            }

            let profile = try await getUserProfile(.withTokens(user.tokens))

            let viewModel = SimplifiedLoginViewModel(
                displayText: context.displayText,
                profile: profile,
                tracking: tracking,
                authenticator: self
            )

            return SimplifiedLoginView(viewModel: viewModel)
        } catch let error as KeychainStorageError {
            throw .keychainStorageError(error)
        } catch let error as DecodingError {
            throw .decodingError(error)
        } catch {
            throw .simplifiedLoginFailed(error)
        }
    }

    public func assertionForSimplifiedLogin() async throws(SimplifiedLoginError) -> String? {
        do {
            guard let user = try getSharedUser() else { return nil }

            var request = URLRequest(url: environment.assertionForSimplifiedLoginURL)
            request.httpShouldHandleCookies = false
            request.httpMethod = "POST"
            request.setAuthorization(.bearer(token: user.tokens.accessToken))

            struct Container: Codable {
                struct Response: Codable, Equatable {
                    let assertion: String
                }

                let data: Response
            }

            // we are intentionally not using the `AuthenticatedURLSession`
            // as we do not want to attempt a token refresh with a refresh token
            // from another app as the client id will mismatch
            // and the response will be HTTP 400 - Bad Request.
            let container: Container = try await urlSession.data(for: request)
            return container.data.assertion
        } catch let error as KeychainStorageError {
            throw .keychainStorageError(error)
        } catch let error as DecodingError {
            throw .decodingError(error)
        } catch {
            throw .simplifiedLoginFailed(error)
        }
    }
#endif

    private func refreshTokens() async throws {
        guard case .loggedIn(let user) = state.value else {
            logger.error("Unable to refresh tokens. User is logged out.")
            throw SchibstedAuthenticatorError.refreshTokenFailed(.userIsLoggedOut)
        }

        do {
            let tokens = try await getTokens(parameters: [
                "client_id": clientId,
                "grant_type": "refresh_token",
                "refresh_token": user.tokens.refreshToken
            ])

            let updatedUser = SchibstedAuthenticatorUser(
                tokens: UserTokens(
                    accessToken: tokens.accessToken,
                    refreshToken: tokens.refreshToken,
                    idTokenClaims: user.tokens.idTokenClaims,
                    expiration: Date(timeIntervalSinceNow: TimeInterval(tokens.expiresIn))
                ),
                sdrn: user.sdrn
            )

            try storeUserInKeychain(updatedUser)

            state.value = .loggedIn(updatedUser)
        } catch {
            if case URLRequestError.httpStatus(_, let data, _) = error, let data {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase

                if let oAuthError = try? decoder.decode(OAuthError.self, from: data),
                   oAuthError.error == "invalid_grant" {
                    try logout()
                }
            }

            throw error
        }
    }

    private func getUserProfile(
        _ request: GetUserProfileRequest
    ) async throws -> SchibstedAuthenticatorUserProfile {
        struct Container: Codable {
            var data: SchibstedAuthenticatorUserProfile
        }

        var urlRequest: URLRequest
        switch request {
        case .withTokens(let userTokens):
            urlRequest = URLRequest(url: environment.userProfileURL(userUUID: userTokens.idTokenClaims.sub))
            urlRequest.httpShouldHandleCookies = false
            urlRequest.httpMethod = "GET"
            urlRequest.setAuthorization(.bearer(token: userTokens.accessToken))
        case .withAuthenticatedURLSession:
            switch state.value {
            case .loggedIn(let user):
                urlRequest = URLRequest(url: environment.userProfileURL(userUUID: user.tokens.idTokenClaims.sub))
                urlRequest.httpShouldHandleCookies = false
                urlRequest.httpMethod = "GET"
            default:
                throw SchibstedAuthenticatorError.notLoggedIn
            }
        }

        let urlSessionForRequest = switch request {
        case .withTokens:
            urlSession
        case .withAuthenticatedURLSession:
            authenticatedURLSession()
        }

        let decoder = JSONDecoder(dateDecodingStrategy: .formatted(DateFormatter(dateFormat: "yyyy-MM-dd HH:mm:ss")))
        let container: Container = try await urlSessionForRequest.data(for: urlRequest, decoder: decoder)
        return container.data
    }

    private func getSharedUserContext(
        tokens: UserTokens
    ) async throws -> UserContextFromTokenResponse? {
        var request = URLRequest(url: environment.userContextFromTokenURL)
        request.httpShouldHandleCookies = false
        request.httpMethod = "GET"
        request.setAuthorization(.bearer(token: tokens.accessToken))

        // we are intentionally not using the `AuthenticatedURLSession`
        // as we do not want to attempt a token refresh with a refresh token
        // from another app as the client id will mismatch
        // and the response will be HTTP 400 - Bad Request.
        return try await urlSession.data(for: request)
    }

    private func getSharedUser() throws -> SchibstedAuthenticatorUser? {
        guard let data = try keychainStorage.getAll(forAccount: nil) else {
            return nil
        }

        let userSession = try data
            .map { try JSONDecoder().decode(UserSession.self, from: $0) }
            .sorted { $0.updatedAt > $1.updatedAt }
            .first

        guard let userSession else {
            return nil
        }

        let idTokenClaims = userSession.userTokens.idTokenClaims

        guard idTokenClaims.iss.removeTrailingSlash() == environment.issuer.removeTrailingSlash() else {
            logger.error("Invalid issuer in the ID Token Claims. Found \(environment.issuer.removeTrailingSlash()), expected \(idTokenClaims.iss.removeTrailingSlash())")
            throw IdTokenValidationError.invalidIssuer
        }

        return SchibstedAuthenticatorUser(
            tokens: userSession.userTokens,
            sdrn: environment.sdrn(userId: idTokenClaims.userId)
        )
    }

    private func storeUserInKeychain(_ user: SchibstedAuthenticatorUser) throws {
        let session = UserSession(
            userTokens: user.tokens,
            updatedAt: Date()
        )
        do {
            try keychainStorage.setValue(JSONEncoder().encode(session), forAccount: clientId)
        } catch {
            logger.error("Failed to store user '\(user)' in keychain. Error: \(error)")
            throw error
        }
    }

    /// Extracts the `code` from the URL and then use it to request
    /// a fresh set of User Tokens (Access, Refresh and ID).
    private func getTokens(
        from url: URL,
        authState: AuthState
    ) async throws -> UserTokens {
        logger.debug("Parsing callback url '\(url)'")

        // If the path contains `cancel`, assume the request been cancelled.
        if url.pathComponents.contains("cancel") {
            throw SchibstedAuthenticatorError.cancelled
        }

        // If there's a `error` query parameter, assume the request failed
        // and parse the error into a `OAuthError` we can throw.
        if let error = url[queryItem: "error"] {
            let error = SchibstedAuthenticatorError.oauth(OAuthError(
                error: error,
                description: url[queryItem: "error_description"]
            ))
            throw error
        }

        // Retrive the login code from the URL.
        guard let code = url[queryItem: "code"] else {
            throw SchibstedAuthenticatorError.missingCode
        }

        // The `state` query parameter should match our auth state.
        // See https://auth0.com/docs/secure/attack-protection/state-parameters
        let state = url[queryItem: "state"]
        guard let state, authState.state == state else {
            logger.error("Unsolicited response. State mismatch, found '\(state ?? "<nil>")', expected '\(authState.state)'.")
            throw SchibstedAuthenticatorError.unsolicitedResponse
        }

        return try await getTokens(
            code: code,
            codeVerifier: authState.codeVerifier,
            nonce: authState.nonce,
            expectedAMR: authState.multifactorAuthentication?.rawValue
        )
    }

    private func getTokens(
        code: String,
        codeVerifier: String,
        nonce: String? = nil,
        expectedAMR: String? = nil
    ) async throws -> UserTokens {
        let tokens = try await getTokens(parameters: [
            "client_id": clientId,
            "code": code,
            "redirect_uri": redirectURI.absoluteString,
            "code_verifier": codeVerifier,
            "grant_type": "authorization_code"
        ])

        return try await validateTokens(
            tokens: tokens,
            nonce: nonce,
            expectedAMR: expectedAMR
        )
    }

    private func getTokens(parameters: [String: String]) async throws -> TokenResponse {
        var request = URLRequest(url: environment.tokenURL, parameters: parameters)
        request.setValue("v1", forHTTPHeaderField: "X-OIDC")

        // We explicitly don't handle 401s when requesting the tokens
        // as it would otherwise result in a infinite request loop.
        return try await urlSession.data(for: request)
    }

    private func validateTokens(
        tokens: TokenResponse,
        nonce: String?,
        expectedAMR: String?
    ) async throws -> UserTokens {
        let claims = try await idTokenValidator.validate(
            idToken: tokens.idToken,
            jwks: jwks,
            issuer: environment.issuer,
            clientId: clientId,
            nonce: nonce,
            expectedAMR: expectedAMR
        )

        return UserTokens(
            accessToken: tokens.accessToken,
            refreshToken: tokens.refreshToken,
            idTokenClaims: claims,
            expiration: Date(timeIntervalSinceNow: TimeInterval(tokens.expiresIn))
        )
    }
}

private extension URL {
    /// Creates an login URL.
    ///
    /// - parameters:
    ///   - environment: The environment.
    ///   - clientId: The client id.
    ///   - redirectURI: The redirect URI.
    ///   - authState: The auth state.
    ///   - assertion: Optional assertion.
    ///   - assertion: A string value used to share identity and security details across different security domains.
    ///   - xDomainId: The session ID used for origin tracking of the login session.
    static func login(
        environment: SchibstedAuthenticatorEnvironment,
        clientId: String,
        redirectURI: URL,
        authState: AuthState,
        assertion: String?,
        xDomainId: UUID?
    ) -> URL {
        let codeChallenge = Data(SHA256.hash(data: Data(authState.codeVerifier.utf8)))

        var queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectURI.absoluteString),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: "openid offline_access"),
            URLQueryItem(name: "state", value: authState.state),
            URLQueryItem(name: "nonce", value: authState.nonce),
            URLQueryItem(name: "code_challenge", value: codeChallenge.base64URLEncodedString()),
            URLQueryItem(name: "code_challenge_method", value: "S256")
        ]

        if let assertion {
            queryItems.append(URLQueryItem(name: "assertion", value: assertion))
        }

        if let xDomainId {
            queryItems.append(URLQueryItem(name: "x_domain_id", value: xDomainId.uuidString))
        }

        if let multifactorAuthentication = authState.multifactorAuthentication {
            queryItems.append(URLQueryItem(name: "acr_values", value: multifactorAuthentication.rawValue))
        } else {
            queryItems.append(URLQueryItem(name: "prompt", value: "select_account"))
        }

        return environment.authorizeURL.appending(queryItems: queryItems)
    }
}

// Container for various auth states
private struct AuthState: Codable, Sendable {
    // A random string used to prevent CSRF attacks.
    let state: String
    // A random value that will be bound to the ID Token and that can be used to mitigate replay attacks.
    let nonce: String
    // Proof Key for Code Exchange (PKCE).
    let codeVerifier: String
    // Multi-factor Authentication.
    let multifactorAuthentication: MultifactorAuthentication?

    init?(multifactorAuthentication: MultifactorAuthentication? = nil) {
        guard let state = String.secureRandom(length: 10),
              let nonce = String.secureRandom(length: 10),
              let codeVerifier = String.secureRandom(length: 60) else {
            return nil
        }
        self.state = state
        self.nonce = nonce
        self.codeVerifier = codeVerifier
        self.multifactorAuthentication = multifactorAuthentication
    }
}

private struct UserContextFromTokenResponse: Codable, Equatable {
    enum CodingKeys: String, CodingKey {
        case identifier
        case displayText = "display_text"
        case clientName = "client_name"
    }

    // User Identifier.
    let identifier: String
    // User Display Name.
    let displayText: String
    // Client Name (e.g. Aftonbladet).
    let clientName: String
}

// Token Response, see https://docs.schibsted.io/schibsted-account/guides/tokens/#obtaining-user-tokens
private struct TokenResponse: Codable, Equatable, Sendable {
    // Access token.
    let accessToken: String
    // Refresh token.
    let refreshToken: String
    // ID token.
    let idToken: String?
    // Access token expiration
    let expiresIn: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case idToken = "id_token"
        case expiresIn = "expires_in"
    }
}

private enum GetUserProfileRequest {
    case withTokens(UserTokens)
    case withAuthenticatedURLSession
}

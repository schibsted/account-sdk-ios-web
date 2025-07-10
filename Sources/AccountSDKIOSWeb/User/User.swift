//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

@MainActor
public protocol UserDelegate: AnyObject {
    func userDidLogout()
}

@MainActor
public protocol UserProtocol: Sendable {
    var delegates: MulticastDelegate<UserDelegate> { get }
    var uuid: String? { get }
    var userId: String? { get }

    func logout()
    func isLoggedIn() -> Bool

    func webSessionURL(
        clientId: String,
        redirectURI: String,
        state: String?,
        completion: @escaping HTTPResultHandler<URL>
    )

    func oneTimeCode(
        clientId: String,
        completion: @escaping HTTPResultHandler<String>
    )

    func fetchProfileData(completion: @escaping HTTPResultHandler<UserProfileResponse>)
}

/// Representation of logged-in user.
@MainActor
public class User: UserProtocol {
    let client: Client
    var tokens: UserTokens?

    /**
     Sets the tokens. Should only be used when testing.
     */
    public func setTokens(_ tokens: UserTokens) {
        self.tokens = tokens
    }

    /// Delegates listening to User events such as logout
    public let delegates: MulticastDelegate = MulticastDelegate<UserDelegate>()

    let refreshHandler = TokenRefreshRequestHandler()

    /// user idToken
    public var idToken: String? {
        return tokens?.idToken
    }

    /// User UUID
    public var uuid: String? {
        return tokens?.idTokenClaims.sub
    }

    /**
     User integer id (as string). Equivalent of legacyID in old AccountSDK

     A user_id used by some Schibsted account APIs
     */
    public var userId: String? {
        return tokens?.idTokenClaims.userId
    }

    internal init(client: Client, tokens: UserTokens) {
        self.client = client
        self.tokens = tokens
    }

    /**
     Log user out
     
     Will remove stored session, including all user tokens.
     */
    public func logout() {
        tokens = nil
        client.destroySession()
        self.delegates.invokeDelegates({ $0.userDidLogout() })
    }

    /**
     Check if this user is logged-in.
         
     The user may have been logged out either explicitly via `logout` method or automatically if no valid
     tokens could be obtained (e.g. due to expired or invalidated refresh token).
     */
    public func isLoggedIn() -> Bool {
        return tokens != nil
    }

    /**
     Generate URL with embedded one-time code for creating a web session for the current user.
     
     - parameter clientId: which client to get the code on behalf of, e.g. client id for associated web application. Needs to be from the same merchant.
     - parameter redirectURI: where to redirect the user after the session has been created. The exact redirect URI must be registered for the given client in Self Service.
     - parameter state: An opaque value used by the client to maintain state between
     - parameter completion: The callback that receives the URL or an error in case of failure
     */
    public func webSessionURL(
        clientId: String,
        redirectURI: String,
        state: String? = nil,
        completion: @escaping HTTPResultHandler<URL>
    ) {
        client.schibstedAccountAPI.sessionExchange(
            for: self,
            clientId: clientId,
            redirectURI: redirectURI,
            state: state
        ) { result in
            switch result {
            case .success(let response):
                let url = self.client.configuration.serverURL.appendingPathComponent("/session/\(response.code)")
                completion(.success(url))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /**
     Requests a OAuth authorization code for the current user.
     The code is short-lived and one-time use only.
    
     - parameter clientId: which client to get the code on behalf of, e.g. client id for associated web application
     - parameter completion: callback that receives the one time code
     */
    public func oneTimeCode(clientId: String, completion: @escaping HTTPResultHandler<String>) {
        client.schibstedAccountAPI.codeExchange(for: self, clientId: clientId) { result in
            switch result {
            case .success(let response):
                let code = response.code
                completion(.success(code))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /// Fetch user profile data
    public func fetchProfileData(completion: @escaping HTTPResultHandler<UserProfileResponse>) {
        client.schibstedAccountAPI.userProfile(for: self, completion: completion)
    }
}

extension User {
    func userContextFromToken(completion: @escaping HTTPResultHandler<UserContextFromTokenResponse>) {
        client.schibstedAccountAPI.userContextFromToken(for: self, completion: completion)
    }

    func assertionForSimplifiedLogin(completion: @escaping HTTPResultHandler<SimplifiedLoginAssertionResponse>) {
        self.client.schibstedAccountAPI.assertionForSimplifiedLogin(for: self, completion: completion)
    }

    static func shouldLogout(tokenResponseBody: String?) -> Bool {
        if let errorJSON = tokenResponseBody,
           let oauthError = OAuthError.fromJSON(errorJSON),
           oauthError.error == "invalid_grant" {
            return true
        }

        return false
    }

    func refreshTokens(completion: @escaping @MainActor (Result<UserTokens, RefreshTokenError>) -> Void) {
        self.refreshHandler.refreshWithoutRetry(user: self, completion: completion)
    }

    func makeRequest<T: Decodable>(request: URLRequest, completion: @escaping HTTPResultHandler<T>) {
        guard let tokens = self.tokens else {
            completion(.failure(.unexpectedError(underlying: LoginStateError.notLoggedIn)))
            return
        }
        var requestCopy = request
        requestCopy.setValue("Bearer \(tokens.accessToken)", forHTTPHeaderField: "Authorization")
        client.httpClient.execute(request: requestCopy, completion: completion)
    }

    /**
     Perform a request with user access token as Bearer token in Authorization header.
     
     If the initial request fails with a 401, a refresh token request is made to get a new access token and the request will be retried with the new token if successful.
     If the refresh token request fails with an OAuth 'invalid_grant' error response, meaning the refresh token has expired or been invalidated, the user will be
     logged-out (and all existing tokens will be destroyed).

     - parameter request: request to perform with authentication using user tokens
     - parameter completion: callback that receives the HTTP response or an error in case of failure
     */
    func withAuthentication<T: Decodable>(request: URLRequest, completion: @escaping HTTPResultHandler<T>) {
        makeRequest(request: request) { (requestResult: Result<T, HTTPError>) in
            switch requestResult {
            case .failure(.errorResponse(let code, let body)):
                // 401 might indicate expired access token
                if code == 401 {
                    self.refreshHandler.refreshWithRetry(user: self,
                                                         requestResult: requestResult,
                                                         request: request,
                                                         completion: completion)
                } else {
                    completion(.failure(.errorResponse(code: code, body: body)))
                }
            default:
                completion(requestResult)
            }
        }
    }
}

// MARK: NetworkRefreshRequestHandler

extension User {
    /// TokenRefreshRequestHandler is responsible for calling refresh once,  and queuing subsequent requests to wait for the One refresh.
    @MainActor
    final class TokenRefreshRequestHandler {

        // swiftlint:disable:next nesting
        private enum State {
            case isRefreshing
            case notRefreshing
        }

        private let isTokenRefreshing: Synchronized<State> = .init(.notRefreshing)
        private let requestsOnRefreshFailure: Synchronized<[@MainActor (Result<UserTokens, RefreshTokenError>) -> Void]> = .init([])
        private let requestsOnRefreshSuccess: Synchronized<[DispatchWorkItem]> = .init([])
        private let completionsOnRefreshWithoutRetry: Synchronized<[@MainActor (Result<UserTokens, RefreshTokenError>) -> Void]> = .init([])
        private let tokenRefresher: UserTokensRefreshing
        private let requestMaker: UserRequestMaking

        init(
            tokenRefresher: UserTokensRefreshing = DefaultUserTokensRefresher(),
            requestMaker: UserRequestMaking = DefaultUserRequestMaker()
        ) {
            self.tokenRefresher = tokenRefresher
            self.requestMaker = requestMaker
        }

        // MARK: Refresh flows

        func refreshWithRetry<T: Decodable>(
            user: User,
            requestResult: Result<T, HTTPError>,
            request: URLRequest,
            completion: @escaping HTTPResultHandler<T>
        ) {
            // Save work to be executed on refresh success and failure
            let requestMaker = self.requestMaker
            saveRequestOnRefreshSuccess {
                requestMaker.makeRequest(user: user, request: request, completion: completion)
            }
            saveRequestOnRefreshFailure(initialRequestResult: requestResult, completion: completion)

            switch isTokenRefreshing.value {
            case .notRefreshing:
                isTokenRefreshing.modify { _ in .isRefreshing }
                refreshAndExecute(user: user)
            case .isRefreshing:
                break
            }
        }

        func refreshWithoutRetry(user: User, completion: @escaping @MainActor (Result<UserTokens, RefreshTokenError>) -> Void) {
            saveRefreshWithoutRetryCompletion(completion: completion) // Save work to be executed after refresh

            switch isTokenRefreshing.value {
            case .notRefreshing:
                isTokenRefreshing.modify { _ in .isRefreshing }
                refreshAndExecute(user: user)
            case .isRefreshing:
                break
            }
        }

        private func refreshAndExecute(user: User) {
            tokenRefresher.refreshTokens(for: user) { result in
                self.isTokenRefreshing.modify { _ in .notRefreshing }
                self.executeAfterRefresh(with: result)

                switch result {
                case .success:
                    // On successfull refresh. Execute all waiting requests.
                    self.executeRequestOnRefreshSuccess()
                case .failure(.refreshRequestFailed(.errorResponse(_, let body))):
                    // Should logout on invalid grant
                    if User.shouldLogout(tokenResponseBody: body) {
                        SchibstedAccountLogger.instance.info("Invalid refresh token, logging user out")
                        user.logout()
                    }

                    self.executeOnRefreshFailure(with: result)
                default:
                    self.executeOnRefreshFailure(with: result)
                }
            }
        }

        // MARK: Read and write request lists

        private func saveRefreshWithoutRetryCompletion(completion: @escaping @MainActor (Result<UserTokens, RefreshTokenError>) -> Void) {
            completionsOnRefreshWithoutRetry.modify { currentValue in
                var newValue = currentValue
                newValue.append(completion)
                return newValue
            }
        }

        private func saveRequestOnRefreshSuccess(_ block: @escaping @MainActor () -> Void) {
            requestsOnRefreshSuccess.modify { currentValue in
                var newValue = currentValue
                let item = DispatchWorkItem {
                    DispatchQueue.main.async {
                        block()
                    }
                }
                newValue.append(item)
                return newValue
            }
        }

        private func saveRequestOnRefreshFailure<T: Decodable>(
            initialRequestResult: Result<T, HTTPError>,
            completion: @escaping HTTPResultHandler<T>
        ) {
            let failure: @MainActor (Result<UserTokens, RefreshTokenError>) -> Void = { result in
                switch result {
                case .failure(.refreshRequestFailed(.errorResponse(_, let body))):
                    guard User.shouldLogout(tokenResponseBody: body) else {
                        completion(initialRequestResult)
                        return
                    }
                    completion(.failure(.unexpectedError(underlying: LoginStateError.notLoggedIn)))
                case .failure:
                    completion(initialRequestResult)

                default: // Should not get here
                    completion(initialRequestResult)
                }
            }

            requestsOnRefreshFailure.modify { currentValue in
                var newValue = currentValue
                newValue.append(failure)
                return newValue
            }
        }

        private func removeAll() {
            requestsOnRefreshSuccess.modify { _ in [] }
            requestsOnRefreshFailure.modify { _ in [] }
        }

        // MARK: Execute requests and completions

        private func executeRequestOnRefreshSuccess() {
            requestsOnRefreshSuccess.value.forEach({
                DispatchQueue.main.async(execute: $0)
            }) // Execute in FIFO order.
            removeAll()
        }

        private func executeOnRefreshFailure(with result: Result<UserTokens, RefreshTokenError>) {
            requestsOnRefreshFailure.value.forEach { $0(result) }
            removeAll()
        }

        private func executeAfterRefresh(with result: Result<UserTokens, RefreshTokenError>) {
            completionsOnRefreshWithoutRetry.value.forEach { $0(result) }
            completionsOnRefreshWithoutRetry.modify { _ in [] }
        }
    }
}

protocol UserTokensRefreshing: AnyObject {
    @MainActor
    func refreshTokens(for user: User, completion: @escaping @MainActor (Result<UserTokens, RefreshTokenError>) -> Void)
}

final class DefaultUserTokensRefresher: UserTokensRefreshing {
    @MainActor
    func refreshTokens(for user: User, completion: @escaping @MainActor (Result<UserTokens, RefreshTokenError>) -> Void) {
        user.client.refreshTokens(for: user, completion: completion)
    }
}

protocol UserRequestMaking: AnyObject {
    @MainActor
    func makeRequest<T: Decodable>(user: User, request: URLRequest, completion: @escaping HTTPResultHandler<T>)
}

final class DefaultUserRequestMaker: UserRequestMaking {
    @MainActor
    func makeRequest<T>(
        user: User,
        request: URLRequest,
        completion: @escaping HTTPResultHandler<T>
    ) where T: Decodable {
        user.makeRequest(request: request, completion: completion)
    }
}

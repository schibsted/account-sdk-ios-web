//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import XCTest
import Cuckoo

@testable import AccountSDKIOSWeb

final class ClientTests: XCTestCase {
    private static let keyId = "test key"
    private static nonisolated(unsafe) var jwsUtil: JWSUtil!
    
    override class func setUp() {
        jwsUtil = JWSUtil()
    }

    @MainActor
    func testHandleAuthenticationResponseRejectsUnsolicitedResponse() {
        let mockStorage = MockStorage()
        stub(mockStorage) { mock in
            when(mock.value(forKey: Client.authStateKey)).thenReturn(nil)
        }
        let client = Client(configuration: Fixtures.clientConfig, sessionStorage: MockSessionStorage(), stateStorage: StateStorage(storage: mockStorage))
        
        Await.until { done in
            client.handleAuthenticationResponse(url: URL(staticString: "com.example://login?state=no-exist&code=123456")) { result in
                XCTAssertEqual(result.error, .unsolicitedResponse)
                DispatchQueue.main.async { done() }
            }
        }
    }

    @MainActor
    func testHandleAuthenticationResponseHandlesErrorResponse() {
        let state = "testState"
        let mockStorage = MockStorage()
        stub(mockStorage) { mock in
            let authState = AuthState(state: state, nonce: "testNonce", codeVerifier: "codeVerifier", mfa: nil)
            when(mock.value(forKey: Client.authStateKey)).thenReturn(try! JSONEncoder().encode(authState))
            when(mock.removeValue(forKey: Client.authStateKey)).thenDoNothing()
        }
        
        let client = Client(configuration: Fixtures.clientConfig, sessionStorage: MockSessionStorage(), stateStorage: StateStorage(storage: mockStorage))
        Await.until { done in
            client.handleAuthenticationResponse(url: URL(string: "com.example://login?state=\(state)&error=invalid_request&error_description=test%20error")!) { result in
                XCTAssertEqual(result.error, .authenticationErrorResponse(error: OAuthError(error: "invalid_request", errorDescription: "test error")))
                DispatchQueue.main.async { done() }
            }
        }
    }

    @MainActor
    func testHandleAuthenticationResponseHandlesMissingAuthCode() {
        let state = "testState"
        let mockStorage = MockStorage()
        stub(mockStorage) { mock in
            let authState = AuthState(state: state, nonce: "testNonce", codeVerifier: "codeVerifier", mfa: nil)
            when(mock.value(forKey: Client.authStateKey)).thenReturn(try! JSONEncoder().encode(authState))
            when(mock.removeValue(forKey: Client.authStateKey)).thenDoNothing()
        }

        let client = Client(configuration: Fixtures.clientConfig, sessionStorage: MockSessionStorage(), stateStorage: StateStorage(storage: mockStorage))
        Await.until { done in
            client.handleAuthenticationResponse(url: URL(string: "com.example://login?state=\(state)")!) { result in
                XCTAssertEqual(result.error, .unexpectedError(message: "Missing authorization code from authentication response"))
                DispatchQueue.main.async { done() }
            }
        }
    }

    @MainActor
    func testHandleAuthenticationResponseHandlesSuccessResponse() {
        let idToken = createIdToken(claims: Fixtures.idTokenClaims)
        let tokenResponse = TokenResponse(accessToken: "accessToken", refreshToken: "refreshToken", idToken: idToken, scope: "openid", expiresIn: 3600)
        let mockHTTPClient = MockHTTPClient()

        stub(mockHTTPClient) { mock in
            when(mock.execute(request: ParameterMatcher(), withRetryPolicy: ParameterMatcher(), completion: ParameterMatcher()))
                .then { _, _, completion in
                    completion(.success(tokenResponse))
                }

            let jwksResponse = JWKSResponse(keys: [RSAJWK(kid: ClientTests.keyId, kty: "RSA", e: ClientTests.jwsUtil.publicJWK.exponent, n: ClientTests.jwsUtil.publicJWK.modulus, alg: "RS256", use: "sig")])
            when(mock.execute(request: ParameterMatcher(), withRetryPolicy: ParameterMatcher(), completion: ParameterMatcher()))
                .then { _, _, completion in
                    completion(.success(jwksResponse))
                }
        }

        let mockSessionStorage = MockSessionStorage()
        stub(mockSessionStorage) { mock in
            when(mock.store(any(), accessGroup: any())).then {_ in }
        }
        let state = "testState"
        let mockStorage = MockStorage()
        stub(mockStorage) { mock in
            let authState = AuthState(state: state, nonce: Fixtures.idTokenClaims.nonce!, codeVerifier: "codeVerifier", mfa: nil)
            when(mock.value(forKey: Client.authStateKey)).thenReturn(try! JSONEncoder().encode(authState))
            when(mock.removeValue(forKey: Client.authStateKey)).thenDoNothing()
        }

        let client = Client(configuration: Fixtures.clientConfig, sessionStorage: mockSessionStorage, stateStorage: StateStorage(storage: mockStorage), httpClient: mockHTTPClient)
        Await.until { done in
            client.handleAuthenticationResponse(url: URL(string: "com.example://login?code=12345&state=\(state)")!) { result in
                let expectedTokens = UserTokens(accessToken: tokenResponse.accessToken, refreshToken: tokenResponse.refreshToken, idToken: tokenResponse.idToken!, idTokenClaims: Fixtures.idTokenClaims)
                DispatchQueue.main.async {
                    XCTAssertEqual(result.successValue?.client.configuration.clientId, client.configuration.clientId)
                    XCTAssertEqual(result.successValue?.tokens, expectedTokens)
                    XCTAssertEqual(client.state, state)
                    done()
                }
            }
        }
    }

    @MainActor
    func testHandleAuthenticationResponseHandlesTokenErrorResponse() {
        let mockSessionStorage = MockSessionStorage()
        stub(mockSessionStorage) { mock in
            when(mock.store(any(), accessGroup: any())).thenDoNothing()
        }
        let state = "testState"
        let mockStorage = MockStorage()
        stub(mockStorage) { mock in
            let authState = AuthState(state: state, nonce: Fixtures.idTokenClaims.nonce!, codeVerifier: "codeVerifier", mfa: nil)
            when(mock.value(forKey: Client.authStateKey)).thenReturn(try! JSONEncoder().encode(authState))
            when(mock.removeValue(forKey: Client.authStateKey)).thenDoNothing()
        }
        
        let testData = [
            (
                HTTPError.errorResponse(code: 400, body: "{\"error\": \"invalid_request\", \"error_description\": \"test error\"}"),
                LoginError.tokenErrorResponse(error: OAuthError(error: "invalid_request", errorDescription: "test error"))
            ),
            (
                HTTPError.unexpectedError(underlying: HTTPError.noData),
                LoginError.unexpectedError(message: "Failed to obtain user tokens: \(TokenError.tokenRequestError(AccountSDKIOSWeb.HTTPError.unexpectedError(underlying: AccountSDKIOSWeb.HTTPError.noData)))")
            )
        ]
        for (returnedResponse, expectedResult) in testData {
            let mockHTTPClient = MockHTTPClient()
            stub(mockHTTPClient) { mock in
                when(mock.execute(request: any(), withRetryPolicy: any(), completion: ParameterMatcher()))
                    .then { (_, _, completion: HTTPResultHandler<TokenResponse>) in
                        completion(.failure(returnedResponse))
                    }
            }
            
            let client = Client(configuration: Fixtures.clientConfig, sessionStorage: mockSessionStorage, stateStorage: StateStorage(storage: mockStorage), httpClient: mockHTTPClient)
            Await.until { done in
                client.handleAuthenticationResponse(url: URL(string: "com.example://login?code=12345&state=\(state)")!) { result in
                    XCTAssertEqual(result.error, expectedResult)
                    DispatchQueue.main.async { done() }
                }
            }
        }
    }

    @MainActor
    func testHandleAuthenticationResponseRejectsExpectedAMRValueInIdToken() {
        let nonce = "testNonce"
        let claims = Fixtures.idTokenClaims.copy(amr: OptionalValue(nil)) // no AMR in ID Token
        let idToken = createIdToken(claims: claims)
        let tokenResponse = TokenResponse(accessToken: "accessToken", refreshToken: "refreshToken", idToken: idToken, scope: "openid", expiresIn: 3600)
        let mockHTTPClient = MockHTTPClient()
        
        stub(mockHTTPClient) { mock in
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: ParameterMatcher()))
                .then { _, _, completion in
                    completion(.success(tokenResponse))
                }
            
            let jwksResponse = JWKSResponse(keys: [RSAJWK(kid: ClientTests.keyId, kty: "RSA", e: ClientTests.jwsUtil.publicJWK.exponent, n: ClientTests.jwsUtil.publicJWK.modulus, alg: "RS256", use: "sig")])
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: ParameterMatcher()))
                .then { _, _, completion in
                    completion(.success(jwksResponse))
                }
        }

        let state = "testState"
        let mockStorage = MockStorage()
        stub(mockStorage) { mock in
            let authState = AuthState(state: state, nonce: nonce, codeVerifier: "codeVerifier", mfa: MFAType.otp)
            when(mock.value(forKey: Client.authStateKey)).thenReturn(try! JSONEncoder().encode(authState))
            when(mock.removeValue(forKey: Client.authStateKey)).thenDoNothing()
        }
        
        let client = Client(configuration: Fixtures.clientConfig, sessionStorage: MockSessionStorage(), stateStorage: StateStorage(storage: mockStorage), httpClient: mockHTTPClient)
        Await.until { done in
            client.handleAuthenticationResponse(url: URL(string: "com.example://login?code=12345&state=\(state)")!) { result in
                XCTAssertEqual(result.error, .missingExpectedMFA)
                DispatchQueue.main.async { done() }
            }
        }
    }

    @MainActor
    func testHandleAuthenticationResponseCancelResponse() {
        let mockStorage = MockStorage()
        stub(mockStorage) { mock in
            when(mock.value(forKey: Client.authStateKey)).thenReturn(nil)
        }
        let client = Client(configuration: Fixtures.clientConfig, sessionStorage: MockSessionStorage(), stateStorage: StateStorage(storage: mockStorage))
        
        Await.until { done in
            client.handleAuthenticationResponse(url: URL(staticString: "com.example:/cancel")) { result in
                XCTAssertEqual(result.error, .canceled)
                DispatchQueue.main.async { done() }
            }
        }
    }

    @MainActor
    func testResumeLastLoggedInUserWithExistingSession() {
        let session = UserSession(clientId: Fixtures.clientConfig.clientId, userTokens: Fixtures.userTokens, updatedAt: Date())
        let mockSessionStorage = MockSessionStorage()
        stub(mockSessionStorage) { mock in
            when(mock.get(forClientId: Fixtures.clientConfig.clientId)).thenReturn(session)
        }

        let client = Client(configuration: Fixtures.clientConfig, sessionStorage: mockSessionStorage, stateStorage: StateStorage(storage: MockStorage()))
        let user = client.resumeLastLoggedInUser()
        XCTAssertEqual(user?.client.configuration.clientId, client.configuration.clientId)
        XCTAssertEqual(user?.tokens, Fixtures.userTokens)
    }

    @MainActor
    func testResumeLastLoggedInUserWithoutSession() {
        let mockSessionStorage = MockSessionStorage()
        stub(mockSessionStorage) { mock in
            when(mock.get(forClientId: Fixtures.clientConfig.clientId)).thenReturn(nil)
        }

        let client = Client(configuration: Fixtures.clientConfig, sessionStorage: mockSessionStorage, stateStorage: StateStorage(storage: MockStorage()))
        let user = client.resumeLastLoggedInUser()
        XCTAssertNil(user)
    }

    private func createIdToken(claims: IdTokenClaims) -> String {
        let data = try! JSONEncoder().encode(claims)
        return ClientTests.jwsUtil.createJWS(payload: data, keyId: ClientTests.keyId)
    }

    @MainActor
    func testAccountPagesURL() {
        let client = Client(configuration: Fixtures.clientConfig, httpClient: MockHTTPClient())
        XCTAssertEqual(client.configuration.accountPagesURL.absoluteString, "\(Fixtures.clientConfig.serverURL.absoluteString)/profile-pages")
    }

    @MainActor
    func testDidNotStartNewSessionBeforeFinishingOldOne() {
        let client = Client(configuration: Fixtures.clientConfig, httpClient: MockHTTPClient())
        let firstSession = client.getLoginSession { result in
            if result.error == .previousSessionInProgress {
                XCTFail("Failed to create first session. This should never happened")
            }
        }
        let secondSession = client.getLoginSession { result in
            XCTAssertEqual(result.error, LoginError.previousSessionInProgress)
        }
        let thirdSession = client.getLoginSession { result in
            XCTAssertEqual(result.error, LoginError.previousSessionInProgress)
        }
        XCTAssertNotNil(firstSession)
        XCTAssertNil(secondSession)
        XCTAssertNil(thirdSession)
    }

    @MainActor
    func testDoNotRetryStoringToKeychainInCaseOfSuccess() {
        let idToken = createIdToken(claims: Fixtures.idTokenClaims)
        let tokenResponse = TokenResponse(accessToken: "accessToken", refreshToken: "refreshToken", idToken: idToken, scope: "openid", expiresIn: 3600)
        let mockHTTPClient = MockHTTPClient()

        stub(mockHTTPClient) { mock in
            when(mock.execute(request: ParameterMatcher(), withRetryPolicy: ParameterMatcher(), completion: ParameterMatcher()))
                .then { _, _, completion in
                    completion(.success(tokenResponse))
                }
        }
        
        let mockSessionStorage = MockSessionStorage()
        
        stub(mockSessionStorage) { mock in
            when(mock.store(any(), accessGroup: any())).then {_ in }
        }
        let stateStorage = StateStorage(storage: MockStorage())
        
        let client = Client(configuration: Fixtures.clientConfig, sessionStorage: mockSessionStorage, stateStorage: stateStorage, httpClient: mockHTTPClient)
        
        let user = User(client: client, tokens: Fixtures.userTokens)
        
        client.refreshTokens(for: user) { result in
            switch result {
            case .success(let tokens):
                let expectedTokens = UserTokens(accessToken: tokenResponse.accessToken, refreshToken: tokenResponse.refreshToken, idToken: user.tokens!.idToken, idTokenClaims: Fixtures.idTokenClaims)
                XCTAssertEqual(tokens, expectedTokens)
            case .failure(let error):
                XCTFail("Unexprected error \(error.localizedDescription)")
            }
        }
        verify(mockSessionStorage, times(1)).store(any(), accessGroup: any())
    }

    @MainActor
    func testRetryStoringToKeychainInCaseOfFailure() {
        let idToken = createIdToken(claims: Fixtures.idTokenClaims)
        let tokenResponse = TokenResponse(accessToken: "accessToken", refreshToken: "refreshToken", idToken: idToken, scope: "openid", expiresIn: 3600)
        let mockHTTPClient = MockHTTPClient()

        stub(mockHTTPClient) { mock in
            when(mock.execute(request: ParameterMatcher(), withRetryPolicy: ParameterMatcher(), completion: ParameterMatcher()))
                .then { _, _, completion in
                    completion(.success(tokenResponse))
                }
        }
        
        let mockSessionStorage = MockSessionStorage()
        
        stub(mockSessionStorage) { mock in
            when(mock.store(any(), accessGroup: any())).then { _ in
                throw KeychainStorageError.operationError
            }
        }
        let stateStorage = StateStorage(storage: MockStorage())
        
        let client = Client(configuration: Fixtures.clientConfig, sessionStorage: mockSessionStorage, stateStorage: stateStorage, httpClient: mockHTTPClient)
        
        let user = User(client: client, tokens: Fixtures.userTokens)
        
        client.refreshTokens(for: user) { result in
            switch result {
            case .success(_):
                XCTFail("Unexpected success")
            case .failure(let error):
                XCTAssertEqual(String(describing: error), "unexpectedError(error: AccountSDKIOSWeb.KeychainStorageError.operationError)")
            }
        }
        verify(mockSessionStorage, times(2)).store(any(), accessGroup: any())
    }

    @MainActor
    func testSuccessfullSecondAttemptToStoreSessionTokens() {
        let idToken = createIdToken(claims: Fixtures.idTokenClaims)
        let tokenResponse = TokenResponse(accessToken: "accessToken", refreshToken: "refreshToken", idToken: idToken, scope: "openid", expiresIn: 3600)
        let mockHTTPClient = MockHTTPClient()
        var isFirst = true

        stub(mockHTTPClient) { mock in
            when(mock.execute(request: ParameterMatcher(), withRetryPolicy: ParameterMatcher(), completion: ParameterMatcher()))
                .then { _, _, completion in
                    completion(.success(tokenResponse))
                }
        }
        
        let mockSessionStorage = MockSessionStorage()
        
        stub(mockSessionStorage) { mock in
            when(mock.store(any(), accessGroup: any())).then {_ in
                if isFirst {
                    isFirst = false
                    throw KeychainStorageError.operationError
                }
            }
        }
        let stateStorage = StateStorage(storage: MockStorage())
        
        let client = Client(configuration: Fixtures.clientConfig, sessionStorage: mockSessionStorage, stateStorage: stateStorage, httpClient: mockHTTPClient)
        
        let user = User(client: client, tokens: Fixtures.userTokens)
        
        client.refreshTokens(for: user) { result in
            switch result {
            case .success(let tokens):
                let expectedTokens = UserTokens(accessToken: tokenResponse.accessToken, refreshToken: tokenResponse.refreshToken, idToken: user.tokens!.idToken, idTokenClaims: Fixtures.idTokenClaims)
                XCTAssertEqual(tokens, expectedTokens)
            case .failure(let error):
                XCTFail("Unexprected error \(error.localizedDescription)")
            }
        }
        verify(mockSessionStorage, times(2)).store(any(), accessGroup: any())
    }

    @MainActor
    func testGetExternalId() {
        let client = Client(configuration: Fixtures.clientConfig,
                            sessionStorage: MockSessionStorage(),
                            stateStorage: StateStorage(storage: MockStorage()))
        // value generated via : https://emn178.github.io/online-tools/sha256.html
        let mockedHash = "e0b2b31df36848059b44ac0ee6784607b003a3688ac6bbdb196d8465bbc8b281"
        let externalId = client.getExternalId(pairId: "pairId", externalParty: "externalParty", suffix: "optionalSuffix")
        XCTAssertEqual(externalId, mockedHash)
        
        // value generated via : https://emn178.github.io/online-tools/sha256.html
        let mockedHashWithoutSuffix = "386eb5f9c3e56843ff83e43fa3d69fc4c2b2072f8e8036332baefb04e96f28b9"
        let externalIdWithoutSuffix = client.getExternalId(pairId: "pairId", externalParty: "externalParty")
        XCTAssertEqual(externalIdWithoutSuffix, mockedHashWithoutSuffix)
    }
}

fileprivate extension Client {
    convenience init(configuration: ClientConfiguration, sessionStorage: SessionStorage, stateStorage: StateStorage, httpClient: HTTPClient = HTTPClientWithURLSession()) {
        let jwks = RemoteJWKS(jwksURI: configuration.serverURL.appendingPathComponent("/oauth/jwks"), httpClient: httpClient)
        let tokenHandler = TokenHandler(configuration: configuration, httpClient: httpClient, jwks: jwks)
        self.init(configuration: configuration,
                  sessionStorage: sessionStorage,
                  stateStorage: stateStorage,
                  httpClient: httpClient,
                  jwks:jwks, tokenHandler: tokenHandler)
    }
}

extension Result {
    var successValue: Success? {
        guard case let .success(value) = self else { return nil }
        return value
    }

    var error: Failure? {
        guard case let .failure(error) = self else { return nil }
        return error
    }
}

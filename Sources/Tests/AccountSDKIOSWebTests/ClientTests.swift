import XCTest
import Cuckoo
@testable import AccountSDKIOSWeb

final class ClientTests: XCTestCase {
    private static let keyId = "test key"
    private static var jwsUtil: JWSUtil!
    
    override class func setUp() {
        jwsUtil = JWSUtil()
    }

    func testHandleAuthenticationResponseRejectsUnsolicitedResponse() {
        let mockStorage = MockStorage()
        stub(mockStorage) { mock in
            when(mock.value(forKey: Client.authStateKey)).thenReturn(nil)
        }
        let client = Client(configuration: Fixtures.clientConfig, sessionStorage: MockSessionStorage(), stateStorage: StateStorage(storage: mockStorage))
        
        Await.until { done in
            client.handleAuthenticationResponse(url: URL("com.example://login?state=no-exist&code=123456")) { result in
                XCTAssertEqual(result, .failure(.unsolicitedResponse))
                done()
            }
        }
    }
    
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
                XCTAssertEqual(result, .failure(.authenticationErrorResponse(error: OAuthError(error: "invalid_request", errorDescription: "test error"))))
                done()
            }
        }
    }
    
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
                XCTAssertEqual(result, .failure(.unexpectedError(message: "Missing authorization code from authentication response")))
                done()
            }
        }
    }

    func testHandleAuthenticationResponseHandlesSuccessResponse() {
        let idToken = createIdToken(claims: Fixtures.idTokenClaims)
        let tokenResponse = TokenResponse(access_token: "accessToken", refresh_token: "refreshToken", id_token: idToken, scope: "openid", expires_in: 3600)
        let mockHTTPClient = MockHTTPClient()
        
        stub(mockHTTPClient) { mock in
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: anyClosure()))
                .then { _, _, completion in
                    completion(.success(tokenResponse))
                }
            
            let jwksResponse = JWKSResponse(keys: [RSAJWK(kid: ClientTests.keyId, kty: "RSA", e: ClientTests.jwsUtil.publicJWK.exponent, n: ClientTests.jwsUtil.publicJWK.modulus, alg: "RS256", use: "sig")])
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: anyClosure()))
                .then { _, _, completion in
                    completion(.success(jwksResponse))
                }
        }
        
        let mockSessionStorage = MockSessionStorage()
        stub(mockSessionStorage) { mock in
            when(mock.store(any(), completion: anyClosure())).then {_, completion in
                completion(.success())
            }
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
                let expectedTokens = UserTokens(accessToken: tokenResponse.access_token, refreshToken: tokenResponse.refresh_token, idToken: tokenResponse.id_token!, idTokenClaims: Fixtures.idTokenClaims)
                XCTAssertEqual(result, .success(User(client: client, tokens: expectedTokens)))
                done()
            }
        }
    }
    
    func testHandleAuthenticationResponseHandlesTokenErrorResponse() {
        let mockSessionStorage = MockSessionStorage()
        stub(mockSessionStorage) { mock in
            when(mock.store(any(), completion: anyClosure())).thenDoNothing()
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
                LoginError.unexpectedError(message: "Failed to obtain user tokens")
            )
        ]
        for (returnedResponse, expectedResult) in testData {
            let mockHTTPClient = MockHTTPClient()
            stub(mockHTTPClient) { mock in
                when(mock.execute(request: any(), withRetryPolicy: any(), completion: anyClosure()))
                    .then { (_, _, completion: HTTPResultHandler<TokenResponse>) in
                        completion(.failure(returnedResponse))
                    }
            }
            
            let client = Client(configuration: Fixtures.clientConfig, sessionStorage: mockSessionStorage, stateStorage: StateStorage(storage: mockStorage), httpClient: mockHTTPClient)
            Await.until { done in
                client.handleAuthenticationResponse(url: URL(string: "com.example://login?code=12345&state=\(state)")!) { result in
                    XCTAssertEqual(result, .failure(expectedResult))
                    done()
                }
            }
        }
    }

    func testHandleAuthenticationResponseRejectsExpectedAMRValueInIdToken() {
        let nonce = "testNonce"
        let claims = Fixtures.idTokenClaims.copy(amr: OptionalValue(nil)) // no AMR in ID Token
        let idToken = createIdToken(claims: claims)
        let tokenResponse = TokenResponse(access_token: "accessToken", refresh_token: "refreshToken", id_token: idToken, scope: "openid", expires_in: 3600)
        let mockHTTPClient = MockHTTPClient()
        
        stub(mockHTTPClient) { mock in
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: anyClosure()))
                .then { _, _, completion in
                    completion(.success(tokenResponse))
                }
            
            let jwksResponse = JWKSResponse(keys: [RSAJWK(kid: ClientTests.keyId, kty: "RSA", e: ClientTests.jwsUtil.publicJWK.exponent, n: ClientTests.jwsUtil.publicJWK.modulus, alg: "RS256", use: "sig")])
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: anyClosure()))
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
                XCTAssertEqual(result, .failure(.missingExpectedMFA))
                done()
            }
        }
    }

    func testResumeLastLoggedInUserWithExistingSession() {
        let session = UserSession(clientId: Fixtures.clientConfig.clientId, userTokens: Fixtures.userTokens, updatedAt: Date())
        let mockSessionStorage = MockSessionStorage()
        stub(mockSessionStorage) { mock in
            when(mock.get(forClientId: Fixtures.clientConfig.clientId, completion: anyClosure()))
                .then { clientID, completion in
                    completion(session)
                }
        }

        let client = Client(configuration: Fixtures.clientConfig, sessionStorage: mockSessionStorage, stateStorage: StateStorage(storage: MockStorage()))
        client.resumeLastLoggedInUser { user in
            XCTAssertEqual(user, User(client: client, tokens: Fixtures.userTokens))
        }        
    }

    func testResumeLastLoggedInUserWithoutSession() {
        let mockSessionStorage = MockSessionStorage()
        stub(mockSessionStorage) { mock in
            when(mock.get(forClientId: Fixtures.clientConfig.clientId, completion: anyClosure()))
                .then { clientID, completion in
                    completion(nil)
                }
        }

        let client = Client(configuration: Fixtures.clientConfig, sessionStorage: mockSessionStorage, stateStorage: StateStorage(storage: MockStorage()))
        client.resumeLastLoggedInUser  { user in
            XCTAssertNil(user)
        }
    }

    private func createIdToken(claims: IdTokenClaims) -> String {
        let data = try! JSONEncoder().encode(claims)
        return ClientTests.jwsUtil.createJWS(payload: data, keyId: ClientTests.keyId)
    }
    
    func testAccountPagesURL() {
        let client = Client(configuration: Fixtures.clientConfig, httpClient: MockHTTPClient())
        XCTAssertEqual(client.configuration.accountPagesURL.absoluteString, "\(Fixtures.clientConfig.serverURL.absoluteString)/account/summary")
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

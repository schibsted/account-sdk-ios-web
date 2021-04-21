import XCTest
import Cuckoo
@testable import AccountSDKIOSWeb

final class ClientTests: XCTestCase {
    private static let keyId = "test key"
    private static var jwsUtil: JWSUtil!
    
    override class func setUp() {
        jwsUtil = JWSUtil()
    }
    
    private func compareScope(_ receivedScope: String, _ expectedScope: Set<String>) {
        let scope = Set(receivedScope.components(separatedBy: " "))
        XCTAssertEqual(scope, expectedScope)
    }

    func testLoginURL() {
        let mockStorage = MockStorage()
        stub(mockStorage) { mock in
            when(mock.setValue(any(), forKey: Client.authStateKey)).thenDoNothing()
        }

        let client = Client(configuration: Fixtures.clientConfig, sessionStorage: MockSessionStorage(), stateStorage: StateStorage(storage: mockStorage))
        let loginURL = client.loginURL()
        
        XCTAssertEqual(loginURL?.scheme, "https")
        XCTAssertEqual(loginURL?.host, "issuer.example.com")
        XCTAssertEqual(loginURL?.path, "/oauth/authorize")
        
        let components = URLComponents(url: loginURL!, resolvingAgainstBaseURL: true)
        let queryParams = components?.queryItems?.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
        
        XCTAssertEqual(queryParams!["client_id"], Fixtures.clientConfig.clientId)
        XCTAssertEqual(queryParams!["redirect_uri"], Fixtures.clientConfig.redirectURI.absoluteString)
        XCTAssertEqual(queryParams!["response_type"], "code")
        XCTAssertEqual(queryParams!["prompt"], "select_account")
        compareScope(queryParams!["scope"]!, Set(["openid", "offline_access"]))
        XCTAssertNotNil(queryParams!["state"])
        XCTAssertNotNil(queryParams!["nonce"])
        XCTAssertNotNil(queryParams!["code_challenge"])
        XCTAssertEqual(queryParams!["code_challenge_method"], "S256")
    }
    
    func testLoginURLWithExtraScopes() {
        let mockStorage = MockStorage()
        stub(mockStorage) { mock in
            when(mock.setValue(any(), forKey: Client.authStateKey)).thenDoNothing()
        }
        let client = Client(configuration: Fixtures.clientConfig, sessionStorage: MockSessionStorage(), stateStorage: StateStorage(storage: mockStorage))
        let loginURL = client.loginURL(extraScopeValues: ["scope1", "scope2"])
        
        XCTAssertEqual(loginURL?.scheme, "https")
        XCTAssertEqual(loginURL?.host, "issuer.example.com")
        XCTAssertEqual(loginURL?.path, "/oauth/authorize")
        
        let components = URLComponents(url: loginURL!, resolvingAgainstBaseURL: true)
        let queryParams = components?.queryItems?.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }

        XCTAssertEqual(queryParams!["client_id"], Fixtures.clientConfig.clientId)
        XCTAssertEqual(queryParams!["redirect_uri"], Fixtures.clientConfig.redirectURI.absoluteString)
        XCTAssertEqual(queryParams!["response_type"], "code")
        XCTAssertEqual(queryParams!["prompt"], "select_account")
        compareScope(queryParams!["scope"]!, Set(["openid", "offline_access", "scope1", "scope2"]))
        XCTAssertNotNil(queryParams!["state"])
        XCTAssertNotNil(queryParams!["nonce"])
        XCTAssertNotNil(queryParams!["code_challenge"])
        XCTAssertEqual(queryParams!["code_challenge_method"], "S256")
    }
    
    func testLoginURLWithMFAIncludesACRValues() {
        let mockStorage = MockStorage()
        stub(mockStorage) { mock in
            when(mock.setValue(any(), forKey: Client.authStateKey)).thenDoNothing()
        }
        let client = Client(configuration: Fixtures.clientConfig, sessionStorage: MockSessionStorage(), stateStorage: StateStorage(storage: mockStorage))
        let loginURL = client.loginURL(withMFA: .otp)
        
        XCTAssertEqual(loginURL?.scheme, "https")
        XCTAssertEqual(loginURL?.host, "issuer.example.com")
        XCTAssertEqual(loginURL?.path, "/oauth/authorize")
        
        let components = URLComponents(url: loginURL!, resolvingAgainstBaseURL: true)
        let queryParams = components?.queryItems?.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }

        XCTAssertEqual(queryParams!["acr_values"], "otp")
        XCTAssertNil(queryParams!["prompt"])

        XCTAssertEqual(queryParams!["client_id"], Fixtures.clientConfig.clientId)
        XCTAssertEqual(queryParams!["redirect_uri"], Fixtures.clientConfig.redirectURI.absoluteString)
        XCTAssertEqual(queryParams!["response_type"], "code")
        compareScope(queryParams!["scope"]!, Set(["openid", "offline_access"]))
        XCTAssertNotNil(queryParams!["state"])
        XCTAssertNotNil(queryParams!["nonce"])
        XCTAssertNotNil(queryParams!["code_challenge"])
        XCTAssertEqual(queryParams!["code_challenge_method"], "S256")
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
            when(mock.store(any())).thenDoNothing()
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
            when(mock.store(any())).thenDoNothing()
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
            when(mock.get(forClientId: Fixtures.clientConfig.clientId)).thenReturn(session)
        }

        let client = Client(configuration: Fixtures.clientConfig, sessionStorage: mockSessionStorage, stateStorage: StateStorage(storage: MockStorage()))
        let user = client.resumeLastLoggedInUser()
        XCTAssertEqual(user, User(client: client, tokens: Fixtures.userTokens))
    }

    func testResumeLastLoggedInUserWithoutSession() {
        let mockSessionStorage = MockSessionStorage()
        stub(mockSessionStorage) { mock in
            when(mock.get(forClientId: Fixtures.clientConfig.clientId)).thenReturn(nil)
        }

        let client = Client(configuration: Fixtures.clientConfig, sessionStorage: mockSessionStorage, stateStorage: StateStorage(storage: MockStorage()))
        XCTAssertNil(client.resumeLastLoggedInUser())
    }

    private func createIdToken(claims: IdTokenClaims) -> String {
        let data = try! JSONEncoder().encode(claims)
        return ClientTests.jwsUtil.createJWS(payload: data, keyId: ClientTests.keyId)
    }
}

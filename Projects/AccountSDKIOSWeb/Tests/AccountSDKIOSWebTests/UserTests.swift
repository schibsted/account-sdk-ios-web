//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import XCTest
import Cuckoo
@testable import AccountSDKIOSWeb

final class UserTests: XCTestCase {
    private let request = URLRequest(url: URL(string: "http://example.com/test")!)
    private let closureMatcher: ParameterMatcher<HTTPResultHandler<TestResponse>> = anyClosure()
    
    private static let keyId = "test key"
    private static var jwsUtil: JWSUtil!
    
    override class func setUp() {
        jwsUtil = JWSUtil()
    }
    
    private func verifyAuthenticatedRequest(for mockHTTPClient: MockHTTPClient, withToken token: String) {
        let argumentCaptor = ArgumentCaptor<URLRequest>()
        verify(mockHTTPClient).execute(request: argumentCaptor.capture(), withRetryPolicy: any(), completion: self.closureMatcher)
        XCTAssertEqual(argumentCaptor.value!.value(forHTTPHeaderField: "Authorization"), "Bearer \(token)")
    }

    func testWithAuthenticationForwardsResponseIfSuccessful() {
        let response = TestResponse(data: "test")
        let mockHTTPClient = MockHTTPClient()
        stub(mockHTTPClient) { mock in
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: anyClosure()))
                .then { _, _, completion in
                    completion(.success(response))
                }
        }

        let client = Client(configuration: Fixtures.clientConfig, httpClient: mockHTTPClient)
        let user = User(client: client, tokens: Fixtures.userTokens)
        Await.until { done in
            user.withAuthentication(request: self.request) { (result: Result<TestResponse, HTTPError>) in
                switch result {
                case .success(let receivedResponse):
                    XCTAssertEqual(receivedResponse, response)
                    self.verifyAuthenticatedRequest(for: mockHTTPClient, withToken: "accessToken")
                default:
                    XCTFail("Unexpected result \(result)")
                }

                done()
            }
        }
    }

    func testWithAuthenticationForwardsErrorResponse() {
        let mockHTTPClient = MockHTTPClient()
        stub(mockHTTPClient) { mock in
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: anyClosure()))
                .then { (_, _, completion: HTTPResultHandler<TestResponse>) in
                    completion(.failure(.errorResponse(code: 400, body: "Bad request")))
                }
        }

        let client = Client(configuration: Fixtures.clientConfig, httpClient: mockHTTPClient)
        let user = User(client: client, tokens: Fixtures.userTokens)
        Await.until { done in
            user.withAuthentication(request: self.request) { (result: Result<TestResponse, HTTPError>) in
                switch result {
                case .failure(.errorResponse(let code, let body)):
                    XCTAssertEqual(code, 400)
                    XCTAssertEqual(body, "Bad request")
                    self.verifyAuthenticatedRequest(for: mockHTTPClient, withToken: "accessToken")
                default:
                    XCTFail("Unexpected result \(result)")
                }

                done()
            }
        }
    }
    
    func testWithAuthenticationRefreshesTokenUpon401Response() {
        let successResponse = TestResponse(data: "success")
        let mockHTTPClient = MockHTTPClient()

        stub(mockHTTPClient) { mock in
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: anyClosure()))
                .then { (_, _, completion: HTTPResultHandler<TestResponse>) in
                    completion(.failure(.errorResponse(code: 401, body: "Unauthorized")))
                }
                .then { _, _, completion in
                    completion(.success(successResponse))
                }

            // refresh token request
            let tokenResponse = TokenResponse(accessToken: "newAccessToken", refreshToken: "newRefreshToken", idToken: nil, scope: nil, expiresIn: 3600)
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: anyClosure()))
                .then { _, _, completion in
                    completion(.success(tokenResponse))
                }
        }
        let mockSessionStorage = MockSessionStorage()
        stub(mockSessionStorage) { mock in
            when(mock.store(any(), accessGroup: any())).then { _ in }
        }
        
        let client = Client(configuration: Fixtures.clientConfig, sessionStorage: mockSessionStorage, stateStorage: StateStorage(), httpClient: mockHTTPClient)
        let user = User(client: client, tokens: Fixtures.userTokens)
        Await.until { done in
            user.withAuthentication(request: self.request) { (result: Result<TestResponse, HTTPError>) in
                switch result {
                case .success(let receivedResponse):
                    XCTAssertEqual(receivedResponse, successResponse)
                    
                    let argumentCaptor = ArgumentCaptor<URLRequest>()
                    verify(mockHTTPClient, times(2)).execute(request: argumentCaptor.capture(), withRetryPolicy: any(), completion: self.closureMatcher)
                    let calls = argumentCaptor.allValues
                    // original token used in first request
                    XCTAssertEqual(calls[0].value(forHTTPHeaderField: "Authorization"), "Bearer accessToken")
                    // refreshed token used in second request
                    XCTAssertEqual(calls[1].value(forHTTPHeaderField: "Authorization"), "Bearer newAccessToken")
                    
                    // refreshed tokens are persisted in session storage
                    verify(mockSessionStorage).store(ParameterMatcher<UserSession>{
                        $0.userTokens.accessToken == "newAccessToken" &&
                        $0.userTokens.refreshToken == "newRefreshToken"
                    }, accessGroup: any())
                default:
                    XCTFail("Unexpected result \(result)")
                }
                done()
            }
        }
    }

    func testWithAuthenticationForwards401ResponseWhenNoRefreshToken() {
        let mockHTTPClient = MockHTTPClient()
        stub(mockHTTPClient) { mock in
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: anyClosure()))
                .then { (_, _, completion: HTTPResultHandler<TestResponse>) in
                    completion(.failure(.errorResponse(code: 401, body: "Unauthorized")))
                }
        }

        let client = Client(configuration: Fixtures.clientConfig, httpClient: mockHTTPClient)
        let noRefreshToken = UserTokens(accessToken: "accessToken", refreshToken: nil, idToken: "idToken", idTokenClaims: Fixtures.idTokenClaims)
        let user = User(client: client, tokens: noRefreshToken)
        Await.until { done in
            user.withAuthentication(request: self.request) { (result: Result<TestResponse, HTTPError>) in
                switch result {
                case .failure(.errorResponse(let code, let body)):
                    XCTAssertEqual(code, 401)
                    XCTAssertEqual(body, "Unauthorized")
                    self.verifyAuthenticatedRequest(for: mockHTTPClient, withToken: "accessToken")
                default:
                    XCTFail("Unexpected result \(result)")
                }

                done()
            }
        }
    }
    
    func testWithAuthenticationForwardsOriginalResponseWhenTokenRefreshFails() {
        let mockHTTPClient = MockHTTPClient()
        stub(mockHTTPClient) { mock in
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: anyClosure()))
                .then { (_, _, completion: HTTPResultHandler<TestResponse>) in
                    completion(.failure(.errorResponse(code: 401, body: "Unauthorized")))
                }
            
            // refresh token request
            let closureMatcher: ParameterMatcher<HTTPResultHandler<TokenResponse>> = anyClosure()
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: closureMatcher))
                .then { _, _, completion in
                    completion(.failure(.errorResponse(code: 500, body: "Something went wrong")))
                }
        }

        let client = Client(configuration: Fixtures.clientConfig, httpClient: mockHTTPClient)
        let user = User(client: client, tokens: Fixtures.userTokens)
        Await.until { done in
            user.withAuthentication(request: self.request) { (result: Result<TestResponse, HTTPError>) in
                switch result {
                case .failure(.errorResponse(let code, let body)):
                    XCTAssertEqual(code, 401)
                    XCTAssertEqual(body, "Unauthorized")
                    self.verifyAuthenticatedRequest(for: mockHTTPClient, withToken: "accessToken")
                default:
                    XCTFail("Unexpected result \(result)")
                }

                done()
            }
        }
    }
    
    func testWithAuthenticationLogsUserOutOnInvalidGrantRefreshResponse() {
        let mockHTTPClient = MockHTTPClient()
        stub(mockHTTPClient) { mock in
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: anyClosure()))
                .then { (_, _, completion: HTTPResultHandler<TestResponse>) in
                    // 1. service response
                    completion(.failure(.errorResponse(code: 401, body: "Unauthorized")))
                }
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: anyClosure()))
                .then { (_, _, completion: HTTPResultHandler<TokenResponse>) in
                    // 2. failed refresh response
                    completion(.failure(.errorResponse(code: 400, body: """
                        {
                            "error": "invalid_grant",
                            "error_description": "Invalid refresh token"
                        }
                        """)))
                }
        }

        let mockSessionStorage = MockSessionStorage()
        stub(mockSessionStorage) { mock in
            when(mock.remove(forClientId: Fixtures.clientConfig.clientId)).thenDoNothing()
        }
        let client = Client(configuration: Fixtures.clientConfig, sessionStorage: mockSessionStorage, stateStorage: StateStorage(storage: MockStorage()), httpClient: mockHTTPClient)
        let user = User(client: client, tokens: Fixtures.userTokens)
        Await.until { done in
            user.withAuthentication(request: self.request) { (result: Result<TestResponse, HTTPError>) in
                switch result {
                case .failure(.unexpectedError(underlying: LoginStateError.notLoggedIn)):
                    // expected error, do nothing
                    break
                default:
                    XCTFail("Unexpected result \(result)")
                }
                done()
            }
        }
    }
    
    func testSessionExchangeReturnsCorrectURL() {
        let sessionCode = "testSessionCode"
        let mockHTTPClient = MockHTTPClient()
        stub(mockHTTPClient) { mock in
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: anyClosure()))
                .then { _, _, completion in
                    completion(.success(SchibstedAccountAPIResponse(data: SessionExchangeResponse(code: sessionCode))))
                }
        }

        let client = Client(configuration: Fixtures.clientConfig, httpClient: mockHTTPClient)
        let user = User(client: client, tokens: Fixtures.userTokens)
        Await.until { done in
            user.webSessionURL(clientId: "webClientId", redirectURI: "https://example.com/protected") { result in
                switch result {
                case .success(let url):
                    XCTAssertEqual(url.absoluteString, "\(Fixtures.clientConfig.serverURL.absoluteString)/session/\(sessionCode)")
                default:
                    XCTFail("Unexpected result \(result)")
                }

                done()
            }
        }
    }
    
    func testCodeExchangeReturnsCorrectOneTimeCode() {
        let oneTimeCode = "testCode"
        let mockHTTPClient = MockHTTPClient()
        stub(mockHTTPClient) { mock in
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: anyClosure()))
                .then { _, _, completion in
                    completion(.success(SchibstedAccountAPIResponse(data: CodeExchangeResponse(code: oneTimeCode))))
                }
        }

        let client = Client(configuration: Fixtures.clientConfig, httpClient: mockHTTPClient)
        let user = User(client: client, tokens: Fixtures.userTokens)
        Await.until { done in
            user.oneTimeCode(clientId: "webClientId") { result in
                switch result {
                case .success(let code):
                    XCTAssertEqual(code, oneTimeCode)
                default:
                    XCTFail("Unexpected result \(result)")
                }

                done()
            }
        }
    }
    
    func testLogoutDestroysTokensAndSession() {
        let mockSessionStorage = MockSessionStorage()
        stub(mockSessionStorage) { mock in
            when(mock.remove(forClientId: Fixtures.clientConfig.clientId)).thenDoNothing()
        }

        let client = Client(configuration: Fixtures.clientConfig, sessionStorage: mockSessionStorage, stateStorage: StateStorage(storage: MockStorage()), httpClient: MockHTTPClient())
        let user = User(client: client, tokens: Fixtures.userTokens)
        
        user.logout()
        XCTAssertNil(user.tokens)
        XCTAssertNil(user.uuid)
        XCTAssertFalse(user.isLoggedIn())
        
        verify(mockSessionStorage).remove(forClientId: Fixtures.clientConfig.clientId)
    }
    
    func testAssertionReturnsCorrectValue() {
        let mockHTTPClient = MockHTTPClient()
        let expectedResponse = SimplifiedLoginAssertionResponse(assertion: "for-whom-the-bell-tolls")
        stub(mockHTTPClient) { mock in
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: anyClosure()))
                .then { _, _, completion in
                    completion(.success(SchibstedAccountAPIResponse(data: expectedResponse)))
                }
        }
        
        let client = Client(configuration: Fixtures.clientConfig, httpClient: mockHTTPClient)
        let user = User(client: client, tokens: Fixtures.userTokens)
        Await.until { done in
            user.assertionForSimplifiedLogin { result in
                switch result {
                case .success(let assertion):
                    XCTAssertEqual(assertion, expectedResponse)
                default:
                    XCTFail("Unexpected result \(result)")
                }
                done()
            }
        }
    }
    
    func testUserContextReturnsCorrectValue() {
        let mockHTTPClient = MockHTTPClient()
        let expectedResponse = UserContextFromTokenResponse(identifier: "identifier", displayText: "master-of-puppets", clientName: "metallica")
        stub(mockHTTPClient) { mock in
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: anyClosure()))
                .then { _, _, completion in
                    completion(.success(expectedResponse))
                }
        }
        let client = Client(configuration: Fixtures.clientConfig, httpClient: mockHTTPClient)
        let user = User(client: client, tokens: Fixtures.userTokens)
        Await.until { done in
            user.userContextFromToken { result in
                switch result {
                case .success(let context):
                    XCTAssertEqual(context, expectedResponse)
                default:
                    XCTFail("Unexpected result \(result)")
                }
                done()
            }
        }
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

import XCTest
import Cuckoo
@testable import AccountSDKIOSWeb

final class UserTests: XCTestCase {
    private let clientConfig = ClientConfiguration(environment: .pre, clientId: "client1", redirectURI: URL("com.example.client1://login"))
    private let request = URLRequest(url: URL(string: "http://example.com/test")!)
    private let closureMatcher: ParameterMatcher<(Result<TestResponse, HTTPError>) -> Void> = anyClosure()
    
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

        let client = Client(configuration: clientConfig, httpClient: mockHTTPClient)
        let user = User(client: client, accessToken: "accessToken", refreshToken: "refreshToken", idToken: "idToken", idTokenClaims: Fixtures.idTokenClaims)
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
                .then { (_, _, completion: (Result<TestResponse, HTTPError>) -> Void) in
                    completion(.failure(.errorResponse(code: 400, body: "Bad request")))
                }
        }

        let client = Client(configuration: clientConfig, httpClient: mockHTTPClient)
        let user = User(client: client, accessToken: "accessToken", refreshToken: "refreshToken", idToken: "idToken", idTokenClaims: Fixtures.idTokenClaims)
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
                .then { (_, _, completion: (Result<TestResponse, HTTPError>) -> Void) in
                    completion(.failure(.errorResponse(code: 401, body: "Unauthorized")))
                }
                .then { _, _, completion in
                    completion(.success(successResponse))
                }

            // refresh token request
            let tokenResponse = TokenResponse(access_token: "newAccessToken", refresh_token: "newRefreshToken", id_token: nil, scope: nil, expires_in: 3600)
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: anyClosure()))
                .then { _, _, completion in
                    completion(.success(tokenResponse))
                }
        }

        let client = Client(configuration: clientConfig, httpClient: mockHTTPClient)
        let user = User(client: client, accessToken: "accessToken", refreshToken: "refreshToken", idToken: "idToken", idTokenClaims: Fixtures.idTokenClaims)
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
                .then { (_, _, completion: (Result<TestResponse, HTTPError>) -> Void) in
                    completion(.failure(.errorResponse(code: 401, body: "Unauthorized")))
                }
        }

        let client = Client(configuration: clientConfig, httpClient: mockHTTPClient)
        let user = User(client: client, accessToken: "accessToken", refreshToken: nil, idToken: "idToken", idTokenClaims: Fixtures.idTokenClaims)
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
                .then { (_, _, completion: (Result<TestResponse, HTTPError>) -> Void) in
                    completion(.failure(.errorResponse(code: 401, body: "Unauthorized")))
                }
            
            // refresh token request
            let closureMatcher: ParameterMatcher<(Result<TokenResponse, HTTPError>) -> Void> = anyClosure()
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: closureMatcher))
                .then { _, _, completion in
                    completion(.failure(.errorResponse(code: 400, body: "{\"error\": \"invalid_grant\"}")))
                }
        }

        let client = Client(configuration: clientConfig, httpClient: mockHTTPClient)
        let user = User(client: client, accessToken: "accessToken", refreshToken: "refreshToken", idToken: "idToken", idTokenClaims: Fixtures.idTokenClaims)
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
    
    func testSessionExchangeReturnsCorrectURL() {
        let sessionCode = "testSessionCode"
        let mockHTTPClient = MockHTTPClient()
        stub(mockHTTPClient) { mock in
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: anyClosure()))
                .then { _, _, completion in
                    completion(.success(SchibstedAccountAPIResponse(data: SessionExchangeResponse(code: sessionCode))))
                }
        }

        let client = Client(configuration: clientConfig, httpClient: mockHTTPClient)
        let user = User(client: client, accessToken: "accessToken", refreshToken: "refreshToken", idToken: "idToken", idTokenClaims: Fixtures.idTokenClaims)
        Await.until { done in
            user.webSessionURL(clientId: "webClientId", redirectURI: "https://example.com/protected") { result in
                switch result {
                case .success(let url):
                    XCTAssertEqual(url.absoluteString, "\(self.clientConfig.serverURL.absoluteString)/session/\(sessionCode)")
                default:
                    XCTFail("Unexpected result \(result)")
                }

                done()
            }
        }
    }
}

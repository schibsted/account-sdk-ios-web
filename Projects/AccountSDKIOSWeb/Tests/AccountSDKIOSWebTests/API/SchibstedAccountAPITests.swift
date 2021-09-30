import XCTest
import Cuckoo
@testable import AccountSDKIOSWeb

final class SchibstedAccountAPITests: XCTestCase {
    func testUserProfile() {
        let userProfileResponse = UserProfileResponse(userId: "12345", email: "test@example.com")
        
        let mockHTTPClient = MockHTTPClient()
        stub(mockHTTPClient) {mock in
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: anyClosure()))
                .then { _, _, completion in
                    completion(.success(SchibstedAccountAPIResponse(data: userProfileResponse)))
                }
        }
        
        let client = Client(configuration: Fixtures.clientConfig, httpClient: mockHTTPClient)
        let user = User(client: client, tokens: Fixtures.userTokens)
        
        let api = SchibstedAccountAPI(baseURL: Fixtures.clientConfig.serverURL)
        Await.until { done in
            api.userProfile(for: user) { result in
                switch result {
                case .success(let receivedResponse):
                    XCTAssertEqual(receivedResponse, userProfileResponse)
                    
                    let argumentCaptor = ArgumentCaptor<URLRequest>()
                    let closureMatcher: ParameterMatcher<HTTPResultHandler<SchibstedAccountAPIResponse<UserProfileResponse>>> = anyClosure()
                    verify(mockHTTPClient).execute(request: argumentCaptor.capture(), withRetryPolicy: any(), completion: closureMatcher)
                    let requestUrl = argumentCaptor.value!.url
                    XCTAssertEqual(requestUrl, Fixtures.clientConfig.serverURL.appendingPathComponent("/api/2/user/\(Fixtures.userTokens.idTokenClaims.sub)"))
                default:
                    XCTFail("Unexpected result \(result)")
                }
                
                done()
            }
        }
    }
    
    // MARK: OldSDK Api endpoints
    
    func testOldSDKCodeExchangeSuccessResponse() {
        let expectedCode = "A code"
        let response = CodeExchangeResponse(code: expectedCode)

        
        let mockHTTPClient = MockHTTPClient()
        stub(mockHTTPClient) {mock in
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: anyClosure()))
                .then { _, _, completion in
                    completion(.success(SchibstedAccountAPIResponse(data: response)))
                }
        }
        
        let api = SchibstedAccountAPI(baseURL: Fixtures.clientConfig.serverURL)
        Await.until { done in
            api.oldSDKCodeExchange(with: mockHTTPClient, clientId: "", oldSDKAccessToken: "") { result in
                switch result {
                case .success(let receivedResponse):
                    XCTAssertEqual(receivedResponse.data.code, expectedCode)
                default:
                    XCTFail("Unexpected result \(result)")
                }
                done()
            }
        }
    }
    
    func testOldSDKCodeExchangeURL() {
        let mockHTTPClient = MockHTTPClient()
        stub(mockHTTPClient) {mock in
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: anyClosure()))
                .then { _, _, completion in
                    completion(.success(SchibstedAccountAPIResponse(data: CodeExchangeResponse(code: ""))))
                }
        }
        
        let api = SchibstedAccountAPI(baseURL: Fixtures.clientConfig.serverURL)
        Await.until { done in
            api.oldSDKCodeExchange(with: mockHTTPClient, clientId: "", oldSDKAccessToken: "") { result in
                
                let argumentCaptor = ArgumentCaptor<URLRequest>()
                let closureMatcher: ParameterMatcher<HTTPResultHandler<SchibstedAccountAPIResponse<CodeExchangeResponse>>> = anyClosure()
                verify(mockHTTPClient).execute(request: argumentCaptor.capture(), withRetryPolicy: any(), completion: closureMatcher)
                let requestUrl = argumentCaptor.value!.url
                XCTAssertEqual(requestUrl, Fixtures.clientConfig.serverURL.appendingPathComponent("/api/2/oauth/exchange"))
                
                done()
            }
        }
    }
    
  
    
    func testOldSDKRefreshSuccessResponse() {
        let expectedResponse = TokenResponse(access_token: Fixtures.userTokens.accessToken,
                                             refresh_token: Fixtures.userTokens.refreshToken,
                                             id_token: nil,
                                             scope: nil,
                                             expires_in: 1337)
        
        let mockHTTPClient = MockHTTPClient()
        stub(mockHTTPClient) {mock in
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: anyClosure()))
                .then { _, _, completion in
                    completion(.success(expectedResponse))
                }
        }
        
        let api = SchibstedAccountAPI(baseURL: Fixtures.clientConfig.serverURL)
        Await.until { done in
            api.oldSDKRefresh(with: mockHTTPClient, refreshToken: "", clientId: "", clientSecret: "") { result in
                switch result {
                case .success(let receivedResponse):
                    XCTAssertEqual(receivedResponse.access_token, expectedResponse.access_token)
                    XCTAssertEqual(receivedResponse.refresh_token, expectedResponse.refresh_token)
                default:
                    XCTFail("Unexpected result \(result)")
                }
                done()
            }
        }
    }
    
    func testOldSDKRefreshURL() {
        let mockHTTPClient = MockHTTPClient()
        stub(mockHTTPClient) {mock in
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: anyClosure()))
                .then { _, _, completion in
                    completion(.success(TokenResponse(access_token: "", refresh_token: "", id_token: nil, scope: nil, expires_in: 1337)))
                }
        }
        
        let api = SchibstedAccountAPI(baseURL: Fixtures.clientConfig.serverURL)
        Await.until { done in
            api.oldSDKRefresh(with: mockHTTPClient, refreshToken: "", clientId: "", clientSecret: "") { result in
                let argumentCaptor = ArgumentCaptor<URLRequest>()
                let closureMatcher: ParameterMatcher<HTTPResultHandler<TokenResponse>> = anyClosure()
                verify(mockHTTPClient).execute(request: argumentCaptor.capture(), withRetryPolicy: any(), completion: closureMatcher)
                let requestUrl = argumentCaptor.value!.url
                XCTAssertEqual(requestUrl, Fixtures.clientConfig.serverURL.appendingPathComponent("/oauth/token"))
                    
                done()
            }
        }
    }
}

final class RequestBuilderTests: XCTestCase {
    
    // MARK: CodeExchange tests

    func testCodeExchangeAsRequestExpectedURL() throws {
        let expectedClientId = "aString"
        let baseURL = URL("https://example.com")
        let expectedURL = baseURL.appendingPathComponent("/api/2/oauth/exchange")
        
        let sut = RequestBuilder.codeExchange(clientId: expectedClientId)
        let request = sut.asRequest(baseURL: baseURL)
        XCTAssertEqual(request.url, expectedURL)
    }
    
    func testCodeExchangeAsRequestWrongURL() throws {
        let expectedClientId = "aString"
        let baseURL = URL("https://example.com")
        let expectedURL = baseURL.appendingPathComponent("/bad/path")
        
        let sut = RequestBuilder.codeExchange(clientId: expectedClientId)
        let request = sut.asRequest(baseURL: baseURL)
        XCTAssertNotEqual(request.url, expectedURL)
    }
    
    // MARK: OldSDKRefreshToken tests
    
    func testOldSDKRefreshTokenAsRequestExpectedURL() throws {
        let baseURL = URL("https://example.com")
        let expectedURL = baseURL.appendingPathComponent("/oauth/token")
        let expectedRefreshToken = "A refreshToken"
        
        let sut = RequestBuilder.oldSDKRefreshToken(oldSDKRefreshToken: expectedRefreshToken)
        let request = sut.asRequest(baseURL: baseURL)
        XCTAssertEqual(request.url, expectedURL, "The url expected path should be: \(expectedURL.absoluteString)")
    }
    
    func testOldSDKRefreshTokenAsRequestWrongURL() throws {
        let baseURL = URL("https://example.com")
        let expectedURL = baseURL.appendingPathComponent("/bad/path")
        let expectedRefreshToken = "A refreshToken"
        
        let sut = RequestBuilder.oldSDKRefreshToken(oldSDKRefreshToken: expectedRefreshToken)
        let request = sut.asRequest(baseURL: baseURL)
        XCTAssertNotEqual(request.url, expectedURL, "The url expected path should be: /oauth/token")
    }
    
}

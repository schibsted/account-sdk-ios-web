import XCTest
import Cuckoo
@testable import AccountSDKIOSWeb

final class AccountSDKIOSWebTests: XCTestCaseWithMockHTTPClient {
    
    let testURL = URL("http://www.example.com")
    let testConfig : URLSessionConfiguration = {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return config
    }()
    var returnFailure = true
    
    override func setUp() {
        MockURLProtocol.requestHandler = nil
        returnFailure = true
        setRequestHandler()
        super.setUp()
    }
    override func tearDown() {
        MockURLProtocol.requestHandler = nil
    }
    
    func testRetryRequestWithSuccessfullyRefreshedToken() {
        
        // given
        let tokenResponse: TokenResponse = TokenResponse(access_token: "newAccessToken", refresh_token: "newRefreshToken", id_token: nil, scope: nil, expires_in: 3600)
        self.stubHTTPClientExecuteRefreshRequest(mockHTTPClient: mockHTTPClient!, refreshResult: .success(tokenResponse))
        
        let mockSessionStorage = MockSessionStorage()
        self.stubSessionStorageStore(mockSessionStorage: mockSessionStorage, result: .success())
        
        let client = Client(configuration: Fixtures.clientConfig, sessionStorage: mockSessionStorage, stateStorage: StateStorage(), httpClient: mockHTTPClient!)
        let user = User(client: client, tokens: Fixtures.userTokens)
        
        let expectation = self.expectation(description: "Original request should be retired with success server response")

        // when
        let sut = AuthenticatedURLSession(user: user, configuration: testConfig)
        let request = URLRequest(url: testURL)
        let test = sut.dataTask(with: request) { data, response, error in
            // then
            XCTAssertNil(error, "An unexpected result was encountered. Error is not nil")
            XCTAssertNotNil(response)
            guard let httpURLResponse = response as? HTTPURLResponse else {
                XCTFail("Incorrect respone")
                return
            }
            XCTAssertEqual(httpURLResponse.statusCode, 200 , "refreshTokenDataTask was never resumed")
            expectation.fulfill()
        }
        test.resume()
        self.waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    func testReturnOriginalErrorOnRefreshTokenRequestFailure() {
        // given
        self.stubHTTPClientExecuteRefreshRequest(mockHTTPClient: mockHTTPClient!, refreshResult: .failure(.errorResponse(code: 500, body: "Something went wrong with refresh")))

        let client = Client(configuration: Fixtures.clientConfig, httpClient: mockHTTPClient)
        let user = User(client: client, tokens: Fixtures.userTokens)
        
        let expectation = self.expectation(description: "Return original 401 error response on refresh token request failure")

        // when
        let sut = AuthenticatedURLSession(user: user, configuration: testConfig)
        let request = URLRequest(url: testURL)
        let test = sut.dataTask(with: request) { data, response, error in
            // then
            XCTAssertNil(error, "An unexpected result was encountered. Error is not nil")
            XCTAssertNotNil(response)
            guard let httpURLResponse = response as? HTTPURLResponse else {
                XCTFail("Incorrect respone")
                return
            }
            XCTAssertEqual(httpURLResponse.statusCode, 401)
            expectation.fulfill()
        }
        test.resume()
        self.waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    // helper fo MockURLProtocol
    // current implementation works for case when failure is the first event
    func setRequestHandler(successCode: Int = 200, errorCode: Int = 401) {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: self.returnFailure ? errorCode : successCode, httpVersion:nil, headerFields:nil)!
            self.returnFailure = false
            return (response, Data())
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

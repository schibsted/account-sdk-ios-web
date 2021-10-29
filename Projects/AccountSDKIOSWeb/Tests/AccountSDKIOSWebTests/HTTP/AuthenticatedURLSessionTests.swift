import XCTest
import Cuckoo
@testable import AccountSDKIOSWeb

final class AccountSDKIOSWebTests: XCTestCaseWithMockHTTPClient {
    
    let testURL = URL("http://www.example.com")
    
    func testRetryRequestWithSuccessfullyRefreshedToken() {
        
        // given
        let tokenResponse: TokenResponse = TokenResponse(access_token: "newAccessToken", refresh_token: "newRefreshToken", id_token: nil, scope: nil, expires_in: 3600)
        self.stubHTTPClientExecuteRefreshRequest(mockHTTPClient: mockHTTPClient!, refreshResult: .success(tokenResponse))
        
        let mockSessionStorage = MockSessionStorage()
        self.stubSessionStorageStore(mockSessionStorage: mockSessionStorage, result: .success())
        
        let client = Client(configuration: Fixtures.clientConfig, sessionStorage: mockSessionStorage, stateStorage: StateStorage(), httpClient: mockHTTPClient!)
        let user = User(client: client, tokens: Fixtures.userTokens)
        
        let session = URLSessionMock()
        session.errorResponse = HTTPURLResponse(url: testURL, statusCode: 401, httpVersion: nil, headerFields: nil)
        session.successResponse = HTTPURLResponse(url: testURL, statusCode: 200, httpVersion: nil, headerFields: nil)
        session.startWithFailure = true
        
        let expectation = self.expectation(description: "Original request should be retired with success server response")
        
        // when
        let sut = AuthenticatedURLSession(user: user, session: session)
        let request = URLRequest(url: testURL)
        let test = sut.dataTask(with: request) { data, response, error in
            // then
            XCTAssertNil(error, "An unexpected result was encountered. Error is not nil")
            XCTAssertNotNil(response)
            XCTAssertEqual(response, session.successResponse, "refreshTokenDataTask was never resumed")
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
        
        let session = URLSessionMock()
        session.errorResponse = HTTPURLResponse(url: testURL, statusCode: 401, httpVersion: nil, headerFields: nil)
        session.startWithFailure = true
        
        let expectation = self.expectation(description: "Return original 401 error response on refresh token request failure")
        
        // when
        let sut = AuthenticatedURLSession(user: user, session: session)
        let request = URLRequest(url: testURL)
        let test = sut.dataTask(with: request) { data, response, error in
            // then
            XCTAssertNil(data, "An unexpected result was encountered")
            XCTAssertNotNil(response)
            XCTAssertEqual(response, session.errorResponse)
            expectation.fulfill()
        }
        test.resume()
        self.waitForExpectations(timeout: 0.5, handler: nil)
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

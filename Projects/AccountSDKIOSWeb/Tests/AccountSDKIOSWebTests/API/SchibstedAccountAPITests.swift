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

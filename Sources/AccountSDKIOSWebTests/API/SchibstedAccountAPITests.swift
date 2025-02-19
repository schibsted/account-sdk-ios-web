//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import XCTest
import Cuckoo

@testable import AccountSDKIOSWeb

final class SchibstedAccountAPITests: XCTestCase {
    
    // MARK: AssertionForSimplifiedLoginRequest
    
    func testAssertionForSimplifiedLoginURL() {
        let response = SimplifiedLoginAssertionResponse(assertion: "My assertion string")

        
        let mockHTTPClient = MockHTTPClient()
        stub(mockHTTPClient) {mock in
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: anyClosure()))
                .then { _, _, completion in
                    completion(.success(SchibstedAccountAPIResponse(data: response)))
                }
        }
        
        let client = Client(configuration: Fixtures.clientConfig, httpClient: mockHTTPClient)
        let user = User(client: client, tokens: Fixtures.userTokens)
        let api = Fixtures.schibstedAccountAPI
        Await.until { done in
            api.assertionForSimplifiedLogin(for: user) { result in
                switch result {
                case .success:
                    let argumentCaptor = ArgumentCaptor<URLRequest>()
                    let closureMatcher: ParameterMatcher<HTTPResultHandler<SchibstedAccountAPIResponse<SimplifiedLoginAssertionResponse>>> = anyClosure()
                    verify(mockHTTPClient).execute(request: argumentCaptor.capture(), withRetryPolicy: any(), completion: closureMatcher)
                    let requestUrl = argumentCaptor.value!.url
                    
                    XCTAssertEqual(requestUrl, Fixtures.clientConfig.serverURL.appendingPathComponent("/api/2/user/auth/token"),
                                   "The request URL should be \(Fixtures.clientConfig.serverURL.appendingPathComponent("/api/2/user/auth/token"))")
                default:
                    XCTFail("Unexpected result \(result)")
                }
                done()
            }
        }
    }
    
    func testAssertionForSimplifiedLoginSuccessResponse() {
        let response = SimplifiedLoginAssertionResponse(assertion: "My assertion string")
        
        let mockHTTPClient = MockHTTPClient()
        stub(mockHTTPClient) {mock in
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: anyClosure()))
                .then { _, _, completion in
                    completion(.success(SchibstedAccountAPIResponse(data: response)))
                }
        }
        
        let client = Client(configuration: Fixtures.clientConfig, httpClient: mockHTTPClient)
        let user = User(client: client, tokens: Fixtures.userTokens)
        let api = Fixtures.schibstedAccountAPI
        Await.until { done in
            api.assertionForSimplifiedLogin(for: user) { result in
                switch result {
                case .success(let receivedResponse):
                    XCTAssertEqual(response, receivedResponse)
                default:
                    XCTFail("Unexpected result \(result)")
                }
                done()
            }
        }
    }
    
    // MARK: SessionService endpoints

    func testUserContextFromTokenUsesSessionServiceURL() {
        let response = UserContextFromTokenResponse(identifier: "An identifier",
                                                    displayText: "A display name",
                                                    clientName: "Schibsted Client Name")

        
        let mockHTTPClient = MockHTTPClient()
        stub(mockHTTPClient) {mock in
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: anyClosure()))
                .then { _, _, completion in
                    completion(.success(response))
                }
        }
        
        let client = Client(configuration: Fixtures.clientConfig, httpClient: mockHTTPClient)
        let user = User(client: client, tokens: Fixtures.userTokens)
        let api = Fixtures.schibstedAccountAPI
        Await.until { done in
            api.userContextFromToken(for: user) { result in
                switch result {
                case .success:
                    let argumentCaptor = ArgumentCaptor<URLRequest>()
                    let closureMatcher: ParameterMatcher<HTTPResultHandler<UserContextFromTokenResponse>> = anyClosure()
                    verify(mockHTTPClient).execute(request: argumentCaptor.capture(), withRetryPolicy: any(), completion: closureMatcher)
                    let requestUrl = argumentCaptor.value!.url
                    
                    XCTAssertEqual(requestUrl, Fixtures.clientConfig.sessionServiceURL.appendingPathComponent("/user-context-from-token"),
                                   "The request URL should be a session-service url \(Fixtures.clientConfig.sessionServiceURL.appendingPathComponent("/user-context-from-token"))")
                default:
                    XCTFail("Unexpected result \(result)")
                }
                done()
            }
        }
    }
    
    func testUserContextFromTokenSuccessResponse() {
        let response = UserContextFromTokenResponse(identifier: "An identifier",
                                                    displayText: "A display name",
                                                    clientName: "Schibsted Client Name")

        
        let mockHTTPClient = MockHTTPClient()
        stub(mockHTTPClient) {mock in
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: anyClosure()))
                .then { _, _, completion in
                    completion(.success(response))
                }
        }
        
        let client = Client(configuration: Fixtures.clientConfig, httpClient: mockHTTPClient)
        let user = User(client: client, tokens: Fixtures.userTokens)
        let api = Fixtures.schibstedAccountAPI
        Await.until { done in
            api.userContextFromToken(for: user) { result in
                switch result {
                case .success(let receivedResponse):
                    XCTAssertEqual(response, receivedResponse)
                default:
                    XCTFail("Unexpected result \(result)")
                }
                done()
            }
        }
    }
    
    // MARK: OldSDK Api endpoints
   
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
        
        let api = Fixtures.schibstedAccountAPI
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
    
    // MARK: Session Service Request
    
    func testUserContextFromTokensRequestWrongURL() throws {
        let sessionURL = URL(staticString: "https://example.com")
        let expectedURL = sessionURL.appendingPathComponent("/bad/path")

        let sut = RequestBuilder.userContextFromToken
        let request = sut.asRequest(baseURL: sessionURL)
        XCTAssertNotEqual(request.url, expectedURL)
    }
    
    // MARK: CodeExchange tests

    func testCodeExchangeAsRequestExpectedURL() throws {
        let expectedClientId = "aString"
        let baseURL = URL(staticString: "https://example.com")
        let expectedURL = baseURL.appendingPathComponent("/api/2/oauth/exchange")
        
        let sut = RequestBuilder.codeExchange(clientId: expectedClientId)
        let request = sut.asRequest(baseURL: baseURL)
        XCTAssertEqual(request.url, expectedURL)
    }
    
    func testCodeExchangeAsRequestWrongURL() throws {
        let expectedClientId = "aString"
        let baseURL = URL(staticString: "https://example.com")
        let expectedURL = baseURL.appendingPathComponent("/bad/path")
        
        let sut = RequestBuilder.codeExchange(clientId: expectedClientId)
        let request = sut.asRequest(baseURL: baseURL)
        XCTAssertNotEqual(request.url, expectedURL)
    }
    
    // MARK: OldSDKRefreshToken tests
    
    func testOldSDKRefreshTokenAsRequestExpectedURL() throws {
        let baseURL = URL(staticString: "https://example.com")
        let expectedURL = baseURL.appendingPathComponent("/oauth/token")
        let expectedRefreshToken = "A refreshToken"
        
        let sut = RequestBuilder.oldSDKRefreshToken(oldSDKRefreshToken: expectedRefreshToken)
        let request = sut.asRequest(baseURL: baseURL)
        XCTAssertEqual(request.url, expectedURL, "The url expected path should be: \(expectedURL.absoluteString)")
    }
    
    func testOldSDKRefreshTokenAsRequestWrongURL() throws {
        let baseURL = URL(staticString: "https://example.com")
        let expectedURL = baseURL.appendingPathComponent("/bad/path")
        let expectedRefreshToken = "A refreshToken"
        
        let sut = RequestBuilder.oldSDKRefreshToken(oldSDKRefreshToken: expectedRefreshToken)
        let request = sut.asRequest(baseURL: baseURL)
        XCTAssertNotEqual(request.url, expectedURL, "The url expected path should be: /oauth/token")
    }

    // MARK: Session Service Request
    
    func testAssertionForSimplifiedLoginAsRequestExpectedURL() throws {
        let baseURL = URL(staticString: "https://example.com")
        let expectedURL = baseURL.appendingPathComponent("/api/2/user/auth/token")

        let sut = RequestBuilder.assertionForSimplifiedLogin
        let request = sut.asRequest(baseURL: baseURL)
        XCTAssertEqual(request.url, expectedURL, "expexted url should be \(expectedURL.absoluteString)")
    }
}

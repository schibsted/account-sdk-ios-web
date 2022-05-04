//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import XCTest
import Cuckoo
@testable import AccountSDKIOSWeb

class TokenRefreshRequestHandlerTests: XCTestCaseWithMockHTTPClient {
    private let request = URLRequest(url: URL(string: "http://example.com/test")!)
    private let closureMatcher: ParameterMatcher<HTTPResultHandler<TestResponse>> = anyClosure()
    
    // MARK: refreshWithRetry
    
    func testRefreshWithRetryOnRefreshFailureCompletionCalled() {
        self.stubHTTPClientExecuteRefreshRequest(mockHTTPClient: mockHTTPClient!, refreshResult: .failure(.errorResponse(code: 500, body: "Something went wrong with refresh")))

        let client = Client(configuration: Fixtures.clientConfig, httpClient: mockHTTPClient)
        let user = User(client: client, tokens: Fixtures.userTokens)
        
        let initialResultBody = "This is initialResultBody"
        let initialResult: Result<TestResponse,HTTPError> = .failure(.errorResponse(code: 1337, body: initialResultBody))
        let sut = User.TokenRefreshRequestHandler()
        
        let expectation = self.expectation(description: "When refresh fails. Completion should be called with initialResult")
        sut.refreshWithRetry(user: user,
                             requestResult: initialResult,
                             request: self.request) { result in
            switch result {
            case .failure( .errorResponse(code: _, body: let body)):
                XCTAssertEqual(initialResultBody, body)
                expectation.fulfill()
            default:
                XCTFail()
            }
        }
        self.wait(for: [expectation], timeout: 1)
    }
    
    func testRefreshWithRetryRetriedRequestSucess() {
        let tokenResponse: TokenResponse = TokenResponse(access_token: "newAccessToken", refresh_token: "newRefreshToken", id_token: nil, scope: nil, expires_in: 3600)
        self.stubHTTPClientExecuteRefreshRequest(mockHTTPClient: mockHTTPClient!, refreshResult: .success(tokenResponse))
        
        let sucessResponse = TestResponse(data:  "Retried request SUCCESS")
        self.stubHTTPClientExecuteRequest(mockHTTPClient: mockHTTPClient!, result: .success(sucessResponse))

        let mockSessionStorage = MockSessionStorage()
        self.stubSessionStorageStore(mockSessionStorage: mockSessionStorage, result: .success())
        
        let client = Client(configuration: Fixtures.clientConfig, sessionStorage: mockSessionStorage, stateStorage: StateStorage(), httpClient: mockHTTPClient!)
        let user = User(client: client, tokens: Fixtures.userTokens)
        
        let anyResult: Result<TestResponse,HTTPError> = .failure(.errorResponse(code: 1337, body: "foo"))
        let expectation = self.expectation(description: "completion should be called with result from retried request")
        let sut = User.TokenRefreshRequestHandler()
        sut.refreshWithRetry(user: user,
                             requestResult: anyResult,
                             request: self.request) { result in
            switch result {
            case .success(let receivedResponse):
                XCTAssertEqual(sucessResponse.data, receivedResponse.data)
                expectation.fulfill()
            default:
                XCTFail()
            }
        }
        self.wait(for: [expectation], timeout: 1)
    }
    
    func testRefreshWithRetryRetriedRequestFailure() {
        let tokenResponse: TokenResponse = TokenResponse(access_token: "newAccessToken", refresh_token: "newRefreshToken", id_token: nil, scope: nil, expires_in: 3600)
        self.stubHTTPClientExecuteRefreshRequest(mockHTTPClient: mockHTTPClient!, refreshResult: .success(tokenResponse))
        

        self.stubHTTPClientExecuteRequest(mockHTTPClient: mockHTTPClient!, result: .failure(.errorResponse(code: 1337, body: "Retried request FAILING")))

        let mockSessionStorage = MockSessionStorage()
        self.stubSessionStorageStore(mockSessionStorage: mockSessionStorage, result: .success())
        
        let client = Client(configuration: Fixtures.clientConfig, sessionStorage: mockSessionStorage, stateStorage: StateStorage(), httpClient: mockHTTPClient!)
        let user = User(client: client, tokens: Fixtures.userTokens)
        
        let anyResult: Result<TestResponse,HTTPError> = .failure(.errorResponse(code: 1337, body: "foo"))
        let expectation = self.expectation(description: "completion should be called with result from retried request")
        let sut = User.TokenRefreshRequestHandler()
        sut.refreshWithRetry(user: user,
                             requestResult: anyResult,
                             request: self.request) { result in
            switch result {
            case .failure(.errorResponse(code: 1337, body: let body)):
                XCTAssertEqual("Retried request FAILING", body)
                expectation.fulfill()
            default:
                XCTFail()
            }
        }
        self.wait(for: [expectation], timeout: 1)
    }
    
    func testRefreshWithRetrySameRequestRetried() {
        let tokenResponse: TokenResponse = TokenResponse(access_token: "newAccessToken", refresh_token: "newRefreshToken", id_token: nil, scope: nil, expires_in: 3600)
        self.stubHTTPClientExecuteRefreshRequest(mockHTTPClient: mockHTTPClient!, refreshResult: .success(tokenResponse))
        
        let successResponse = TestResponse(data:  "Any response for retried request")
        self.stubHTTPClientExecuteRequest(mockHTTPClient: mockHTTPClient!, result: .success(successResponse))
        let mockSessionStorage = MockSessionStorage()
        self.stubSessionStorageStore(mockSessionStorage: mockSessionStorage, result: .success())
        
        let client = Client(configuration: Fixtures.clientConfig, sessionStorage: mockSessionStorage, stateStorage: StateStorage(), httpClient: mockHTTPClient!)
        let user = User(client: client, tokens: Fixtures.userTokens)
        let anyInitialResult: Result<TestResponse,HTTPError> = .failure(.errorResponse(code: 1337, body: "foo"))
        
        let expectation = self.expectation(description: "After successfull refresh the passedRequest should be executed")
        let passedRequest = URLRequest(url: URL(string: "http://anyurl.com/test")!)
        
        let sut = User.TokenRefreshRequestHandler()
        sut.refreshWithRetry(user: user,
                             requestResult: anyInitialResult,
                             request: passedRequest) { _ in
            
            let argumentCaptor = ArgumentCaptor<URLRequest>()
            verify(self.mockHTTPClient!, times(1)).execute(request: argumentCaptor.capture(), withRetryPolicy: any(), completion: self.closureMatcher)
            let calls = argumentCaptor.allValues
            XCTAssertEqual(calls[0].url!.absoluteString, passedRequest.url!.absoluteString, "HTTPClient should execute the primary passedRequest")
            
            expectation.fulfill()
        }
        self.wait(for: [expectation], timeout: 1)
    }
    
    // MARK: refreshWithoutRetry
    
    func testRefreshWithoutRetryCompletionCalledWithRefreshResultFailure() {
        let refreshResultBody = "Something went wrong"
        let refreshResult: Result<TokenResponse, HTTPError> = .failure(.errorResponse(code: 500, body: refreshResultBody))
        self.stubHTTPClientExecuteRefreshRequest(mockHTTPClient: mockHTTPClient!, refreshResult: refreshResult)

        let client = Client(configuration: Fixtures.clientConfig, httpClient: mockHTTPClient)
        let user = User(client: client, tokens: Fixtures.userTokens)
                                     
        let expectation = self.expectation(description: "completion should be called with refresh result")
        let sut = User.TokenRefreshRequestHandler()
        sut.refreshWithoutRetry(user: user) { result in
            switch result {
            case .failure(.refreshRequestFailed(.errorResponse(_, let body))):
                XCTAssertEqual(body, refreshResultBody)
                expectation.fulfill()
            default:
                XCTFail()
            }
        }
        self.wait(for: [expectation], timeout: 1)
    }
    
    func testRefreshWithoutRetryCompletionCalledWithRefreshResultSuccess() {
        let tokenResponse = TokenResponse(access_token: "newAccessToken", refresh_token: "newRefreshToken", id_token: nil, scope: nil, expires_in: 3600)
        self.stubHTTPClientExecuteRefreshRequest(mockHTTPClient: mockHTTPClient!, refreshResult: .success(tokenResponse))

        let mockSessionStorage = MockSessionStorage()
        self.stubSessionStorageStore(mockSessionStorage: mockSessionStorage, result: .success())

        let client = Client(configuration: Fixtures.clientConfig, sessionStorage: mockSessionStorage, stateStorage: StateStorage(), httpClient: mockHTTPClient!)
        let user = User(client: client, tokens: Fixtures.userTokens)
                                     
        let expectation = self.expectation(description: "completion should be called with refresh result")
        let sut = User.TokenRefreshRequestHandler()
        sut.refreshWithoutRetry(user: user) { result in
            switch result {
            case .success(let data):
                XCTAssertEqual(data.accessToken, tokenResponse.access_token)
                XCTAssertEqual(data.refreshToken, tokenResponse.refresh_token)
                expectation.fulfill()
            default:
                XCTFail()
            }
        }
        self.wait(for: [expectation], timeout: 1)
    }

    func testRefreshWithoutRetryThreadSafety() {
        // Arrange
        let mockSessionStorage = MockSessionStorage()
        self.stubSessionStorageStore(mockSessionStorage: mockSessionStorage, result: .success())

        let client = Client(configuration: Fixtures.clientConfig, sessionStorage: mockSessionStorage, stateStorage: StateStorage(), httpClient: mockHTTPClient!)
        let user = User(client: client, tokens: Fixtures.userTokens)

        let exp = expectation(description: "Should be called only once")
        exp.assertForOverFulfill = true

        let refresher = FakeUserTokensRefresher()
        refresher.onDidCallRefreshTokens = {
            exp.fulfill()
        }

        let sut = User.TokenRefreshRequestHandler(tokenRefresher: refresher)

        // Act
        let group = DispatchGroup()

        var completionsExpectations: [XCTestExpectation] = []

        for expId in 0...1000 {
            let currentExp = expectation(description: "id-\(expId)")
            completionsExpectations.append(currentExp)
            group.enter()

            DispatchQueue.global().async {
                let sleepVal = arc4random() % 1000
                usleep(sleepVal)
                sut.refreshWithoutRetry(user: user) { result in
                    currentExp.fulfill()
                }
                group.leave()
            }
        }

        // Assert
        let result = group.wait(timeout: DispatchTime.now() + 5)
        XCTAssert(result == .success)
        refresher.completion?(.success(Fixtures.userTokens))
        wait(for: [exp] + completionsExpectations, timeout: 1)
    }

    func testRefreshWithRetryThreadSafety() {
        // Arrange
        let anyInitialResult: Result<TestResponse,HTTPError> = .success(TestResponse(data: "a"))
        let passedRequest = URLRequest(url: URL(string: "http://anyurl.com/test")!)

        let mockSessionStorage = MockSessionStorage()
        self.stubSessionStorageStore(mockSessionStorage: mockSessionStorage, result: .success())

        let client = Client(configuration: Fixtures.clientConfig, sessionStorage: mockSessionStorage, stateStorage: StateStorage(), httpClient: mockHTTPClient!)
        let user = User(client: client, tokens: Fixtures.userTokens)

        let exp = expectation(description: "Should be called only once")
        exp.assertForOverFulfill = true

        let refresher = FakeUserTokensRefresher()
        refresher.onDidCallRefreshTokens = {
            exp.fulfill()
        }

        let requestMaker = FakeUserRequestMaker()

        let allRequestsExp = expectation(description: "all completion blocks")
        allRequestsExp.expectedFulfillmentCount = 1000
        allRequestsExp.assertForOverFulfill = false
        requestMaker.onDidMakeRequest = {
            allRequestsExp.fulfill()
        }

        let sut = User.TokenRefreshRequestHandler(tokenRefresher: refresher, requestMaker: requestMaker)

        // Act
        let group = DispatchGroup()

        for _ in 0...1000 {
            group.enter()

            DispatchQueue.global().async {
                let sleepVal = arc4random() % 1000
                usleep(sleepVal)
                sut.refreshWithRetry(
                    user: user,
                    requestResult: anyInitialResult,
                    request: passedRequest
                ) { _ in }
                group.leave()
            }
        }

        // Assert
        let result = group.wait(timeout: DispatchTime.now() + 5)
        XCTAssert(result == .success)
        refresher.completion?(.success(Fixtures.userTokens))
        wait(for: [allRequestsExp], timeout: 1)
        wait(for: [exp], timeout: 1)
    }
}

final class FakeUserTokensRefresher: UserTokensRefreshing {
    var onDidCallRefreshTokens: () -> Void = {}
    var completion: ((Result<UserTokens, RefreshTokenError>) -> Void)?
    func refreshTokens(for user: User, completion: @escaping (Result<UserTokens, RefreshTokenError>) -> Void) {
        self.completion = completion
        onDidCallRefreshTokens()
    }
}

final class FakeUserRequestMaker: UserRequestMaking {
    var onDidMakeRequest: () -> Void = {}
    func makeRequest<T>(user: User, request: URLRequest, completion: @escaping HTTPResultHandler<T>) where T : Decodable {
        onDidMakeRequest()
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

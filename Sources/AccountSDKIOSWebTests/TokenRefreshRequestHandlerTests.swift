//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation
import Cuckoo
import Testing

@testable import AccountSDKIOSWeb

@Suite
@MainActor
struct TokenRefreshRequestHandlerTests {
    private let request = URLRequest(url: URL(string: "http://example.com/test")!)
    private let closureMatcher: ParameterMatcher<HTTPResultHandler<TestResponse>> = ParameterMatcher()
    private let mockHTTPClientHelpers = MockHTTPClientHelpers()

    // MARK: refreshWithRetry

    @Test
    func testRefreshWithRetryOnRefreshFailureCompletionCalled() async {
        mockHTTPClientHelpers.stubHTTPClientExecuteRefreshRequest(refreshResult: .failure(.errorResponse(code: 500, body: "Something went wrong with refresh")))

        let client = Client(configuration: Fixtures.clientConfig, httpClient: mockHTTPClientHelpers.mockHTTPClient)
        let user = User(client: client, tokens: Fixtures.userTokens)

        let initialResultBody = "This is initialResultBody"
        let initialResult: Result<TestResponse,HTTPError> = .failure(.errorResponse(code: 1337, body: initialResultBody))
        let sut = User.TokenRefreshRequestHandler()

        let expectation = TestExpectation(description: "When refresh fails. Completion should be called with initialResult")
        sut.refreshWithRetry(
            user: user,
            requestResult: initialResult,
            request: self.request
        ) { result in
            switch result {
            case .failure( .errorResponse(code: _, body: let body)):
                if body == initialResultBody {
                    Task {
                        await expectation.fulfill()
                    }
                }
            default:
                break
            }
        }

        await expectation.wait()
    }

    @Test
    func testRefreshWithRetryRetriedRequestSucess() async {
        let tokenResponse: TokenResponse = TokenResponse(accessToken: "newAccessToken", refreshToken: "newRefreshToken", idToken: nil, scope: nil, expiresIn: 3600)
        mockHTTPClientHelpers.stubHTTPClientExecuteRefreshRequest(refreshResult: .success(tokenResponse))

        let sucessResponse = TestResponse(data:  "Retried request SUCCESS")
        mockHTTPClientHelpers.stubHTTPClientExecuteRequest(result: .success(sucessResponse))

        let mockSessionStorage = MockSessionStorage()
        mockHTTPClientHelpers.stubSessionStorageStore(mockSessionStorage: mockSessionStorage, result: .success())

        let client = Client(
            configuration: Fixtures.clientConfig,
            sessionStorage: mockSessionStorage,
            stateStorage: StateStorage(),
            httpClient: mockHTTPClientHelpers.mockHTTPClient
        )
        let user = User(client: client, tokens: Fixtures.userTokens)

        let anyResult: Result<TestResponse,HTTPError> = .failure(.errorResponse(code: 1337, body: "foo"))
        let expectation = TestExpectation(description: "completion should be called with result from retried request")
        let sut = User.TokenRefreshRequestHandler()
        sut.refreshWithRetry(
            user: user,
            requestResult: anyResult,
            request: self.request
        ) { result in
            switch result {
            case .success(let receivedResponse):
                if sucessResponse.data == receivedResponse.data {
                    Task {
                        await expectation.fulfill()
                    }
                }
            default:
                break
            }
        }

        await expectation.wait()
    }

    @Test
    func testRefreshWithRetryRetriedRequestFailure() async {
        let tokenResponse: TokenResponse = TokenResponse(accessToken: "newAccessToken", refreshToken: "newRefreshToken", idToken: nil, scope: nil, expiresIn: 3600)
        mockHTTPClientHelpers.stubHTTPClientExecuteRefreshRequest(refreshResult: .success(tokenResponse))
        mockHTTPClientHelpers.stubHTTPClientExecuteRequest(result: .failure(.errorResponse(code: 1337, body: "Retried request FAILING")))

        let mockSessionStorage = MockSessionStorage()
        mockHTTPClientHelpers.stubSessionStorageStore(mockSessionStorage: mockSessionStorage, result: .success())

        let client = Client(
            configuration: Fixtures.clientConfig,
            sessionStorage: mockSessionStorage,
            stateStorage: StateStorage(),
            httpClient: mockHTTPClientHelpers.mockHTTPClient
        )
        let user = User(client: client, tokens: Fixtures.userTokens)

        let anyResult: Result<TestResponse,HTTPError> = .failure(.errorResponse(code: 1337, body: "foo"))
        let expectation = TestExpectation(description: "completion should be called with result from retried request")
        let sut = User.TokenRefreshRequestHandler()
        sut.refreshWithRetry(
            user: user,
            requestResult: anyResult,
            request: self.request
        ) { result in
            switch result {
            case .failure(.errorResponse(code: 1337, body: let body)):
                if body == "Retried request FAILING" {
                    Task {
                        await expectation.fulfill()
                    }
                }
            default:
                break
            }
        }
        
        await expectation.wait()
    }

    @Test
    func testRefreshWithoutRetryCompletionCalledWithRefreshResultFailure() async {
        let refreshResultBody = "Something went wrong"
        let refreshResult: Result<TokenResponse, HTTPError> = .failure(.errorResponse(code: 500, body: refreshResultBody))
        mockHTTPClientHelpers.stubHTTPClientExecuteRefreshRequest(refreshResult: refreshResult)

        let client = Client(configuration: Fixtures.clientConfig, httpClient: mockHTTPClientHelpers.mockHTTPClient)
        let user = User(client: client, tokens: Fixtures.userTokens)

        let expectation = TestExpectation(description: "completion should be called with refresh result")
        let sut = User.TokenRefreshRequestHandler()
        sut.refreshWithoutRetry(user: user) { result in
            switch result {
            case .failure(.refreshRequestFailed(.errorResponse(_, let body))):
                if body == refreshResultBody {
                    Task {
                        await expectation.fulfill()
                    }
                }
            default:
                break
            }
        }

        await expectation.wait()
    }

    @Test
    func testRefreshWithoutRetryCompletionCalledWithRefreshResultSuccess() async {
        let tokenResponse = TokenResponse(accessToken: "newAccessToken", refreshToken: "newRefreshToken", idToken: nil, scope: nil, expiresIn: 3600)
        mockHTTPClientHelpers.stubHTTPClientExecuteRefreshRequest(refreshResult: .success(tokenResponse))

        let mockSessionStorage = MockSessionStorage()
        mockHTTPClientHelpers.stubSessionStorageStore(mockSessionStorage: mockSessionStorage, result: .success())

        let client = Client(
            configuration: Fixtures.clientConfig,
            sessionStorage: mockSessionStorage,
            stateStorage: StateStorage(),
            httpClient: mockHTTPClientHelpers.mockHTTPClient
        )
        let user = User(client: client, tokens: Fixtures.userTokens)

        let expectation = TestExpectation(description: "completion should be called with refresh result")
        let sut = User.TokenRefreshRequestHandler()
        sut.refreshWithoutRetry(user: user) { result in
            switch result {
            case .success(let data):
                #expect(data.accessToken == tokenResponse.accessToken)
                #expect(data.refreshToken == tokenResponse.refreshToken)
                Task {
                    await expectation.fulfill()
                }
            default:
                Issue.record()
            }
        }

        await expectation.wait()
    }
}

final class FakeUserTokensRefresher: UserTokensRefreshing {
    var onDidCallRefreshTokens: () -> Void = {}
    var completion: ((Result<UserTokens, RefreshTokenError>) -> Void)?
    @MainActor
    func refreshTokens(for user: User, completion: @escaping @MainActor (Result<UserTokens, RefreshTokenError>) -> Void) {
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

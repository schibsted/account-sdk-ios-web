//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation
import Testing

@testable import AccountSDKIOSWeb

@MainActor
@Suite(.disabled("unstable"))
final class AccountSDKIOSWebTests {
    let testURL = URL(staticString: "http://www.example.com")
    let testConfig : URLSessionConfiguration = {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return config
    }()
    let mockHTTPClientHelpers = MockHTTPClientHelpers()

    @Test
    func testRetryRequestWithSuccessfullyRefreshedToken() async {
        setRequestHandler(statusCode: 200)

        // given
        let tokenResponse: TokenResponse = TokenResponse(accessToken: "newAccessToken", refreshToken: "newRefreshToken", idToken: nil, scope: nil, expiresIn: 3600)
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
        
        let expectation = TestExpectation(description: "Original request should be retried with success server response")

        // when
        let sut = AuthenticatedURLSession(user: user, configuration: testConfig)
        let request = URLRequest(url: testURL)
        let test = sut.dataTask(with: request) { data, response, error in
            // then
            #expect(error == nil, "An unexpected result was encountered. Error is not nil")
            #expect(response != nil)
            guard let httpURLResponse = response as? HTTPURLResponse else {
                Issue.record("Incorrect respone")
                return
            }
            #expect(httpURLResponse.statusCode == 200 , "refreshTokenDataTask was never resumed")
            Task {
                await expectation.fulfill()
            }
        }

        test.resume()

        await expectation.wait()

        MockURLProtocol.requestHandler = nil
    }

    @Test
    func testReturnOriginalErrorOnRefreshTokenRequestFailure() async {
        setRequestHandler(statusCode: 401)

        // given
        mockHTTPClientHelpers.stubHTTPClientExecuteRefreshRequest(
            refreshResult: .failure(.errorResponse(code: 500, body: "Something went wrong with refresh"))
        )

        let client = Client(configuration: Fixtures.clientConfig, httpClient: mockHTTPClientHelpers.mockHTTPClient)
        let user = User(client: client, tokens: Fixtures.userTokens)
        
        let expectation = TestExpectation(description: "Return original 401 error response on refresh token request failure")

        // when
        let sut = AuthenticatedURLSession(user: user, configuration: testConfig)
        let request = URLRequest(url: testURL)
        let test = sut.dataTask(with: request) { data, response, error in
            // then
            guard let httpURLResponse = response as? HTTPURLResponse else {
                return
            }
            if httpURLResponse.statusCode == 401 {
                Task {
                    await expectation.fulfill()
                }
            }
        }

        test.resume()

        await expectation.wait()

        MockURLProtocol.requestHandler = nil
    }
    
    // helper fo MockURLProtocol
    // current implementation works for case when failure is the first event
    func setRequestHandler(statusCode: Int) {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: statusCode, httpVersion:nil, headerFields:nil)!
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

//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import XCTest
import Cuckoo

@testable import AccountSDKIOSWeb

final class SimplifiedLoginManagerTests: XCTestCase {
    @MainActor
    func testRequestSimplifiedLogin_noLoggedInSessionInSharedKeychain () {
        let mockHTTPClient = MockHTTPClient()
        let client = Client(configuration: Fixtures.clientConfig, httpClient: mockHTTPClient)
        let sut = SimplifiedLoginManager(client: client, contextProvider: ASWebAuthSessionContextProvider(), completion: { result in })
        
        let expectation = self.expectation(description: "Should fail with SimplifiedLoginError.noLoggedInSessionInSharedKeychain")
        sut.requestSimplifiedLogin(completion: { result in
            switch result {
            case .failure(SimplifiedLoginManager.SimplifiedLoginError.noLoggedInSessionInSharedKeychain):
                expectation.fulfill()
            default:
                XCTFail("Should fail with SimplifiedLoginError.noLoggedInSessionInSharedKeychain")
            }
        })
        
        self.wait(for: [expectation], timeout: 2)
    }

    @MainActor
    func testRequestSimplifiedLogin_failingFetcher() {
        //Mock Client
        let mockHTTPClient = MockHTTPClient()
        let jwks = RemoteJWKS(jwksURI: Fixtures.clientConfig.serverURL.appendingPathComponent("/oauth/jwks"), httpClient: mockHTTPClient)
        let tokenHandler = TokenHandler(configuration: Fixtures.clientConfig, httpClient: mockHTTPClient, jwks: jwks)
        let mockClient = MockClient(configuration: Fixtures.clientConfig,
                                      sessionStorage: MockSessionStorage(),
                                      stateStorage: StateStorage(storage: MockStorage()),
                                      httpClient: mockHTTPClient,
                                      jwks: jwks,
                                      tokenHandler: tokenHandler)
        let returnedUserSession = UserSession(clientId: "aClientId", userTokens: Fixtures.userTokens, updatedAt: Date())
        mockClient.userSessionToReturn = returnedUserSession
        
        // Mock Fetcher
        let mockFetcher = MockSimplifiedLoginFetcher()
        mockFetcher.fetchDataToReturn = .failure(LoginError.canceled)
        
        // Visible Window
        let vc = UIViewController()
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
        
        let sut = SimplifiedLoginManager(client: mockClient, contextProvider: ASWebAuthSessionContextProvider(), fetcher: mockFetcher, completion: { result in })
        let expectation = self.expectation(description: "Should fail when fetchData fails")
        sut.requestSimplifiedLogin(window, completion: { result in
            switch result {
            case .failure(LoginError.canceled):
                expectation.fulfill()
            default:
                XCTFail("Should fail when fetchData fails. With erro: \(String(describing: mockFetcher.fetchDataToReturn))")
            }
        })
        
        self.wait(for: [expectation], timeout: 2)
    }

    @MainActor
    func testRequestSimplifiedLogin_success() {
        //Mock Client
        let mockHTTPClient = MockHTTPClient()
        let jwks = RemoteJWKS(jwksURI: Fixtures.clientConfig.serverURL.appendingPathComponent("/oauth/jwks"), httpClient: mockHTTPClient)
        let tokenHandler = TokenHandler(configuration: Fixtures.clientConfig, httpClient: mockHTTPClient, jwks: jwks)
        let mockClient = MockClient(configuration: Fixtures.clientConfig,
                                      sessionStorage: MockSessionStorage(),
                                      stateStorage: StateStorage(storage: MockStorage()),
                                      httpClient: mockHTTPClient,
                                      jwks: jwks,
                                      tokenHandler: tokenHandler)
        let returnedUserSession = UserSession(clientId: "aClientId", userTokens: Fixtures.userTokens, updatedAt: Date())
        mockClient.userSessionToReturn = returnedUserSession
        
        // Mock Fetcher
        let mockFetcher = MockSimplifiedLoginFetcher()
        let contextResponse = UserContextFromTokenResponse(identifier: "23", displayText: "32", clientName: "32")
        let userProfileResponse = Fixtures.userProfileResponse
        mockFetcher.fetchDataToReturn = .success(SimplifiedLoginFetchedData(contextResponse, userProfileResponse))
        
        // Visible Window
        let vc = UIViewController()
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
        
        
        let sut = SimplifiedLoginManager(client: mockClient, contextProvider: ASWebAuthSessionContextProvider(), fetcher: mockFetcher, completion: { result in })
        let expectation = self.expectation(description: "Should be a sucessfull flow")
        sut.requestSimplifiedLogin(window, completion: { result in
            switch result {
            case .success():
                XCTAssertTrue(window.visibleViewController is SimplifiedLoginViewController, "A ViewController of type SimplifiedLoginViewController, should be visible")
                expectation.fulfill()
            default:
                XCTFail("Should be a sucessfull flow")
            }
        })
        
        self.wait(for: [expectation], timeout: 2)
    }
    
    // MARK: Integration tests

    @MainActor
    func testRequestSimplifiedLogin_noWindow() {
        // MockHTTPClient
        let contextResponse = UserContextFromTokenResponse(identifier: "23", displayText: "32", clientName: "32")
        let userProfileResponse = Fixtures.userProfileResponse
        let mockHTTPClient = MockHTTPClient()
        stub(mockHTTPClient) { mock in
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: ParameterMatcher()))
                .then { (_, _, completion: HTTPResultHandler<UserContextFromTokenResponse>) in
                    completion(.success(contextResponse))
                }
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: ParameterMatcher()))
                .then { (_, _, completion) in
                    completion(.success(SchibstedAccountAPIResponse(data: userProfileResponse)))
                }
        }
        
        // MockClient
        let jwks = RemoteJWKS(jwksURI: Fixtures.clientConfig.serverURL.appendingPathComponent("/oauth/jwks"), httpClient: mockHTTPClient)
        let tokenHandler = TokenHandler(configuration: Fixtures.clientConfig, httpClient: mockHTTPClient, jwks: jwks)
        let mockClient = MockClient(configuration: Fixtures.clientConfig,
                                      sessionStorage: MockSessionStorage(),
                                      stateStorage: StateStorage(storage: MockStorage()),
                                      httpClient: mockHTTPClient,
                                      jwks: jwks,
                                      tokenHandler: tokenHandler)
        let returnedUserSession = UserSession(clientId: "aClientId", userTokens: Fixtures.userTokens, updatedAt: Date())
        mockClient.userSessionToReturn = returnedUserSession
        
        let expectation = self.expectation(description: "Should fail with SimplifiedLoginError.noVisibleViewControllerFound")
        let sut = SimplifiedLoginManager(client: mockClient, contextProvider: ASWebAuthSessionContextProvider(), completion: { result in })
        sut.requestSimplifiedLogin(completion: { result in
            switch result {
            case .failure(SimplifiedLoginManager.SimplifiedLoginError.noVisibleViewControllerFound):
                expectation.fulfill()
            default:
                XCTFail("Should fail with SimplifiedLoginError.noVisibleViewControllerFound")
            }
        })
        
        wait(for: [expectation], timeout: 1)
    }

    @MainActor
    func testRequestSimplifiedLogin_failingProfileResponse() {
        // MockHTTPClient
        let userProfileResponse = Fixtures.userProfileResponse
        let mockHTTPClient = MockHTTPClient()
        let expectedError: Result<UserContextFromTokenResponse, HTTPError> = .failure(HTTPError.unexpectedError(underlying: LoginError.unsolicitedResponse))
        stub(mockHTTPClient) { mock in
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: ParameterMatcher()))
                .then { (_, _, completion: HTTPResultHandler<UserContextFromTokenResponse>) in
                    completion(expectedError)
                }
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: ParameterMatcher()))
                .then { (_, _, completion) in
                    completion(.success(SchibstedAccountAPIResponse(data: userProfileResponse)))
                }
        }
        
        // MockClient
        let jwks = RemoteJWKS(jwksURI: Fixtures.clientConfig.serverURL.appendingPathComponent("/oauth/jwks"), httpClient: mockHTTPClient)
        let tokenHandler = TokenHandler(configuration: Fixtures.clientConfig, httpClient: mockHTTPClient, jwks: jwks)
        let mockClient = MockClient(configuration: Fixtures.clientConfig,
                                      sessionStorage: MockSessionStorage(),
                                      stateStorage: StateStorage(storage: MockStorage()),
                                      httpClient: mockHTTPClient,
                                      jwks: jwks,
                                      tokenHandler: tokenHandler)
        let returnedUserSession = UserSession(clientId: "aClientId", userTokens: Fixtures.userTokens, updatedAt: Date())
        mockClient.userSessionToReturn = returnedUserSession
        
        let expectation = self.expectation(description: "Should fail when fetchData fails")
        let sut = SimplifiedLoginManager(client: mockClient, contextProvider: ASWebAuthSessionContextProvider(), completion: { result in })
        sut.requestSimplifiedLogin(completion: { result in
            switch result {
            case .failure(HTTPError.unexpectedError(underlying: LoginError.unsolicitedResponse)):
                expectation.fulfill()
            default:
                XCTFail("Should fail with expectedError: \(expectedError)")
            }
        })
        
        wait(for: [expectation], timeout: 2)
    }

    @MainActor
    func testRequestSimplifiedLogin_integrationSuccess() {
        // MockHTTPClient
        let contextResponse = UserContextFromTokenResponse(identifier: "23", displayText: "32", clientName: "32")
        let userProfileResponse = Fixtures.userProfileResponse
        let mockHTTPClient = MockHTTPClient()
        stub(mockHTTPClient) { mock in
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: ParameterMatcher()))
                .then { (_, _, completion: HTTPResultHandler<UserContextFromTokenResponse>) in
                    completion(.success(contextResponse))
                }
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: ParameterMatcher()))
                .then { (_, _, completion) in
                    completion(.success(SchibstedAccountAPIResponse(data: userProfileResponse)))
                }
        }
        // MockClient
        let jwks = RemoteJWKS(jwksURI: Fixtures.clientConfig.serverURL.appendingPathComponent("/oauth/jwks"), httpClient: mockHTTPClient)
        let tokenHandler = TokenHandler(configuration: Fixtures.clientConfig, httpClient: mockHTTPClient, jwks: jwks)
        let mockClient = MockClient(configuration: Fixtures.clientConfig,
                                      sessionStorage: MockSessionStorage(),
                                      stateStorage: StateStorage(storage: MockStorage()),
                                      httpClient: mockHTTPClient,
                                      jwks: jwks,
                                      tokenHandler: tokenHandler)
        let returnedUserSession = UserSession(clientId: "aClientId", userTokens: Fixtures.userTokens, updatedAt: Date())
        mockClient.userSessionToReturn = returnedUserSession
        
        // Visible Window
        let vc = UIViewController()
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
        
        
        let sut = SimplifiedLoginManager(client: mockClient, contextProvider: ASWebAuthSessionContextProvider(), completion: { result in })
        let expectation = self.expectation(description: "Should be a successfull flow")
        sut.requestSimplifiedLogin(window, completion: { result in
            switch result {
            case .success():
                XCTAssertTrue(window.visibleViewController is SimplifiedLoginViewController, "A ViewController of type SimplifiedLoginViewController, should be visible")
                expectation.fulfill()
            default:
                XCTFail("Should be a sucessfull flow")
            }
        })
        
        wait(for: [expectation], timeout: 2)
    }
}

class MockClient: Client, @unchecked Sendable {
    var userSessionToReturn: UserSession?
    override func getLatestSharedSession() -> UserSession? {
        return userSessionToReturn
    }
}

class MockSimplifiedLoginFetcher: SimplifiedLoginFetching {
    var fetchDataToReturn: (Result<SimplifiedLoginFetchedData, Error>)?
    func fetchData(completion: @escaping (Result<SimplifiedLoginFetchedData, Error>) -> Void) {
        guard let retData = fetchDataToReturn else {
            XCTFail("Mock not set up properly")
            return
        }
        completion(retData)
    }
    var fetchAssertiontoReturn: (Result<SimplifiedLoginAssertionResponse, Error>)?
    func fetchAssertion(completion: @escaping (Result<SimplifiedLoginAssertionResponse, Error>) -> Void) {
        guard let retData = fetchAssertiontoReturn else {
            XCTFail("Mock not set up properly")
            return
        }
        completion(retData)
    }
}

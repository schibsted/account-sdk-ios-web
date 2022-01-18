import XCTest
import Cuckoo
@testable import AccountSDKIOSWeb

final class SimplifiedLoginManagerTests: XCTestCase {
 
    // MARK: -
    
    func testRequestSimplifiedLogin_noLoggedInSessionInSharedKeychain (){
        let mockHTTPClient = MockHTTPClient()
        let client = Client(configuration: Fixtures.clientConfig, httpClient: mockHTTPClient)
        let sut = SimplifiedLoginManager(client: client, contextProvider: ASWebAuthSessionContextProvider(), env: .pre, completion: { result in })
        
        let expectation = self.expectation(description: "Should fail with SimplifiedLoginError.noLoggedInSessionInSharedKeychain")
        sut.requestSimplifiedLogin("A client name", completion: { result in
            switch result {
            case .failure(SimplifiedLoginManager.SimplifiedLoginError.noLoggedInSessionInSharedKeychain):
                expectation.fulfill()
            default:
                XCTFail("Should fail with SimplifiedLoginError.noLoggedInSessionInSharedKeychain")
            }
        })
        
        self.wait(for: [expectation], timeout: 2)
    }
    
    func testRequestSimplifiedLogin_noClientName() {
        let httpClient = MockHTTPClient()
        let jwks = RemoteJWKS(jwksURI: Fixtures.clientConfig.serverURL.appendingPathComponent("/oauth/jwks"), httpClient: httpClient)
        let tokenHandler = TokenHandler(configuration: Fixtures.clientConfig, httpClient: httpClient, jwks: jwks)
        let mockClient = MockClient(configuration: Fixtures.clientConfig,
                                      sessionStorage: MockSessionStorage(),
                                      stateStorage: StateStorage(storage: MockStorage()),
                                      httpClient: httpClient,
                                      jwks: jwks,
                                      tokenHandler: tokenHandler)
        let returnedUserSession = UserSession(clientId: "aClientId", userTokens: Fixtures.userTokens, updatedAt: Date())
        mockClient.userSessionToReturn = returnedUserSession
        
        let expectation = self.expectation(description: "Should fail with SimplifiedLoginError.noClientNameFound when clientName is nil")
        let sut = SimplifiedLoginManager(client: mockClient, contextProvider: ASWebAuthSessionContextProvider(), env: .pre, completion: { result in })
        sut.requestSimplifiedLogin(nil, completion: { result in
            switch result {
            case .failure(SimplifiedLoginManager.SimplifiedLoginError.noClientNameFound):
                expectation.fulfill()
            default:
                XCTFail("Should fail with SimplifiedLoginError.noClientNameFound when clientName is nil")
            }
        })
        
        self.wait(for: [expectation], timeout: 2)
    }
    
    // MARK: Integration tests
    
    func testRequestSimplifiedLogin_noWindow() {
        // MockHTTPClient
        let contextResponse = UserContextFromTokenResponse(identifier: "23", display_text: "32", client_name: "32")
        let userProfileResponse = Fixtures.userProfileResponse
        let mockHTTPClient = MockHTTPClient()
        stub(mockHTTPClient) { mock in
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: anyClosure()))
                .then { (_, _, completion: HTTPResultHandler<UserContextFromTokenResponse>) in
                    completion(.success(contextResponse))
                }
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: anyClosure()))
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
        let sut = SimplifiedLoginManager(client: mockClient, contextProvider: ASWebAuthSessionContextProvider(), env: .pre, completion: { result in })
        sut.requestSimplifiedLogin("A name", completion: { result in
            switch result {
            case .failure(SimplifiedLoginManager.SimplifiedLoginError.noVisibleViewControllerFound):
                expectation.fulfill()
            default:
                XCTFail("Should fail with SimplifiedLoginError.noVisibleViewControllerFound")
            }
        })
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testRequestSimplifiedLogin_failingProfileResponse() {
        // MockHTTPClient
        let userProfileResponse = Fixtures.userProfileResponse
        let mockHTTPClient = MockHTTPClient()
        let expectedError: Result<UserContextFromTokenResponse, HTTPError> = .failure(HTTPError.unexpectedError(underlying: LoginError.unsolicitedResponse))
        stub(mockHTTPClient) { mock in
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: anyClosure()))
                .then { (_, _, completion: HTTPResultHandler<UserContextFromTokenResponse>) in
                    completion(expectedError)
                }
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: anyClosure()))
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
        let sut = SimplifiedLoginManager(client: mockClient, contextProvider: ASWebAuthSessionContextProvider(), env: .pre, completion: { result in })
        sut.requestSimplifiedLogin("A name", completion: { result in
            switch result {
            case .failure(HTTPError.unexpectedError(underlying: LoginError.unsolicitedResponse)):
                expectation.fulfill()
            default:
                XCTFail("Should fail with expectedError: \(expectedError)")
            }
        })
        
        wait(for: [expectation], timeout: 2)
    }

    func testRequestSimplifiedLogin_success() {
        // MockHTTPClient
        let contextResponse = UserContextFromTokenResponse(identifier: "23", display_text: "32", client_name: "32")
        let userProfileResponse = Fixtures.userProfileResponse
        let mockHTTPClient = MockHTTPClient()
        stub(mockHTTPClient) { mock in
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: anyClosure()))
                .then { (_, _, completion: HTTPResultHandler<UserContextFromTokenResponse>) in
                    completion(.success(contextResponse))
                }
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: anyClosure()))
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
        
        
        let sut = SimplifiedLoginManager(client: mockClient, contextProvider: ASWebAuthSessionContextProvider(), env: .pre, completion: { result in })
        let expectation = self.expectation(description: "Should be a successfull flow")
        sut.requestSimplifiedLogin("A name", window: window, completion: { result in
            switch result {
            case .success():
                XCTAssertTrue(window.visibleViewController is SimplifiedLoginViewController, "A ViewController of type SimplifiedLoginViewController, should be visible")
                expectation.fulfill()
            default:
                XCTFail("Should fail with SimplifiedLoginError.noVisibleViewControllerFound")
            }
        })
        
        wait(for: [expectation], timeout: 2)
    }
}

class MockClient: Client {
    var userSessionToReturn: UserSession?
    override func getLatestSharedSession() -> UserSession? {
        return userSessionToReturn
    }
}

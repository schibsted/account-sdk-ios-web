import XCTest
import Cuckoo
@testable import AccountSDKIOSWeb

final class SimplifiedLoginManagerTests: XCTestCase {
 
    // MARK: -
    
    func testGetSimplifiedLogin_noLoggedInSessionInSharedKeychain (){
        let mockHTTPClient = MockHTTPClient()
        let client = Client(configuration: Fixtures.clientConfig, httpClient: mockHTTPClient)
        let sut = SimplifiedLoginManager(client: client, contextProvider: ASWebAuthSessionContextProvider(), env: .pre, completion: { result in })
        
        let expectation = self.expectation(description: "Should fail with SimplifiedLoginError.noLoggedInSessionInSharedKeychain")
        sut.requestSimplifiedLogin(nil, completion: { result in
            switch result {
            case .failure(SimplifiedLoginManager.SimplifiedLoginError.noLoggedInSessionInSharedKeychain):
                expectation.fulfill()
            default:
                XCTFail("Should fail with SimplifiedLoginError.noLoggedInSessionInSharedKeychain")
            }
        })
        
        self.wait(for: [expectation], timeout: 0.2)
    }
    
    func testGetSimplifiedLogin_noClientName() {
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
        
        self.wait(for: [expectation], timeout: 0.2)
    }
}

class MockClient: Client {
    var userSessionToReturn: UserSession?
    override func getLatestSharedSession() -> UserSession? {
        return userSessionToReturn
    }
}

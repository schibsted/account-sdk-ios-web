import XCTest
import Cuckoo
@testable import AccountSDKIOSWeb

final class ClientTests: XCTestCase {
    private let config = ClientConfiguration(environment: .pre, clientId: "client1", clientSecret: "clientSecret", redirectURI: URL("com.example.client1://login"))
    private let userDefaults: UserDefaults! = UserDefaults(suiteName: #file)!

    private static let keyId = "test key"
    private static var jwsUtil: JWSUtil!
    
    override class func setUp() {
        jwsUtil = JWSUtil()
    }
    
    override func setUp() {
        DefaultStorage.storage = UserDefaultsStorage(userDefaults)
        let mockTokenStorage = MockTokenStorage()
        stub(mockTokenStorage) { mock in
            when(mock.store(any())).thenDoNothing()
        }
        DefaultTokenStorage.storage = mockTokenStorage
    }
    
    override func tearDown() {
        userDefaults.removePersistentDomain(forName: #file)
    }
    
    func testLoginURL() {
        let client = Client(configuration: config)
        let loginURL = client.loginURL()
        
        XCTAssertEqual(loginURL?.scheme, "https")
        XCTAssertEqual(loginURL?.host, "identity-pre.schibsted.com")
        XCTAssertEqual(loginURL?.path, "/oauth/authorize")
        
        let components = URLComponents(url: loginURL!, resolvingAgainstBaseURL: true)
        let queryParams = components?.queryItems?.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
        
        XCTAssertEqual(queryParams!["client_id"], config.clientId)
        XCTAssertEqual(queryParams!["redirect_uri"], config.redirectURI.absoluteString)
        XCTAssertEqual(queryParams!["response_type"], "code")
        XCTAssertEqual(queryParams!["prompt"], "select_account")
        XCTAssertEqual(queryParams!["scope"], "openid")
        XCTAssertNotNil(queryParams!["state"])
        XCTAssertNotNil(queryParams!["nonce"])
        XCTAssertNotNil(queryParams!["code_challenge"])
        XCTAssertEqual(queryParams!["code_challenge_method"], "S256")
    }
    
    func testHandleAuthenticationResponseRejectsUnsolicitedResponse() {
        let client = Client(configuration: config)
        
        let callbackExpectation = expectation(description: "Returns error to callback closure")
        
        client.handleAuthenticationResponse(url: URL("com.example://login?state=no-exist&code=123456")) { result in
            XCTAssertEqual(result, .failure(.unsolicitedResponse))
            callbackExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testHandleAuthenticationResponseHandlesErrorResponse() {
        let client = Client(configuration: config)
   
        let callbackExpectation = expectation(description: "Returns error to callback closure")
        
        let state = "testState"
        DefaultStorage.setValue(WebFlowData(state: state, codeVerifier: "codeVerifier"), forKey: Client.webFlowLoginStateKey)

        client.handleAuthenticationResponse(url: URL(string: "com.example://login?state=\(state)&error=invalid_request&error_description=test%20error")!) { result in
            XCTAssertEqual(result, .failure(.authenticationErrorResponse(error: OAuthError(error: "invalid_request", errorDescription: "test error"))))
            callbackExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testHandleAuthenticationResponseHandlesMissingAuthCode() {
        let client = Client(configuration: config)
   
        let callbackExpectation = expectation(description: "Returns error to callback closure")
        
        let state = "testState"
        DefaultStorage.setValue(WebFlowData(state: state, codeVerifier: "codeVerifier"), forKey: Client.webFlowLoginStateKey)

        client.handleAuthenticationResponse(url: URL(string: "com.example://login?state=\(state)")!) { result in
            XCTAssertEqual(result, .failure(.unexpectedError(message: "Missing authorization code from authentication response")))
            callbackExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }

    func testHandleAuthenticationResponseHandlesSuccessResponse() {
        let uuid = "test_user_uuid"
        let idToken = createIdToken(uuid: uuid)
        let tokenResponse = TokenResponse(access_token: "accessToken", refresh_token: "refreshToken", id_token: idToken, scope: "openid", expires_in: 3600)
        let mockHTTPClient = MockHTTPClient()
        
        stub(mockHTTPClient) { mock in
            when(mock.post(url: equal(to: config.serverURL.appendingPathComponent("/oauth/token")),
                           body: any(),
                           contentType: HTTPUtil.xWWWFormURLEncodedContentType,
                           authorization: HTTPUtil.basicAuth(username: config.clientId, password: config.clientSecret),
                           completion: anyClosure()))
                .then { _, _, _, _, completion in
                    completion(.success(tokenResponse))
                }
            
            let jwksResponse = JWKSResponse(keys: [RSAJWK(kid: ClientTests.keyId, kty: "RSA", e: ClientTests.jwsUtil.publicJWK.exponent, n: ClientTests.jwsUtil.publicJWK.modulus, alg: "RS256", use: "sig")])
            when(mock.get(url: equal(to: config.serverURL.appendingPathComponent("/oauth/jwks")), completion: anyClosure()))
                .then { _, completion in
                    completion(.success(jwksResponse))
                }
        }
        
        let client = Client(configuration: config, httpClient: mockHTTPClient)
        
        let callbackExpectation = expectation(description: "Exchanges code for user tokens")

        let state = "testState"
        DefaultStorage.setValue(WebFlowData(state: state, codeVerifier: "codeVerifier"), forKey: Client.webFlowLoginStateKey)

        client.handleAuthenticationResponse(url: URL(string: "com.example://login?code=12345&state=\(state)")!) { result in
            XCTAssertEqual(result, .success(User(accessToken: tokenResponse.access_token, refreshToken: tokenResponse.refresh_token, idToken: idToken, idTokenClaims: IdTokenClaims(sub: uuid))))
            callbackExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testResumeLastLoggedInUserWithExistingTokens() {
        let storedTokens = StoredUserTokens(clientId: config.clientId, accessToken: "accessToken", refreshToken: "refreshToken", idToken: "idToken", idTokenClaims: IdTokenClaims(sub: "userUuid"))
        let mockTokenStorage = MockTokenStorage()
        stub(mockTokenStorage) { mock in
            when(mock.get()).thenReturn(storedTokens)
        }
        
        DefaultTokenStorage.storage = mockTokenStorage
        let client = Client(configuration: config)
        let user = client.resumeLastLoggedInUser()
        XCTAssertEqual(user, User(accessToken: storedTokens.accessToken, refreshToken: storedTokens.refreshToken, idToken: storedTokens.idToken, idTokenClaims: storedTokens.idTokenClaims))
    }
    
    func testResumeLastLoggedInUserWithExistingTokensForAnotherClient() {
        let storedTokens = StoredUserTokens(clientId: "otherClientId", accessToken: "accessToken", refreshToken: "refreshToken", idToken: "idToken", idTokenClaims: IdTokenClaims(sub: "userUuid"))
        let mockTokenStorage = MockTokenStorage()
        stub(mockTokenStorage) { mock in
            when(mock.get()).thenReturn(storedTokens)
        }
        
        DefaultTokenStorage.storage = mockTokenStorage
        let client = Client(configuration: config)
        XCTAssertNil(client.resumeLastLoggedInUser())
    }
    
    func testResumeLastLoggedInUserWithoutTokens() {
        let mockTokenStorage = MockTokenStorage()
        stub(mockTokenStorage) { mock in
            when(mock.get()).thenReturn(nil)
        }
        
        DefaultTokenStorage.storage = mockTokenStorage
        let client = Client(configuration: config)
        XCTAssertNil(client.resumeLastLoggedInUser())
    }
    
    private func createIdToken(uuid: String) -> String {
        let data = try! JSONEncoder().encode(IdTokenClaims(sub: uuid))
        return ClientTests.jwsUtil.createJWS(payload: data, keyId: ClientTests.keyId)
    }
}

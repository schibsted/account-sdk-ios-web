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
        let mockSessionStorage = MockSessionStorage()
        stub(mockSessionStorage) { mock in
            when(mock.store(any())).thenDoNothing()
        }
        DefaultSessionStorage.storage = mockSessionStorage
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
    
    func testLoginURLWithExtraScopes() {
        let client = Client(configuration: config)
        let loginURL = client.loginURL(extraScopeValues: ["scope1", "scope2"])
        
        XCTAssertEqual(loginURL?.scheme, "https")
        XCTAssertEqual(loginURL?.host, "identity-pre.schibsted.com")
        XCTAssertEqual(loginURL?.path, "/oauth/authorize")
        
        let components = URLComponents(url: loginURL!, resolvingAgainstBaseURL: true)
        let queryParams = components?.queryItems?.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }

        let scope = Set(queryParams!["scope"]!.components(separatedBy: " "))
        XCTAssertEqual(queryParams!["client_id"], config.clientId)
        XCTAssertEqual(queryParams!["redirect_uri"], config.redirectURI.absoluteString)
        XCTAssertEqual(queryParams!["response_type"], "code")
        XCTAssertEqual(queryParams!["prompt"], "select_account")
        XCTAssertEqual(scope, Set(["openid", "scope1", "scope2"]))
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
        let idToken = createIdToken(claims: Fixtures.idTokenClaims)
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
            XCTAssertEqual(result, .success(User(clientId: self.config.clientId, accessToken: tokenResponse.access_token, refreshToken: tokenResponse.refresh_token, idToken: idToken, idTokenClaims: Fixtures.idTokenClaims)))
            callbackExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testResumeLastLoggedInUserWithExistingSession() {
        let session = UserSession(clientId: config.clientId, userTokens: Fixtures.userTokens, updatedAt: Date())
        let mockSessionStorage = MockSessionStorage()
        stub(mockSessionStorage) { mock in
            when(mock.get(forClientId: config.clientId)).thenReturn(session)
        }
        
        DefaultSessionStorage.storage = mockSessionStorage
        let client = Client(configuration: config)
        let user = client.resumeLastLoggedInUser()
        XCTAssertEqual(user, User(session: session))
    }
    
    func testResumeLastLoggedInUserWithoutSession() {
        let mockSessionStorage = MockSessionStorage()
        stub(mockSessionStorage) { mock in
            when(mock.get(forClientId: config.clientId)).thenReturn(nil)
        }
        
        DefaultSessionStorage.storage = mockSessionStorage
        let client = Client(configuration: config)
        XCTAssertNil(client.resumeLastLoggedInUser())
    }
    
    func testSimplifiedLoginDataWithExistingSession() {
        let now = Date()
        let newestSession = UserSession(clientId: config.clientId, userTokens: Fixtures.userTokens, updatedAt: now)
        let earlierSession = UserSession(clientId: "other client", userTokens: Fixtures.userTokens, updatedAt: now.addingTimeInterval(-1000))
        let mockSessionStorage = MockSessionStorage()
        stub(mockSessionStorage) { mock in
            when(mock.getAll()).thenReturn([newestSession, earlierSession])
        }
        
        DefaultSessionStorage.storage = mockSessionStorage
        let client = Client(configuration: config)
        let result = client.simplifiedLoginData()
        XCTAssertEqual(result, SimplifiedLoginData(uuid: newestSession.userTokens.idTokenClaims.sub, clients: [newestSession.clientId, earlierSession.clientId]))
    }
    
    func testSimplifiedLoginDataWithoutSession() {
        let mockSessionStorage = MockSessionStorage()
        stub(mockSessionStorage) { mock in
            when(mock.getAll()).thenReturn([])
        }
        
        DefaultSessionStorage.storage = mockSessionStorage
        XCTAssertNil(Client(configuration: config).simplifiedLoginData())
    }
    
    func testPerformSimplifiedLogin() {
        let session = UserSession(clientId: "anyClientId", userTokens: Fixtures.userTokens, updatedAt: Date())
        let mockSessionStorage = MockSessionStorage()
        stub(mockSessionStorage) { mock in
            when(mock.getAll()).thenReturn([session])
            when(mock.store(any())).thenDoNothing()
        }
        DefaultSessionStorage.storage = mockSessionStorage

        let idToken = createIdToken(claims: Fixtures.idTokenClaims)
        let tokenResponse = TokenResponse(access_token: "otherAccessToken", refresh_token: "otherRefreshToken", id_token: idToken, scope: "openid", expires_in: 3600)
        let mockHTTPClient = MockHTTPClient()
        stub(mockHTTPClient) { mock in
            when(mock.post(url: equal(to: config.serverURL.appendingPathComponent("/api/2/oauth/exchange")),
                           body: any(),
                           contentType: HTTPUtil.xWWWFormURLEncodedContentType,
                           authorization: "Bearer \(Fixtures.userTokens.accessToken)",
                           completion: anyClosure()))
                .then { _, _, _, _, completion in
                    completion(.success(SchibstedAccountAPIResponse(data: OAuthCodeExchangeResponse(code: "authCode"))))
                }

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
        
        let callbackExpectation = expectation(description: "Returns logged-in user to callback closure")
        
        let client = Client(configuration: config, httpClient: mockHTTPClient)
        client.performSimplifiedLogin { result in
            let user = User(clientId: self.config.clientId,
                            accessToken: tokenResponse.access_token,
                            refreshToken: tokenResponse.refresh_token,
                            idToken: idToken,
                            idTokenClaims: Fixtures.userTokens.idTokenClaims)
            XCTAssertEqual(result, .success(user))
            callbackExpectation.fulfill()
        }

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func testPerformSimplifiedLoginWithoutSession() {
        let mockSessionStorage = MockSessionStorage()
        stub(mockSessionStorage) { mock in
            when(mock.getAll()).thenReturn([])
        }
        DefaultSessionStorage.storage = mockSessionStorage
        let client = Client(configuration: config)
        client.performSimplifiedLogin { result in
            XCTAssertEqual(result, .failure(.unexpectedError(message: "No user sessions found")))
        }
    }

    private func createIdToken(claims: IdTokenClaims) -> String {
        let data = try! JSONEncoder().encode(claims)
        return ClientTests.jwsUtil.createJWS(payload: data, keyId: ClientTests.keyId)
    }
}

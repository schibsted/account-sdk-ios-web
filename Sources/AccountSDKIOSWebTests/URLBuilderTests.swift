//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import XCTest
import Cuckoo

@testable import AccountSDKIOSWeb

final class URLBuilderTests: XCTestCase {
    let authStateKey: String = "AString"
    private var mockStorage: MockStorage!
    
    override func setUp() {
        mockStorage = MockStorage()
        stub(mockStorage) { mock in
            when(mock.setValue(any(), forKey: authStateKey)).thenDoNothing()
        }
    }

    func testLoginURLWithAssertion() {
        let sut = URLBuilder(configuration: Fixtures.clientConfig)
        let authRequest = URLBuilder.AuthorizationRequest(loginHint: "", assertion: "assertion string", extraScopeValues: [])
        let state = "extra state"
        let loginURL = sut.loginURL(authRequest: authRequest, authState: AuthState(mfa: nil, state: state))
        
        XCTAssertEqual(loginURL?.scheme, "https")
        XCTAssertEqual(loginURL?.host, "issuer.example.com")
        XCTAssertEqual(loginURL?.path, "/oauth/authorize")
        
        let components = URLComponents(url: loginURL!, resolvingAgainstBaseURL: true)
        let queryParams = components?.queryItems?.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
        
        XCTAssertEqual(queryParams!["client_id"], Fixtures.clientConfig.clientId)
        XCTAssertEqual(queryParams!["redirect_uri"], Fixtures.clientConfig.redirectURI.absoluteString)
        XCTAssertEqual(queryParams!["response_type"], "code")
        XCTAssertEqual(queryParams!["prompt"], "select_account")
        compareScope(queryParams!["scope"]!, Set(["openid", "offline_access"]))
        XCTAssertEqual(queryParams!["state"], state)
        XCTAssertNotNil(queryParams!["nonce"])
        XCTAssertNotNil(queryParams!["code_challenge"])
        XCTAssertEqual(queryParams!["code_challenge_method"], "S256")
        
        XCTAssertEqual(queryParams!["assertion"], "assertion string")
    }
    
    func testLoginURL() {
        let sut = URLBuilder(configuration: Fixtures.clientConfig)
        let authRequest = URLBuilder.AuthorizationRequest(loginHint: "", assertion: "", extraScopeValues: [])
        let loginURL = sut.loginURL(authRequest: authRequest, authState: AuthState(mfa: nil, state: nil))
        
        XCTAssertEqual(loginURL?.scheme, "https")
        XCTAssertEqual(loginURL?.host, "issuer.example.com")
        XCTAssertEqual(loginURL?.path, "/oauth/authorize")
        
        let components = URLComponents(url: loginURL!, resolvingAgainstBaseURL: true)
        let queryParams = components?.queryItems?.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
        
        XCTAssertEqual(queryParams!["client_id"], Fixtures.clientConfig.clientId)
        XCTAssertEqual(queryParams!["redirect_uri"], Fixtures.clientConfig.redirectURI.absoluteString)
        XCTAssertEqual(queryParams!["response_type"], "code")
        XCTAssertEqual(queryParams!["prompt"], "select_account")
        compareScope(queryParams!["scope"]!, Set(["openid", "offline_access"]))
        XCTAssertNotNil(queryParams!["state"])
        XCTAssertNotNil(queryParams!["nonce"])
        XCTAssertNotNil(queryParams!["code_challenge"])
        XCTAssertEqual(queryParams!["code_challenge_method"], "S256")
    }
    
    func testLoginURLWithExtraScopes() {
        let sut = URLBuilder(configuration: Fixtures.clientConfig)

        let authRequest = URLBuilder.AuthorizationRequest(loginHint: "", assertion: "", extraScopeValues: ["scope1", "scope2"])
        let loginURL = sut.loginURL(authRequest: authRequest, authState: AuthState(mfa: nil, state: nil))
        
        XCTAssertEqual(loginURL?.scheme, "https")
        XCTAssertEqual(loginURL?.host, "issuer.example.com")
        XCTAssertEqual(loginURL?.path, "/oauth/authorize")
        
        let components = URLComponents(url: loginURL!, resolvingAgainstBaseURL: true)
        let queryParams = components?.queryItems?.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }

        XCTAssertEqual(queryParams!["client_id"], Fixtures.clientConfig.clientId)
        XCTAssertEqual(queryParams!["redirect_uri"], Fixtures.clientConfig.redirectURI.absoluteString)
        XCTAssertEqual(queryParams!["response_type"], "code")
        XCTAssertEqual(queryParams!["prompt"], "select_account")
        compareScope(queryParams!["scope"]!, Set(["openid", "offline_access", "scope1", "scope2"]))
        XCTAssertNotNil(queryParams!["state"])
        XCTAssertNotNil(queryParams!["nonce"])
        XCTAssertNotNil(queryParams!["code_challenge"])
        XCTAssertEqual(queryParams!["code_challenge_method"], "S256")
    }
    
    func testLoginURLWithMFAIncludesACRValues() {
        let sut = URLBuilder(configuration: Fixtures.clientConfig)
        let authRequest = URLBuilder.AuthorizationRequest(loginHint: "", assertion: "", extraScopeValues: [])
        let loginURL = sut.loginURL(authRequest: authRequest, authState: AuthState(mfa: .otp, state: "extra state"))
        
        XCTAssertEqual(loginURL?.scheme, "https")
        XCTAssertEqual(loginURL?.host, "issuer.example.com")
        XCTAssertEqual(loginURL?.path, "/oauth/authorize")
        
        let components = URLComponents(url: loginURL!, resolvingAgainstBaseURL: true)
        let queryParams = components?.queryItems?.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }

        XCTAssertEqual(queryParams!["acr_values"], "otp")
        XCTAssertNil(queryParams!["prompt"])

        XCTAssertEqual(queryParams!["client_id"], Fixtures.clientConfig.clientId)
        XCTAssertEqual(queryParams!["redirect_uri"], Fixtures.clientConfig.redirectURI.absoluteString)
        XCTAssertEqual(queryParams!["response_type"], "code")
        compareScope(queryParams!["scope"]!, Set(["openid", "offline_access"]))
        XCTAssertEqual(queryParams!["state"], "extra state")
        XCTAssertNotNil(queryParams!["nonce"])
        XCTAssertNotNil(queryParams!["code_challenge"])
        XCTAssertEqual(queryParams!["code_challenge_method"], "S256")
    }
    
    private func compareScope(_ receivedScope: String, _ expectedScope: Set<String>) {
        let scope = Set(receivedScope.components(separatedBy: " "))
        XCTAssertEqual(scope, expectedScope)
    }
}

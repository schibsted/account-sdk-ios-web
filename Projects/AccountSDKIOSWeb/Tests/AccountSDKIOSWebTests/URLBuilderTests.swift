//
//  URLBuilderTests.swift
//  AccountSDKIOSWeb
//
//  Created by Daniel Echegaray on 2021-06-11.
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

    func testLoginURL() {
        let sut = URLBuilder(configuration: Fixtures.clientConfig, stateStorage: StateStorage(storage: mockStorage), authStateKey: authStateKey)
        
        let loginURL = sut.loginURL()
        
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
        let sut = URLBuilder(configuration: Fixtures.clientConfig, stateStorage: StateStorage(storage: mockStorage), authStateKey: authStateKey)

        let loginURL = sut.loginURL(extraScopeValues: ["scope1", "scope2"])
        
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
        let sut = URLBuilder(configuration: Fixtures.clientConfig, stateStorage: StateStorage(storage: mockStorage), authStateKey: authStateKey)

        let loginURL = sut.loginURL(withMFA: .otp)
        
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
        XCTAssertNotNil(queryParams!["state"])
        XCTAssertNotNil(queryParams!["nonce"])
        XCTAssertNotNil(queryParams!["code_challenge"])
        XCTAssertEqual(queryParams!["code_challenge_method"], "S256")
    }
    
    private func compareScope(_ receivedScope: String, _ expectedScope: Set<String>) {
        let scope = Set(receivedScope.components(separatedBy: " "))
        XCTAssertEqual(scope, expectedScope)
    }
}

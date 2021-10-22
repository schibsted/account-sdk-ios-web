//
//  ExampleWebTests.swift
//  ExampleWebTests
//
//  Created by Daniel Echegaray on 2021-10-22.
//

import XCTest

import AccountSDKIOSWeb
import AccountSDKIOSWebTests

class ExampleWebTests: XCTestCase {

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let clientRedirectURI = URL(string: "com.sdk-example.pre.602504e1b41fa31789a95aa7:/login")!
        let clientConfiguration = ClientConfiguration(environment: .pre,
                                                      clientId: "602504e1b41fa31789a95aa7",
                                                      redirectURI: clientRedirectURI)
        
        let client = Client(configuration: clientConfiguration)
        let userWithSetAccessToken = UserTests().setUserAccessToken(accessToken: "232", client: client)
    }

}

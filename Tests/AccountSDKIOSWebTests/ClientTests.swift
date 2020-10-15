import XCTest
@testable import AccountSDKIOSWeb

final class AccountSDKIOSWebTests: XCTestCase {
    private let config = ClientConfiguration(environment: .pre, clientID: "client1", clientSecret: "clientSecret", redirectURI: URL("com.example.client1://login"))

    func testLoginURL() {
        let client = Client(configuration: config)
        let loginURL = client.loginURL(shouldPersistUser: false)
        
        XCTAssertEqual(loginURL?.scheme, "https")
        XCTAssertEqual(loginURL?.host, "identity-pre.schibsted.com")
        XCTAssertEqual(loginURL?.path, "/oauth/authorize")
        
        let components = URLComponents(url: loginURL!, resolvingAgainstBaseURL: true)
        let queryParams = components?.queryItems?.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
        
        XCTAssertEqual(queryParams!["client_id"], config.clientID)
        XCTAssertEqual(queryParams!["redirect_uri"], config.redirectURI.absoluteString)
        XCTAssertEqual(queryParams!["response_type"], "code")
        XCTAssertEqual(queryParams!["scope"], "openid")
        XCTAssertNotNil(queryParams!["state"])
        XCTAssertNotNil(queryParams!["nonce"])
        XCTAssertNotNil(queryParams!["code_challenge"])
        XCTAssertEqual(queryParams!["code_challenge_method"], "S256")
    }
}

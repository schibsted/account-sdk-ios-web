//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation
@testable import AccountSDKIOSWeb

struct Fixtures {
    static let clientConfig = ClientConfiguration(env: .pre, serverURL: URL(string: "https://issuer.example.com")!, sessionServiceURL: URL(string: "https://another.issuer.example.com")!, clientId: "client1", redirectURI: URL("com.example.client1://login"))
    static let idTokenClaims = IdTokenClaims(iss: clientConfig.issuer, sub: "userUuid", userId: "12345", aud: ["client1"], exp: Date().timeIntervalSince1970 + 3600, nonce: "testNonce", amr: nil)
    static let userTokens = UserTokens(accessToken: "accessToken", refreshToken: "refreshToken", idToken: "idToken", idTokenClaims: Fixtures.idTokenClaims)
    
    static let jwsUtil = JWSUtil()
    static let schibstedAccountAPI = SchibstedAccountAPI(baseURL: Fixtures.clientConfig.serverURL, sessionServiceURL: Fixtures.clientConfig.sessionServiceURL)
    
    static let userProfileResponse = UserProfileResponse(uuid: "uuid", userId: "12345", status: 0, email: "email@email.com", emailVerified: nil, emails: [], phoneNumber: "123456789", phoneNumberVerified: nil, phoneNumbers: [], displayName: "foo bar", name: Name(givenName: "John", familyName: "White", formatted: nil), addresses: [:], gender: "male", birthday: "0000-00-00", accounts: [:], merchants: [], published: "2022-06-10 09:54:23", verified: "2022-06-10 09:54:23", updated: "2022-06-10 09:54:23", passwordChanged: nil, lastAuthenticated: "2022-06-10 09:54:23", lastLoggedIn: "2022-06-10 09:54:23", locale: "sv_SE", utcOffset: "UTC+01")
    static let userContext = UserContextFromTokenResponse(identifier: "foo", displayText: "foo bar", clientName: "bar")
}

extension IdTokenClaims {   
    func copy(iss: String? = nil, sub: String? = nil, userId: String? = nil, aud: [String]? = nil, exp: Double? = nil, nonce: OptionalValue<String>? = nil, amr: OptionalValue<[String]>? = nil) -> IdTokenClaims {
        return IdTokenClaims(iss: iss ?? self.iss,
                             sub: sub ?? self.sub,
                             userId: userId ?? self.userId,
                             aud: aud ?? self.aud,
                             exp: exp ?? self.exp,
                             nonce: nonce.map { $0.value } ?? self.nonce,
                             amr: amr.map { $0.value } ?? self.amr)
    }
}

struct OptionalValue<T> {
    let value: T?
    
    public init(_ value: T?) {
        self.value = value
    }   
}

struct TestResponse: Codable, Equatable {
    let data: String
}

extension URL {
    init(_ string: StaticString) {
        guard let url = URL(string: "\(string)") else {
            preconditionFailure("Invalid static URL string: \(string)")
        }

        self = url
    }
}

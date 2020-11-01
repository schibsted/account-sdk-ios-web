import Foundation
@testable import AccountSDKIOSWeb

struct Fixtures {
    static let idTokenClaims = IdTokenClaims(sub: "userUuid")
    static let userTokens = UserTokens(accessToken: "accessToken", refreshToken: "refreshToken", idToken: "idToken", idTokenClaims: Fixtures.idTokenClaims)
}

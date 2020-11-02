import Foundation
@testable import AccountSDKIOSWeb

struct Fixtures {
    static let idTokenClaims = IdTokenClaims(sub: "userUuid", amr: nil)
    static let userTokens = UserTokens(accessToken: "accessToken", refreshToken: "refreshToken", idToken: "idToken", idTokenClaims: Fixtures.idTokenClaims)
}

import Foundation
@testable import AccountSDKIOSWeb

struct Fixtures {
    static let idTokenClaims = IdTokenClaims(iss: "https://issuer.example.com", sub: "userUuid", aud: ["client1"], exp: Date().timeIntervalSince1970 + 3600, nonce: "testNonce", amr: nil)
    static let userTokens = UserTokens(accessToken: "accessToken", refreshToken: "refreshToken", idToken: "idToken", idTokenClaims: Fixtures.idTokenClaims)
    
    static let jwsUtil = JWSUtil()
}

extension IdTokenClaims {   
    func copy(iss: String? = nil, sub: String? = nil, aud: [String]? = nil, exp: Double? = nil, nonce: OptionalValue<String>? = nil, amr: OptionalValue<[String]>? = nil) -> IdTokenClaims {
        return IdTokenClaims(iss: iss ?? self.iss,
                             sub: sub ?? self.sub,
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

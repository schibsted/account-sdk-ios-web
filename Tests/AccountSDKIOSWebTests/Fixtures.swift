import Foundation
@testable import AccountSDKIOSWeb

struct Fixtures {
    static let clientConfig = ClientConfiguration(serverURL: URL(string: "https://issuer.example.com")!, clientId: "client1", redirectURI: URL("com.example.client1://login"))
    static let idTokenClaims = IdTokenClaims(iss: "https://issuer.example.com", sub: "userUuid", userId: "12345", aud: ["client1"], exp: Date().timeIntervalSince1970 + 3600, nonce: "testNonce", amr: nil)
    static let userTokens = UserTokens(accessToken: "accessToken", refreshToken: "refreshToken", idToken: "idToken", idTokenClaims: Fixtures.idTokenClaims)
    
    static let jwsUtil = JWSUtil()
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

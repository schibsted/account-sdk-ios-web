import Foundation
import Security

internal struct UserSession: Codable {
    let clientId: String
    let userTokens: UserTokens
    let updatedAt: Date
}

internal struct UserTokens: Codable {
    let accessToken: String
    let refreshToken: String?
    let idToken: String
    let idTokenClaims: IdTokenClaims
}

internal protocol SessionStorage {
    func store(_ value: UserSession)
    func get(forClientId: String) -> UserSession?
    func remove(forClientId: String)
}

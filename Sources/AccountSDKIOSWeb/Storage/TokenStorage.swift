import Foundation
import Security

internal struct StoredUserTokens: Codable {
    let clientId: String
    let accessToken: String
    let refreshToken: String?
    let idToken: String
    let idTokenClaims: IdTokenClaims
}

internal protocol TokenStorage {
    func store(_ value: StoredUserTokens)
    func get(forClientId: String) -> StoredUserTokens?
    func remove(forClientId: String)
}

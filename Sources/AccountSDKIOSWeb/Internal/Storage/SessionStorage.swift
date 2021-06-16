import Foundation
import Security

internal struct UserSession: Codable, Equatable {
    let clientId: String
    let userTokens: UserTokens
    let updatedAt: Date
}

internal struct UserTokens: Codable, Equatable, CustomStringConvertible {
    let accessToken: String
    let refreshToken: String?
    let idToken: String
    let idTokenClaims: IdTokenClaims
    
    var description: String {
        return "UserTokens("
            + "accessToken: \(removeSignature(fromToken: accessToken)),\n"
            + "refreshToken: \(removeSignature(fromToken: refreshToken)),\n"
            + "idToken: \(removeSignature(fromToken: idToken)),\n"
            + "idTokenClaims: \(idTokenClaims))"
    }
}

internal protocol SessionStorage {
    func store(_ value: UserSession)
    func get(forClientId: String) -> UserSession?
    func getAll() -> [UserSession]
    func remove(forClientId: String)
}

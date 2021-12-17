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
    func store(_ value: UserSession, accessGroup: String?, completion: @escaping (Result<Void, Error>) -> Void)
    func get(forClientId: String, completion: @escaping (UserSession?) -> Void)  
    func getAll() -> [UserSession]
    func remove(forClientId: String)
    func getLatestSession() -> UserSession?
}

extension SessionStorage {
    func getLatestSession() -> UserSession? {
        let latestUserSession = self.getAll()
            .sorted { $0.updatedAt > $1.updatedAt }
            .first
        return latestUserSession
    }
}

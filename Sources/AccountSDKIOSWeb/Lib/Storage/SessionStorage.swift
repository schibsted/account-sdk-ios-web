import Foundation
import Security

internal struct UserSession: Codable, Equatable {
    let clientId: String
    let userTokens: UserTokens
    let updatedAt: Date
}

public struct UserTokens: Codable, Equatable, CustomStringConvertible {
    let accessToken: String
    let refreshToken: String?
    let idToken: String
    let idTokenClaims: IdTokenClaims
    
    public init(accessToken: String, refreshToken: String?, idToken: String, idTokenClaims: IdTokenClaims) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.idToken = idToken
        self.idTokenClaims = idTokenClaims
    }
    
    public var description: String {
        return "UserTokens("
            + "accessToken: \(removeSignature(fromToken: accessToken)),\n"
            + "refreshToken: \(removeSignature(fromToken: refreshToken)),\n"
            + "idToken: \(removeSignature(fromToken: idToken)),\n"
            + "idTokenClaims: \(idTokenClaims))"
    }
}

internal protocol SessionStorage {
    func store(_ value: UserSession, completion: @escaping (Result<Void, Error>) -> Void)
    func get(forClientId: String, completion: @escaping (UserSession?) -> Void)  
    func getAll() -> [UserSession]
    func remove(forClientId: String)
}

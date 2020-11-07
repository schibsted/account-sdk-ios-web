import Foundation

public class User: Equatable {
    private let sessionStorage: SessionStorage
    
    private let clientId: String
    private let accessToken: String
    private let refreshToken: String?
    private let idToken: String
    private let idTokenClaims: IdTokenClaims
    
    public let uuid: String
    
    init(sessionStorage: SessionStorage, clientId: String, accessToken: String, refreshToken: String?, idToken: String, idTokenClaims: IdTokenClaims) {
        self.sessionStorage = sessionStorage
        self.clientId = clientId
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.idToken = idToken
        
        self.idTokenClaims = idTokenClaims
        self.uuid = idTokenClaims.sub
    }
    
    convenience init(session: UserSession, sessionStorage: SessionStorage) {
        self.init(sessionStorage: sessionStorage,
                  clientId: session.clientId,
                  accessToken: session.userTokens.accessToken,
                  refreshToken: session.userTokens.refreshToken,
                  idToken: session.userTokens.idToken,
                  idTokenClaims: session.userTokens.idTokenClaims)
    }
    
    public func logout() {
        sessionStorage.remove(forClientId: clientId)
    }
    
    public static func == (lhs: User, rhs: User) -> Bool {
        return lhs.uuid == rhs.uuid
            && lhs.clientId == rhs.clientId
            && lhs.accessToken == rhs.accessToken
            && lhs.refreshToken == rhs.refreshToken
            && lhs.idToken == rhs.idToken
            && lhs.idTokenClaims == rhs.idTokenClaims
    }
}

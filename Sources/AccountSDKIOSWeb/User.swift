import Foundation

public class User: Equatable {
    private let accessToken: String
    private let refreshToken: String?
    private let idToken: String
    private let idTokenClaims: IdTokenClaims
    
    public let uuid: String
    
    init(accessToken: String, refreshToken: String?, idToken: String, idTokenClaims: IdTokenClaims) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.idToken = idToken
        
        self.idTokenClaims = idTokenClaims
        self.uuid = idTokenClaims.sub
    }
    
    public static func == (lhs: User, rhs: User) -> Bool {
        return lhs.accessToken == rhs.accessToken
            && lhs.refreshToken == rhs.refreshToken
            && lhs.idToken == rhs.idToken
    }
}

import Foundation
import JOSESwift

class LegacyKeychainSessionStorage {
    private let storage: LegacyKeychainTokenStorage
    
    convenience init(accessGroup: String? = nil) {
        self.init(storage: LegacyKeychainTokenStorage(accessGroup: accessGroup))
    }
    
    init(storage: LegacyKeychainTokenStorage) {
        self.storage = storage
    }

    func get(forClientId: String) -> UserSession? {
        let sessions = storage.get()
            .compactMap(toUserSession(_:))
            .filter { $0.clientId == forClientId } // filter tokens only for the requested client

        // return the newest token, based on 'iat' claim in ID Token
        return sessions.sorted { $0.updatedAt > $1.updatedAt }.first
    }
    
    func remove() {
        storage.remove()
    }
    
    private func toUserSession(_ legacyTokenData: LegacyTokenData) -> UserSession? {
        let validatedAccessToken = validateTokenFormat(legacyTokenData.accessToken)
        guard let accessTokenClaims = unverifiedClaims(from: validatedAccessToken),
              let clientId = accessTokenClaims["client_id"] as? String else {
            return nil
        }

        guard let unverifiedIdTokenClaims = unverifiedClaims(from: legacyTokenData.idToken),
              let sub = unverifiedIdTokenClaims["sub"] as? String else {
            return nil
        }

        let updatedAt: Date
        if let issuedAt = unverifiedIdTokenClaims["iat"] as? Double {
            updatedAt = Date(timeIntervalSince1970: issuedAt)
        } else {
            updatedAt = Date()
        }

        let legacyUserId = unverifiedIdTokenClaims["legacy_user_id"] as? String
        let idTokenClaims = IdTokenClaims(iss: unverifiedIdTokenClaims["iss"] as! String,
                                          sub: sub,
                                          userId: legacyUserId ?? "",
                                          aud: [],
                                          exp: unverifiedIdTokenClaims["exp"] as! Double,
                                          nonce: unverifiedIdTokenClaims["nonce"] as? String,
                                          amr: nil)
        let userTokens = UserTokens(accessToken: legacyTokenData.accessToken,
                                    refreshToken: legacyTokenData.refreshToken,
                                    idToken: legacyTokenData.idToken,
                                    idTokenClaims: idTokenClaims)
        return UserSession(clientId: clientId, userTokens: userTokens, updatedAt: updatedAt)
    }
    
    private func unverifiedClaims(from token: String) -> [String: Any]? {
        guard let jws = try? JWS(compactSerialization: token) else {
            return nil
        }

        return try? JSONSerialization.jsonObject(with: jws.payload.data()) as? [String: Any]
    }
    
    private func validateTokenFormat(_ token: String) -> String {
        var validToken = token
        if !validToken.starts(with: "e") {
            validToken = "e\(token.dropFirst())"
        }
        return validToken
    }
}


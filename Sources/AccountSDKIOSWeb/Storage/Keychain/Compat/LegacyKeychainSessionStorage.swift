import Foundation
import JOSESwift

class LegacyKeychainSessionStorage {
    private let storage: LegacyKeychainTokenStorage
    
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
        guard let accessTokenClaims = unverifiedClaims(from: legacyTokenData.accessToken),
              let clientId = accessTokenClaims["client_id"] as? String else {
            return nil
        }

        guard let idTokenClaims = unverifiedClaims(from: legacyTokenData.idToken),
              let sub = idTokenClaims["sub"] as? String else {
            return nil
        }

        let updatedAt: Date
        if let issuedAt = idTokenClaims["iat"] as? Double {
            updatedAt = Date(timeIntervalSince1970: issuedAt)
        } else {
            updatedAt = Date()
        }

        let userTokens = UserTokens(accessToken: legacyTokenData.accessToken,
                                    refreshToken: legacyTokenData.refreshToken,
                                    idToken: legacyTokenData.idToken,
                                    idTokenClaims: IdTokenClaims(sub: sub, nonce: idTokenClaims["nonce"] as? String, amr: nil))
        return UserSession(clientId: clientId, userTokens: userTokens, updatedAt: updatedAt)
    }
    
    private func unverifiedClaims(from token: String) -> [String: Any]? {
        guard let jws = try? JWS(compactSerialization: token) else {
            return nil
        }

        return try? JSONSerialization.jsonObject(with: jws.payload.data()) as? [String: Any]
    }
}

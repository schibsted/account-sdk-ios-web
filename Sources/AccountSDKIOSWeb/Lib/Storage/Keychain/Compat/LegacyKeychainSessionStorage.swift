//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

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

    func get(forClientId: String) -> LegacyUserSession? {
        let sessions = storage.get()
            .compactMap(toLegacyUserSession(_:))
            .filter { $0.clientId == forClientId } // filter tokens only for the requested client

        // return the newest token, based on 'iat' claim in ID Token
        return sessions.sorted { $0.updatedAt > $1.updatedAt }.first
    }

    func remove() {
        storage.remove()
    }

    private func toLegacyUserSession(_ legacyTokenData: LegacyTokenData) -> LegacyUserSession? {
        let validatedAccessToken = validateTokenFormat(legacyTokenData.accessToken)
        guard let accessTokenClaims = unverifiedClaims(from: validatedAccessToken),
              let clientId = accessTokenClaims["client_id"] as? String else {
            return nil
        }
        return LegacyUserSession(clientId: clientId,
                                 accessToken: validatedAccessToken,
                                 refreshToken: legacyTokenData.refreshToken,
                                 updatedAt: Date())
    }

    private func unverifiedClaims(from token: String) -> [String: Any]? {
        guard let jws = try? JWS(compactSerialization: token) else {
            return nil
        }

        return try? JSONSerialization.jsonObject(with: jws.payload.data()) as? [String: Any]
    }

    // Access token saved by the old SDK sometimes has a wrong first character. This leads to JWS token decoding error and migration failure. To prevent this issue swapping characters is make before decoding.
    private func validateTokenFormat(_ token: String) -> String {
        var validToken = token
        if !validToken.starts(with: "e") {
            validToken = "e\(token.dropFirst())"
        }
        return validToken
    }
}

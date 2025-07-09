//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation
import Security

struct UserSession: Codable, Equatable, Sendable {
    let clientId: String
    let userTokens: UserTokens
    let updatedAt: Date
}

public struct UserTokens: Codable, Equatable, Sendable, CustomStringConvertible {
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

protocol SessionStorage: Sendable {
    var accessGroup: String? { get }
    func store(_ value: UserSession, accessGroup: String?) throws
    func get(forClientId: String) -> UserSession?
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

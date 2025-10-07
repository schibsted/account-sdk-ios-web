//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

/// Claims used within the ID Token for all OAuth 2.0 flows.
public struct IdTokenClaims: Codable, Equatable, Sendable {
    enum CodingKeys: String, CodingKey {
        case iss
        case sub
        case userId = "legacy_user_id"
        case aud
        case exp
        case nonce
        case amr
    }

    /// Issuer Identifier for the Issuer of the response.
    ///
    /// The iss value is a case-sensitive URL using the https scheme that contains scheme, host,
    /// and optionally, port number and path components and no query or fragment components.
    public let iss: String

    /// A locally unique and never reassigned identifier within the Issuer for the End-User,
    /// which is intended to be consumed by the Client.
    ///
    /// It MUST NOT exceed 255 ASCII characters in length.
    /// The sub value is a case-sensitive string.
    public let sub: String

    /// Legacy User ID (not part of OAuth Standard)
    public let userId: String

    /// Audience(s) that this ID Token is intended for. It MUST contain the OAuth 2.0 `client_id` as an audience value.
    public let aud: [String]

    /// Expiration time on or after which the ID Token MUST NOT be accepted.
    public let exp: Double

    /// String value used to associate a Client session with an ID Token, and to mitigate replay attacks.
    public let nonce: String?

    /// Authentication Methods References.
    ///
    /// JSON array of strings that are identifiers for authentication methods used in the authentication.
    public let amr: [String]?

    public init(
        iss: String,
        sub: String,
        userId: String,
        aud: [String],
        exp: Double,
        nonce: String?,
        amr: [String]?
    ) {
        self.iss = iss
        self.sub = sub
        self.userId = userId
        self.aud = aud
        self.exp = exp
        self.nonce = nonce
        self.amr = amr
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.iss = try values.decode(String.self, forKey: .iss)
        self.sub = try values.decode(String.self, forKey: .sub)
        self.userId = try values.decode(String.self, forKey: .userId)
        self.aud = try IdTokenClaims.extractAudience(from: values)
        self.exp = try values.decode(Double.self, forKey: .exp)
        self.nonce = try values.decodeIfPresent(String.self, forKey: .nonce)
        self.amr = try values.decodeIfPresent([String].self, forKey: .amr)
    }

    /// In the general case, the aud value is an array of case-sensitive strings.
    /// In the common special case when there is one audience, the aud value MAY be a single case-sensitive string.
    private static func extractAudience(from values: KeyedDecodingContainer<CodingKeys>) throws -> [String] {
        // first try to read 'aud' as a plain string value
        guard let singleAudienceValue = try? values.decode(String.self, forKey: .aud) else {
            // if that fails, try to read it as an array of values
            return try values.decode([String].self, forKey: .aud)
        }
        return [singleAudienceValue]
    }
}

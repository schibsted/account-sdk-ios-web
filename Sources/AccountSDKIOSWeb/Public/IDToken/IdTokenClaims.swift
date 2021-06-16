import Foundation

public struct IdTokenClaims: Codable, Equatable {
    let iss: String
    let sub: String
    let userId: String
    let aud: [String]
    let exp: Double
    let nonce: String?
    let amr: [String]?
    
   enum CodingKeys: String, CodingKey {
        case iss
        case sub
        case legacy_user_id
        case aud
        case exp
        case nonce
        case amr
    }
}

extension IdTokenClaims {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.iss = try values.decode(String.self, forKey: .iss)
        self.sub = try values.decode(String.self, forKey: .sub)
        self.userId = try values.decode(String.self, forKey: .legacy_user_id)
        self.aud = try IdTokenClaims.extractAudience(from: values)
        self.exp = try values.decode(Double.self, forKey: .exp)
        self.nonce = try values.decodeIfPresent(String.self, forKey: .nonce)
        self.amr = try values.decodeIfPresent([String].self, forKey: .amr)
    }
    
    private static func extractAudience(from values: KeyedDecodingContainer<CodingKeys>) throws -> [String] {
        // first try to read 'aud' as a plain string value
        guard let singleAudienceValue = try? values.decode(String.self, forKey: .aud) else {
            // if that fails, try to read it as an array of values
            return try values.decode([String].self, forKey: .aud)
        }
        
        return [singleAudienceValue]
    }
}

extension IdTokenClaims {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(iss, forKey: .iss)
        try container.encode(sub, forKey: .sub)
        try container.encode(userId, forKey: .legacy_user_id)
        try container.encode(aud, forKey: .aud)
        try container.encode(exp, forKey: .exp)
        try container.encode(nonce, forKey: .nonce)
        try container.encode(amr, forKey: .amr)
    }
}

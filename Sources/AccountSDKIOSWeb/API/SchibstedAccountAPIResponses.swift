import Foundation

internal struct SchibstedAccountAPIResponse<T: Codable>: Codable {
    let data: T
}

struct CodeExchangeResponse: Codable {
    let code: String
}

struct SessionExchangeResponse: Codable {
    let code: String
}

public struct Name: Codable {
    public var givenName: String? = nil
    public var familyName: String? = nil
    public var formatted: String? = nil
}

public struct UserProfileResponse: Codable {
    public var userId: String? = nil
    public var email: String? = nil
    public var phoneNumber: String? = nil
    public var displayName: String? = nil
    public var name: Name? = nil
}

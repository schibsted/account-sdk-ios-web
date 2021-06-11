import Foundation

internal struct SchibstedAccountAPIResponse<T: Codable>: Codable {
    let data: T
}

struct SessionExchangeResponse: Codable {
    let code: String
}

public struct UserProfileResponse: Codable, Equatable {
    public var uuid: String? = nil
    public var userId: String? = nil
    public var status: Int? = nil
    public var email: String? = nil
    internal var emailVerified: StringOrIgnore? = nil
    public var emails: [Email]? = nil
    public var phoneNumber: String? = nil
    internal var phoneNumberVerified: StringOrIgnore? = nil
    public var phoneNumbers: [PhoneNumber]? = nil
    public var displayName: String? = nil
    public var name: Name? = nil
    public var addresses: [String: Address]? = nil
    public var gender: String? = nil
    internal var birthday: String?
    public var accounts: [String: Account]? = nil
    public var merchants: [Int]? = nil
    public var published: String? = nil
    public var verified: String? = nil
    public var updated: String? = nil
    public var passwordChanged: String? = nil
    public var lastAuthenticated: String? = nil
    public var lastLoggedIn: String? = nil
    public var locale: String? = nil
    public var utcOffset: String? = nil

    public var emailVerifiedDate: String? {
        get { emailVerified?.value }
    }
    
    public var phoneNumberVerifiedDate: String? {
        get { phoneNumberVerified?.value }
    }
    
    public var birthdate: String? {
        get {
            if birthday == "0000-00-00" {
                return nil
            }
            return birthday
        }
    }
}

public protocol Identifier: Codable, Equatable {
    var value: String? { get }
    var type: String?  { get }
    var isPrimary: Bool? { get }
    var isVerified: Bool? { get }
    var verifiedTime: String? { get }
}

public struct Email: Identifier {
    public var value: String? = nil
    public var type: String? = nil
    internal var primary: StringBool? = nil
    internal var verified: StringBool? = nil
    public var verifiedTime: String? = nil
    
    public var isPrimary: Bool? { get { primary?.value } }
    public var isVerified: Bool? { get { verified?.value } }
}

public struct PhoneNumber: Identifier {
    public var value: String? = nil
    public var type: String? = nil
    internal var primary: StringBool? = nil
    internal var verified: StringBool? = nil
    public var verifiedTime: String? = nil
    
    public var isPrimary: Bool? { get { primary?.value } }
    public var isVerified: Bool? { get { verified?.value } }
}

public struct Name: Codable, Equatable {
    public var givenName: String? = nil
    public var familyName: String? = nil
    public var formatted: String? = nil
}

public struct Account: Codable, Equatable {
    public var id: String? = nil
    public var accountName: String? = nil
    public var domain: String? = nil
    public var connected: String? = nil
}

public struct Address: Codable, Equatable {
    public var formatted: String? = nil
    public var streetAddress: String? = nil
    public var postalCode: String? = nil
    public var locality: String? = nil
    public var region: String? = nil
    public var country: String? = nil
    public var type: AddressType? = nil

    public enum AddressType: String, Codable, Equatable {
        case home = "home"
        case delivery = "delivery"
        case invoice = "invoice"
    }
}

internal struct StringBool: Codable, Equatable {
    let value: Bool?
    let asString: Bool
}

extension StringBool {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        guard let value = try? container.decode(Bool.self) else {
            let value = try? container.decode(String.self)
            self.value = value == "true"
            asString = true
            return
        }
        
        self.value = value
        asString = false
    }
    
    func encode(to encoder: Encoder) throws {
        guard let boolValue = value else {
            return
        }

        var container = encoder.singleValueContainer()
        if (asString) {
            try container.encode(String(boolValue))
        } else {
            try container.encode(boolValue)
        }
    }
}

internal struct StringOrIgnore: Codable, Equatable {
    let value: String?
}

extension StringOrIgnore {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.value = try? container.decode(String.self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        guard let stringValue = value else {
            try container.encode(false)
            return
        }

        try container.encode(stringValue)
    }
}

import Foundation

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
    
    init(
        uuid: String? = nil,
        userId: String? = nil,
        status: Int? = nil,
        email: String? = nil,
        emailVerified: StringOrIgnore? = nil,
        emails: [Email]? = nil,
        phoneNumber: String? = nil,
        phoneNumberVerified: StringOrIgnore? = nil,
        phoneNumbers: [PhoneNumber]? = nil,
        displayName: String? = nil,
        name: Name? = nil,
        addresses: [String: Address]? = nil,
        gender: String? = nil,
        birthday: String? = nil,
        accounts: [String: Account]? = nil,
        merchants: [Int]? = nil,
        published: String? = nil,
        verified: String? = nil,
        updated: String? = nil,
        passwordChanged: String? = nil,
        lastAuthenticated: String? = nil,
        lastLoggedIn: String? = nil,
        locale: String? = nil,
        utcOffset: String? = nil
    ) {
        self.uuid = uuid
        self.userId = userId
        self.status = status
        self.email = email
        self.emailVerified = emailVerified
        self.emails = emails
        self.phoneNumber = phoneNumber
        self.phoneNumberVerified = phoneNumberVerified
        self.phoneNumbers = phoneNumbers
        self.displayName = displayName
        self.name = name
        self.addresses = addresses
        self.gender = gender
        self.birthday = birthday
        self.accounts = accounts
        self.merchants = merchants
        self.published = published
        self.verified = verified
        self.updated = updated
        self.passwordChanged = passwordChanged
        self.lastAuthenticated = lastAuthenticated
        self.lastLoggedIn = lastLoggedIn
        self.locale = locale
        self.utcOffset = utcOffset
    }
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.uuid = try? keyedContainer.decode(String.self, forKey: .uuid)
        self.userId = try? keyedContainer.decode(String.self, forKey: .userId)
        self.status = try? keyedContainer.decode(Int.self, forKey: .status)
        self.email = try? keyedContainer.decode(String.self, forKey: .email)
        self.emailVerified = try? keyedContainer.decode(StringOrIgnore.self, forKey: .emailVerified)
        self.emails = try? keyedContainer.decode([Email].self, forKey: .emails)
        self.phoneNumber = try? keyedContainer.decode(String.self, forKey: .phoneNumber)
        self.phoneNumberVerified = try? keyedContainer.decode(StringOrIgnore.self, forKey: .phoneNumberVerified)
        self.phoneNumbers = try? keyedContainer.decode([PhoneNumber].self, forKey: .phoneNumbers)
        self.displayName = try? keyedContainer.decode(String.self, forKey: .displayName)
        self.name = try? keyedContainer.decode(Name.self, forKey: .name)
        self.gender = try? keyedContainer.decode(String.self, forKey: .gender)
        self.birthday = try? keyedContainer.decode(String.self, forKey: .birthday)
        self.merchants = try? keyedContainer.decode([Int].self, forKey: .merchants)
        self.published = try? keyedContainer.decode(String.self, forKey: .published)
        self.verified = try? keyedContainer.decode(String.self, forKey: .verified)
        self.updated = try? keyedContainer.decode(String.self, forKey: .updated)
        self.passwordChanged = try? keyedContainer.decode(String.self, forKey: .passwordChanged)
        self.lastAuthenticated = try? keyedContainer.decode(String.self, forKey: .lastAuthenticated)
        self.lastLoggedIn = try? keyedContainer.decode(String.self, forKey: .lastLoggedIn)
        self.locale = try? keyedContainer.decode(String.self, forKey: .locale)
        self.utcOffset = try? keyedContainer.decode(String.self, forKey: .utcOffset)
        
        // Backend service could return empty dictionary as an array.
        if let addresses = try? keyedContainer.decodeIfPresent([String: Address].self, forKey: .addresses) {
            self.addresses = addresses
        } else {
            self.addresses = [:]
        }
        
        if let accounts = try? keyedContainer.decodeIfPresent([String: Account].self, forKey: .accounts) {
            self.accounts = accounts
        } else {
            self.accounts = [:]
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

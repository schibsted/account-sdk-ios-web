//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

public struct UserProfileResponse: Codable, Equatable {
    public var uuid: String
    public var userId: String
    public var status: Int
    public var email: String
    internal var emailVerified: StringOrIgnore?
    public var emails: [Email]
    public var phoneNumber: String?
    internal var phoneNumberVerified: StringOrIgnore?
    public var phoneNumbers: [PhoneNumber]?
    public var displayName: String
    public var name: Name
    public var addresses: [String: Address]?
    public var gender: String
    internal var birthday: String
    public var accounts: [String: Account]?
    public var merchants: [Int]?
    public var published: String
    public var verified: String?
    public var updated: String
    public var passwordChanged: String?
    public var lastAuthenticated: String
    public var lastLoggedIn: String
    public var locale: String
    public var utcOffset: String

    public var emailVerifiedDate: String? {
        return emailVerified?.value
    }

    public var phoneNumberVerifiedDate: String? {
        return phoneNumberVerified?.value
    }

    public var birthdate: String? {
        if birthday == "0000-00-00" {
            return nil
        }
        return birthday
    }

    init(
        uuid: String,
        userId: String,
        status: Int,
        email: String,
        emailVerified: StringOrIgnore? = nil,
        emails: [Email],
        phoneNumber: String? = nil,
        phoneNumberVerified: StringOrIgnore? = nil,
        phoneNumbers: [PhoneNumber]? = nil,
        displayName: String,
        name: Name,
        addresses: [String: Address]? = nil,
        gender: String,
        birthday: String,
        accounts: [String: Account]? = nil,
        merchants: [Int]? = nil,
        published: String,
        verified: String? = nil,
        updated: String,
        passwordChanged: String? = nil,
        lastAuthenticated: String,
        lastLoggedIn: String,
        locale: String,
        utcOffset: String
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
        self.uuid = try keyedContainer.decode(String.self, forKey: .uuid)
        self.userId = try keyedContainer.decode(String.self, forKey: .userId)
        self.status = try keyedContainer.decode(Int.self, forKey: .status)
        self.email = try keyedContainer.decode(String.self, forKey: .email)
        self.emailVerified = try? keyedContainer.decode(StringOrIgnore.self, forKey: .emailVerified)
        self.emails = try keyedContainer.decode([Email].self, forKey: .emails)
        self.phoneNumber = try? keyedContainer.decode(String.self, forKey: .phoneNumber)
        self.phoneNumberVerified = try? keyedContainer.decode(StringOrIgnore.self, forKey: .phoneNumberVerified)
        self.phoneNumbers = try? keyedContainer.decode([PhoneNumber].self, forKey: .phoneNumbers)
        self.displayName = try keyedContainer.decode(String.self, forKey: .displayName)
        self.name = try keyedContainer.decode(Name.self, forKey: .name)
        self.gender = try keyedContainer.decode(String.self, forKey: .gender)
        self.birthday = try keyedContainer.decode(String.self, forKey: .birthday)
        self.merchants = try? keyedContainer.decode([Int].self, forKey: .merchants)
        self.published = try keyedContainer.decode(String.self, forKey: .published)
        self.verified = try? keyedContainer.decode(String.self, forKey: .verified)
        self.updated = try keyedContainer.decode(String.self, forKey: .updated)
        self.passwordChanged = try? keyedContainer.decode(String.self, forKey: .passwordChanged)
        self.lastAuthenticated = try keyedContainer.decode(String.self, forKey: .lastAuthenticated)
        self.lastLoggedIn = try keyedContainer.decode(String.self, forKey: .lastLoggedIn)
        self.locale = try keyedContainer.decode(String.self, forKey: .locale)
        self.utcOffset = try keyedContainer.decode(String.self, forKey: .utcOffset)

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
    var type: String? { get }
    var isPrimary: Bool? { get }
    var isVerified: Bool? { get }
    var verifiedTime: String? { get }
}

public struct Email: Identifier {
    public var value: String?
    public var type: String?
    internal var primary: StringBool?
    internal var verified: StringBool?
    public var verifiedTime: String?

    public var isPrimary: Bool? { return primary?.value }
    public var isVerified: Bool? { return verified?.value }
}

public struct PhoneNumber: Identifier {
    public var value: String?
    public var type: String?
    internal var primary: StringBool?
    internal var verified: StringBool?
    public var verifiedTime: String?

    public var isPrimary: Bool? { return primary?.value }
    public var isVerified: Bool? { return verified?.value }
}

public struct Name: Codable, Equatable {
    public var givenName: String?
    public var familyName: String?
    public var formatted: String?
}

public struct Account: Codable, Equatable {
    public var id: String?
    public var accountName: String?
    public var domain: String?
    public var connected: String?
}

public struct Address: Codable, Equatable {
    public var formatted: String?
    public var streetAddress: String?
    public var postalCode: String?
    public var locality: String?
    public var region: String?
    public var country: String?
    public var type: AddressType?

    public enum AddressType: String, Codable, Equatable {
        case home
        case delivery
        case invoice
    }
}

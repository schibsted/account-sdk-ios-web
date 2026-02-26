//
// Copyright © 2026 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

public import Foundation

/// Schibsted Account User Profile.
public struct SchibstedAuthenticatorUserProfile: Codable, Equatable, Sendable {
    /// User UUID.
    public let uuid: UUID
    /// (Legacy) User ID.
    public let userId: String
    /// Email.
    public let email: String?
    /// Display Name.
    public let displayName: String
    /// Full name.
    public let name: Name?
    /// Addresses.
    public let addresses: Addresses?
    /// Gender.
    public let gender: String?
    /// Schibsted Account Merchant IDs associated with the user.
    public let merchants: [Int]?
    /// User SDRN.
    public let sdrn: String?

    /// Creates an SchibstedAuthenticatorUserProfile instance.
    public init(
        uuid: UUID,
        userId: String,
        email: String? = nil,
        displayName: String,
        name: Name? = nil,
        addresses: Addresses? = nil,
        gender: String? = nil,
        merchants: [Int]? = nil,
        sdrn: String? = nil
    ) {
        self.uuid = uuid
        self.userId = userId
        self.email = email
        self.displayName = displayName
        self.name = name
        self.addresses = addresses
        self.gender = gender
        self.merchants = merchants
        self.sdrn = sdrn
    }

    /// User Profile Name.
    public struct Name: Codable, Equatable, Sendable {
        /// Given name.
        public let givenName: String?
        /// Family name.
        public let familyName: String?
        /// Formatted full name.
        public let formatted: String?

        public init(
            givenName: String?,
            familyName: String?,
            formatted: String? = nil
        ) {
            self.givenName = givenName
            self.familyName = familyName
            self.formatted = formatted
        }
    }

    public struct Addresses: Codable, Equatable, Sendable {
        /// Home address.
        public let home: Address?
    }

    /// User Profile Address.
    public struct Address: Codable, Equatable, Sendable {
        /// Formatted address.
        public let formatted: String?
        /// Street address.
        public let streetAddress: String?
        /// Postal code.
        public let postalCode: String?
        /// Locality.
        public let locality: String?
        /// Region.
        public let region: String?
        /// Country.
        public let country: String?

        public init(
            formatted: String?,
            streetAddress: String?,
            postalCode: String?,
            locality: String?,
            region: String?,
            country: String?
        ) {
            self.formatted = formatted
            self.streetAddress = streetAddress
            self.postalCode = postalCode
            self.locality = locality
            self.region = region
            self.country = country
        }
    }
}

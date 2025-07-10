//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

/// Multi-factor authentication methods
public enum MFAType: Codable, Sendable {
    /// Ask user to re-authenticate by entering their password
    case password
    /// One-time code generated from TOTP app
    case otp
    /// One-time code sent to user as SMS
    case sms
    /// BankId verification
    case eid
    /// BankId verification for PRE environment
    case preEid(PreEidType)

  var rawValue: String {
    switch self {
    case .password:
        return "password"
    case .otp:
        return "otp"
    case .sms:
        return "sms"
    case .eid:
        return "eid"
    case .preEid(let value):
        return value.rawValue
    }
  }
}

public enum PreEidType: String, Codable, Sendable {
    /// BankId verification - Denmark
    case dk = "eid-dk"  // swiftlint:disable:this identifier_name
    /// BankId verification - Finland
    case fi = "eid-fi"
    /// BankId verification - Norway
    case no = "eid-no"
    /// BankId verification - Sweden
    case se = "eid-se"
}

import Foundation

/// Multi-factor authentication methods
public enum MFAType: Codable {
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

public enum PreEidType: String, Codable {
    // swiftlint:disable identifier_name
    /// BankId verification - Norway
    case no = "eid-no"
    /// BankId verification - Sweden
    case se = "eid-se"
}

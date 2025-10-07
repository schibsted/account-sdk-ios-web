//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

/// Multi-factor authentication methods.
public enum MultifactorAuthentication: Codable, Sendable {
    /// Ask user to re-authenticate by entering their password.
    case password
    /// One-time code generated from TOTP app.
    case oneTimeCode
    /// One-time code sent to user as SMS.
    case sms
    /// BankId verification.
    case bankId
    /// BankId verification for PRE environment.
    case preBankId(PreBankId)

    public var rawValue: String {
        switch self {
        case .password:
            "password"
        case .oneTimeCode:
            "otp"
        case .sms:
            "sms"
        case .bankId:
            "eid"
        case .preBankId(let pre):
            pre.rawValue
        }
    }

    /// Pre-production Bank ID verification.
    public enum PreBankId: String, Codable, Sendable {
        /// BankId verification - Finland
        case fi = "eid-fi"
        /// BankId verification - Norway
        case no = "eid-no"
        /// BankId verification - Sweden
        case se = "eid-se"
    }
}

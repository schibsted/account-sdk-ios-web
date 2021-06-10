import Foundation

internal struct AuthState: Codable {
    let state: String
    let nonce: String
    let codeVerifier: String
    let mfa: MFAType?
}

/// Multi-factor authentication methods
public enum MFAType: String, Codable {
    /// Ask user to re-authenticate by entering their password
    case password = "password"
    /// One-time code generated from TOTP app
    case otp = "otp"
    /// One-time code sent to user as SMS
    case sms = "sms"
}

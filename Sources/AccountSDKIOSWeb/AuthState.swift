import Foundation
import CommonCrypto

internal struct AuthState: Codable {
    let state: String
    let nonce: String
    let codeVerifier: String
    let mfa: MFAType?
    let codeChallengeMethod: String
    
    func makeCodeChallenge () -> String {
        return computeCodeChallenge(from: codeVerifier)
    }
    
}

extension AuthState {
    
    init(mfa: MFAType?) {
        
        let state = randomString(length: 10)
        let nonce = randomString(length: 10)
        let codeVerifier = randomString(length: 60)
        let codeChallengeMethod = "S256"
        
        self.init(state: state, nonce: nonce, codeVerifier: codeVerifier, mfa: mfa, codeChallengeMethod: codeChallengeMethod)
    }
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

fileprivate func randomString(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).map { _ in letters.randomElement()! })
}

fileprivate func computeCodeChallenge(from codeVerifier: String) -> String {
    func base64url(data: Data) -> String {
        let base64url = data.base64EncodedString()
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "=", with: "")
        return base64url
    }

    func sha256(data: Data) -> Data {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash)
    }

    return base64url(data: sha256(data: Data(codeVerifier.utf8)))
}

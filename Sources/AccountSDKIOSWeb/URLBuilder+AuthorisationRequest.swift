import Foundation
import CommonCrypto

extension URLBuilder {
    
    struct AuthorisationRequest {
        let state: String
        let nonce: String
        let codeVerifier: String
        
        init() {
            state = Self.randomString(length: 10)
            nonce = Self.randomString(length: 10)
            codeVerifier = Self.randomString(length: 60)
        }
        
        var codeChallenge: String {
            get {
                return Self.computeCodeChallenge(from: codeVerifier)
            }
        }

        
        private static func randomString(length: Int) -> String {
            let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            return String((0..<length).map { _ in letters.randomElement()! })
        }
        
        private static func computeCodeChallenge(from codeVerifier: String) -> String {
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
    }
}

import Foundation
import CommonCrypto

struct URLBuilder {
    
    let configuration: ClientConfiguration
    let defaultScopeValues = ["openid", "offline_access"]
    let stateStorage: StateStorage
    let authStateKey: String
    
    func loginURL(withMFA: MFAType? = nil,
                  loginHint: String? = nil,
                  extraScopeValues: Set<String> = []) -> URL? {
        let state = randomString(length: 10)
        let nonce = randomString(length: 10)
        let codeVerifier = randomString(length: 60)
        let authState = AuthState(state: state, nonce: nonce, codeVerifier: codeVerifier, mfa: withMFA)

        if !stateStorage.setValue(authState, forKey: authStateKey) {
            SchibstedAccountLogger.instance.error("Failed to store login state")
            return nil;
        }

        let scopes = extraScopeValues.union(defaultScopeValues)
        let scopeString = scopes.joined(separator: " ")
        let codeChallenge = computeCodeChallenge(from: codeVerifier)

        var authRequestParams = [
            URLQueryItem(name: "client_id", value: configuration.clientId),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI.absoluteString),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: scopeString),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "nonce", value: nonce),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
        ]
        
        if let loginHint = loginHint { authRequestParams.append(URLQueryItem(name: "login_hint", value: loginHint)) }
        
        if let mfa = withMFA {
            authRequestParams.append(URLQueryItem(name: "acr_values", value: mfa.rawValue))
        } else {
            // Only add this if no MFA is specified to avoid prompting user unnecessarily
            authRequestParams.append(URLQueryItem(name: "prompt", value: "select_account"))
        }

        return makeURLWithQuery(
            forPath: "/oauth/authorize",
            queryItems: authRequestParams
        )
    }
    
    private func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
    
    private func makeURLWithQuery(forPath path: String, queryItems: [URLQueryItem]) -> URL {
        let url = configuration.serverURL.appendingPathComponent(path)
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            preconditionFailure("Failed to create URLComponents from \(url)")
        }
        urlComponents.queryItems = queryItems

        guard let finalUrl = urlComponents.url else {
            preconditionFailure("Failed to create URL from \(urlComponents)")
        }
        return finalUrl
    }
    
    private func computeCodeChallenge(from codeVerifier: String) -> String {
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

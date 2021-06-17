import Foundation

struct URLBuilder {
    
    let configuration: ClientConfiguration
    let defaultScopeValues = ["openid", "offline_access"]
    
    func loginURL(authRequest: AuthorizationRequest, authState: AuthState) -> URL? {

        let scopes = authRequest.extraScopeValues.union(defaultScopeValues)
        let scopeString = scopes.joined(separator: " ")
        
        var authRequestParams = [
            URLQueryItem(name: "client_id", value: configuration.clientId),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI.absoluteString),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: scopeString),
            
            URLQueryItem(name: "state", value: authState.state),
            URLQueryItem(name: "nonce", value: authState.nonce),
            URLQueryItem(name: "code_challenge", value: authState.makeCodeChallenge()),
            URLQueryItem(name: "code_challenge_method", value: authState.codeChallengeMethod),
        ]
        
        if let loginHint = authRequest.loginHint { authRequestParams.append(URLQueryItem(name: "login_hint", value: loginHint)) }
        
        if let mfa = authState.mfa {
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
}

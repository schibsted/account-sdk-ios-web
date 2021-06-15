import Foundation

extension URLBuilder {
    
    struct AuthorizationRequest {
        let withMFA: MFAType?
        let loginHint: String?
        let extraScopeValues: Set<String>
        let authState: AuthState
    }
}

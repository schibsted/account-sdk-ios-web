import Foundation

extension URLBuilder {
    
    struct AuthorizationRequest {
        let loginHint: String?
        let extraScopeValues: Set<String>
    }
}

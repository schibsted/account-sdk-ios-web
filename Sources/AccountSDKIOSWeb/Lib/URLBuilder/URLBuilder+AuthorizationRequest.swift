import Foundation

extension URLBuilder {

    struct AuthorizationRequest {
        let loginHint: String?
        let assertion: String?
        let extraScopeValues: Set<String>
    }
}

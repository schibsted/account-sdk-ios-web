//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

extension URLBuilder {

    struct AuthorizationRequest {
        let loginHint: String?
        let assertion: String?
        let extraScopeValues: Set<String>
    }
}

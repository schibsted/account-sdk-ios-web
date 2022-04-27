//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

internal extension URL {
    func valueOf(queryParameter name: String) -> String? {
        guard let url = URLComponents(url: self, resolvingAgainstBaseURL: true) else { return nil }
        return url.queryItems?.first(where: { $0.name == name })?.value
    }
}

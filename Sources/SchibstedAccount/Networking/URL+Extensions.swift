//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

extension URL {
    /// An array of query items for the URL in the order in which they appear in the original query string.
    var queryItems: [URLQueryItem]? {
        URLComponents(url: self, resolvingAgainstBaseURL: false)?.queryItems
    }

    /// Returns the first query item with a matching `name`.
    subscript(queryItem name: String) -> String? {
        queryItems?.first(where: { $0.name.lowercased() == name.lowercased() })?.value
    }
}

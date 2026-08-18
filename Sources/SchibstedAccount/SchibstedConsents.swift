// 
// Copyright © 2026 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

/// Consents
public struct SchibstedConsents: Codable, Hashable, Sendable, CustomDebugStringConvertible {
    /// The consent status
    public enum Status: String, Codable, Sendable {
        case accepted
        case rejected
        case unknown
    }

    /// Indicates if this data can be used for advertising.
    public let advertising: Status

    /// Indicates if this data can be used for analytics and product improvement.
    public let analytics: Status

    /// Indicates if this data can be used for marketing.
    public let marketing: Status

    /// Indicates if this data can be used for personalization.
    public let personalization: Status

    /// The source of consent information.
    public let source: String

    /// Creates an Consents instance.
    ///
    /// - parameter advertising: Indicates if this data can be used for advertising.
    /// - parameter analytics: Indicates if this data can be used for analytics and product improvement.
    /// - parameter marketing: Indicates if this data can be used for marketing.
    /// - parameter personalization: Indicates if this data can be used for personalization.
    /// - parameter source: The source of consent information.
    public init(
        advertising: Status,
        analytics: Status,
        marketing: Status,
        personalization: Status,
        source: String = "cmp"
    ) {
        self.advertising = advertising
        self.analytics = analytics
        self.marketing = marketing
        self.personalization = personalization
        self.source = source
    }

    public var debugDescription: String {
        "Consents(advertising: \(advertising), analytics: \(analytics), marketing: \(marketing), personalization: \(personalization))"
    }

    func queryItems() -> [URLQueryItem] {
        var consents: [String] = []

        if advertising == .accepted {
            consents.append("advertising")
        }

        if analytics == .accepted {
            consents.append("analytics")
        }

        if marketing == .accepted {
            consents.append("marketing")
        }

        if personalization == .accepted {
            consents.append("personalization")
        }

        return [
            URLQueryItem(name: "consents", value: consents.isEmpty ? "rejected" : consents.joined(separator: ",")),
            URLQueryItem(name: "consent_version", value: "v1")
        ]
    }
}

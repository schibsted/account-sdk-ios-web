//
// Copyright © 2026 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

public import Foundation

/// Schibsted Authenticator Environment.
public enum SchibstedAuthenticatorEnvironment: String, Sendable {
    /// Sweden
    case sweden
    /// Finland
    case finland
    /// Norway
    case norway
    /// Pre-production
    case pre

    /// The OAuth server URL.
    public var serverURL: URL {
        switch self {
        case .sweden:
            URL(string: "https://login.schibsted.com")!
        case .finland:
            URL(string: "https://login.schibsted.fi")!
        case .norway:
            URL(string: "https://payment.schibsted.no")!
        case .pre:
            URL(string: "https://identity-pre.schibsted.com")!
        }
    }

    /// The privacy policy URL.
    public var privacyPolicyURL: URL {
        switch self {
        case .sweden, .pre:
            URL(string: "https://info.privacy.schibsted.com/se/schibsted-sverige-personuppgiftspolicy")!
        case .norway:
            URL(string: "https://info.privacy.schibsted.com/no/schibsted-norge-personvernerklaering")!
        case .finland:
            URL(string: "https://info.privacy.schibsted.com/fi/tietosuoja-ja-evastekaytannot/")!
        }
    }

    /// The OAuth issuer (same as ``serverURL``).
    public var issuer: String {
        serverURL.absoluteString
    }

    /// Gets a SDRN for a given (legacy) user id.
    ///
    /// - parameter userId: The (legacy) user id
    /// - returns: User SDRN.
    public func sdrn(userId: String) -> String {
        switch self {
        case .sweden, .pre: 
            "sdrn:schibsted.com:user:\(userId)"
        case .norway: 
            "sdrn:spid.no:user:\(userId)"
        case .finland: 
            "sdrn:schibsted.fi:user:\(userId)"
        }
    }
}

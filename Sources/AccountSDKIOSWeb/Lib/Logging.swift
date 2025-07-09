//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation
import Logging

public enum SchibstedAccountLogger {
    /// Common logging instance used by the SDK
    public static let instance = Logger(label: "com.schibsted.account")
}

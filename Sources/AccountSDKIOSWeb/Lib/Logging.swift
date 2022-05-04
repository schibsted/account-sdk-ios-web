//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation
import Logging

public enum SchibstedAccountLogger {
    /// Common logging instance used by the SDK
    public static var instance = Logger(label: "com.schibsted.account")
}

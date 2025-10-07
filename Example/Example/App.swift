//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import SwiftUI
import Logging

@main
struct SchibstedAccountSDKDemoApp: App {
    init() {
        LoggingSystem.bootstrap { label in
            var handler = StreamLogHandler.standardError(label: label)
            handler.logLevel = Logger.Level.debug
            return handler
        }
    }

    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}

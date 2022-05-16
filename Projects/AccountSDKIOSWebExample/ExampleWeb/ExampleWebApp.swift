//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import SwiftUI
import AccountSDKIOSWeb

@main
struct ExampleWebApp: App {
    static let client: Client =  Client(configuration: ExampleWebApp.clientConfiguration, appIdentifierPrefix: nil) //provide appIdentifierPrefix in order to enable Simplified Login feature
    static let clientConfiguration: ClientConfiguration = ClientConfiguration(environment: .pre,
                                                                              clientId: "602504e1b41fa31789a95aa7",
                                                                              redirectURI: URL(string: "com.sdk-example.pre.602504e1b41fa31789a95aa7:/login")!)
    

    var body: some Scene {
        WindowGroup {
            ContentView(client: Self.client, clientConfiguration: Self.clientConfiguration)
        }
    }
}

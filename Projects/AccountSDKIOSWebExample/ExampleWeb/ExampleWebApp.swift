import SwiftUI
import AccountSDKIOSWeb

@main
struct ExampleWebApp: App {
    static let client: Client =  Client(configuration: ExampleWebApp.clientConfiguration, appIdentifierPrefix: "Z9DH9VRKR2") //provide appIdentifierPrefix in order to enable Simplified Login feature
    static let clientConfiguration: ClientConfiguration = ClientConfiguration(environment: .pre,
                                                                              clientId: "602504e1b41fa31789a95aa7",
                                                                              redirectURI: URL(string: "com.sdk-example.pre.602504e1b41fa31789a95aa7:/login")!)
    

    var body: some Scene {
        WindowGroup {
            ContentView(client: Self.client, clientConfiguration: Self.clientConfiguration)
        }
    }
}

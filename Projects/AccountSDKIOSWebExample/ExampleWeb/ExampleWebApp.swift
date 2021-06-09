import SwiftUI
import AccountSDKIOSWeb

@main
struct ExampleWebApp: App {
    private let client: Client
    private let clientId = "602504e1b41fa31789a95aa7"
    private let clientRedirectURIScheme: String?
    
    init() {
        let clientRedirectURI = URL(string: "com.sdk-example.pre.602504e1b41fa31789a95aa7:/login")! //SchibstedAccount.Development.RedirectURI"
        self.clientRedirectURIScheme = clientRedirectURI.scheme
        let clientConfiguration = ClientConfiguration(environment: .pre,
                                                      clientId: "602504e1b41fa31789a95aa7",
                                                      redirectURI: clientRedirectURI)
        client = Client(configuration: clientConfiguration)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(client: client, clientID: clientId, clientRedirectURIScheme: clientRedirectURIScheme)
        }
    }
}

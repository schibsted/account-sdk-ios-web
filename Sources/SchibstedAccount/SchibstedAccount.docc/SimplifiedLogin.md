# Simplified Login
Allows brands to prompt users who land on their site with a suggestion to continue on the site in a logged-in state with just one click.

> Prerequisite: apps must be on the same Apple Developer account to access the shared keychain.

## Configure

1. In your app target, add the **Keychain Sharing** capability with keychain group `com.schibsted.simplifiedLogin`.
2. Initialize ``SchibstedAuthenticator`` with `appIdentifierPrefix` (usually your team identifier prefix).

```swift
let authenticator = SchibstedAuthenticator(
    environment: .sweden,
    clientId: clientId,
    appIdentifierPrefix: "xxxxxxxxxx",
    redirectURI: redirectURI
)
```

## Request

```swift
let simplifiedLoginView = try await authenticator.requestSimplifiedLogin()
```

## SwiftUI

```swift
struct ContentView: View {
    let authenticator: SchibstedAuthenticator

    @State var simplifiedLoginView: SimplifiedLoginView?

    var body: some View {
        VStack {
            Text("Hello")
        }
        .sheet(item: $simplifiedLoginView) { simplifiedLoginView in
            simplifiedLoginView
                .presentationDetents([.medium, .large])
        }
        .task {
            simplifiedLoginView = try await authenticator.requestSimplifiedLogin()
        }
    }
}
```

## UIKit

```swift
guard let simplifiedLoginView = try await authenticator.requestSimplifiedLogin() else {
    return
}

let hostingController = UIHostingController(rootView: simplifiedLoginView)
hostingController.modalPresentationStyle = .pageSheet
hostingController.isModalInPresentation = false
hostingController.sheetPresentationController?.detents = [.medium(), .large()]

present(hostingController, animated: true)
```

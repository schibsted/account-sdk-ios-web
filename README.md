# Schibsted Account SDK for iOS

[![Build Status](https://github.com/schibsted/account-sdk-ios-web/actions/workflows/build.yml/badge.svg?branch=master)](https://github.com/schibsted/account-sdk-ios-web/actions/workflows/build.yml)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/schibsted/account-sdk-ios-web?label=Release)
![Platform](https://img.shields.io/badge/Platforms-iOS%2016.0+,_tvOS%2016.0+-orange.svg?style=flat)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://schibsted.ghe.com/app-foundation/schibsted-account-sdk-ios/blob/main/LICENSE)

## Getting started

To implement login with Schibsted account in your app, please first have a look at our
[documentation](https://docs.schibsted.io/schibsted-account/#best-practices). 
This will help you create a client and configure the necessary data.

**Note:** This SDK requires your client to be registered as a `public_mobile_client` in Self Service (see the [mobile sdk's](https://docs.schibsted.io/schibsted-account/#schibsted-account-mobile-sdk-s) dedicated section for more help)
  
### Requirements

* iOS 16.0+
* tvOS 16.0+

### Installation

Swift Package Manager

```swift
.package(url: "https://github.com/schibsted/account-sdk-ios-web", from: "6.0.0")
```

## Usage

### Initialize the authenticator

```swift
let authenticator = SchibstedAuthenticator(
    environment: .sweden,
    clientId: clientId,
    redirectURI: redirectURI
)
```

### Login

```swift
let presentationContextProvider = WebAuthenticationPresentationContext()

let user = try await authenticator.login(
    presentationContextProvider: presentationContextProvider
)
```

### Logout

```swift
try authenticator.logout()
```

### Get the User Profile

```
let userProfile = try await authenticator.userProfile()
```

### Observing state changes

```swift
authenticator.state
    .sink { state in
        switch state {
        case .loggingIn:
            print("Logging in...")
        case .loggedIn(let user):
            print("User \(user.profile?.displayName) logged in")
        case .loggedOut:
            print("User logged out")
        }
    }
    .store(in: &cancellables)
```

## Logging

This SDK uses [`SwiftLog`](https://github.com/apple/swift-log), allowing you to easily customise the logging.

Use `LoggingSystem.bootstrap` to configure the log level as necessary.

```swift
LoggingSystem.bootstrap { label in
    var handler = StreamLogHandler.standardError(label: label)
    handler.logLevel = Logger.Level.debug
    return handler
}
```

## Simplified Login

### Configuring Simplified Login

Prerequisite: Applications need to be on the same Apple Development account in order to have access to the shared keychain. 

1\. In your application target, add Keychain Sharing capability with keychain group set to `com.schibsted.simplifiedLogin`.

2\. Initialize the `SchibstedAuthenticator`, passing the additional parameter `appIdentifierPrefix` - it is usually the same as team identifier prefix, a 10 characters combination of both numbers and letters assigned by Apple.

```swift
let authenticator = SchibstedAuthenticator(
    environment: .sweden,
    clientId: clientId,
    appIdentifierPrefix: "xxxxxxxxxx",
    redirectURI: redirectURI
)
```

3\. Request the simplified login

```swift
let simplifiedLoginView = try await authenticator.requestSimplifiedLogin()
```

4\. Present the View

**SwiftUI:**

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

**UIKit:**

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

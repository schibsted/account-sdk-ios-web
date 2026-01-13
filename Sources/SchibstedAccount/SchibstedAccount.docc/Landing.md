# ``SchibstedAccount``

Schibsted Account is Schibsted's own login and account product in the Nordic consumer market and our end users' entry point to the Schibsted login ecosystem.

## Getting started
- To implement login with Schibsted account in your app, please first have a look at our
[Schibsted Account documentation](https://docs.schibsted.io/schibsted-account/#best-practices). 
This will help you create a client and configure the necessary data.

> Note: This SDK requires your client to be registered as a `public_mobile_client` in Self Service (see the [mobile sdk's](https://docs.schibsted.io/schibsted-account/#schibsted-account-mobile-sdk-s) dedicated section for more help)

- [Installation](https://github.com/schibsted/account-sdk-ios-web/blob/master/README.md)
- [Technical Documentation](https://github.com/schibsted/account-sdk-ios-web/blob/master/docs/README.md)

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

### Get the user profile

```swift
let userProfile = try await authenticator.userProfile()
```

### Observe state changes

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

Logging is built on [SwiftLog](https://github.com/apple/swift-log). Use `LoggingSystem.bootstrap` to configure the log level.

```swift
LoggingSystem.bootstrap { label in
    var handler = StreamLogHandler.standardError(label: label)
    handler.logLevel = Logger.Level.debug
    return handler
}
```

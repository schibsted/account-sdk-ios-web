# AccountSDKIOSWeb

New implementation of the Schibsted account iOS SDK making use of the web flows.

## Getting started

```swift
let clientConfiguration = ClientConfiguration(environment: .pre,
                                            clientId: clientId,
                                            clientSecret: clientSecret,
                                            redirectURI: redirectURI)
let sessionStorageConfig = SessionStorageConfig(accessGroup: "<possibly shared keychain group>",
                                                legacyAccessGroup: "<current keychain group>")
let client = Client(configuration: clientConfiguration,
                        sessionStorageConfig: sessionStorageConfig)
client.login(withSSO: true) { result in
    switch result {
    case .success(let user):
        print("Success - logged in as \(user.uuid)!")
    case .failure(let error):
        print(error)
    }
}
```

## Notes when using Universal Links

When using Universal Links as redirect URI, the OS handles opening the app associated with the link instead of triggering the `ASWebAuthenticationSession` callback.
It results in the `ASWebAuthenticationSession` view not being closed properly, which instead needs to be done manually:

1. Get a reference to `ASWebAuthenticationSession` and start it:
    ```swift
    let contextProvider = ASWebAuthSessionContextProvider()
    asWebAuthSession = client.getLoginSession(contextProvider: contextProvider, withSSO: true, completion: handleLoginResult)
    asWebAuthSession.start() // this will trigger the web context asking the user to login

    func handleLoginResult(_ result: Result<User, LoginError>) {
        switch result {
        case .success(let user):
            print("Success - logged-in as \(user.uuid)!")
            self.user = user
        case .failure(let error):
            print(error)
        }
   }
   ```
1. Handle the response as an incoming URL, e.g. via your app's delegate `application(_:open:options:)`:
    ```swift
    func application(_ application: UIApplication,
                     open url: URL,
                     options: [UIApplicationOpenURLOptionsKey : Any] = [:] ) -> Bool {
        client.handleAuthenticationResponse(url: url) { result in
            DispatchQueue.main.async {
                asWebAuthSession.cancel() // manually close the ASWebAuthenticationSession
            }
            handleLoginResult(result)
        }
    }
    ```

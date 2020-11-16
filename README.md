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

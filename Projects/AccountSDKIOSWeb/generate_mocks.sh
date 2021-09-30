./cuckoo/run generate --testable AccountSDKIOSWeb \
  --output Tests/AccountSDKIOSWebTests/GeneratedMocks.swift \
    ../../Sources/AccountSDKIOSWeb/Lib/HTTP/HTTPClient.swift \
    ../../Sources/AccountSDKIOSWeb/Lib/HTTP/URLSessionProtocol.swift \
    ../../Sources/AccountSDKIOSWeb/Lib/Storage/SessionStorage.swift \
    ../../Sources/AccountSDKIOSWeb/Lib/Storage/Storage.swift \
    ../../Sources/AccountSDKIOSWeb/Lib/Storage/Keychain/Compat/LegacyKeychainSessionStorage.swift \
    ../../Sources/AccountSDKIOSWeb/Lib/Storage/Keychain/Compat/LegacyKeychainTokenStorage.swift \
    ../../Sources/AccountSDKIOSWeb/Lib/API/SchibstedAccountAPI.swift \
    ../../Sources/AccountSDKIOSWeb/Lib/Storage/Keychain/KeychainSessionStorage.swift

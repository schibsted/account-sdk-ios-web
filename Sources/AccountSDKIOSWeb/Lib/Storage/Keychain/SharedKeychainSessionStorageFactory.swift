import Foundation

struct SharedKeychainSessionStorageFactory {
    
    static let sharedKeychainGroup = "com.schibsted.simplifiedLogin"
    private var keychain: KeychainSessionStorage?
    private var sharedKeychain: KeychainSessionStorage?
    private let dispatchSemaphore = DispatchSemaphore(value: 1)

    init(keychain: KeychainSessionStorage? = nil, sharedKeychain: KeychainSessionStorage? = nil) {
        self.keychain = keychain
        self.sharedKeychain = sharedKeychain
    }

    func makeKeychain(clientId: String, service: String, accessGroup: String? = nil, appIdentifierPrefix: String? = nil) -> KeychainSessionStorage {
        
        let keychain = self.keychain ?? KeychainSessionStorage(service: service, accessGroup: accessGroup)
        
        guard let appIdentifierPrefix = appIdentifierPrefix else {
            SchibstedAccountLogger.instance.debug("Return regular keychain when appIdentifierPrefix is not provided")
            return keychain
        }
        
        let sharedKeychainAccessGroup = "\(appIdentifierPrefix).\(Self.sharedKeychainGroup)"
        
        let sharedKeychain = self.sharedKeychain ?? KeychainSessionStorage(service: service, accessGroup: sharedKeychainAccessGroup)
        
        // check if correct entitlements are added to the app
        do {
            let _ = try sharedKeychain.checkEntitlements()
        } catch (let error) {
            guard let keychainError = error as? KeychainStorageError, keychainError != .entitlementMissing else {
                SchibstedAccountLogger.instance.debug("Return regular keychain when entitlements are missing")
                return keychain
            }
        }
        
        let clientSessionInSharedKeychain = sharedKeychain.getAll()
            .filter { $0.clientId == clientId }
        
        guard clientSessionInSharedKeychain.isEmpty else {
            SchibstedAccountLogger.instance.debug("Session for clientId already exists in shared keychain. Return shared keychain")
            return sharedKeychain
        }
        
        // update accessGroup for clientId entry
        var didMigrateKeychainToShared = false
        keychain.get(forClientId: clientId) { userSession in
            guard let userSession = userSession else {
                dispatchSemaphore.signal()
                return
            }
            keychain.remove(forClientId: clientId)
            sharedKeychain.store(userSession, accessGroup: sharedKeychainAccessGroup) { result in
                switch (result) {
                case .success():
                    didMigrateKeychainToShared = true
                    SchibstedAccountLogger.instance.debug("Session successfully migrated to a shared keychain")
                    break
                case .failure(let error):
                    keychain.store(userSession, accessGroup: nil) { _ in } // roll back
                    SchibstedAccountLogger.instance.error("Cannot store data to shared keychain with error \(error.localizedDescription)")
                    break
                }
                dispatchSemaphore.signal()
            }
        }

        dispatchSemaphore.wait()

        return didMigrateKeychainToShared ? sharedKeychain : keychain
    }
}

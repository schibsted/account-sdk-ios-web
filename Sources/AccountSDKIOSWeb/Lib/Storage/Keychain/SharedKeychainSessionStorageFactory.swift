import Foundation

struct SharedKeychainSessionStorageFactory {
    
    static let sharedKeychainGroup = "com.schibsted.simplifiedLogin"
    private var keychain: KeychainSessionStorage?
    private var sharedKeychain: KeychainSessionStorage?
    
    init(keychain: KeychainSessionStorage? = nil, sharedKeychain: KeychainSessionStorage? = nil) {
        self.keychain = keychain
        self.sharedKeychain = sharedKeychain
    }

    func makeKeychain(clientId: String, service: String, accessGroup: String? = nil, appIdentifierPrefix: String? = nil) -> KeychainSessionStorage {
        
        let keychain = self.keychain ?? KeychainSessionStorage(service: service, accessGroup: accessGroup)
        
        // return regular keychain when appIdentifierPrefix is not provided
        guard let appIdentifierPrefix = appIdentifierPrefix else {
            return keychain
        }
        
        let sharedKeychainAccessGroup = "\(appIdentifierPrefix).\(Self.sharedKeychainGroup)"
        
        let sharedKeychain = self.sharedKeychain ?? KeychainSessionStorage(service: service, accessGroup: sharedKeychainAccessGroup)
        
        // check if correct entitlements are added to the app
        do {
            let _ = try sharedKeychain.checkEntitlements()
        } catch (let error) {
            guard let keychainError = error as? KeychainStorageError, keychainError != .entitlementMissing else {
                // return regular keychain for missing entitlements
                return keychain
            }
        }
        
        // update accessGroup for clientId entry
        keychain.get(forClientId: clientId) { userSession in
            if let userSession = userSession {
                sharedKeychain.store(userSession, accessGroup: sharedKeychainAccessGroup) { result in
                    switch (result) {
                    case .success():
                        break
                    case .failure(let error):
                        SchibstedAccountLogger.instance.error("Cannot store data to shared keychain with error \(error.localizedDescription)")
                        break
                    }
                }
            }
        }
        return sharedKeychain
    }
}

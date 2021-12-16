import Foundation

struct SharedKeychainSessionStorageFactory {
    
    static let sharedKeychainGroup = "com.schibsted.simplifiedLogin"
    
    static func getKeychain(service: String, accessGroup: String? = nil, appIdentifierPrefix: String? = nil) -> KeychainSessionStorage {
        
        let keychain = KeychainSessionStorage(service: service, accessGroup: accessGroup)
        
        // return regular keychain when appIdentifierPrefix is not provided
        guard let appIdentifierPrefix = appIdentifierPrefix else {
            return keychain
        }
        
        let sharedKeychainAccessGroup = "\(appIdentifierPrefix).\(Self.sharedKeychainGroup)"
        
        let sharedKeychain = KeychainSessionStorage(service: service, accessGroup: sharedKeychainAccessGroup)
        
        // check if correct entitlements are added to the app
        do {
            let _ = try sharedKeychain.checkEntitlements()
        } catch (let error) {
            guard let keychainError = error as? KeychainStorageError, keychainError != .entitlementMissing else {
                // return regular keychain for missing entitlements
                return keychain
            }
        }
        
        // return shared keychain when regular one is empty
        guard let latestUserSession = keychain.getLatestSession() else {
            return sharedKeychain
        }
        
        //update accessGroup
        let semaphore = DispatchSemaphore(value: 0)

        //update accessGroup
        sharedKeychain.store(latestUserSession, accessGroup: sharedKeychainAccessGroup) { result in
            switch (result) {
            case .success():
                break
            case .failure(let error):
                SchibstedAccountLogger.instance.error("Cannot store data to shared keychain with error \(error.localizedDescription)")
                break
                //or we should return regular keychain here? (rather very rare situation)
            }
            semaphore.signal()
        }

        let _ = semaphore.wait(timeout: .now() + 2.0)
        return sharedKeychain
    }
}

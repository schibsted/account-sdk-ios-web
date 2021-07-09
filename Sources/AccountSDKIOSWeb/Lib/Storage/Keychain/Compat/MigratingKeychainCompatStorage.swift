import Foundation

class MigratingKeychainCompatStorage: SessionStorage {
    private let newStorage: KeychainSessionStorage
    private let legacyStorage: LegacyKeychainSessionStorage
    private let legacyClientConfiguration: ClientConfiguration
    private let newClientConfiguration: ClientConfiguration
    
    init(from: LegacyKeychainSessionStorage, to: KeychainSessionStorage, legacyClientConfiguration: ClientConfiguration, newClientConfiguration: ClientConfiguration) {
        self.newStorage = to
        self.legacyStorage = from
        self.legacyClientConfiguration = legacyClientConfiguration
        self.newClientConfiguration = newClientConfiguration
    }
    
    func store(_ value: UserSession) {
        // only delegate to new storage; no need to store in legacy storage
        newStorage.store(value)
    }
    
    func get(forClientId: String, completion: @escaping (UserSession?) -> Void ) {
        // try new storage first
        newStorage.get(forClientId: forClientId) { session in
            if let session = session {
                completion(session)
                return
            }
            
            // if no existing session found, look in legacy storage with
            guard let legacySession = legacyStorage.get(forClientId: legacyClientConfiguration.clientId) else {
                completion(nil)
                return
            }

            migrateLegacyUserSession(forClientId: forClientId, legacySession: legacySession, completion: completion)
        }
    }
    
    private func migrateLegacyUserSession(forClientId: String, legacySession: UserSession, completion: @escaping (UserSession?) -> Void) {
        let legacyClient = Client(configuration: legacyClientConfiguration)
        let legacyUser = User(client: legacyClient, tokens: legacySession.userTokens)
        let client = Client(configuration: newClientConfiguration)
        
        legacyUser.oneTimeCode(clientId: forClientId) { result in
            switch result {
            case .success(let code):
                client.makeTokenRequest(authCode: code, authState: nil) { result in
                    switch result {
                    case .success(let tokenResult):
                        let newUserSession = UserSession(clientId: client.configuration.clientId, userTokens: tokenResult.userTokens, updatedAt: Date())
                        self.newStorage.store(newUserSession)
                        self.legacyStorage.remove()
                        completion(newUserSession)
                    case .failure( _):
                        completion(nil)
                    }
                }
            case .failure( _):
                completion(nil)
            }
        }
    }
    
    func getAll() -> [UserSession] {
        // only delegate to new storage; this functionality is not supported by legacyStorage
        return newStorage.getAll()
    }
    
    func remove(forClientId: String) {
        // only delegate to new storage; data should have already been removed from legacy storage during migration
        newStorage.remove(forClientId: forClientId)
    }
}


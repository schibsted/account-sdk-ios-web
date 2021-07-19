import Foundation

class MigratingKeychainCompatStorage: SessionStorage {
    private let newStorage: KeychainSessionStorage
    private let legacyStorage: LegacyKeychainSessionStorage
    private let legacyClient: Client
    private let makeTokenRequest: (_ authCode: String, _ authState: AuthState?, _ completion:  @escaping (Result<TokenResult, TokenError>) -> Void) -> Void
    
    init(from: LegacyKeychainSessionStorage,
         to: KeychainSessionStorage,
         legacyClient: Client,
         makeTokenRequest: @escaping (_ authCode: String, _ authState: AuthState?, _ completion:  @escaping (Result<TokenResult, TokenError>) -> Void) -> Void)
    {
        self.newStorage = to
        self.legacyStorage = from
        self.legacyClient = legacyClient
        self.makeTokenRequest = makeTokenRequest
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
            guard let legacySession = self.legacyStorage.get(forClientId: self.legacyClient.configuration.clientId) else {
                completion(nil)
                return
            }

            self.migrateLegacyUserSession(forClientId: forClientId, legacySession: legacySession, completion: completion)
        }
    }
    
    private func migrateLegacyUserSession(forClientId: String, legacySession: UserSession, completion: @escaping (UserSession?) -> Void) {
        let legacyUser = User(client: legacyClient, tokens: legacySession.userTokens)
        
        legacyUser.oneTimeCode(clientId: forClientId) { result in
            switch result {
            case .success(let code):
                self.makeTokenRequest(code, nil) { result in
                    switch result {
                    case .success(let tokenResult):
                        let newUserSession = UserSession(clientId: forClientId, userTokens: tokenResult.userTokens, updatedAt: Date())
                        self.newStorage.store(newUserSession)
                        self.legacyStorage.remove()
                        completion(newUserSession)
                    case .failure(let error):
                        SchibstedAccountLogger.instance.info("Token error response: \(error.localizedDescription)")
                        completion(nil)
                    }
                }
            case .failure(let error):
                SchibstedAccountLogger.instance.info("Failed to migrate tokens. With error: \(error.localizedDescription)")
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


import Foundation

internal class KeychainSessionStorage: SessionStorage {
    private let keychain: KeychainStorage
    
    init(service: String, accessGroup: String? = nil) {
        self.keychain = KeychainStorage(forService: service, accessGroup: accessGroup)
    }
    
    func store(_ value: UserSession) {
        guard let tokenData = try? JSONEncoder().encode(value) else {
             fatalError("Failed to JSON encode user tokens for storage")
        }
        
        keychain.setValue(tokenData, forAccount: value.clientId)
    }

    func get(forClientId: String) -> UserSession? {
        guard let data = keychain.getValue(forAccount: forClientId),
              let tokenData = try? JSONDecoder().decode(UserSession.self, from: data) else {
            return nil
        }
        return tokenData
    }
    
    func getAll() -> [UserSession] {
        let data = keychain.getAll()
        return data.compactMap { try? JSONDecoder().decode(UserSession.self, from: $0) }
    }

    func remove(forClientId: String) {
        keychain.removeValue(forAccount: forClientId)
    }
}

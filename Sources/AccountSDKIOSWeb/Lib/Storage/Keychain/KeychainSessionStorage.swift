import Foundation

internal class KeychainSessionStorage: SessionStorage {
    
    private let keychain: KeychainStorage
    
    init(service: String, accessGroup: String? = nil) {
        self.keychain = KeychainStorage(forService: service, accessGroup: accessGroup)
    }
    
    func store(_ value: UserSession) {
        guard let tokenData = try? JSONEncoder().encode(value) else {
            SchibstedAccountLogger.instance.error("Failed to JSON encode user tokens for storage")
            return
        }
        
        do {
            try keychain.setValue(tokenData, forAccount: value.clientId)
        } catch {
            SchibstedAccountLogger.instance.error("\(error.localizedDescription)")
        }
    }
    
    func get(forClientId: String, completion: @escaping (UserSession?) -> Void){
        do {
            if let data = try keychain.getValue(forAccount: forClientId) {
                let tokenData = try? JSONDecoder().decode(UserSession.self, from: data)
                completion(tokenData)
            }
        } catch {
            SchibstedAccountLogger.instance.error("\(error.localizedDescription)")
            completion(nil)
        }
    }
    
    func getAll() -> [UserSession] {
        let data = keychain.getAll()
        return data.compactMap { try? JSONDecoder().decode(UserSession.self, from: $0) }
    }
    
    func remove(forClientId: String) {
        do {
            try keychain.removeValue(forAccount: forClientId)
        } catch {
            SchibstedAccountLogger.instance.error("\(error.localizedDescription)")
        }
    }
}

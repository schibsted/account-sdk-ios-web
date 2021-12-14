import Foundation

internal class KeychainSessionStorage: SessionStorage {

    private let keychain: KeychainStorage
    public let accessGroup: String?
    
    init(service: String, accessGroup: String? = nil) {
        self.accessGroup = accessGroup
        self.keychain = KeychainStorage(forService: service, accessGroup: accessGroup)
    }
    
    func store(_ value: UserSession, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let tokenData = try? JSONEncoder().encode(value) else {
            SchibstedAccountLogger.instance.error("\(KeychainStorageError.itemEncodingError.localizedDescription)")
            completion(.failure(KeychainStorageError.itemEncodingError))
            return
        }
        do {
            try keychain.setValue(tokenData, forAccount: value.clientId)
            completion(.success())
        } catch {
            SchibstedAccountLogger.instance.error("\(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    func get(forClientId: String, completion: @escaping (UserSession?) -> Void){
        do {
            if let data = try keychain.getValue(forAccount: forClientId) {
                let tokenData = try JSONDecoder().decode(UserSession.self, from: data)
                completion(tokenData)
            } else {
                completion(nil)
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
    
    func getAccessGroup() -> String? {
        return accessGroup
    }
}

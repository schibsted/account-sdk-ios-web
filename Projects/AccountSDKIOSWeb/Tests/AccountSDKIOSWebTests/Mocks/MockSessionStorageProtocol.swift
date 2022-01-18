import Foundation
@testable import AccountSDKIOSWeb

struct MockSessionStorageProtocol: SessionStorage {
    var accessGroup: String?
    
    let sessions: [UserSession]
    func getAll() -> [UserSession] {
        return sessions
    }
    
    func store(_ value: UserSession, accessGroup: String?, completion: @escaping (Result<Void, Error>) -> Void) { }
    func get(forClientId: String, completion: @escaping (UserSession?) -> Void) { }
    func remove(forClientId: String) {}
}

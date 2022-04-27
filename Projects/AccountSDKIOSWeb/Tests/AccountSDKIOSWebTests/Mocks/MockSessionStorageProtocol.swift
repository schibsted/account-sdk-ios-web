//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

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

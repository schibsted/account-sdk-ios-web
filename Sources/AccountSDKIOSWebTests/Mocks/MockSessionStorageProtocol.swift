//
// Copyright © 2025 Schibsted.
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
    
    func store(_ value: AccountSDKIOSWeb.UserSession, accessGroup: String?) throws { }
    func get(forClientId: String) -> AccountSDKIOSWeb.UserSession? { return nil }
    func remove(forClientId: String) {}
}

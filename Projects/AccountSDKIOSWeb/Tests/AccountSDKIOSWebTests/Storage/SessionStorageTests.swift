//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import XCTest
@testable import AccountSDKIOSWeb

class SessionStorageTests: XCTestCase {
    func testGetLatestSession_emptyArray () {
        let sut = MockSessionStorageProtocol(sessions: [])
        let maybeSession = sut.getLatestSession()
        XCTAssertNil(maybeSession, "getLatestSession should return nil if sessions array is empty")
    }
    
    func testGetLatestSession_singleElement () {
        let session = UserSession(clientId: "Any string", userTokens: Fixtures.userTokens, updatedAt: Date())
        let sut = MockSessionStorageProtocol(sessions: [session]
        )
        let maybeSession = sut.getLatestSession()
        XCTAssertEqual(maybeSession, session, "getLatestSession should return the only session in array")
    }
    
    func testGetLatestSession_multipleElements () {
        let currentDate = Date()
        let latestSession = UserSession(clientId: "Any string", userTokens: Fixtures.userTokens, updatedAt: currentDate)
        
        var sessions: [UserSession] = [latestSession]
        for index in 1...10 {
            let earlierDate = currentDate.addingTimeInterval(TimeInterval(Float(-index)))
            let earlierSession = UserSession(clientId: "Any string", userTokens: Fixtures.userTokens, updatedAt: earlierDate)
            sessions.append(earlierSession)
        }
        
        let sut = MockSessionStorageProtocol(sessions: sessions.shuffled())
        
        XCTAssertEqual(sut.getLatestSession(), latestSession, "getLatestSession should return the latest session")
        XCTAssertEqual(sut.getLatestSession()?.updatedAt, currentDate, "session.updatedAt should be currentDate ")
    }
}

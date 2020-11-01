import XCTest
import Cuckoo
@testable import AccountSDKIOSWeb

final class DefaultSessionStorageTests: XCTestCase {
    func testGetAllReturnsResultSortedByUpdatedAt() {
        let now = Date()
        let newestSession = UserSession(clientId: "client1", userTokens: Fixtures.userTokens, updatedAt: now)
        let olderSession = UserSession(clientId: "client1", userTokens: Fixtures.userTokens, updatedAt: now.addingTimeInterval(TimeInterval(-1000)))

        let mockSessionStorage = MockSessionStorage()
        stub(mockSessionStorage) { mock in
            when(mock.getAll())
                .thenReturn([olderSession, newestSession])
        }
        DefaultSessionStorage.storage = mockSessionStorage
        
        let result = DefaultSessionStorage.getAll()
        XCTAssertEqual(result, [newestSession, olderSession])
    }
}

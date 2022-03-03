import XCTest
@testable import AccountSDKIOSWeb

final class MFATypeTests: XCTestCase {
    
    func testReturnsCorrectValuesForEidOnPre() {
        let eidSe : MFAType = .preEid(.se)
        let eidNo : MFAType = .preEid(.no)
        
        XCTAssertEqual(eidSe.rawValue, PreEidType.se.rawValue)
        XCTAssertEqual(eidNo.rawValue, PreEidType.no.rawValue)
    }
    
}



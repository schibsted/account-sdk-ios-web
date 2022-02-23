import XCTest
@testable import AccountSDKIOSWeb

final class MFATypeTests: XCTestCase {
    
    func testReturnsCorrectValuesForEidOnPre() {
        let eidSe : MFAType = .preEid(.se)
        let eidNo : MFAType = .preEid(.no)
        let eidFi : MFAType = .preEid(.fi)
        let eidDk : MFAType = .preEid(.dk)
        
        XCTAssertEqual(eidSe.rawValue, PreEidType.se.rawValue)
        XCTAssertEqual(eidNo.rawValue, PreEidType.no.rawValue)
        XCTAssertEqual(eidFi.rawValue, PreEidType.fi.rawValue)
        XCTAssertEqual(eidDk.rawValue, PreEidType.dk.rawValue)
    }
    
}



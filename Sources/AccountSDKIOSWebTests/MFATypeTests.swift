//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import XCTest
@testable import AccountSDKIOSWeb

final class MFATypeTests: XCTestCase {
    
    func testReturnsCorrectValuesForEidOnPre() {
        let eidSe : MFAType = .preEid(.se)
        let eidNo : MFAType = .preEid(.no)
        let eidFi : MFAType = .preEid(.fi)
        
        XCTAssertEqual(eidSe.rawValue, PreEidType.se.rawValue)
        XCTAssertEqual(eidNo.rawValue, PreEidType.no.rawValue)
        XCTAssertEqual(eidFi.rawValue, PreEidType.fi.rawValue)
    }
    
}



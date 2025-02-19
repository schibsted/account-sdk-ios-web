//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import XCTest

extension XCTWaiter.Result: @retroactive CustomStringConvertible {
    public var description: String {
        let state: String
        switch self {
        case .completed: state  = "completed"
        case .timedOut: state = "timedOut"
        case .incorrectOrder: state = "incorrectOrder"
        case .invertedFulfillment: state = "invertedFulfillment"
        case .interrupted: state = "interrupted"
        @unknown default: state = "unknown"
        }
        
        return "XCTWaiterResult(\(state))"
    }
}

struct Await {
    static func until(timeout: Double = 1, call: @escaping (@escaping () -> Void) -> Void) {
        let expectation = XCTestExpectation()
        
        call { expectation.fulfill() }
        
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        switch result {
        case .completed:
            break // do nothing
        default:
            XCTFail("Waiting for expectation errored: \(result)")
        }
    }
}

//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import XCTest
@testable import AccountSDKIOSWeb

final class MulticastDelegateTests: XCTestCase {
    
    func testAddDelegate() {
        let sut =  MulticastDelegate<MockDelegate>()
        let mock = MockDelegate()
        let mock2 = MockDelegate()
        
        XCTAssertTrue(sut.delegates.count == 0 )
        sut.addDelegate(mock)
        XCTAssertTrue(sut.delegates.count == 1)
        sut.addDelegate(mock2)
        XCTAssertTrue(sut.delegates.count == 2)
    }
    
    func testRemoveDelegate() {
        let sut =  MulticastDelegate<MockDelegate>()
        let mock = MockDelegate()
        let mock2 = MockDelegate()
        
        sut.addDelegate(mock)
        sut.addDelegate(mock2)
        
        sut.removeDelegate(mock2)
        XCTAssertTrue(sut.delegates.contains(mock))
        XCTAssertFalse(sut.delegates.contains(mock2))
    }
    
    // MARK: Invoke Delegate on Adding delegates
 
    func testInvokeDelegateSingle() {
        let sut =  MulticastDelegate<MockDelegate>()
        let mock = MockDelegate()
        
        let expectation = self.expectation(description: "Should be fulfilled if the delegate is added correctly")
        mock.customInvocation = {
            expectation.fulfill()
        }
        
        sut.addDelegate(mock)
        sut.invokeDelegates { $0.customInvocation?() }
        XCTAssertNotNil(mock.customInvocation)
        self.waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    func testInvokeDelegateMultiple() {
        let sut =  MulticastDelegate<MockDelegate>()
        let mocks = [MockDelegate(), MockDelegate(), MockDelegate()]
        
        mocks.forEach {
            let expectation = self.expectation(description: "Should be fulfilled if the delegate is added correctly")
            $0.customInvocation = {
                expectation.fulfill()
            }
            
            sut.addDelegate($0) // Adding the delegates
            XCTAssertNotNil($0.customInvocation)
        }
        
        sut.invokeDelegates { $0.customInvocation?() }
        self.waitForExpectations(timeout: 0.5, handler: nil)
    }
    
    // MARK: Invoke Delegate on Removing Delegate
    
    func testInvokeDelegateNotCalledOnRemovedDelegate() {
        let sut =  MulticastDelegate<MockDelegate>()
        let mock = MockDelegate()
        mock.customInvocation = {
            mock.invocationCounter += 1
        }
        
        sut.addDelegate(mock)
        sut.invokeDelegates { $0.customInvocation?() }
        XCTAssertEqual(mock.invocationCounter, 1, "Confirming that mock is added and called by MulticastDelegate")
        
        sut.removeDelegate(mock)
        sut.invokeDelegates { $0.customInvocation?() }
        XCTAssertEqual(mock.invocationCounter, 1, "mock is removed from MulticastDelegate and should not increase its invocationCounter")
    }
    
    func testInvokeDelegateNotCalledOnRemovedDelegateMultiple() {
        let sut =  MulticastDelegate<MockDelegate>()
        let mocks = [MockDelegate(), MockDelegate(), MockDelegate()]
        
        mocks.forEach {
            let mock = $0
            $0.customInvocation = {
                mock.invocationCounter += 1
            }
            sut.addDelegate($0) // Adding the delegates
        }
        
        sut.invokeDelegates { $0.customInvocation?() }
        mocks.forEach { XCTAssertEqual($0.invocationCounter, 1, "Confirming that mock is added and called by MulticastDelegate")}
        
        let randomMock = mocks.randomElement()!
        sut.removeDelegate(randomMock)
        sut.invokeDelegates { $0.customInvocation?() }
        XCTAssertEqual(randomMock.invocationCounter, 1, "randomMock is removed from MulticastDelegate and should not increase its invocationCounter")

    }
}

fileprivate class MockDelegate {
    var customInvocation: (() -> Void)?
    var invocationCounter: Int = 0
}

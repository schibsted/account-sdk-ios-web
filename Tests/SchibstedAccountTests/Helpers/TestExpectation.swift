// 
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation
import Testing

actor TestExpectation {
    let description: Comment?
    let expectedFulfillmentCount: UInt
    let assertForOverFulfill: Bool

    private(set) var actualFulfillmentCount: UInt = 0

    private var continuation: SafeCheckedContinuation<Void, Never>?
    private var timeoutTask: Task<Void, Never>? {
        didSet { oldValue?.cancel() }
    }

    init(
        description: @autoclosure @Sendable () -> Comment? = nil,
        expectedFulfillmentCount: UInt = 1,
        assertForOverFulfill: Bool = true
    ) {
        self.description = description()
        self.expectedFulfillmentCount = expectedFulfillmentCount
        self.assertForOverFulfill = assertForOverFulfill
    }

    deinit {
        timeoutTask?.cancel()
        timeoutTask = nil
    }

    func fulfill() {
        actualFulfillmentCount += 1
        if actualFulfillmentCount >= expectedFulfillmentCount {
            continuation?.resume()
        }
    }

    func wait(
        timeout: TimeInterval = 1.0,
        sourceLocation: SourceLocation = #_sourceLocation
    ) async {
        guard expectedFulfillmentCount != 0 else {
            try? await Task.sleep(nanoseconds: UInt64(timeout) * NSEC_PER_SEC)
            if assertForOverFulfill {
                #expect(actualFulfillmentCount == expectedFulfillmentCount, description, sourceLocation: sourceLocation)
            } else {
                #expect(actualFulfillmentCount >= expectedFulfillmentCount, description, sourceLocation: sourceLocation)
            }
            return
        }

        guard actualFulfillmentCount < expectedFulfillmentCount else {
            return // already fulfilled, bail out
        }

        await withSafeCheckedContinuation { (continuation: SafeCheckedContinuation<Void, Never>) in
            timeoutTask = Task.detached { [continuation] in
                try? await Task.sleep(nanoseconds: UInt64(timeout) * NSEC_PER_SEC)
                continuation.resume()
            }

            self.continuation = continuation
        }

        timeoutTask = nil

        if assertForOverFulfill {
            #expect(actualFulfillmentCount == expectedFulfillmentCount, description, sourceLocation: sourceLocation)
        } else {
            #expect(actualFulfillmentCount >= expectedFulfillmentCount, description, sourceLocation: sourceLocation)
        }
    }
}

private func withSafeCheckedContinuation<T>(
    isolation: isolated (any Actor)? = #isolation,
    function: String = #function,
    _ body: (SafeCheckedContinuation<T, Never>) -> Void
) async -> sending T {
    await withCheckedContinuation { (continuation: CheckedContinuation<T, Never>) in
        body(SafeCheckedContinuation(continuation))
    }
}

private final class SafeCheckedContinuation<T: Sendable, E>: @unchecked Sendable where E: Error {
    private let continuation: CheckedContinuation<T, E>
    private var didResume = false

    init(_ continuation: CheckedContinuation<T, E>) {
        self.continuation = continuation
    }

    func resume(with result: Result<T, E>) {
        guard !didResume else { return }
        didResume = true
        continuation.resume(with: result)
    }

    func resume(returning value: T) {
        resume(with: .success(value))
    }

    func resume(throwing error: E) {
        resume(with: .failure(error))
    }
}

private extension SafeCheckedContinuation where T == Void {
    func resume() {
        resume(returning: ())
    }
}

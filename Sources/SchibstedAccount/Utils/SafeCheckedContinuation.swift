// 
// Copyright © 2026 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation
import struct os.OSAllocatedUnfairLock

/// A mechanism to interface between synchronous and asynchronous code,
/// logging correctness violations.
///
/// A *continuation* is an opaque representation of program state.
///
/// To create a safe continuation in asynchronous code,
/// call the `withSafeCheckedContinuation(function:_:)` or
/// `withSafeCheckedThrowingContinuation(function:_:)` function.
///
/// To resume the asynchronous task,
/// call the `resume(returning:)`, `resume(throwing:)`, `resume(with:)`, or `resume()` method.
final class SafeCheckedContinuation<T, E>: @unchecked Sendable where E: Error {
    private let lock = OSAllocatedUnfairLock()

    /// The checked continuation to be safely resumed.
    private let continuation: CheckedContinuation<T, E>

    /// Whether the continuation was already resumed once.
    /// Once set to `true` prevents the `continuation` from being resumed.
    private var didResume = false

    /// Creates a safe continuation from an checked continuation.
    ///
    /// - Parameters:
    ///   - continuation: An instance of `CheckedContinuation`
    ///     that hasn't yet been resumed.
    ///     After passing the checked continuation to this initializer,
    ///     don't use it outside of this object.
    init(_ continuation: CheckedContinuation<T, E>) {
        self.continuation = continuation
    }

    /// Resume the task awaiting the continuation by having it either
    /// return normally or throw an error based on the state of the given
    /// `Result` value.
    ///
    /// - Parameter result: A value to either return or throw from the
    ///   continuation.
    ///
    /// A safe continuation can only resumed once. If the continuation has
    /// already been resumed through this object, then the attempt to resume
    /// the continuation will be ignored.
    ///
    /// After `resume` enqueues the task, control immediately returns to
    /// the caller. The task continues executing when its executor is
    /// able to reschedule it.
    func resume(with result: sending Result<T, E>) {
        lock.lock()
        defer { lock.unlock() }
        
        guard !didResume else { return }
        didResume = true
        continuation.resume(with: result)
    }

    /// Resume the task awaiting the continuation by having it return normally
    /// from its suspension point.
    ///
    /// - Parameter value: The value to return from the continuation.
    ///
    /// A safe continuation can only resumed once. If the continuation has
    /// already been resumed through this object, then the attempt to resume
    /// the continuation will be ignored.
    ///
    /// After `resume` enqueues the task, control immediately returns to
    /// the caller. The task continues executing when its executor is
    /// able to reschedule it.
    func resume(returning value: sending T) {
        resume(with: .success(value))
    }

    /// Resume the task awaiting the continuation by having it throw an error
    /// from its suspension point.
    ///
    /// - Parameter error: The error to throw from the continuation.
    ///
    /// A safe continuation can only resumed once. If the continuation has
    /// already been resumed through this object, then the attempt to resume
    /// the continuation will be ignored.
    ///
    /// After `resume` enqueues the task, control immediately returns to
    /// the caller. The task continues executing when its executor is
    /// able to reschedule it.
    func resume(throwing error: E) {
        resume(with: .failure(error))
    }
}

extension SafeCheckedContinuation where T == Void {
    /// Resume the task awaiting the continuation by having it return normally
    /// from its suspension point.
    ///
    /// A safe continuation can only resumed once. If the continuation has
    /// already been resumed through this object, then the attempt to resume
    /// the continuation will be ignored.
    ///
    /// After `resume` enqueues the task, control immediately returns to
    /// the caller. The task continues executing when its executor is
    /// able to reschedule it.
    func resume() {
        resume(returning: ())
    }
}

/// Suspends the current task,
/// then calls the given closure with a checked continuation for the current task.
///
/// - Parameters:
///   - function: A string identifying the declaration that is the notional
///     source for the continuation, used to identify the continuation in
///     runtime diagnostics related to misuse of this continuation.
///   - body: A closure that takes a `SafeCheckedContinuation` parameter.
///     If the continuation is called more than once, subsequent calls are ignored.
nonisolated(nonsending)
func withSafeCheckedContinuation<T>(
    function: String = #function,
    _ body: (SafeCheckedContinuation<T, Never>) -> Void
) async -> T {
    await withCheckedContinuation(
        function: function
    ) { (continuation: CheckedContinuation<T, Never>) in
        body(SafeCheckedContinuation(continuation))
    }
}

//
// Copyright © 2026 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

public import Combine

/// A read-only version of the Combine `CurrentValueSubject<Output, Failure>`
/// that wraps a single value and publishes a new element whenever the value changes.
///
/// Maintains a buffer of the most recently published element.
public final class CurrentValueProperty<Output: Sendable>: Publisher, Sendable {
    /// The kind of errors this publisher might publish.
    public typealias Failure = Never

    private nonisolated(unsafe) let currentValueSubject: CurrentValueSubject<Output, Never>

    /// Creates a pulse property with the given initial value.
    init(_ value: Output) {
        self.currentValueSubject = CurrentValueSubject(value)
    }

    /// The value wrapped by this subject, published as a new element whenever it changes.
    public internal(set) var value: Output {
        get { currentValueSubject.value }
        set { currentValueSubject.value = newValue }
    }

    /// Attaches the specified subscriber to this publisher.
    public func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, Output == S.Input {
        currentValueSubject.receive(subscriber: subscriber)
    }
}

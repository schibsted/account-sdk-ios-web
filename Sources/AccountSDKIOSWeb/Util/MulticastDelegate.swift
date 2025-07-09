//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

public final class MulticastDelegate<T>: @unchecked Sendable {
    lazy var delegates: NSHashTable<AnyObject> = NSHashTable.weakObjects()

    public func addDelegate(_ delegate: T) {
        delegates.add(delegate as AnyObject)
    }

    public func removeDelegate(_ delegate: T) {
        delegates.remove(delegate as AnyObject)
    }

    func invokeDelegates(_ invocation: (T) -> Void) {
        delegates.allObjects.reversed().forEach { invocation($0 as! T) } // swiftlint:disable:this force_cast
    }
}

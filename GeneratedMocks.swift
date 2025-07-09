// MARK: - Mocks generated from file: 'Sources/AccountSDKIOSWeb/Lib/API/SchibstedAccountAPI.swift' at 2025-07-09 17:51:44 +0000

import Cuckoo
import Foundation
import UIKit
import AccountSDKIOSWeb



// MARK: - Mocks generated from file: 'Sources/AccountSDKIOSWeb/Lib/HTTP/HTTPClient.swift' at 2025-07-09 17:51:44 +0000

import Cuckoo
import Foundation
import AccountSDKIOSWeb

public class MockHTTPClient: HTTPClient, Cuckoo.ProtocolMock, @unchecked Sendable {
    public typealias MocksType = HTTPClient
    public typealias Stubbing = __StubbingProxy_HTTPClient
    public typealias Verification = __VerificationProxy_HTTPClient

    // Original typealiases

    public let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: false)

    private var __defaultImplStub: (any HTTPClient)?

    public func enableDefaultImplementation(_ stub: any HTTPClient) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }

    
    public func execute<T: Decodable> (request p0: URLRequest, withRetryPolicy p1: RetryPolicy, completion p2: @escaping HTTPResultHandler<T>) {
        return cuckoo_manager.call(
            "execute<T: Decodable> (request p0: URLRequest, withRetryPolicy p1: RetryPolicy, completion p2: @escaping HTTPResultHandler<T>)",
            parameters: (p0, p1, p2),
            escapingParameters: (p0, p1, p2),
            superclassCall: Cuckoo.MockManager.crashOnProtocolSuperclassCall(),
            defaultCall: __defaultImplStub!.execute(request: p0, withRetryPolicy: p1, completion: p2)
        )
    }

    public struct __StubbingProxy_HTTPClient: Cuckoo.StubbingProxy {
        private let cuckoo_manager: Cuckoo.MockManager
    
        public init(manager: Cuckoo.MockManager) {
            self.cuckoo_manager = manager
        }
        
        func execute<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, M3: Cuckoo.Matchable, T: Decodable>(request p0: M1, withRetryPolicy p1: M2, completion p2: M3) -> Cuckoo.ProtocolStubNoReturnFunction<(URLRequest, RetryPolicy,  HTTPResultHandler<T>)> where M1.MatchedType == URLRequest, M2.MatchedType == RetryPolicy, M3.MatchedType ==  HTTPResultHandler<T> {
            let matchers: [Cuckoo.ParameterMatcher<(URLRequest, RetryPolicy,  HTTPResultHandler<T>)>] = [wrap(matchable: p0) { $0.0 }, wrap(matchable: p1) { $0.1 }, wrap(matchable: p2) { $0.2 }]
            return .init(stub: cuckoo_manager.createStub(for: MockHTTPClient.self,
                method: "execute<T: Decodable> (request p0: URLRequest, withRetryPolicy p1: RetryPolicy, completion p2: @escaping HTTPResultHandler<T>)",
                parameterMatchers: matchers
            ))
        }
    }

    public struct __VerificationProxy_HTTPClient: Cuckoo.VerificationProxy {
        private let cuckoo_manager: Cuckoo.MockManager
        private let callMatcher: Cuckoo.CallMatcher
        private let sourceLocation: Cuckoo.SourceLocation
    
        public init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
            self.cuckoo_manager = manager
            self.callMatcher = callMatcher
            self.sourceLocation = sourceLocation
        }
        
        
        @discardableResult
        func execute<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, M3: Cuckoo.Matchable, T: Decodable>(request p0: M1, withRetryPolicy p1: M2, completion p2: M3) -> Cuckoo.__DoNotUse<(URLRequest, RetryPolicy,  HTTPResultHandler<T>), Void> where M1.MatchedType == URLRequest, M2.MatchedType == RetryPolicy, M3.MatchedType ==  HTTPResultHandler<T> {
            let matchers: [Cuckoo.ParameterMatcher<(URLRequest, RetryPolicy,  HTTPResultHandler<T>)>] = [wrap(matchable: p0) { $0.0 }, wrap(matchable: p1) { $0.1 }, wrap(matchable: p2) { $0.2 }]
            return cuckoo_manager.verify(
                "execute<T: Decodable> (request p0: URLRequest, withRetryPolicy p1: RetryPolicy, completion p2: @escaping HTTPResultHandler<T>)",
                callMatcher: callMatcher,
                parameterMatchers: matchers,
                sourceLocation: sourceLocation
            )
        }
    }
}

public class HTTPClientStub:HTTPClient, @unchecked Sendable {


    
    public func execute<T: Decodable> (request p0: URLRequest, withRetryPolicy p1: RetryPolicy, completion p2: @escaping HTTPResultHandler<T>) {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
}




// MARK: - Mocks generated from file: 'Sources/AccountSDKIOSWeb/Lib/Storage/Keychain/KeychainSessionStorage.swift' at 2025-07-09 17:51:44 +0000

import Cuckoo
import Foundation
import AccountSDKIOSWeb

class MockKeychainSessionStorage: KeychainSessionStorage, Cuckoo.ClassMock, @unchecked Sendable {
    typealias MocksType = KeychainSessionStorage
    typealias Stubbing = __StubbingProxy_KeychainSessionStorage
    typealias Verification = __VerificationProxy_KeychainSessionStorage

    // Original typealiases

    let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: true)

    private var __defaultImplStub: KeychainSessionStorage?

    func enableDefaultImplementation(_ stub: KeychainSessionStorage) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }
    
    override var accessGroup: String? {
        get {
            return cuckoo_manager.getter(
                "accessGroup",
                superclassCall: super.accessGroup,
                defaultCall: __defaultImplStub!.accessGroup
            )
        }
    }

    
    override func store(_ p0: UserSession, accessGroup p1: String?) throws {
        return try cuckoo_manager.callThrows(
            "store(_ p0: UserSession, accessGroup p1: String?) throws",
            parameters: (p0, p1),
            escapingParameters: (p0, p1),
            superclassCall: super.store(p0, accessGroup: p1),
            defaultCall: __defaultImplStub!.store(p0, accessGroup: p1)
        )
    }
    
    override func get(forClientId p0: String) -> UserSession? {
        return cuckoo_manager.call(
            "get(forClientId p0: String) -> UserSession?",
            parameters: (p0),
            escapingParameters: (p0),
            superclassCall: super.get(forClientId: p0),
            defaultCall: __defaultImplStub!.get(forClientId: p0)
        )
    }
    
    override func getAll() -> [UserSession] {
        return cuckoo_manager.call(
            "getAll() -> [UserSession]",
            parameters: (),
            escapingParameters: (),
            superclassCall: super.getAll(),
            defaultCall: __defaultImplStub!.getAll()
        )
    }
    
    override func remove(forClientId p0: String) {
        return cuckoo_manager.call(
            "remove(forClientId p0: String)",
            parameters: (p0),
            escapingParameters: (p0),
            superclassCall: super.remove(forClientId: p0),
            defaultCall: __defaultImplStub!.remove(forClientId: p0)
        )
    }
    
    override func checkEntitlements() throws -> Data? {
        return try cuckoo_manager.callThrows(
            "checkEntitlements() throws -> Data?",
            parameters: (),
            escapingParameters: (),
            superclassCall: super.checkEntitlements(),
            defaultCall: __defaultImplStub!.checkEntitlements()
        )
    }
    
    func getLatestSession() -> UserSession? {
        return cuckoo_manager.call(
            "getLatestSession() -> UserSession?",
            parameters: (),
            escapingParameters: (),
            superclassCall: super.getLatestSession(),
            defaultCall: __defaultImplStub!.getLatestSession()
        )
    }

    struct __StubbingProxy_KeychainSessionStorage: Cuckoo.StubbingProxy {
        private let cuckoo_manager: Cuckoo.MockManager
    
        init(manager: Cuckoo.MockManager) {
            self.cuckoo_manager = manager
        }
        
        var accessGroup: Cuckoo.ClassToBeStubbedReadOnlyProperty<MockKeychainSessionStorage,String?> {
            return .init(manager: cuckoo_manager, name: "accessGroup")
        }
        
        func store<M1: Cuckoo.Matchable, M2: Cuckoo.OptionalMatchable>(_ p0: M1, accessGroup p1: M2) -> Cuckoo.ClassStubNoReturnThrowingFunction<(UserSession, String?)> where M1.MatchedType == UserSession, M2.OptionalMatchedType == String {
            let matchers: [Cuckoo.ParameterMatcher<(UserSession, String?)>] = [wrap(matchable: p0) { $0.0 }, wrap(matchable: p1) { $0.1 }]
            return .init(stub: cuckoo_manager.createStub(for: MockKeychainSessionStorage.self,
                method: "store(_ p0: UserSession, accessGroup p1: String?) throws",
                parameterMatchers: matchers
            ))
        }
        
        func get<M1: Cuckoo.Matchable>(forClientId p0: M1) -> Cuckoo.ClassStubFunction<(String), UserSession?> where M1.MatchedType == String {
            let matchers: [Cuckoo.ParameterMatcher<(String)>] = [wrap(matchable: p0) { $0 }]
            return .init(stub: cuckoo_manager.createStub(for: MockKeychainSessionStorage.self,
                method: "get(forClientId p0: String) -> UserSession?",
                parameterMatchers: matchers
            ))
        }
        
        func getAll() -> Cuckoo.ClassStubFunction<(), [UserSession]> {
            let matchers: [Cuckoo.ParameterMatcher<Void>] = []
            return .init(stub: cuckoo_manager.createStub(for: MockKeychainSessionStorage.self,
                method: "getAll() -> [UserSession]",
                parameterMatchers: matchers
            ))
        }
        
        func remove<M1: Cuckoo.Matchable>(forClientId p0: M1) -> Cuckoo.ClassStubNoReturnFunction<(String)> where M1.MatchedType == String {
            let matchers: [Cuckoo.ParameterMatcher<(String)>] = [wrap(matchable: p0) { $0 }]
            return .init(stub: cuckoo_manager.createStub(for: MockKeychainSessionStorage.self,
                method: "remove(forClientId p0: String)",
                parameterMatchers: matchers
            ))
        }
        
        func checkEntitlements() -> Cuckoo.ClassStubThrowingFunction<(), Data?> {
            let matchers: [Cuckoo.ParameterMatcher<Void>] = []
            return .init(stub: cuckoo_manager.createStub(for: MockKeychainSessionStorage.self,
                method: "checkEntitlements() throws -> Data?",
                parameterMatchers: matchers
            ))
        }
        
        func getLatestSession() -> Cuckoo.ProtocolStubFunction<(), UserSession?> {
            let matchers: [Cuckoo.ParameterMatcher<Void>] = []
            return .init(stub: cuckoo_manager.createStub(for: MockKeychainSessionStorage.self,
                method: "getLatestSession() -> UserSession?",
                parameterMatchers: matchers
            ))
        }
    }

    struct __VerificationProxy_KeychainSessionStorage: Cuckoo.VerificationProxy {
        private let cuckoo_manager: Cuckoo.MockManager
        private let callMatcher: Cuckoo.CallMatcher
        private let sourceLocation: Cuckoo.SourceLocation
    
        init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
            self.cuckoo_manager = manager
            self.callMatcher = callMatcher
            self.sourceLocation = sourceLocation
        }
        
        var accessGroup: Cuckoo.VerifyReadOnlyProperty<String?> {
            return .init(manager: cuckoo_manager, name: "accessGroup", callMatcher: callMatcher, sourceLocation: sourceLocation)
        }
        
        
        @discardableResult
        func store<M1: Cuckoo.Matchable, M2: Cuckoo.OptionalMatchable>(_ p0: M1, accessGroup p1: M2) -> Cuckoo.__DoNotUse<(UserSession, String?), Void> where M1.MatchedType == UserSession, M2.OptionalMatchedType == String {
            let matchers: [Cuckoo.ParameterMatcher<(UserSession, String?)>] = [wrap(matchable: p0) { $0.0 }, wrap(matchable: p1) { $0.1 }]
            return cuckoo_manager.verify(
                "store(_ p0: UserSession, accessGroup p1: String?) throws",
                callMatcher: callMatcher,
                parameterMatchers: matchers,
                sourceLocation: sourceLocation
            )
        }
        
        
        @discardableResult
        func get<M1: Cuckoo.Matchable>(forClientId p0: M1) -> Cuckoo.__DoNotUse<(String), UserSession?> where M1.MatchedType == String {
            let matchers: [Cuckoo.ParameterMatcher<(String)>] = [wrap(matchable: p0) { $0 }]
            return cuckoo_manager.verify(
                "get(forClientId p0: String) -> UserSession?",
                callMatcher: callMatcher,
                parameterMatchers: matchers,
                sourceLocation: sourceLocation
            )
        }
        
        
        @discardableResult
        func getAll() -> Cuckoo.__DoNotUse<(), [UserSession]> {
            let matchers: [Cuckoo.ParameterMatcher<Void>] = []
            return cuckoo_manager.verify(
                "getAll() -> [UserSession]",
                callMatcher: callMatcher,
                parameterMatchers: matchers,
                sourceLocation: sourceLocation
            )
        }
        
        
        @discardableResult
        func remove<M1: Cuckoo.Matchable>(forClientId p0: M1) -> Cuckoo.__DoNotUse<(String), Void> where M1.MatchedType == String {
            let matchers: [Cuckoo.ParameterMatcher<(String)>] = [wrap(matchable: p0) { $0 }]
            return cuckoo_manager.verify(
                "remove(forClientId p0: String)",
                callMatcher: callMatcher,
                parameterMatchers: matchers,
                sourceLocation: sourceLocation
            )
        }
        
        
        @discardableResult
        func checkEntitlements() -> Cuckoo.__DoNotUse<(), Data?> {
            let matchers: [Cuckoo.ParameterMatcher<Void>] = []
            return cuckoo_manager.verify(
                "checkEntitlements() throws -> Data?",
                callMatcher: callMatcher,
                parameterMatchers: matchers,
                sourceLocation: sourceLocation
            )
        }
        
        
        @discardableResult
        func getLatestSession() -> Cuckoo.__DoNotUse<(), UserSession?> {
            let matchers: [Cuckoo.ParameterMatcher<Void>] = []
            return cuckoo_manager.verify(
                "getLatestSession() -> UserSession?",
                callMatcher: callMatcher,
                parameterMatchers: matchers,
                sourceLocation: sourceLocation
            )
        }
    }
}

class KeychainSessionStorageStub:KeychainSessionStorage, @unchecked Sendable {
    
    override var accessGroup: String? {
        get {
            return DefaultValueRegistry.defaultValue(for: (String?).self)
        }
    }


    
    override func store(_ p0: UserSession, accessGroup p1: String?) throws {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
    override func get(forClientId p0: String) -> UserSession? {
        return DefaultValueRegistry.defaultValue(for: (UserSession?).self)
    }
    
    override func getAll() -> [UserSession] {
        return DefaultValueRegistry.defaultValue(for: ([UserSession]).self)
    }
    
    override func remove(forClientId p0: String) {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
    override func checkEntitlements() throws -> Data? {
        return DefaultValueRegistry.defaultValue(for: (Data?).self)
    }
    
    func getLatestSession() -> UserSession? {
        return DefaultValueRegistry.defaultValue(for: (UserSession?).self)
    }
}




// MARK: - Mocks generated from file: 'Sources/AccountSDKIOSWeb/Lib/Storage/SessionStorage.swift' at 2025-07-09 17:51:44 +0000

import Cuckoo
import Foundation
import Security
import AccountSDKIOSWeb

class MockSessionStorage: SessionStorage, Cuckoo.ProtocolMock, @unchecked Sendable {
    typealias MocksType = SessionStorage
    typealias Stubbing = __StubbingProxy_SessionStorage
    typealias Verification = __VerificationProxy_SessionStorage

    // Original typealiases

    let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: false)

    private var __defaultImplStub: (any SessionStorage)?

    func enableDefaultImplementation(_ stub: any SessionStorage) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }
    
    var accessGroup: String? {
        get {
            return cuckoo_manager.getter(
                "accessGroup",
                superclassCall: Cuckoo.MockManager.crashOnProtocolSuperclassCall(),
                defaultCall: __defaultImplStub!.accessGroup
            )
        }
    }

    
    func store(_ p0: UserSession, accessGroup p1: String?) throws {
        return try cuckoo_manager.callThrows(
            "store(_ p0: UserSession, accessGroup p1: String?) throws",
            parameters: (p0, p1),
            escapingParameters: (p0, p1),
            superclassCall: Cuckoo.MockManager.crashOnProtocolSuperclassCall(),
            defaultCall: __defaultImplStub!.store(p0, accessGroup: p1)
        )
    }
    
    func get(forClientId p0: String) -> UserSession? {
        return cuckoo_manager.call(
            "get(forClientId p0: String) -> UserSession?",
            parameters: (p0),
            escapingParameters: (p0),
            superclassCall: Cuckoo.MockManager.crashOnProtocolSuperclassCall(),
            defaultCall: __defaultImplStub!.get(forClientId: p0)
        )
    }
    
    func getAll() -> [UserSession] {
        return cuckoo_manager.call(
            "getAll() -> [UserSession]",
            parameters: (),
            escapingParameters: (),
            superclassCall: Cuckoo.MockManager.crashOnProtocolSuperclassCall(),
            defaultCall: __defaultImplStub!.getAll()
        )
    }
    
    func remove(forClientId p0: String) {
        return cuckoo_manager.call(
            "remove(forClientId p0: String)",
            parameters: (p0),
            escapingParameters: (p0),
            superclassCall: Cuckoo.MockManager.crashOnProtocolSuperclassCall(),
            defaultCall: __defaultImplStub!.remove(forClientId: p0)
        )
    }
    
    func getLatestSession() -> UserSession? {
        return cuckoo_manager.call(
            "getLatestSession() -> UserSession?",
            parameters: (),
            escapingParameters: (),
            superclassCall: Cuckoo.MockManager.crashOnProtocolSuperclassCall(),
            defaultCall: __defaultImplStub!.getLatestSession()
        )
    }

    struct __StubbingProxy_SessionStorage: Cuckoo.StubbingProxy {
        private let cuckoo_manager: Cuckoo.MockManager
    
        init(manager: Cuckoo.MockManager) {
            self.cuckoo_manager = manager
        }
        
        var accessGroup: Cuckoo.ProtocolToBeStubbedReadOnlyProperty<MockSessionStorage,String?> {
            return .init(manager: cuckoo_manager, name: "accessGroup")
        }
        
        func store<M1: Cuckoo.Matchable, M2: Cuckoo.OptionalMatchable>(_ p0: M1, accessGroup p1: M2) -> Cuckoo.ProtocolStubNoReturnThrowingFunction<(UserSession, String?)> where M1.MatchedType == UserSession, M2.OptionalMatchedType == String {
            let matchers: [Cuckoo.ParameterMatcher<(UserSession, String?)>] = [wrap(matchable: p0) { $0.0 }, wrap(matchable: p1) { $0.1 }]
            return .init(stub: cuckoo_manager.createStub(for: MockSessionStorage.self,
                method: "store(_ p0: UserSession, accessGroup p1: String?) throws",
                parameterMatchers: matchers
            ))
        }
        
        func get<M1: Cuckoo.Matchable>(forClientId p0: M1) -> Cuckoo.ProtocolStubFunction<(String), UserSession?> where M1.MatchedType == String {
            let matchers: [Cuckoo.ParameterMatcher<(String)>] = [wrap(matchable: p0) { $0 }]
            return .init(stub: cuckoo_manager.createStub(for: MockSessionStorage.self,
                method: "get(forClientId p0: String) -> UserSession?",
                parameterMatchers: matchers
            ))
        }
        
        func getAll() -> Cuckoo.ProtocolStubFunction<(), [UserSession]> {
            let matchers: [Cuckoo.ParameterMatcher<Void>] = []
            return .init(stub: cuckoo_manager.createStub(for: MockSessionStorage.self,
                method: "getAll() -> [UserSession]",
                parameterMatchers: matchers
            ))
        }
        
        func remove<M1: Cuckoo.Matchable>(forClientId p0: M1) -> Cuckoo.ProtocolStubNoReturnFunction<(String)> where M1.MatchedType == String {
            let matchers: [Cuckoo.ParameterMatcher<(String)>] = [wrap(matchable: p0) { $0 }]
            return .init(stub: cuckoo_manager.createStub(for: MockSessionStorage.self,
                method: "remove(forClientId p0: String)",
                parameterMatchers: matchers
            ))
        }
        
        func getLatestSession() -> Cuckoo.ProtocolStubFunction<(), UserSession?> {
            let matchers: [Cuckoo.ParameterMatcher<Void>] = []
            return .init(stub: cuckoo_manager.createStub(for: MockSessionStorage.self,
                method: "getLatestSession() -> UserSession?",
                parameterMatchers: matchers
            ))
        }
    }

    struct __VerificationProxy_SessionStorage: Cuckoo.VerificationProxy {
        private let cuckoo_manager: Cuckoo.MockManager
        private let callMatcher: Cuckoo.CallMatcher
        private let sourceLocation: Cuckoo.SourceLocation
    
        init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
            self.cuckoo_manager = manager
            self.callMatcher = callMatcher
            self.sourceLocation = sourceLocation
        }
        
        var accessGroup: Cuckoo.VerifyReadOnlyProperty<String?> {
            return .init(manager: cuckoo_manager, name: "accessGroup", callMatcher: callMatcher, sourceLocation: sourceLocation)
        }
        
        
        @discardableResult
        func store<M1: Cuckoo.Matchable, M2: Cuckoo.OptionalMatchable>(_ p0: M1, accessGroup p1: M2) -> Cuckoo.__DoNotUse<(UserSession, String?), Void> where M1.MatchedType == UserSession, M2.OptionalMatchedType == String {
            let matchers: [Cuckoo.ParameterMatcher<(UserSession, String?)>] = [wrap(matchable: p0) { $0.0 }, wrap(matchable: p1) { $0.1 }]
            return cuckoo_manager.verify(
                "store(_ p0: UserSession, accessGroup p1: String?) throws",
                callMatcher: callMatcher,
                parameterMatchers: matchers,
                sourceLocation: sourceLocation
            )
        }
        
        
        @discardableResult
        func get<M1: Cuckoo.Matchable>(forClientId p0: M1) -> Cuckoo.__DoNotUse<(String), UserSession?> where M1.MatchedType == String {
            let matchers: [Cuckoo.ParameterMatcher<(String)>] = [wrap(matchable: p0) { $0 }]
            return cuckoo_manager.verify(
                "get(forClientId p0: String) -> UserSession?",
                callMatcher: callMatcher,
                parameterMatchers: matchers,
                sourceLocation: sourceLocation
            )
        }
        
        
        @discardableResult
        func getAll() -> Cuckoo.__DoNotUse<(), [UserSession]> {
            let matchers: [Cuckoo.ParameterMatcher<Void>] = []
            return cuckoo_manager.verify(
                "getAll() -> [UserSession]",
                callMatcher: callMatcher,
                parameterMatchers: matchers,
                sourceLocation: sourceLocation
            )
        }
        
        
        @discardableResult
        func remove<M1: Cuckoo.Matchable>(forClientId p0: M1) -> Cuckoo.__DoNotUse<(String), Void> where M1.MatchedType == String {
            let matchers: [Cuckoo.ParameterMatcher<(String)>] = [wrap(matchable: p0) { $0 }]
            return cuckoo_manager.verify(
                "remove(forClientId p0: String)",
                callMatcher: callMatcher,
                parameterMatchers: matchers,
                sourceLocation: sourceLocation
            )
        }
        
        
        @discardableResult
        func getLatestSession() -> Cuckoo.__DoNotUse<(), UserSession?> {
            let matchers: [Cuckoo.ParameterMatcher<Void>] = []
            return cuckoo_manager.verify(
                "getLatestSession() -> UserSession?",
                callMatcher: callMatcher,
                parameterMatchers: matchers,
                sourceLocation: sourceLocation
            )
        }
    }
}

class SessionStorageStub:SessionStorage, @unchecked Sendable {
    
    var accessGroup: String? {
        get {
            return DefaultValueRegistry.defaultValue(for: (String?).self)
        }
    }


    
    func store(_ p0: UserSession, accessGroup p1: String?) throws {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
    func get(forClientId p0: String) -> UserSession? {
        return DefaultValueRegistry.defaultValue(for: (UserSession?).self)
    }
    
    func getAll() -> [UserSession] {
        return DefaultValueRegistry.defaultValue(for: ([UserSession]).self)
    }
    
    func remove(forClientId p0: String) {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
    func getLatestSession() -> UserSession? {
        return DefaultValueRegistry.defaultValue(for: (UserSession?).self)
    }
}




// MARK: - Mocks generated from file: 'Sources/AccountSDKIOSWeb/Lib/Storage/Storage.swift' at 2025-07-09 17:51:44 +0000

import Cuckoo
import Foundation
import AccountSDKIOSWeb

class MockStorage: Storage, Cuckoo.ProtocolMock, @unchecked Sendable {
    typealias MocksType = Storage
    typealias Stubbing = __StubbingProxy_Storage
    typealias Verification = __VerificationProxy_Storage

    // Original typealiases

    let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: false)

    private var __defaultImplStub: (any Storage)?

    func enableDefaultImplementation(_ stub: any Storage) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }

    
    func setValue(_ p0: Data, forKey p1: String) {
        return cuckoo_manager.call(
            "setValue(_ p0: Data, forKey p1: String)",
            parameters: (p0, p1),
            escapingParameters: (p0, p1),
            superclassCall: Cuckoo.MockManager.crashOnProtocolSuperclassCall(),
            defaultCall: __defaultImplStub!.setValue(p0, forKey: p1)
        )
    }
    
    func value(forKey p0: String) -> Data? {
        return cuckoo_manager.call(
            "value(forKey p0: String) -> Data?",
            parameters: (p0),
            escapingParameters: (p0),
            superclassCall: Cuckoo.MockManager.crashOnProtocolSuperclassCall(),
            defaultCall: __defaultImplStub!.value(forKey: p0)
        )
    }
    
    func removeValue(forKey p0: String) {
        return cuckoo_manager.call(
            "removeValue(forKey p0: String)",
            parameters: (p0),
            escapingParameters: (p0),
            superclassCall: Cuckoo.MockManager.crashOnProtocolSuperclassCall(),
            defaultCall: __defaultImplStub!.removeValue(forKey: p0)
        )
    }

    struct __StubbingProxy_Storage: Cuckoo.StubbingProxy {
        private let cuckoo_manager: Cuckoo.MockManager
    
        init(manager: Cuckoo.MockManager) {
            self.cuckoo_manager = manager
        }
        
        func setValue<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable>(_ p0: M1, forKey p1: M2) -> Cuckoo.ProtocolStubNoReturnFunction<(Data, String)> where M1.MatchedType == Data, M2.MatchedType == String {
            let matchers: [Cuckoo.ParameterMatcher<(Data, String)>] = [wrap(matchable: p0) { $0.0 }, wrap(matchable: p1) { $0.1 }]
            return .init(stub: cuckoo_manager.createStub(for: MockStorage.self,
                method: "setValue(_ p0: Data, forKey p1: String)",
                parameterMatchers: matchers
            ))
        }
        
        func value<M1: Cuckoo.Matchable>(forKey p0: M1) -> Cuckoo.ProtocolStubFunction<(String), Data?> where M1.MatchedType == String {
            let matchers: [Cuckoo.ParameterMatcher<(String)>] = [wrap(matchable: p0) { $0 }]
            return .init(stub: cuckoo_manager.createStub(for: MockStorage.self,
                method: "value(forKey p0: String) -> Data?",
                parameterMatchers: matchers
            ))
        }
        
        func removeValue<M1: Cuckoo.Matchable>(forKey p0: M1) -> Cuckoo.ProtocolStubNoReturnFunction<(String)> where M1.MatchedType == String {
            let matchers: [Cuckoo.ParameterMatcher<(String)>] = [wrap(matchable: p0) { $0 }]
            return .init(stub: cuckoo_manager.createStub(for: MockStorage.self,
                method: "removeValue(forKey p0: String)",
                parameterMatchers: matchers
            ))
        }
    }

    struct __VerificationProxy_Storage: Cuckoo.VerificationProxy {
        private let cuckoo_manager: Cuckoo.MockManager
        private let callMatcher: Cuckoo.CallMatcher
        private let sourceLocation: Cuckoo.SourceLocation
    
        init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
            self.cuckoo_manager = manager
            self.callMatcher = callMatcher
            self.sourceLocation = sourceLocation
        }
        
        
        @discardableResult
        func setValue<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable>(_ p0: M1, forKey p1: M2) -> Cuckoo.__DoNotUse<(Data, String), Void> where M1.MatchedType == Data, M2.MatchedType == String {
            let matchers: [Cuckoo.ParameterMatcher<(Data, String)>] = [wrap(matchable: p0) { $0.0 }, wrap(matchable: p1) { $0.1 }]
            return cuckoo_manager.verify(
                "setValue(_ p0: Data, forKey p1: String)",
                callMatcher: callMatcher,
                parameterMatchers: matchers,
                sourceLocation: sourceLocation
            )
        }
        
        
        @discardableResult
        func value<M1: Cuckoo.Matchable>(forKey p0: M1) -> Cuckoo.__DoNotUse<(String), Data?> where M1.MatchedType == String {
            let matchers: [Cuckoo.ParameterMatcher<(String)>] = [wrap(matchable: p0) { $0 }]
            return cuckoo_manager.verify(
                "value(forKey p0: String) -> Data?",
                callMatcher: callMatcher,
                parameterMatchers: matchers,
                sourceLocation: sourceLocation
            )
        }
        
        
        @discardableResult
        func removeValue<M1: Cuckoo.Matchable>(forKey p0: M1) -> Cuckoo.__DoNotUse<(String), Void> where M1.MatchedType == String {
            let matchers: [Cuckoo.ParameterMatcher<(String)>] = [wrap(matchable: p0) { $0 }]
            return cuckoo_manager.verify(
                "removeValue(forKey p0: String)",
                callMatcher: callMatcher,
                parameterMatchers: matchers,
                sourceLocation: sourceLocation
            )
        }
    }
}

class StorageStub:Storage, @unchecked Sendable {


    
    func setValue(_ p0: Data, forKey p1: String) {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
    func value(forKey p0: String) -> Data? {
        return DefaultValueRegistry.defaultValue(for: (Data?).self)
    }
    
    func removeValue(forKey p0: String) {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
}



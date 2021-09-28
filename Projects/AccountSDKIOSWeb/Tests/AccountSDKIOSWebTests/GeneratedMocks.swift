// MARK: - Mocks generated from file: ../../Sources/AccountSDKIOSWeb/Lib/HTTP/HTTPClient.swift at 2021-07-16 13:47:30 +0000


import Cuckoo
@testable import AccountSDKIOSWeb

import Foundation


public class MockHTTPClient: HTTPClient, Cuckoo.ProtocolMock {
    
    public typealias MocksType = HTTPClient
    
    public typealias Stubbing = __StubbingProxy_HTTPClient
    public typealias Verification = __VerificationProxy_HTTPClient

    public let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: false)

    
    private var __defaultImplStub: HTTPClient?

    public func enableDefaultImplementation(_ stub: HTTPClient) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }
    

    

    

    
    
    
    public func execute<T: Decodable>(request: URLRequest, withRetryPolicy: RetryPolicy, completion: @escaping HTTPResultHandler<T>)  {
        
    return cuckoo_manager.call("execute(request: URLRequest, withRetryPolicy: RetryPolicy, completion: @escaping HTTPResultHandler<T>)",
            parameters: (request, withRetryPolicy, completion),
            escapingParameters: (request, withRetryPolicy, completion),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.execute(request: request, withRetryPolicy: withRetryPolicy, completion: completion))
        
    }
    

	public struct __StubbingProxy_HTTPClient: Cuckoo.StubbingProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	
	    public init(manager: Cuckoo.MockManager) {
	        self.cuckoo_manager = manager
	    }
	    
	    
	    func execute<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, M3: Cuckoo.Matchable, T: Decodable>(request: M1, withRetryPolicy: M2, completion: M3) -> Cuckoo.ProtocolStubNoReturnFunction<(URLRequest, RetryPolicy, HTTPResultHandler<T>)> where M1.MatchedType == URLRequest, M2.MatchedType == RetryPolicy, M3.MatchedType == HTTPResultHandler<T> {
	        let matchers: [Cuckoo.ParameterMatcher<(URLRequest, RetryPolicy, HTTPResultHandler<T>)>] = [wrap(matchable: request) { $0.0 }, wrap(matchable: withRetryPolicy) { $0.1 }, wrap(matchable: completion) { $0.2 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockHTTPClient.self, method: "execute(request: URLRequest, withRetryPolicy: RetryPolicy, completion: @escaping HTTPResultHandler<T>)", parameterMatchers: matchers))
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
	    func execute<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, M3: Cuckoo.Matchable, T: Decodable>(request: M1, withRetryPolicy: M2, completion: M3) -> Cuckoo.__DoNotUse<(URLRequest, RetryPolicy, HTTPResultHandler<T>), Void> where M1.MatchedType == URLRequest, M2.MatchedType == RetryPolicy, M3.MatchedType == HTTPResultHandler<T> {
	        let matchers: [Cuckoo.ParameterMatcher<(URLRequest, RetryPolicy, HTTPResultHandler<T>)>] = [wrap(matchable: request) { $0.0 }, wrap(matchable: withRetryPolicy) { $0.1 }, wrap(matchable: completion) { $0.2 }]
	        return cuckoo_manager.verify("execute(request: URLRequest, withRetryPolicy: RetryPolicy, completion: @escaping HTTPResultHandler<T>)", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	}
}

public class HTTPClientStub: HTTPClient {
    

    

    
    public func execute<T: Decodable>(request: URLRequest, withRetryPolicy: RetryPolicy, completion: @escaping HTTPResultHandler<T>)   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
}


// MARK: - Mocks generated from file: ../../Sources/AccountSDKIOSWeb/Lib/HTTP/URLSessionProtocol.swift at 2021-07-16 13:47:30 +0000


import Cuckoo
@testable import AccountSDKIOSWeb

import Foundation


 class MockURLSessionProtocol: URLSessionProtocol, Cuckoo.ProtocolMock {
    
     typealias MocksType = URLSessionProtocol
    
     typealias Stubbing = __StubbingProxy_URLSessionProtocol
     typealias Verification = __VerificationProxy_URLSessionProtocol

     let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: false)

    
    private var __defaultImplStub: URLSessionProtocol?

     func enableDefaultImplementation(_ stub: URLSessionProtocol) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }
    

    

    

    
    
    
     func dataTask(with: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTask {
        
    return cuckoo_manager.call("dataTask(with: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTask",
            parameters: (with, completionHandler),
            escapingParameters: (with, completionHandler),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.dataTask(with: with, completionHandler: completionHandler))
        
    }
    

	 struct __StubbingProxy_URLSessionProtocol: Cuckoo.StubbingProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	
	     init(manager: Cuckoo.MockManager) {
	        self.cuckoo_manager = manager
	    }
	    
	    
	    func dataTask<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable>(with: M1, completionHandler: M2) -> Cuckoo.ProtocolStubFunction<(URLRequest, DataTaskResult), URLSessionDataTask> where M1.MatchedType == URLRequest, M2.MatchedType == DataTaskResult {
	        let matchers: [Cuckoo.ParameterMatcher<(URLRequest, DataTaskResult)>] = [wrap(matchable: with) { $0.0 }, wrap(matchable: completionHandler) { $0.1 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockURLSessionProtocol.self, method: "dataTask(with: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTask", parameterMatchers: matchers))
	    }
	    
	}

	 struct __VerificationProxy_URLSessionProtocol: Cuckoo.VerificationProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	    private let callMatcher: Cuckoo.CallMatcher
	    private let sourceLocation: Cuckoo.SourceLocation
	
	     init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
	        self.cuckoo_manager = manager
	        self.callMatcher = callMatcher
	        self.sourceLocation = sourceLocation
	    }
	
	    
	
	    
	    @discardableResult
	    func dataTask<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable>(with: M1, completionHandler: M2) -> Cuckoo.__DoNotUse<(URLRequest, DataTaskResult), URLSessionDataTask> where M1.MatchedType == URLRequest, M2.MatchedType == DataTaskResult {
	        let matchers: [Cuckoo.ParameterMatcher<(URLRequest, DataTaskResult)>] = [wrap(matchable: with) { $0.0 }, wrap(matchable: completionHandler) { $0.1 }]
	        return cuckoo_manager.verify("dataTask(with: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTask", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	}
}

 class URLSessionProtocolStub: URLSessionProtocol {
    

    

    
     func dataTask(with: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTask  {
        return DefaultValueRegistry.defaultValue(for: (URLSessionDataTask).self)
    }
    
}


// MARK: - Mocks generated from file: ../../Sources/AccountSDKIOSWeb/Lib/Storage/Keychain/Compat/LegacyKeychainSessionStorage.swift at 2021-07-16 13:47:30 +0000


import Cuckoo
@testable import AccountSDKIOSWeb

import Foundation
import JOSESwift


 class MockLegacyKeychainSessionStorage: LegacyKeychainSessionStorage, Cuckoo.ClassMock {
    
     typealias MocksType = LegacyKeychainSessionStorage
    
     typealias Stubbing = __StubbingProxy_LegacyKeychainSessionStorage
     typealias Verification = __VerificationProxy_LegacyKeychainSessionStorage

     let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: true)

    
    private var __defaultImplStub: LegacyKeychainSessionStorage?

     func enableDefaultImplementation(_ stub: LegacyKeychainSessionStorage) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }
    

    

    

    
    
    
     override func get(forClientId: String) -> UserSession? {
        
    return cuckoo_manager.call("get(forClientId: String) -> UserSession?",
            parameters: (forClientId),
            escapingParameters: (forClientId),
            superclassCall:
                
                super.get(forClientId: forClientId)
                ,
            defaultCall: __defaultImplStub!.get(forClientId: forClientId))
        
    }
    
    
    
     override func remove()  {
        
    return cuckoo_manager.call("remove()",
            parameters: (),
            escapingParameters: (),
            superclassCall:
                
                super.remove()
                ,
            defaultCall: __defaultImplStub!.remove())
        
    }
    

	 struct __StubbingProxy_LegacyKeychainSessionStorage: Cuckoo.StubbingProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	
	     init(manager: Cuckoo.MockManager) {
	        self.cuckoo_manager = manager
	    }
	    
	    
	    func get<M1: Cuckoo.Matchable>(forClientId: M1) -> Cuckoo.ClassStubFunction<(String), UserSession?> where M1.MatchedType == String {
	        let matchers: [Cuckoo.ParameterMatcher<(String)>] = [wrap(matchable: forClientId) { $0 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockLegacyKeychainSessionStorage.self, method: "get(forClientId: String) -> UserSession?", parameterMatchers: matchers))
	    }
	    
	    func remove() -> Cuckoo.ClassStubNoReturnFunction<()> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return .init(stub: cuckoo_manager.createStub(for: MockLegacyKeychainSessionStorage.self, method: "remove()", parameterMatchers: matchers))
	    }
	    
	}

	 struct __VerificationProxy_LegacyKeychainSessionStorage: Cuckoo.VerificationProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	    private let callMatcher: Cuckoo.CallMatcher
	    private let sourceLocation: Cuckoo.SourceLocation
	
	     init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
	        self.cuckoo_manager = manager
	        self.callMatcher = callMatcher
	        self.sourceLocation = sourceLocation
	    }
	
	    
	
	    
	    @discardableResult
	    func get<M1: Cuckoo.Matchable>(forClientId: M1) -> Cuckoo.__DoNotUse<(String), UserSession?> where M1.MatchedType == String {
	        let matchers: [Cuckoo.ParameterMatcher<(String)>] = [wrap(matchable: forClientId) { $0 }]
	        return cuckoo_manager.verify("get(forClientId: String) -> UserSession?", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func remove() -> Cuckoo.__DoNotUse<(), Void> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return cuckoo_manager.verify("remove()", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	}
}

 class LegacyKeychainSessionStorageStub: LegacyKeychainSessionStorage {
    

    

    
     override func get(forClientId: String) -> UserSession?  {
        return DefaultValueRegistry.defaultValue(for: (UserSession?).self)
    }
    
     override func remove()   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
}


// MARK: - Mocks generated from file: ../../Sources/AccountSDKIOSWeb/Lib/Storage/Keychain/Compat/LegacyKeychainTokenStorage.swift at 2021-07-16 13:47:30 +0000


import Cuckoo
@testable import AccountSDKIOSWeb

import Foundation


 class MockLegacyKeychainTokenStorage: LegacyKeychainTokenStorage, Cuckoo.ClassMock {
    
     typealias MocksType = LegacyKeychainTokenStorage
    
     typealias Stubbing = __StubbingProxy_LegacyKeychainTokenStorage
     typealias Verification = __VerificationProxy_LegacyKeychainTokenStorage

     let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: true)

    
    private var __defaultImplStub: LegacyKeychainTokenStorage?

     func enableDefaultImplementation(_ stub: LegacyKeychainTokenStorage) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }
    

    

    

    
    
    
     override func get() -> [LegacyTokenData] {
        
    return cuckoo_manager.call("get() -> [LegacyTokenData]",
            parameters: (),
            escapingParameters: (),
            superclassCall:
                
                super.get()
                ,
            defaultCall: __defaultImplStub!.get())
        
    }
    
    
    
     override func remove()  {
        
    return cuckoo_manager.call("remove()",
            parameters: (),
            escapingParameters: (),
            superclassCall:
                
                super.remove()
                ,
            defaultCall: __defaultImplStub!.remove())
        
    }
    

	 struct __StubbingProxy_LegacyKeychainTokenStorage: Cuckoo.StubbingProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	
	     init(manager: Cuckoo.MockManager) {
	        self.cuckoo_manager = manager
	    }
	    
	    
	    func get() -> Cuckoo.ClassStubFunction<(), [LegacyTokenData]> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return .init(stub: cuckoo_manager.createStub(for: MockLegacyKeychainTokenStorage.self, method: "get() -> [LegacyTokenData]", parameterMatchers: matchers))
	    }
	    
	    func remove() -> Cuckoo.ClassStubNoReturnFunction<()> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return .init(stub: cuckoo_manager.createStub(for: MockLegacyKeychainTokenStorage.self, method: "remove()", parameterMatchers: matchers))
	    }
	    
	}

	 struct __VerificationProxy_LegacyKeychainTokenStorage: Cuckoo.VerificationProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	    private let callMatcher: Cuckoo.CallMatcher
	    private let sourceLocation: Cuckoo.SourceLocation
	
	     init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
	        self.cuckoo_manager = manager
	        self.callMatcher = callMatcher
	        self.sourceLocation = sourceLocation
	    }
	
	    
	
	    
	    @discardableResult
	    func get() -> Cuckoo.__DoNotUse<(), [LegacyTokenData]> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return cuckoo_manager.verify("get() -> [LegacyTokenData]", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func remove() -> Cuckoo.__DoNotUse<(), Void> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return cuckoo_manager.verify("remove()", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	}
}

 class LegacyKeychainTokenStorageStub: LegacyKeychainTokenStorage {
    

    

    
     override func get() -> [LegacyTokenData]  {
        return DefaultValueRegistry.defaultValue(for: ([LegacyTokenData]).self)
    }
    
     override func remove()   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
}


// MARK: - Mocks generated from file: ../../Sources/AccountSDKIOSWeb/Lib/Storage/Keychain/KeychainSessionStorage.swift at 2021-07-16 13:47:30 +0000


import Cuckoo
@testable import AccountSDKIOSWeb

import Foundation


 class MockKeychainSessionStorage: KeychainSessionStorage, Cuckoo.ClassMock {
    
     typealias MocksType = KeychainSessionStorage
    
     typealias Stubbing = __StubbingProxy_KeychainSessionStorage
     typealias Verification = __VerificationProxy_KeychainSessionStorage

     let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: true)

    
    private var __defaultImplStub: KeychainSessionStorage?

     func enableDefaultImplementation(_ stub: KeychainSessionStorage) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }
    

    

    

    
    
    
     override func store(_ value: UserSession)  {
        
    return cuckoo_manager.call("store(_: UserSession)",
            parameters: (value),
            escapingParameters: (value),
            superclassCall:
                
                super.store(value)
                ,
            defaultCall: __defaultImplStub!.store(value))
        
    }
    
    
    
     override func get(forClientId: String, completion: @escaping (UserSession?) -> Void)  {
        
    return cuckoo_manager.call("get(forClientId: String, completion: @escaping (UserSession?) -> Void)",
            parameters: (forClientId, completion),
            escapingParameters: (forClientId, completion),
            superclassCall:
                
                super.get(forClientId: forClientId, completion: completion)
                ,
            defaultCall: __defaultImplStub!.get(forClientId: forClientId, completion: completion))
        
    }
    
    
    
     override func getAll() -> [UserSession] {
        
    return cuckoo_manager.call("getAll() -> [UserSession]",
            parameters: (),
            escapingParameters: (),
            superclassCall:
                
                super.getAll()
                ,
            defaultCall: __defaultImplStub!.getAll())
        
    }
    
    
    
     override func remove(forClientId: String)  {
        
    return cuckoo_manager.call("remove(forClientId: String)",
            parameters: (forClientId),
            escapingParameters: (forClientId),
            superclassCall:
                
                super.remove(forClientId: forClientId)
                ,
            defaultCall: __defaultImplStub!.remove(forClientId: forClientId))
        
    }
    

	 struct __StubbingProxy_KeychainSessionStorage: Cuckoo.StubbingProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	
	     init(manager: Cuckoo.MockManager) {
	        self.cuckoo_manager = manager
	    }
	    
	    
	    func store<M1: Cuckoo.Matchable>(_ value: M1) -> Cuckoo.ClassStubNoReturnFunction<(UserSession)> where M1.MatchedType == UserSession {
	        let matchers: [Cuckoo.ParameterMatcher<(UserSession)>] = [wrap(matchable: value) { $0 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockKeychainSessionStorage.self, method: "store(_: UserSession)", parameterMatchers: matchers))
	    }
	    
	    func get<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable>(forClientId: M1, completion: M2) -> Cuckoo.ClassStubNoReturnFunction<(String, (UserSession?) -> Void)> where M1.MatchedType == String, M2.MatchedType == (UserSession?) -> Void {
	        let matchers: [Cuckoo.ParameterMatcher<(String, (UserSession?) -> Void)>] = [wrap(matchable: forClientId) { $0.0 }, wrap(matchable: completion) { $0.1 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockKeychainSessionStorage.self, method: "get(forClientId: String, completion: @escaping (UserSession?) -> Void)", parameterMatchers: matchers))
	    }
	    
	    func getAll() -> Cuckoo.ClassStubFunction<(), [UserSession]> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return .init(stub: cuckoo_manager.createStub(for: MockKeychainSessionStorage.self, method: "getAll() -> [UserSession]", parameterMatchers: matchers))
	    }
	    
	    func remove<M1: Cuckoo.Matchable>(forClientId: M1) -> Cuckoo.ClassStubNoReturnFunction<(String)> where M1.MatchedType == String {
	        let matchers: [Cuckoo.ParameterMatcher<(String)>] = [wrap(matchable: forClientId) { $0 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockKeychainSessionStorage.self, method: "remove(forClientId: String)", parameterMatchers: matchers))
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
	
	    
	
	    
	    @discardableResult
	    func store<M1: Cuckoo.Matchable>(_ value: M1) -> Cuckoo.__DoNotUse<(UserSession), Void> where M1.MatchedType == UserSession {
	        let matchers: [Cuckoo.ParameterMatcher<(UserSession)>] = [wrap(matchable: value) { $0 }]
	        return cuckoo_manager.verify("store(_: UserSession)", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func get<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable>(forClientId: M1, completion: M2) -> Cuckoo.__DoNotUse<(String, (UserSession?) -> Void), Void> where M1.MatchedType == String, M2.MatchedType == (UserSession?) -> Void {
	        let matchers: [Cuckoo.ParameterMatcher<(String, (UserSession?) -> Void)>] = [wrap(matchable: forClientId) { $0.0 }, wrap(matchable: completion) { $0.1 }]
	        return cuckoo_manager.verify("get(forClientId: String, completion: @escaping (UserSession?) -> Void)", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func getAll() -> Cuckoo.__DoNotUse<(), [UserSession]> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return cuckoo_manager.verify("getAll() -> [UserSession]", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func remove<M1: Cuckoo.Matchable>(forClientId: M1) -> Cuckoo.__DoNotUse<(String), Void> where M1.MatchedType == String {
	        let matchers: [Cuckoo.ParameterMatcher<(String)>] = [wrap(matchable: forClientId) { $0 }]
	        return cuckoo_manager.verify("remove(forClientId: String)", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	}
}

 class KeychainSessionStorageStub: KeychainSessionStorage {
    

    

    
     override func store(_ value: UserSession)   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
     override func get(forClientId: String, completion: @escaping (UserSession?) -> Void)   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
     override func getAll() -> [UserSession]  {
        return DefaultValueRegistry.defaultValue(for: ([UserSession]).self)
    }
    
     override func remove(forClientId: String)   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
}


// MARK: - Mocks generated from file: ../../Sources/AccountSDKIOSWeb/Lib/Storage/SessionStorage.swift at 2021-07-16 13:47:30 +0000


import Cuckoo
@testable import AccountSDKIOSWeb

import Foundation
import Security


 class MockSessionStorage: SessionStorage, Cuckoo.ProtocolMock {
    
     typealias MocksType = SessionStorage
    
     typealias Stubbing = __StubbingProxy_SessionStorage
     typealias Verification = __VerificationProxy_SessionStorage

     let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: false)

    
    private var __defaultImplStub: SessionStorage?

     func enableDefaultImplementation(_ stub: SessionStorage) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }
    

    

    

    
    
    
     func store(_ value: UserSession)  {
        
    return cuckoo_manager.call("store(_: UserSession)",
            parameters: (value),
            escapingParameters: (value),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.store(value))
        
    }
    
    
    
     func get(forClientId: String, completion: @escaping (UserSession?) -> Void)  {
        
    return cuckoo_manager.call("get(forClientId: String, completion: @escaping (UserSession?) -> Void)",
            parameters: (forClientId, completion),
            escapingParameters: (forClientId, completion),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.get(forClientId: forClientId, completion: completion))
        
    }
    
    
    
     func getAll() -> [UserSession] {
        
    return cuckoo_manager.call("getAll() -> [UserSession]",
            parameters: (),
            escapingParameters: (),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.getAll())
        
    }
    
    
    
     func remove(forClientId: String)  {
        
    return cuckoo_manager.call("remove(forClientId: String)",
            parameters: (forClientId),
            escapingParameters: (forClientId),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.remove(forClientId: forClientId))
        
    }
    

	 struct __StubbingProxy_SessionStorage: Cuckoo.StubbingProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	
	     init(manager: Cuckoo.MockManager) {
	        self.cuckoo_manager = manager
	    }
	    
	    
	    func store<M1: Cuckoo.Matchable>(_ value: M1) -> Cuckoo.ProtocolStubNoReturnFunction<(UserSession)> where M1.MatchedType == UserSession {
	        let matchers: [Cuckoo.ParameterMatcher<(UserSession)>] = [wrap(matchable: value) { $0 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockSessionStorage.self, method: "store(_: UserSession)", parameterMatchers: matchers))
	    }
	    
	    func get<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable>(forClientId: M1, completion: M2) -> Cuckoo.ProtocolStubNoReturnFunction<(String, (UserSession?) -> Void)> where M1.MatchedType == String, M2.MatchedType == (UserSession?) -> Void {
	        let matchers: [Cuckoo.ParameterMatcher<(String, (UserSession?) -> Void)>] = [wrap(matchable: forClientId) { $0.0 }, wrap(matchable: completion) { $0.1 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockSessionStorage.self, method: "get(forClientId: String, completion: @escaping (UserSession?) -> Void)", parameterMatchers: matchers))
	    }
	    
	    func getAll() -> Cuckoo.ProtocolStubFunction<(), [UserSession]> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return .init(stub: cuckoo_manager.createStub(for: MockSessionStorage.self, method: "getAll() -> [UserSession]", parameterMatchers: matchers))
	    }
	    
	    func remove<M1: Cuckoo.Matchable>(forClientId: M1) -> Cuckoo.ProtocolStubNoReturnFunction<(String)> where M1.MatchedType == String {
	        let matchers: [Cuckoo.ParameterMatcher<(String)>] = [wrap(matchable: forClientId) { $0 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockSessionStorage.self, method: "remove(forClientId: String)", parameterMatchers: matchers))
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
	
	    
	
	    
	    @discardableResult
	    func store<M1: Cuckoo.Matchable>(_ value: M1) -> Cuckoo.__DoNotUse<(UserSession), Void> where M1.MatchedType == UserSession {
	        let matchers: [Cuckoo.ParameterMatcher<(UserSession)>] = [wrap(matchable: value) { $0 }]
	        return cuckoo_manager.verify("store(_: UserSession)", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func get<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable>(forClientId: M1, completion: M2) -> Cuckoo.__DoNotUse<(String, (UserSession?) -> Void), Void> where M1.MatchedType == String, M2.MatchedType == (UserSession?) -> Void {
	        let matchers: [Cuckoo.ParameterMatcher<(String, (UserSession?) -> Void)>] = [wrap(matchable: forClientId) { $0.0 }, wrap(matchable: completion) { $0.1 }]
	        return cuckoo_manager.verify("get(forClientId: String, completion: @escaping (UserSession?) -> Void)", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func getAll() -> Cuckoo.__DoNotUse<(), [UserSession]> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return cuckoo_manager.verify("getAll() -> [UserSession]", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func remove<M1: Cuckoo.Matchable>(forClientId: M1) -> Cuckoo.__DoNotUse<(String), Void> where M1.MatchedType == String {
	        let matchers: [Cuckoo.ParameterMatcher<(String)>] = [wrap(matchable: forClientId) { $0 }]
	        return cuckoo_manager.verify("remove(forClientId: String)", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	}
}

 class SessionStorageStub: SessionStorage {
    

    

    
     func store(_ value: UserSession)   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
     func get(forClientId: String, completion: @escaping (UserSession?) -> Void)   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
     func getAll() -> [UserSession]  {
        return DefaultValueRegistry.defaultValue(for: ([UserSession]).self)
    }
    
     func remove(forClientId: String)   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
}


// MARK: - Mocks generated from file: ../../Sources/AccountSDKIOSWeb/Lib/Storage/Storage.swift at 2021-07-16 13:47:30 +0000


import Cuckoo
@testable import AccountSDKIOSWeb

import Foundation


 class MockStorage: Storage, Cuckoo.ProtocolMock {
    
     typealias MocksType = Storage
    
     typealias Stubbing = __StubbingProxy_Storage
     typealias Verification = __VerificationProxy_Storage

     let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: false)

    
    private var __defaultImplStub: Storage?

     func enableDefaultImplementation(_ stub: Storage) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }
    

    

    

    
    
    
     func setValue(_ value: Data, forKey key: String)  {
        
    return cuckoo_manager.call("setValue(_: Data, forKey: String)",
            parameters: (value, key),
            escapingParameters: (value, key),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.setValue(value, forKey: key))
        
    }
    
    
    
     func value(forKey key: String) -> Data? {
        
    return cuckoo_manager.call("value(forKey: String) -> Data?",
            parameters: (key),
            escapingParameters: (key),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.value(forKey: key))
        
    }
    
    
    
     func removeValue(forKey key: String)  {
        
    return cuckoo_manager.call("removeValue(forKey: String)",
            parameters: (key),
            escapingParameters: (key),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.removeValue(forKey: key))
        
    }
    

	 struct __StubbingProxy_Storage: Cuckoo.StubbingProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	
	     init(manager: Cuckoo.MockManager) {
	        self.cuckoo_manager = manager
	    }
	    
	    
	    func setValue<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable>(_ value: M1, forKey key: M2) -> Cuckoo.ProtocolStubNoReturnFunction<(Data, String)> where M1.MatchedType == Data, M2.MatchedType == String {
	        let matchers: [Cuckoo.ParameterMatcher<(Data, String)>] = [wrap(matchable: value) { $0.0 }, wrap(matchable: key) { $0.1 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockStorage.self, method: "setValue(_: Data, forKey: String)", parameterMatchers: matchers))
	    }
	    
	    func value<M1: Cuckoo.Matchable>(forKey key: M1) -> Cuckoo.ProtocolStubFunction<(String), Data?> where M1.MatchedType == String {
	        let matchers: [Cuckoo.ParameterMatcher<(String)>] = [wrap(matchable: key) { $0 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockStorage.self, method: "value(forKey: String) -> Data?", parameterMatchers: matchers))
	    }
	    
	    func removeValue<M1: Cuckoo.Matchable>(forKey key: M1) -> Cuckoo.ProtocolStubNoReturnFunction<(String)> where M1.MatchedType == String {
	        let matchers: [Cuckoo.ParameterMatcher<(String)>] = [wrap(matchable: key) { $0 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockStorage.self, method: "removeValue(forKey: String)", parameterMatchers: matchers))
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
	    func setValue<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable>(_ value: M1, forKey key: M2) -> Cuckoo.__DoNotUse<(Data, String), Void> where M1.MatchedType == Data, M2.MatchedType == String {
	        let matchers: [Cuckoo.ParameterMatcher<(Data, String)>] = [wrap(matchable: value) { $0.0 }, wrap(matchable: key) { $0.1 }]
	        return cuckoo_manager.verify("setValue(_: Data, forKey: String)", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func value<M1: Cuckoo.Matchable>(forKey key: M1) -> Cuckoo.__DoNotUse<(String), Data?> where M1.MatchedType == String {
	        let matchers: [Cuckoo.ParameterMatcher<(String)>] = [wrap(matchable: key) { $0 }]
	        return cuckoo_manager.verify("value(forKey: String) -> Data?", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func removeValue<M1: Cuckoo.Matchable>(forKey key: M1) -> Cuckoo.__DoNotUse<(String), Void> where M1.MatchedType == String {
	        let matchers: [Cuckoo.ParameterMatcher<(String)>] = [wrap(matchable: key) { $0 }]
	        return cuckoo_manager.verify("removeValue(forKey: String)", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	}
}

 class StorageStub: Storage {
    

    

    
     func setValue(_ value: Data, forKey key: String)   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
     func value(forKey key: String) -> Data?  {
        return DefaultValueRegistry.defaultValue(for: (Data?).self)
    }
    
     func removeValue(forKey key: String)   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
}

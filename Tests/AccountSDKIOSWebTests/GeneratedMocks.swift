// MARK: - Mocks generated from file: Sources/AccountSDKIOSWeb/HTTP/HTTPClient.swift at 2020-10-27 07:16:01 +0000


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
    

    

    

    
    
    
    public func get<T: Codable>(url: URL, completion: @escaping (Result<T, HTTPError>) -> Void)  {
        
    return cuckoo_manager.call("get(url: URL, completion: @escaping (Result<T, HTTPError>) -> Void)",
            parameters: (url, completion),
            escapingParameters: (url, completion),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.get(url: url, completion: completion))
        
    }
    
    
    
    public func post<T: Codable>(url: URL, body: Data, contentType: String, authorization: String?, completion: @escaping (Result<T, HTTPError>) -> Void)  {
        
    return cuckoo_manager.call("post(url: URL, body: Data, contentType: String, authorization: String?, completion: @escaping (Result<T, HTTPError>) -> Void)",
            parameters: (url, body, contentType, authorization, completion),
            escapingParameters: (url, body, contentType, authorization, completion),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.post(url: url, body: body, contentType: contentType, authorization: authorization, completion: completion))
        
    }
    

	public struct __StubbingProxy_HTTPClient: Cuckoo.StubbingProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	
	    public init(manager: Cuckoo.MockManager) {
	        self.cuckoo_manager = manager
	    }
	    
	    
	    func get<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, T: Codable>(url: M1, completion: M2) -> Cuckoo.ProtocolStubNoReturnFunction<(URL, (Result<T, HTTPError>) -> Void)> where M1.MatchedType == URL, M2.MatchedType == (Result<T, HTTPError>) -> Void {
	        let matchers: [Cuckoo.ParameterMatcher<(URL, (Result<T, HTTPError>) -> Void)>] = [wrap(matchable: url) { $0.0 }, wrap(matchable: completion) { $0.1 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockHTTPClient.self, method: "get(url: URL, completion: @escaping (Result<T, HTTPError>) -> Void)", parameterMatchers: matchers))
	    }
	    
	    func post<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, M3: Cuckoo.Matchable, M4: Cuckoo.OptionalMatchable, M5: Cuckoo.Matchable, T: Codable>(url: M1, body: M2, contentType: M3, authorization: M4, completion: M5) -> Cuckoo.ProtocolStubNoReturnFunction<(URL, Data, String, String?, (Result<T, HTTPError>) -> Void)> where M1.MatchedType == URL, M2.MatchedType == Data, M3.MatchedType == String, M4.OptionalMatchedType == String, M5.MatchedType == (Result<T, HTTPError>) -> Void {
	        let matchers: [Cuckoo.ParameterMatcher<(URL, Data, String, String?, (Result<T, HTTPError>) -> Void)>] = [wrap(matchable: url) { $0.0 }, wrap(matchable: body) { $0.1 }, wrap(matchable: contentType) { $0.2 }, wrap(matchable: authorization) { $0.3 }, wrap(matchable: completion) { $0.4 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockHTTPClient.self, method: "post(url: URL, body: Data, contentType: String, authorization: String?, completion: @escaping (Result<T, HTTPError>) -> Void)", parameterMatchers: matchers))
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
	    func get<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, T: Codable>(url: M1, completion: M2) -> Cuckoo.__DoNotUse<(URL, (Result<T, HTTPError>) -> Void), Void> where M1.MatchedType == URL, M2.MatchedType == (Result<T, HTTPError>) -> Void {
	        let matchers: [Cuckoo.ParameterMatcher<(URL, (Result<T, HTTPError>) -> Void)>] = [wrap(matchable: url) { $0.0 }, wrap(matchable: completion) { $0.1 }]
	        return cuckoo_manager.verify("get(url: URL, completion: @escaping (Result<T, HTTPError>) -> Void)", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func post<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, M3: Cuckoo.Matchable, M4: Cuckoo.OptionalMatchable, M5: Cuckoo.Matchable, T: Codable>(url: M1, body: M2, contentType: M3, authorization: M4, completion: M5) -> Cuckoo.__DoNotUse<(URL, Data, String, String?, (Result<T, HTTPError>) -> Void), Void> where M1.MatchedType == URL, M2.MatchedType == Data, M3.MatchedType == String, M4.OptionalMatchedType == String, M5.MatchedType == (Result<T, HTTPError>) -> Void {
	        let matchers: [Cuckoo.ParameterMatcher<(URL, Data, String, String?, (Result<T, HTTPError>) -> Void)>] = [wrap(matchable: url) { $0.0 }, wrap(matchable: body) { $0.1 }, wrap(matchable: contentType) { $0.2 }, wrap(matchable: authorization) { $0.3 }, wrap(matchable: completion) { $0.4 }]
	        return cuckoo_manager.verify("post(url: URL, body: Data, contentType: String, authorization: String?, completion: @escaping (Result<T, HTTPError>) -> Void)", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	}
}

public class HTTPClientStub: HTTPClient {
    

    

    
    public func get<T: Codable>(url: URL, completion: @escaping (Result<T, HTTPError>) -> Void)   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
    public func post<T: Codable>(url: URL, body: Data, contentType: String, authorization: String?, completion: @escaping (Result<T, HTTPError>) -> Void)   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
}



public class MockHTTPClientWithURLSession: HTTPClientWithURLSession, Cuckoo.ClassMock {
    
    public typealias MocksType = HTTPClientWithURLSession
    
    public typealias Stubbing = __StubbingProxy_HTTPClientWithURLSession
    public typealias Verification = __VerificationProxy_HTTPClientWithURLSession

    public let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: true)

    
    private var __defaultImplStub: HTTPClientWithURLSession?

    public func enableDefaultImplementation(_ stub: HTTPClientWithURLSession) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }
    

    

    

    
    
    
    public override func get<T: Codable>(url: URL, completion: @escaping (Result<T, HTTPError>) -> Void)  {
        
    return cuckoo_manager.call("get(url: URL, completion: @escaping (Result<T, HTTPError>) -> Void)",
            parameters: (url, completion),
            escapingParameters: (url, completion),
            superclassCall:
                
                super.get(url: url, completion: completion)
                ,
            defaultCall: __defaultImplStub!.get(url: url, completion: completion))
        
    }
    
    
    
    public override func post<T: Codable>(url: URL, body: Data, contentType: String, authorization: String?, completion: @escaping (Result<T, HTTPError>) -> Void)  {
        
    return cuckoo_manager.call("post(url: URL, body: Data, contentType: String, authorization: String?, completion: @escaping (Result<T, HTTPError>) -> Void)",
            parameters: (url, body, contentType, authorization, completion),
            escapingParameters: (url, body, contentType, authorization, completion),
            superclassCall:
                
                super.post(url: url, body: body, contentType: contentType, authorization: authorization, completion: completion)
                ,
            defaultCall: __defaultImplStub!.post(url: url, body: body, contentType: contentType, authorization: authorization, completion: completion))
        
    }
    

	public struct __StubbingProxy_HTTPClientWithURLSession: Cuckoo.StubbingProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	
	    public init(manager: Cuckoo.MockManager) {
	        self.cuckoo_manager = manager
	    }
	    
	    
	    func get<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, T: Codable>(url: M1, completion: M2) -> Cuckoo.ClassStubNoReturnFunction<(URL, (Result<T, HTTPError>) -> Void)> where M1.MatchedType == URL, M2.MatchedType == (Result<T, HTTPError>) -> Void {
	        let matchers: [Cuckoo.ParameterMatcher<(URL, (Result<T, HTTPError>) -> Void)>] = [wrap(matchable: url) { $0.0 }, wrap(matchable: completion) { $0.1 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockHTTPClientWithURLSession.self, method: "get(url: URL, completion: @escaping (Result<T, HTTPError>) -> Void)", parameterMatchers: matchers))
	    }
	    
	    func post<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, M3: Cuckoo.Matchable, M4: Cuckoo.OptionalMatchable, M5: Cuckoo.Matchable, T: Codable>(url: M1, body: M2, contentType: M3, authorization: M4, completion: M5) -> Cuckoo.ClassStubNoReturnFunction<(URL, Data, String, String?, (Result<T, HTTPError>) -> Void)> where M1.MatchedType == URL, M2.MatchedType == Data, M3.MatchedType == String, M4.OptionalMatchedType == String, M5.MatchedType == (Result<T, HTTPError>) -> Void {
	        let matchers: [Cuckoo.ParameterMatcher<(URL, Data, String, String?, (Result<T, HTTPError>) -> Void)>] = [wrap(matchable: url) { $0.0 }, wrap(matchable: body) { $0.1 }, wrap(matchable: contentType) { $0.2 }, wrap(matchable: authorization) { $0.3 }, wrap(matchable: completion) { $0.4 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockHTTPClientWithURLSession.self, method: "post(url: URL, body: Data, contentType: String, authorization: String?, completion: @escaping (Result<T, HTTPError>) -> Void)", parameterMatchers: matchers))
	    }
	    
	}

	public struct __VerificationProxy_HTTPClientWithURLSession: Cuckoo.VerificationProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	    private let callMatcher: Cuckoo.CallMatcher
	    private let sourceLocation: Cuckoo.SourceLocation
	
	    public init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
	        self.cuckoo_manager = manager
	        self.callMatcher = callMatcher
	        self.sourceLocation = sourceLocation
	    }
	
	    
	
	    
	    @discardableResult
	    func get<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, T: Codable>(url: M1, completion: M2) -> Cuckoo.__DoNotUse<(URL, (Result<T, HTTPError>) -> Void), Void> where M1.MatchedType == URL, M2.MatchedType == (Result<T, HTTPError>) -> Void {
	        let matchers: [Cuckoo.ParameterMatcher<(URL, (Result<T, HTTPError>) -> Void)>] = [wrap(matchable: url) { $0.0 }, wrap(matchable: completion) { $0.1 }]
	        return cuckoo_manager.verify("get(url: URL, completion: @escaping (Result<T, HTTPError>) -> Void)", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func post<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, M3: Cuckoo.Matchable, M4: Cuckoo.OptionalMatchable, M5: Cuckoo.Matchable, T: Codable>(url: M1, body: M2, contentType: M3, authorization: M4, completion: M5) -> Cuckoo.__DoNotUse<(URL, Data, String, String?, (Result<T, HTTPError>) -> Void), Void> where M1.MatchedType == URL, M2.MatchedType == Data, M3.MatchedType == String, M4.OptionalMatchedType == String, M5.MatchedType == (Result<T, HTTPError>) -> Void {
	        let matchers: [Cuckoo.ParameterMatcher<(URL, Data, String, String?, (Result<T, HTTPError>) -> Void)>] = [wrap(matchable: url) { $0.0 }, wrap(matchable: body) { $0.1 }, wrap(matchable: contentType) { $0.2 }, wrap(matchable: authorization) { $0.3 }, wrap(matchable: completion) { $0.4 }]
	        return cuckoo_manager.verify("post(url: URL, body: Data, contentType: String, authorization: String?, completion: @escaping (Result<T, HTTPError>) -> Void)", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	}
}

public class HTTPClientWithURLSessionStub: HTTPClientWithURLSession {
    

    

    
    public override func get<T: Codable>(url: URL, completion: @escaping (Result<T, HTTPError>) -> Void)   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
    public override func post<T: Codable>(url: URL, body: Data, contentType: String, authorization: String?, completion: @escaping (Result<T, HTTPError>) -> Void)   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
}


// MARK: - Mocks generated from file: Sources/AccountSDKIOSWeb/Storage/TokenStorage.swift at 2020-10-27 07:16:01 +0000


import Cuckoo
@testable import AccountSDKIOSWeb

import Foundation
import Security


 class MockTokenStorage: TokenStorage, Cuckoo.ProtocolMock {
    
     typealias MocksType = TokenStorage
    
     typealias Stubbing = __StubbingProxy_TokenStorage
     typealias Verification = __VerificationProxy_TokenStorage

     let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: false)

    
    private var __defaultImplStub: TokenStorage?

     func enableDefaultImplementation(_ stub: TokenStorage) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }
    

    

    

    
    
    
     func store(_ value: StoredUserTokens)  {
        
    return cuckoo_manager.call("store(_: StoredUserTokens)",
            parameters: (value),
            escapingParameters: (value),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.store(value))
        
    }
    
    
    
     func get() -> StoredUserTokens? {
        
    return cuckoo_manager.call("get() -> StoredUserTokens?",
            parameters: (),
            escapingParameters: (),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.get())
        
    }
    
    
    
     func remove()  {
        
    return cuckoo_manager.call("remove()",
            parameters: (),
            escapingParameters: (),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.remove())
        
    }
    

	 struct __StubbingProxy_TokenStorage: Cuckoo.StubbingProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	
	     init(manager: Cuckoo.MockManager) {
	        self.cuckoo_manager = manager
	    }
	    
	    
	    func store<M1: Cuckoo.Matchable>(_ value: M1) -> Cuckoo.ProtocolStubNoReturnFunction<(StoredUserTokens)> where M1.MatchedType == StoredUserTokens {
	        let matchers: [Cuckoo.ParameterMatcher<(StoredUserTokens)>] = [wrap(matchable: value) { $0 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockTokenStorage.self, method: "store(_: StoredUserTokens)", parameterMatchers: matchers))
	    }
	    
	    func get() -> Cuckoo.ProtocolStubFunction<(), StoredUserTokens?> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return .init(stub: cuckoo_manager.createStub(for: MockTokenStorage.self, method: "get() -> StoredUserTokens?", parameterMatchers: matchers))
	    }
	    
	    func remove() -> Cuckoo.ProtocolStubNoReturnFunction<()> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return .init(stub: cuckoo_manager.createStub(for: MockTokenStorage.self, method: "remove()", parameterMatchers: matchers))
	    }
	    
	}

	 struct __VerificationProxy_TokenStorage: Cuckoo.VerificationProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	    private let callMatcher: Cuckoo.CallMatcher
	    private let sourceLocation: Cuckoo.SourceLocation
	
	     init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
	        self.cuckoo_manager = manager
	        self.callMatcher = callMatcher
	        self.sourceLocation = sourceLocation
	    }
	
	    
	
	    
	    @discardableResult
	    func store<M1: Cuckoo.Matchable>(_ value: M1) -> Cuckoo.__DoNotUse<(StoredUserTokens), Void> where M1.MatchedType == StoredUserTokens {
	        let matchers: [Cuckoo.ParameterMatcher<(StoredUserTokens)>] = [wrap(matchable: value) { $0 }]
	        return cuckoo_manager.verify("store(_: StoredUserTokens)", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func get() -> Cuckoo.__DoNotUse<(), StoredUserTokens?> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return cuckoo_manager.verify("get() -> StoredUserTokens?", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func remove() -> Cuckoo.__DoNotUse<(), Void> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return cuckoo_manager.verify("remove()", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	}
}

 class TokenStorageStub: TokenStorage {
    

    

    
     func store(_ value: StoredUserTokens)   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
     func get() -> StoredUserTokens?  {
        return DefaultValueRegistry.defaultValue(for: (StoredUserTokens?).self)
    }
    
     func remove()   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
}


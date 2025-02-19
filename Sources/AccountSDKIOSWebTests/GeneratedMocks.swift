// MARK: - Mocks generated from file: Sources/AccountSDKIOSWeb/Lib/API/SchibstedAccountAPI.swift at 2025-02-19 11:15:08 +0000

//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Cuckoo
@testable import AccountSDKIOSWeb

import Foundation
import UIKit


 class MockSchibstedAccountAPI: SchibstedAccountAPI, Cuckoo.ClassMock {
    
     typealias MocksType = SchibstedAccountAPI
    
     typealias Stubbing = __StubbingProxy_SchibstedAccountAPI
     typealias Verification = __VerificationProxy_SchibstedAccountAPI

     let cuckoo_manager = Cuckoo.MockManager.preconfiguredManager ?? Cuckoo.MockManager(hasParent: true)

    
    private var __defaultImplStub: SchibstedAccountAPI?

     func enableDefaultImplementation(_ stub: SchibstedAccountAPI) {
        __defaultImplStub = stub
        cuckoo_manager.enableDefaultStubImplementation()
    }
    

    

    

    
    
    
     override func sessionExchange(for user: User, clientId: String, redirectURI: String, state: String?, completion: @escaping HTTPResultHandler<SessionExchangeResponse>)  {
        
    return cuckoo_manager.call("sessionExchange(for: User, clientId: String, redirectURI: String, state: String?, completion: @escaping HTTPResultHandler<SessionExchangeResponse>)",
            parameters: (user, clientId, redirectURI, state, completion),
            escapingParameters: (user, clientId, redirectURI, state, completion),
            superclassCall:
                
                super.sessionExchange(for: user, clientId: clientId, redirectURI: redirectURI, state: state, completion: completion)
                ,
            defaultCall: __defaultImplStub!.sessionExchange(for: user, clientId: clientId, redirectURI: redirectURI, state: state, completion: completion))
        
    }
    
    
    
     override func codeExchange(for user: User, clientId: String, completion: @escaping HTTPResultHandler<CodeExchangeResponse>)  {
        
    return cuckoo_manager.call("codeExchange(for: User, clientId: String, completion: @escaping HTTPResultHandler<CodeExchangeResponse>)",
            parameters: (user, clientId, completion),
            escapingParameters: (user, clientId, completion),
            superclassCall:
                
                super.codeExchange(for: user, clientId: clientId, completion: completion)
                ,
            defaultCall: __defaultImplStub!.codeExchange(for: user, clientId: clientId, completion: completion))
        
    }
    
    
    
     override func userContextFromToken(for user: User, completion: @escaping HTTPResultHandler<UserContextFromTokenResponse>)  {
        
    return cuckoo_manager.call("userContextFromToken(for: User, completion: @escaping HTTPResultHandler<UserContextFromTokenResponse>)",
            parameters: (user, completion),
            escapingParameters: (user, completion),
            superclassCall:
                
                super.userContextFromToken(for: user, completion: completion)
                ,
            defaultCall: __defaultImplStub!.userContextFromToken(for: user, completion: completion))
        
    }
    
    
    
     override func assertionForSimplifiedLogin(for user: User, completion: @escaping HTTPResultHandler<SimplifiedLoginAssertionResponse>)  {
        
    return cuckoo_manager.call("assertionForSimplifiedLogin(for: User, completion: @escaping HTTPResultHandler<SimplifiedLoginAssertionResponse>)",
            parameters: (user, completion),
            escapingParameters: (user, completion),
            superclassCall:
                
                super.assertionForSimplifiedLogin(for: user, completion: completion)
                ,
            defaultCall: __defaultImplStub!.assertionForSimplifiedLogin(for: user, completion: completion))
        
    }
    
    
    
     override func tokenRequest(with httpClient: HTTPClient, parameters: [String: String], completion: @escaping HTTPResultHandler<TokenResponse>)  {
        
    return cuckoo_manager.call("tokenRequest(with: HTTPClient, parameters: [String: String], completion: @escaping HTTPResultHandler<TokenResponse>)",
            parameters: (httpClient, parameters, completion),
            escapingParameters: (httpClient, parameters, completion),
            superclassCall:
                
                super.tokenRequest(with: httpClient, parameters: parameters, completion: completion)
                ,
            defaultCall: __defaultImplStub!.tokenRequest(with: httpClient, parameters: parameters, completion: completion))
        
    }
    
    
    
     override func userProfile(for user: User, completion: @escaping HTTPResultHandler<UserProfileResponse>)  {
        
    return cuckoo_manager.call("userProfile(for: User, completion: @escaping HTTPResultHandler<UserProfileResponse>)",
            parameters: (user, completion),
            escapingParameters: (user, completion),
            superclassCall:
                
                super.userProfile(for: user, completion: completion)
                ,
            defaultCall: __defaultImplStub!.userProfile(for: user, completion: completion))
        
    }
    

	 struct __StubbingProxy_SchibstedAccountAPI: Cuckoo.StubbingProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	
	     init(manager: Cuckoo.MockManager) {
	        self.cuckoo_manager = manager
	    }
	    
	    
	    func sessionExchange<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, M3: Cuckoo.Matchable, M4: Cuckoo.OptionalMatchable, M5: Cuckoo.Matchable>(for user: M1, clientId: M2, redirectURI: M3, state: M4, completion: M5) -> Cuckoo.ClassStubNoReturnFunction<(User, String, String, String?, HTTPResultHandler<SessionExchangeResponse>)> where M1.MatchedType == User, M2.MatchedType == String, M3.MatchedType == String, M4.OptionalMatchedType == String, M5.MatchedType == HTTPResultHandler<SessionExchangeResponse> {
	        let matchers: [Cuckoo.ParameterMatcher<(User, String, String, String?, HTTPResultHandler<SessionExchangeResponse>)>] = [wrap(matchable: user) { $0.0 }, wrap(matchable: clientId) { $0.1 }, wrap(matchable: redirectURI) { $0.2 }, wrap(matchable: state) { $0.3 }, wrap(matchable: completion) { $0.4 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockSchibstedAccountAPI.self, method: "sessionExchange(for: User, clientId: String, redirectURI: String, state: String?, completion: @escaping HTTPResultHandler<SessionExchangeResponse>)", parameterMatchers: matchers))
	    }
	    
	    func codeExchange<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, M3: Cuckoo.Matchable>(for user: M1, clientId: M2, completion: M3) -> Cuckoo.ClassStubNoReturnFunction<(User, String, HTTPResultHandler<CodeExchangeResponse>)> where M1.MatchedType == User, M2.MatchedType == String, M3.MatchedType == HTTPResultHandler<CodeExchangeResponse> {
	        let matchers: [Cuckoo.ParameterMatcher<(User, String, HTTPResultHandler<CodeExchangeResponse>)>] = [wrap(matchable: user) { $0.0 }, wrap(matchable: clientId) { $0.1 }, wrap(matchable: completion) { $0.2 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockSchibstedAccountAPI.self, method: "codeExchange(for: User, clientId: String, completion: @escaping HTTPResultHandler<CodeExchangeResponse>)", parameterMatchers: matchers))
	    }
	    
	    func userContextFromToken<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable>(for user: M1, completion: M2) -> Cuckoo.ClassStubNoReturnFunction<(User, HTTPResultHandler<UserContextFromTokenResponse>)> where M1.MatchedType == User, M2.MatchedType == HTTPResultHandler<UserContextFromTokenResponse> {
	        let matchers: [Cuckoo.ParameterMatcher<(User, HTTPResultHandler<UserContextFromTokenResponse>)>] = [wrap(matchable: user) { $0.0 }, wrap(matchable: completion) { $0.1 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockSchibstedAccountAPI.self, method: "userContextFromToken(for: User, completion: @escaping HTTPResultHandler<UserContextFromTokenResponse>)", parameterMatchers: matchers))
	    }
	    
	    func assertionForSimplifiedLogin<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable>(for user: M1, completion: M2) -> Cuckoo.ClassStubNoReturnFunction<(User, HTTPResultHandler<SimplifiedLoginAssertionResponse>)> where M1.MatchedType == User, M2.MatchedType == HTTPResultHandler<SimplifiedLoginAssertionResponse> {
	        let matchers: [Cuckoo.ParameterMatcher<(User, HTTPResultHandler<SimplifiedLoginAssertionResponse>)>] = [wrap(matchable: user) { $0.0 }, wrap(matchable: completion) { $0.1 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockSchibstedAccountAPI.self, method: "assertionForSimplifiedLogin(for: User, completion: @escaping HTTPResultHandler<SimplifiedLoginAssertionResponse>)", parameterMatchers: matchers))
	    }
	    
	    func tokenRequest<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, M3: Cuckoo.Matchable>(with httpClient: M1, parameters: M2, completion: M3) -> Cuckoo.ClassStubNoReturnFunction<(HTTPClient, [String: String], HTTPResultHandler<TokenResponse>)> where M1.MatchedType == HTTPClient, M2.MatchedType == [String: String], M3.MatchedType == HTTPResultHandler<TokenResponse> {
	        let matchers: [Cuckoo.ParameterMatcher<(HTTPClient, [String: String], HTTPResultHandler<TokenResponse>)>] = [wrap(matchable: httpClient) { $0.0 }, wrap(matchable: parameters) { $0.1 }, wrap(matchable: completion) { $0.2 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockSchibstedAccountAPI.self, method: "tokenRequest(with: HTTPClient, parameters: [String: String], completion: @escaping HTTPResultHandler<TokenResponse>)", parameterMatchers: matchers))
	    }
	    
	    func userProfile<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable>(for user: M1, completion: M2) -> Cuckoo.ClassStubNoReturnFunction<(User, HTTPResultHandler<UserProfileResponse>)> where M1.MatchedType == User, M2.MatchedType == HTTPResultHandler<UserProfileResponse> {
	        let matchers: [Cuckoo.ParameterMatcher<(User, HTTPResultHandler<UserProfileResponse>)>] = [wrap(matchable: user) { $0.0 }, wrap(matchable: completion) { $0.1 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockSchibstedAccountAPI.self, method: "userProfile(for: User, completion: @escaping HTTPResultHandler<UserProfileResponse>)", parameterMatchers: matchers))
	    }
	    
	}

	 struct __VerificationProxy_SchibstedAccountAPI: Cuckoo.VerificationProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	    private let callMatcher: Cuckoo.CallMatcher
	    private let sourceLocation: Cuckoo.SourceLocation
	
	     init(manager: Cuckoo.MockManager, callMatcher: Cuckoo.CallMatcher, sourceLocation: Cuckoo.SourceLocation) {
	        self.cuckoo_manager = manager
	        self.callMatcher = callMatcher
	        self.sourceLocation = sourceLocation
	    }
	
	    
	
	    
	    @discardableResult
	    func sessionExchange<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, M3: Cuckoo.Matchable, M4: Cuckoo.OptionalMatchable, M5: Cuckoo.Matchable>(for user: M1, clientId: M2, redirectURI: M3, state: M4, completion: M5) -> Cuckoo.__DoNotUse<(User, String, String, String?, HTTPResultHandler<SessionExchangeResponse>), Void> where M1.MatchedType == User, M2.MatchedType == String, M3.MatchedType == String, M4.OptionalMatchedType == String, M5.MatchedType == HTTPResultHandler<SessionExchangeResponse> {
	        let matchers: [Cuckoo.ParameterMatcher<(User, String, String, String?, HTTPResultHandler<SessionExchangeResponse>)>] = [wrap(matchable: user) { $0.0 }, wrap(matchable: clientId) { $0.1 }, wrap(matchable: redirectURI) { $0.2 }, wrap(matchable: state) { $0.3 }, wrap(matchable: completion) { $0.4 }]
	        return cuckoo_manager.verify("sessionExchange(for: User, clientId: String, redirectURI: String, state: String?, completion: @escaping HTTPResultHandler<SessionExchangeResponse>)", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func codeExchange<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, M3: Cuckoo.Matchable>(for user: M1, clientId: M2, completion: M3) -> Cuckoo.__DoNotUse<(User, String, HTTPResultHandler<CodeExchangeResponse>), Void> where M1.MatchedType == User, M2.MatchedType == String, M3.MatchedType == HTTPResultHandler<CodeExchangeResponse> {
	        let matchers: [Cuckoo.ParameterMatcher<(User, String, HTTPResultHandler<CodeExchangeResponse>)>] = [wrap(matchable: user) { $0.0 }, wrap(matchable: clientId) { $0.1 }, wrap(matchable: completion) { $0.2 }]
	        return cuckoo_manager.verify("codeExchange(for: User, clientId: String, completion: @escaping HTTPResultHandler<CodeExchangeResponse>)", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func userContextFromToken<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable>(for user: M1, completion: M2) -> Cuckoo.__DoNotUse<(User, HTTPResultHandler<UserContextFromTokenResponse>), Void> where M1.MatchedType == User, M2.MatchedType == HTTPResultHandler<UserContextFromTokenResponse> {
	        let matchers: [Cuckoo.ParameterMatcher<(User, HTTPResultHandler<UserContextFromTokenResponse>)>] = [wrap(matchable: user) { $0.0 }, wrap(matchable: completion) { $0.1 }]
	        return cuckoo_manager.verify("userContextFromToken(for: User, completion: @escaping HTTPResultHandler<UserContextFromTokenResponse>)", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func assertionForSimplifiedLogin<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable>(for user: M1, completion: M2) -> Cuckoo.__DoNotUse<(User, HTTPResultHandler<SimplifiedLoginAssertionResponse>), Void> where M1.MatchedType == User, M2.MatchedType == HTTPResultHandler<SimplifiedLoginAssertionResponse> {
	        let matchers: [Cuckoo.ParameterMatcher<(User, HTTPResultHandler<SimplifiedLoginAssertionResponse>)>] = [wrap(matchable: user) { $0.0 }, wrap(matchable: completion) { $0.1 }]
	        return cuckoo_manager.verify("assertionForSimplifiedLogin(for: User, completion: @escaping HTTPResultHandler<SimplifiedLoginAssertionResponse>)", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func tokenRequest<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable, M3: Cuckoo.Matchable>(with httpClient: M1, parameters: M2, completion: M3) -> Cuckoo.__DoNotUse<(HTTPClient, [String: String], HTTPResultHandler<TokenResponse>), Void> where M1.MatchedType == HTTPClient, M2.MatchedType == [String: String], M3.MatchedType == HTTPResultHandler<TokenResponse> {
	        let matchers: [Cuckoo.ParameterMatcher<(HTTPClient, [String: String], HTTPResultHandler<TokenResponse>)>] = [wrap(matchable: httpClient) { $0.0 }, wrap(matchable: parameters) { $0.1 }, wrap(matchable: completion) { $0.2 }]
	        return cuckoo_manager.verify("tokenRequest(with: HTTPClient, parameters: [String: String], completion: @escaping HTTPResultHandler<TokenResponse>)", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func userProfile<M1: Cuckoo.Matchable, M2: Cuckoo.Matchable>(for user: M1, completion: M2) -> Cuckoo.__DoNotUse<(User, HTTPResultHandler<UserProfileResponse>), Void> where M1.MatchedType == User, M2.MatchedType == HTTPResultHandler<UserProfileResponse> {
	        let matchers: [Cuckoo.ParameterMatcher<(User, HTTPResultHandler<UserProfileResponse>)>] = [wrap(matchable: user) { $0.0 }, wrap(matchable: completion) { $0.1 }]
	        return cuckoo_manager.verify("userProfile(for: User, completion: @escaping HTTPResultHandler<UserProfileResponse>)", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	}
}

 class SchibstedAccountAPIStub: SchibstedAccountAPI {
    

    

    
    
    
     override func sessionExchange(for user: User, clientId: String, redirectURI: String, state: String?, completion: @escaping HTTPResultHandler<SessionExchangeResponse>)   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
    
    
     override func codeExchange(for user: User, clientId: String, completion: @escaping HTTPResultHandler<CodeExchangeResponse>)   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
    
    
     override func userContextFromToken(for user: User, completion: @escaping HTTPResultHandler<UserContextFromTokenResponse>)   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
    
    
     override func assertionForSimplifiedLogin(for user: User, completion: @escaping HTTPResultHandler<SimplifiedLoginAssertionResponse>)   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
    
    
     override func tokenRequest(with httpClient: HTTPClient, parameters: [String: String], completion: @escaping HTTPResultHandler<TokenResponse>)   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
    
    
     override func userProfile(for user: User, completion: @escaping HTTPResultHandler<UserProfileResponse>)   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
}


// MARK: - Mocks generated from file: Sources/AccountSDKIOSWeb/Lib/HTTP/HTTPClient.swift at 2025-02-19 11:15:08 +0000

//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

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


// MARK: - Mocks generated from file: Sources/AccountSDKIOSWeb/Lib/Storage/Keychain/KeychainSessionStorage.swift at 2025-02-19 11:15:08 +0000

//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

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
    

    
    
    
     override var accessGroup: String? {
        get {
            return cuckoo_manager.getter("accessGroup",
                superclassCall:
                    
                    super.accessGroup
                    ,
                defaultCall: __defaultImplStub!.accessGroup)
        }
        
    }
    

    

    
    
    
     override func store(_ value: UserSession, accessGroup: String?) throws {
        
    return try cuckoo_manager.callThrows("store(_: UserSession, accessGroup: String?) throws",
            parameters: (value, accessGroup),
            escapingParameters: (value, accessGroup),
            superclassCall:
                
                super.store(value, accessGroup: accessGroup)
                ,
            defaultCall: __defaultImplStub!.store(value, accessGroup: accessGroup))
        
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
    
    
    
     override func checkEntitlements() throws -> Data? {
        
    return try cuckoo_manager.callThrows("checkEntitlements() throws -> Data?",
            parameters: (),
            escapingParameters: (),
            superclassCall:
                
                super.checkEntitlements()
                ,
            defaultCall: __defaultImplStub!.checkEntitlements())
        
    }
    
    
    
     func getLatestSession() -> UserSession? {
        
    return cuckoo_manager.call("getLatestSession() -> UserSession?",
            parameters: (),
            escapingParameters: (),
            superclassCall:
                
                super.getLatestSession()
                ,
            defaultCall: __defaultImplStub!.getLatestSession())
        
    }
    

	 struct __StubbingProxy_KeychainSessionStorage: Cuckoo.StubbingProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	
	     init(manager: Cuckoo.MockManager) {
	        self.cuckoo_manager = manager
	    }
	    
	    
	    var accessGroup: Cuckoo.ClassToBeStubbedReadOnlyProperty<MockKeychainSessionStorage, String?> {
	        return .init(manager: cuckoo_manager, name: "accessGroup")
	    }
	    
	    
	    func store<M1: Cuckoo.Matchable, M2: Cuckoo.OptionalMatchable>(_ value: M1, accessGroup: M2) -> Cuckoo.ClassStubNoReturnThrowingFunction<(UserSession, String?)> where M1.MatchedType == UserSession, M2.OptionalMatchedType == String {
	        let matchers: [Cuckoo.ParameterMatcher<(UserSession, String?)>] = [wrap(matchable: value) { $0.0 }, wrap(matchable: accessGroup) { $0.1 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockKeychainSessionStorage.self, method: "store(_: UserSession, accessGroup: String?) throws", parameterMatchers: matchers))
	    }
	    
	    func get<M1: Cuckoo.Matchable>(forClientId: M1) -> Cuckoo.ClassStubFunction<(String), UserSession?> where M1.MatchedType == String {
	        let matchers: [Cuckoo.ParameterMatcher<(String)>] = [wrap(matchable: forClientId) { $0 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockKeychainSessionStorage.self, method: "get(forClientId: String) -> UserSession?", parameterMatchers: matchers))
	    }
	    
	    func getAll() -> Cuckoo.ClassStubFunction<(), [UserSession]> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return .init(stub: cuckoo_manager.createStub(for: MockKeychainSessionStorage.self, method: "getAll() -> [UserSession]", parameterMatchers: matchers))
	    }
	    
	    func remove<M1: Cuckoo.Matchable>(forClientId: M1) -> Cuckoo.ClassStubNoReturnFunction<(String)> where M1.MatchedType == String {
	        let matchers: [Cuckoo.ParameterMatcher<(String)>] = [wrap(matchable: forClientId) { $0 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockKeychainSessionStorage.self, method: "remove(forClientId: String)", parameterMatchers: matchers))
	    }
	    
	    func checkEntitlements() -> Cuckoo.ClassStubThrowingFunction<(), Data?> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return .init(stub: cuckoo_manager.createStub(for: MockKeychainSessionStorage.self, method: "checkEntitlements() throws -> Data?", parameterMatchers: matchers))
	    }
	    
	    func getLatestSession() -> Cuckoo.ProtocolStubFunction<(), UserSession?> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return .init(stub: cuckoo_manager.createStub(for: MockKeychainSessionStorage.self, method: "getLatestSession() -> UserSession?", parameterMatchers: matchers))
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
	    func store<M1: Cuckoo.Matchable, M2: Cuckoo.OptionalMatchable>(_ value: M1, accessGroup: M2) -> Cuckoo.__DoNotUse<(UserSession, String?), Void> where M1.MatchedType == UserSession, M2.OptionalMatchedType == String {
	        let matchers: [Cuckoo.ParameterMatcher<(UserSession, String?)>] = [wrap(matchable: value) { $0.0 }, wrap(matchable: accessGroup) { $0.1 }]
	        return cuckoo_manager.verify("store(_: UserSession, accessGroup: String?) throws", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func get<M1: Cuckoo.Matchable>(forClientId: M1) -> Cuckoo.__DoNotUse<(String), UserSession?> where M1.MatchedType == String {
	        let matchers: [Cuckoo.ParameterMatcher<(String)>] = [wrap(matchable: forClientId) { $0 }]
	        return cuckoo_manager.verify("get(forClientId: String) -> UserSession?", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
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
	    
	    @discardableResult
	    func checkEntitlements() -> Cuckoo.__DoNotUse<(), Data?> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return cuckoo_manager.verify("checkEntitlements() throws -> Data?", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func getLatestSession() -> Cuckoo.__DoNotUse<(), UserSession?> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return cuckoo_manager.verify("getLatestSession() -> UserSession?", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	}
}

 class KeychainSessionStorageStub: KeychainSessionStorage {
        
    
    
     override var accessGroup: String? {
        get {
            return DefaultValueRegistry.defaultValue(for: (String?).self)
        }
        
    }
    

    

    
    
    
     override func store(_ value: UserSession, accessGroup: String?) throws  {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
    
    
     override func get(forClientId: String) -> UserSession?  {
        return DefaultValueRegistry.defaultValue(for: (UserSession?).self)
    }
    
    
    
     override func getAll() -> [UserSession]  {
        return DefaultValueRegistry.defaultValue(for: ([UserSession]).self)
    }
    
    
    
     override func remove(forClientId: String)   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
    
    
     override func checkEntitlements() throws -> Data?  {
        return DefaultValueRegistry.defaultValue(for: (Data?).self)
    }
    
    
    
     func getLatestSession() -> UserSession?  {
        return DefaultValueRegistry.defaultValue(for: (UserSession?).self)
    }
    
}


// MARK: - Mocks generated from file: Sources/AccountSDKIOSWeb/Lib/Storage/SessionStorage.swift at 2025-02-19 11:15:08 +0000

//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

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
    

    
    
    
     var accessGroup: String? {
        get {
            return cuckoo_manager.getter("accessGroup",
                superclassCall:
                    
                    Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                    ,
                defaultCall: __defaultImplStub!.accessGroup)
        }
        
    }
    

    

    
    
    
     func store(_ value: UserSession, accessGroup: String?) throws {
        
    return try cuckoo_manager.callThrows("store(_: UserSession, accessGroup: String?) throws",
            parameters: (value, accessGroup),
            escapingParameters: (value, accessGroup),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.store(value, accessGroup: accessGroup))
        
    }
    
    
    
     func get(forClientId: String) -> UserSession? {
        
    return cuckoo_manager.call("get(forClientId: String) -> UserSession?",
            parameters: (forClientId),
            escapingParameters: (forClientId),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.get(forClientId: forClientId))
        
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
    
    
    
     func getLatestSession() -> UserSession? {
        
    return cuckoo_manager.call("getLatestSession() -> UserSession?",
            parameters: (),
            escapingParameters: (),
            superclassCall:
                
                Cuckoo.MockManager.crashOnProtocolSuperclassCall()
                ,
            defaultCall: __defaultImplStub!.getLatestSession())
        
    }
    

	 struct __StubbingProxy_SessionStorage: Cuckoo.StubbingProxy {
	    private let cuckoo_manager: Cuckoo.MockManager
	
	     init(manager: Cuckoo.MockManager) {
	        self.cuckoo_manager = manager
	    }
	    
	    
	    var accessGroup: Cuckoo.ProtocolToBeStubbedReadOnlyProperty<MockSessionStorage, String?> {
	        return .init(manager: cuckoo_manager, name: "accessGroup")
	    }
	    
	    
	    func store<M1: Cuckoo.Matchable, M2: Cuckoo.OptionalMatchable>(_ value: M1, accessGroup: M2) -> Cuckoo.ProtocolStubNoReturnThrowingFunction<(UserSession, String?)> where M1.MatchedType == UserSession, M2.OptionalMatchedType == String {
	        let matchers: [Cuckoo.ParameterMatcher<(UserSession, String?)>] = [wrap(matchable: value) { $0.0 }, wrap(matchable: accessGroup) { $0.1 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockSessionStorage.self, method: "store(_: UserSession, accessGroup: String?) throws", parameterMatchers: matchers))
	    }
	    
	    func get<M1: Cuckoo.Matchable>(forClientId: M1) -> Cuckoo.ProtocolStubFunction<(String), UserSession?> where M1.MatchedType == String {
	        let matchers: [Cuckoo.ParameterMatcher<(String)>] = [wrap(matchable: forClientId) { $0 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockSessionStorage.self, method: "get(forClientId: String) -> UserSession?", parameterMatchers: matchers))
	    }
	    
	    func getAll() -> Cuckoo.ProtocolStubFunction<(), [UserSession]> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return .init(stub: cuckoo_manager.createStub(for: MockSessionStorage.self, method: "getAll() -> [UserSession]", parameterMatchers: matchers))
	    }
	    
	    func remove<M1: Cuckoo.Matchable>(forClientId: M1) -> Cuckoo.ProtocolStubNoReturnFunction<(String)> where M1.MatchedType == String {
	        let matchers: [Cuckoo.ParameterMatcher<(String)>] = [wrap(matchable: forClientId) { $0 }]
	        return .init(stub: cuckoo_manager.createStub(for: MockSessionStorage.self, method: "remove(forClientId: String)", parameterMatchers: matchers))
	    }
	    
	    func getLatestSession() -> Cuckoo.ProtocolStubFunction<(), UserSession?> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return .init(stub: cuckoo_manager.createStub(for: MockSessionStorage.self, method: "getLatestSession() -> UserSession?", parameterMatchers: matchers))
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
	    func store<M1: Cuckoo.Matchable, M2: Cuckoo.OptionalMatchable>(_ value: M1, accessGroup: M2) -> Cuckoo.__DoNotUse<(UserSession, String?), Void> where M1.MatchedType == UserSession, M2.OptionalMatchedType == String {
	        let matchers: [Cuckoo.ParameterMatcher<(UserSession, String?)>] = [wrap(matchable: value) { $0.0 }, wrap(matchable: accessGroup) { $0.1 }]
	        return cuckoo_manager.verify("store(_: UserSession, accessGroup: String?) throws", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	    @discardableResult
	    func get<M1: Cuckoo.Matchable>(forClientId: M1) -> Cuckoo.__DoNotUse<(String), UserSession?> where M1.MatchedType == String {
	        let matchers: [Cuckoo.ParameterMatcher<(String)>] = [wrap(matchable: forClientId) { $0 }]
	        return cuckoo_manager.verify("get(forClientId: String) -> UserSession?", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
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
	    
	    @discardableResult
	    func getLatestSession() -> Cuckoo.__DoNotUse<(), UserSession?> {
	        let matchers: [Cuckoo.ParameterMatcher<Void>] = []
	        return cuckoo_manager.verify("getLatestSession() -> UserSession?", callMatcher: callMatcher, parameterMatchers: matchers, sourceLocation: sourceLocation)
	    }
	    
	}
}

 class SessionStorageStub: SessionStorage {
        
    
    
     var accessGroup: String? {
        get {
            return DefaultValueRegistry.defaultValue(for: (String?).self)
        }
        
    }
    

    

    
    
    
     func store(_ value: UserSession, accessGroup: String?) throws  {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
    
    
     func get(forClientId: String) -> UserSession?  {
        return DefaultValueRegistry.defaultValue(for: (UserSession?).self)
    }
    
    
    
     func getAll() -> [UserSession]  {
        return DefaultValueRegistry.defaultValue(for: ([UserSession]).self)
    }
    
    
    
     func remove(forClientId: String)   {
        return DefaultValueRegistry.defaultValue(for: (Void).self)
    }
    
    
    
     func getLatestSession() -> UserSession?  {
        return DefaultValueRegistry.defaultValue(for: (UserSession?).self)
    }
    
}


// MARK: - Mocks generated from file: Sources/AccountSDKIOSWeb/Lib/Storage/Storage.swift at 2025-02-19 11:15:08 +0000

//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

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


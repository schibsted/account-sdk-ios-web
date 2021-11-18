import XCTest
import Cuckoo
@testable import AccountSDKIOSWeb

final class MigratingKeychainCompatStorageTests: XCTestCase {
    func testStoreOnlyWritesToNewStorage() {
        let userSession = UserSession(clientId: "client1", userTokens: Fixtures.userTokens, updatedAt: Date())
        
        let legacyStorage = MockLegacyKeychainSessionStorage()
        let newStorage = MockKeychainSessionStorage(service: "test")
        stub(newStorage) { mock in
            when(mock.store(equal(to: userSession), completion: anyClosure())).then { _, completion in
                completion(.success())
            }
        }

        let migratingStorage = MigratingKeychainCompatStorage(from: legacyStorage,
                                                              to: newStorage,
                                                              legacyClient: Client(configuration: Fixtures.clientConfig),
                                                              legacyClientSecret: "",
                                                              makeTokenRequest: { _, _, _ in  })
        migratingStorage.store(userSession) { _ in }

        verify(newStorage).store(equal(to: userSession), completion: anyClosure())
        verifyNoMoreInteractions(legacyStorage)
    }

    func testGetAllOnlyReadsNewStorage() {
        let userSession = UserSession(clientId: "client1", userTokens: Fixtures.userTokens, updatedAt: Date())

        let legacyStorage = MockLegacyKeychainSessionStorage()
        let newStorage = MockKeychainSessionStorage(service: "test")
        stub(newStorage) { mock in
            when(mock.getAll()).thenReturn([userSession])
        }

        let migratingStorage = MigratingKeychainCompatStorage(from: legacyStorage,
                                                              to: newStorage,
                                                              legacyClient: Client(configuration: Fixtures.clientConfig),
                                                              legacyClientSecret: "",
                                                              makeTokenRequest: { _, _, _ in  })
        _ = migratingStorage.getAll()

        verify(newStorage).getAll()
        verifyNoMoreInteractions(legacyStorage)
    }
    
    func testRemoveOnlyRemovesFromNewStorage() {
        let clientId = "client1"

        let legacyStorage = MockLegacyKeychainSessionStorage()
        let newStorage = MockKeychainSessionStorage(service: "test")
        stub(newStorage) { mock in
            when(mock.remove(forClientId: equal(to: clientId))).thenDoNothing()
        }

        let migratingStorage = MigratingKeychainCompatStorage(from: legacyStorage, to: newStorage,
                                                              legacyClient: Client(configuration: Fixtures.clientConfig),
                                                              legacyClientSecret: "",
                                                              makeTokenRequest: { _, _, _ in  })
        migratingStorage.remove(forClientId: clientId)

        verify(newStorage).remove(forClientId: equal(to: clientId))
        verifyNoMoreInteractions(legacyStorage)
    }

    func testGetPrefersNewStorage() {
        let clientId = "client1"
        let userSession = UserSession(clientId: clientId, userTokens: Fixtures.userTokens, updatedAt: Date())

        let legacyStorage = MockLegacyKeychainSessionStorage()
        let newStorage = MockKeychainSessionStorage(service: "test")
        
        stub(newStorage) { mock in
            when(mock.get(forClientId: clientId, completion: anyClosure()))
                .then{ clientId, completion in
                    completion(userSession)
                }
        }
        
        let migratingStorage = MigratingKeychainCompatStorage(from: legacyStorage, to: newStorage,
                                                              legacyClient: Client(configuration: Fixtures.clientConfig),
                                                              legacyClientSecret: "",
                                                              makeTokenRequest: { _, _, _ in  })
        
        migratingStorage.get(forClientId: clientId) { retrievedUserSession in
            XCTAssertEqual(retrievedUserSession, userSession)
        }

        verify(newStorage).get(forClientId: clientId, completion: anyClosure())
        verifyNoMoreInteractions(legacyStorage)
    }

    func testGetMigratesExistingLegacySession() {
        let clientId = "client1"
        let legacyUserSession = UserSession(clientId: clientId, userTokens: Fixtures.userTokens, updatedAt: Date())

        let legacyStorage = MockLegacyKeychainSessionStorage()
        stub(legacyStorage) { mock in
            when(mock.get(forClientId: equal(to: clientId))).thenReturn(legacyUserSession)
            when(mock.remove()).thenDoNothing()
        }
        let newStorage = MockKeychainSessionStorage(service: "test")
        stub(newStorage) { mock in
            when(mock.get(forClientId: equal(to: clientId), completion: anyClosure()))
                .then{ _, completion in
                    completion(nil)
                }
            when(mock.store(equal(to: legacyUserSession), completion: anyClosure())).thenDoNothing()
        }

        let migratingStorage = MigratingKeychainCompatStorage(from: legacyStorage, to: newStorage,
                                                              legacyClient: Client(configuration: Fixtures.clientConfig),
                                                              legacyClientSecret: "",
                                                              makeTokenRequest: { _, _, _ in  })
        
        migratingStorage.get(forClientId: clientId) { retrievedUserSession in
            XCTAssertEqual(retrievedUserSession, nil)
        }
        
        // TODO: Fixup on untangling User and Client
//        verify(newStorage).get(forClientId: equal(to: clientId), completion: anyClosure())
//        verify(legacyStorage).get(forClientId: equal(to: clientId))
//        verify(newStorage).store(equal(to: legacyUserSession))
//        verify(legacyStorage).remove()
    }

    func testGetReturnsNilIfNoSessionExists() {
        let clientId = "client1"

        let legacyStorage = MockLegacyKeychainSessionStorage()
        stub(legacyStorage) { mock in
            when(mock.get(forClientId: equal(to: clientId))).thenReturn(nil)
        }
        let newStorage = MockKeychainSessionStorage(service: "test")
        stub(newStorage) { mock in
            when(mock.get(forClientId: clientId, completion: anyClosure()))
                .then{ _, completion in completion(nil) }
        }

        let migratingStorage = MigratingKeychainCompatStorage(from: legacyStorage, to: newStorage,
                                                              legacyClient: Client(configuration: Fixtures.clientConfig),
                                                              legacyClientSecret: "",
                                                              makeTokenRequest: { _, _, _ in  })
        
        migratingStorage.get(forClientId: clientId) { retrievedUserSession in
            XCTAssertNil(retrievedUserSession)
        }
        
        verify(newStorage).get(forClientId: equal(to: clientId), completion: anyClosure())
        verify(legacyStorage).get(forClientId: clientId)
    }
}

final class OldSDKClientTests: XCTestCase {
    
    func testOneTimeCodeWithRefreshOnCodeExchangeFailure401() throws {
        let expectedCode = "A code string"
        let expectedResponse = SchibstedAccountAPIResponse(data: CodeExchangeResponse(code: expectedCode))
        let mockHTTPClient = MockHTTPClient()
        stub(mockHTTPClient) {mock in
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: anyClosure()))
                .then { _, _, completion in
                    completion(.success(expectedResponse))
                }
        }
        
        let expectedTokenRefreshResponse = TokenResponse(access_token: Fixtures.userTokens.accessToken,
                                             refresh_token: nil,
                                             id_token: nil,
                                             scope: nil,
                                             expires_in: 1337)
        let mockApi = MockSchibstedAccountAPI(baseURL: Fixtures.clientConfig.serverURL, sessionServiceURL: Fixtures.clientConfig.sessionServiceURL)
        var codeExchangeCallCount = 0
        stub(mockApi) { mock in
            when(mock.oldSDKCodeExchange(with: any(), clientId: any(), oldSDKAccessToken: any(), completion: anyClosure()))
                .then{ _, _, _, completion in
                    codeExchangeCallCount += 1
                    completion(.failure(HTTPError.errorResponse(code: 401, body: nil)))
                }
            when(mock.oldSDKRefresh(with: any(), refreshToken: any(), clientId: any(), clientSecret: any(), completion: anyClosure()))
                .then { _, _, _, _, completion in
                    completion(.success(expectedTokenRefreshResponse))
                }
        }
        
        
        let sut = OldSDKClient(clientId: "", clientSecret: "", api: mockApi, legacyTokens: Fixtures.userTokens, httpClient: mockHTTPClient)
        Await.until { done in
            sut.oneTimeCodeWithOldSDKRefresh(newSDKClientId: "") { result in
                switch result {
                case .failure(.errorResponse(let errorCode, _)):
                    XCTAssertEqual(codeExchangeCallCount, 2, "Code Exchange should only be called 2 times on 401 failure.")
                    XCTAssertEqual(401, errorCode)
                default:
                    XCTFail("Unexpected result \(result)")
                }
                
                done()
            }
        }
    }
    
    func testOneTimeCodeWithRefreshOnCodeExchangeSuccess() throws {
        let expectedCode = "A code string"
        let expectedResponse = SchibstedAccountAPIResponse(data: CodeExchangeResponse(code: expectedCode))
        let mockHTTPClient = MockHTTPClient()
        stub(mockHTTPClient) {mock in
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: anyClosure()))
                .then { _, _, completion in
                    completion(.success(expectedResponse))
                }
        }
        
        let expectedTokenRefreshResponse = TokenResponse(access_token: Fixtures.userTokens.accessToken,
                                             refresh_token: nil,
                                             id_token: nil,
                                             scope: nil,
                                             expires_in: 1337)
        let mockApi = MockSchibstedAccountAPI(baseURL: Fixtures.clientConfig.serverURL, sessionServiceURL: Fixtures.clientConfig.sessionServiceURL)
        var codeExchangeCallCount = 0
        stub(mockApi) { mock in
            when(mock.oldSDKCodeExchange(with: any(), clientId: any(), oldSDKAccessToken: any(), completion: anyClosure()))
                .then{ _, _, _, completion in
                    codeExchangeCallCount += 1
                    completion(.success(expectedResponse))
                }
            when(mock.oldSDKRefresh(with: any(), refreshToken: any(), clientId: any(), clientSecret: any(), completion: anyClosure()))
                .then { _, _, _, _, completion in
                    completion(.success(expectedTokenRefreshResponse))
                }
        }
        
        
        let sut = OldSDKClient(clientId: "", clientSecret: "", api: mockApi, legacyTokens: Fixtures.userTokens, httpClient: mockHTTPClient)
        Await.until { done in
            sut.oneTimeCodeWithOldSDKRefresh(newSDKClientId: "") { result in
                switch result {
                case .success(let code):
                    XCTAssertEqual(codeExchangeCallCount, 1, "Code Exchange should only be called once.")
                    XCTAssertEqual(expectedCode, code)
                default:
                    XCTFail("Unexpected result \(result)")
                }
                
                done()
            }
        }
    }
    
    func testOLDSDKRefresh() throws {
        let expectedResponse = TokenResponse(access_token: Fixtures.userTokens.accessToken,
                                             refresh_token: nil,
                                             id_token: nil,
                                             scope: nil,
                                             expires_in: 1337)
        
        let mockHTTPClient = MockHTTPClient()
        stub(mockHTTPClient) {mock in
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: anyClosure()))
                .then { _, _, completion in
                    completion(.success(expectedResponse))
                }
        }
        
        let api = Fixtures.schibstedAccountAPI
        let sut = OldSDKClient(clientId: "", clientSecret: "", api: api, legacyTokens: Fixtures.userTokens, httpClient: mockHTTPClient)
        
        Await.until { done in
            sut.oldSDKRefresh(refreshToken: "") { result in
                switch result {
                case .success(let refreshedToken):
                    XCTAssertEqual(refreshedToken, Fixtures.userTokens.accessToken)
                default:
                    XCTFail("Unexpected result \(result)")
                }
                done()
            }
        }
    }
    
    func testOneTimeCode() throws {
        let expectedCode = "A code string"
        let expectedResponse = SchibstedAccountAPIResponse(data: CodeExchangeResponse(code: expectedCode))

        let mockHTTPClient = MockHTTPClient()
        stub(mockHTTPClient) {mock in
            when(mock.execute(request: any(), withRetryPolicy: any(), completion: anyClosure()))
                .then { _, _, completion in
                    completion(.success(expectedResponse))
                }
        }
        
        let api = Fixtures.schibstedAccountAPI
        let sut = OldSDKClient(clientId: "", clientSecret: "", api: api, legacyTokens: Fixtures.userTokens, httpClient: mockHTTPClient)
        
        Await.until { done in
            sut.oneTimeCode(newSDKClientId: "", oldSDKAccessToken: "") { result in
                switch result {
                case .success(let code):
                    XCTAssertEqual(code, expectedCode)
                default:
                    XCTFail("Unexpected result \(result)")
                }
                done()
            }
        }
    }
}

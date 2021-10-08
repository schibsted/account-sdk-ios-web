import Foundation

class MigratingKeychainCompatStorage: SessionStorage {
    private let newStorage: KeychainSessionStorage
    private let legacyStorage: LegacyKeychainSessionStorage
    private let legacyClient: Client
    private let legacyClientSecret: String
    private let makeTokenRequest: (_ authCode: String, _ authState: AuthState?, _ completion:  @escaping (Result<TokenResult, TokenError>) -> Void) -> Void
    private var oldSDKClient: OldSDKClient?
    
    init(from: LegacyKeychainSessionStorage,
         to: KeychainSessionStorage,
         legacyClient: Client,
         legacyClientSecret: String,
         makeTokenRequest: @escaping (_ authCode: String, _ authState: AuthState?, _ completion:  @escaping (Result<TokenResult, TokenError>) -> Void) -> Void)
    {
        self.newStorage = to
        self.legacyStorage = from
        self.legacyClient = legacyClient
        self.legacyClientSecret = legacyClientSecret
        self.makeTokenRequest = makeTokenRequest
    }
    
    func store(_ value: UserSession, completion: @escaping (Result<Void, Error>) -> Void) {
        // only delegate to new storage; no need to store in legacy storage
        newStorage.store(value, completion: completion)
            
    }
    
    func get(forClientId: String, completion: @escaping (UserSession?) -> Void ) {
        // try new storage first
        newStorage.get(forClientId: forClientId) { session in
            if let session = session {
                completion(session)
                return
            }
            
            // if no existing session found, look in legacy storage with
            guard let legacySession = self.legacyStorage.get(forClientId: self.legacyClient.configuration.clientId) else {
                completion(nil)
                return
            }

            self.migrateLegacyUserSession(forClientId: forClientId, legacySession: legacySession, completion: completion)
        }
    }
    
    private func migrateLegacyUserSession(forClientId: String, legacySession: UserSession, completion: @escaping (UserSession?) -> Void) {
        
        self.oldSDKClient = OldSDKClient(clientId: legacyClient.configuration.clientId, clientSecret: self.legacyClientSecret, api: legacyClient.schibstedAccountAPI, legacyTokens: legacySession.userTokens)
        oldSDKClient?.oneTimeCodeWithOldSDKRefresh(newSDKClientId: forClientId) { result in
            switch result {
            case .success(let code):
                self.makeTokenRequest(code, nil) { result in
                    switch result {
                    case .success(let tokenResult):
                        let newUserSession = UserSession(clientId: forClientId, userTokens: tokenResult.userTokens, updatedAt: Date())
                        self.newStorage.store(newUserSession) { output in
                            switch output {
                            case .success():
                                self.legacyStorage.remove()
                                completion(newUserSession)
                            case .failure(let error):
                                SchibstedAccountLogger.instance.error("\(error.localizedDescription)")
                                completion(nil)
                            }
                        }
                    case .failure(let error):
                        SchibstedAccountLogger.instance.info("Token error response: \(error.localizedDescription)")
                        completion(nil)
                    }
                }
            case .failure(let error):
                SchibstedAccountLogger.instance.info("Failed to migrate tokens. With error: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    func getAll() -> [UserSession] {
        // only delegate to new storage; this functionality is not supported by legacyStorage
        return newStorage.getAll()
    }
    
    func remove(forClientId: String) {
        // only delegate to new storage; data should have already been removed from legacy storage during migration
        newStorage.remove(forClientId: forClientId)
    }
}

///  OldSDKClient is responsible for exchanging Old SDK Token to an Authorization code.
class OldSDKClient {
    let clientId: String
    let clientSecret: String
    let api: SchibstedAccountAPI
    let legacyTokens: UserTokens
    var httpClient: HTTPClient
    
    init(clientId: String, clientSecret: String, api: SchibstedAccountAPI, legacyTokens: UserTokens, httpClient: HTTPClient) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.api = api
        self.legacyTokens = legacyTokens
        self.httpClient = httpClient
        
    }
    
    convenience init(clientId: String, clientSecret: String, api: SchibstedAccountAPI, legacyTokens: UserTokens) {
        let httpClient = HTTPClientWithURLSession()
        self.init(clientId: clientId, clientSecret: clientSecret, api: api, legacyTokens: legacyTokens, httpClient: httpClient)
    }
    
    func oneTimeCodeWithOldSDKRefresh(newSDKClientId: String, completion: @escaping HTTPResultHandler<String>) {
        api.oldSDKCodeExchange(with: httpClient, clientId: newSDKClientId, oldSDKAccessToken: legacyTokens.accessToken) { (requestResult: Result<SchibstedAccountAPIResponse<CodeExchangeResponse>, HTTPError>) in
            switch requestResult {
            case .failure(.errorResponse(let code, let body)):
                // 401 might indicate expired access token
                if code == 401 , let refreshToken = self.legacyTokens.refreshToken {
                    self.oldSDKRefresh(refreshToken: refreshToken) { result in
                        switch result {
                        case .success(let newToken): // retry the request with fresh tokens
                            self.oneTimeCode(newSDKClientId: newSDKClientId, oldSDKAccessToken: newToken, completion: completion)
                        case .failure(let error):
                            SchibstedAccountLogger.instance.info("Failed to refresh legacy tokens: \(error)")
                            completion(.failure(.unexpectedError(underlying: error)))
                        }
                    }
                } else {
                    let error = HTTPError.errorResponse(code: code, body: body)
                    SchibstedAccountLogger.instance.info("Failed legacy code exchange: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                SchibstedAccountLogger.instance.info("Failed legacy code exchange: \(error)")
                completion(.failure(error))
            case .success( let response):
                let code = response.data.code
                completion(.success(code))
            }
        }
    }
    
    func oldSDKRefresh(refreshToken: String, completion: @escaping (Result<String, Error>)-> Void) {
        
        let resultHandler: HTTPResultHandler<TokenResponse> = { result in
            switch result {
            case .success(let tokenResponse):
                completion(.success(tokenResponse.access_token))
            case .failure(let error):
                SchibstedAccountLogger.instance.info("Failed to migrate tokens. With error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        
        api.oldSDKRefresh(with: httpClient, refreshToken: refreshToken, clientId: clientId, clientSecret: clientSecret, completion: resultHandler)
    }
    
    func oneTimeCode(newSDKClientId: String, oldSDKAccessToken: String,  completion: @escaping HTTPResultHandler<String>) {
        self.api.oldSDKCodeExchange(with: self.httpClient, clientId: newSDKClientId, oldSDKAccessToken: oldSDKAccessToken) { (requestResult: Result<SchibstedAccountAPIResponse<CodeExchangeResponse>, HTTPError>) in
            switch requestResult {
            case .failure( let error):
                SchibstedAccountLogger.instance.info("Failed legacy code exchange with refreshed token: \(error)")
                completion(.failure(error))
            case .success( let response):
                let code = response.data.code
                completion(.success(code))
            }
        }
    }
}

import UIKit

public final class SimplifiedLoginManager {
    public enum SimplifiedLoginError: Error {
        case noLoggedInSessionInSharedKeychain
    }
    
    var keychainSessionStorage: KeychainSessionStorage?
    let client: Client
    var user: User?
    
    // Properties for building SimplifiedLoginViewController
    let env: ClientConfiguration.Environment
    let withMFA: MFAType?
    let loginHint: String?
    let extraScopeValues: Set<String>
    let completion: LoginResultHandler
    var withSSO: Bool = true
    
    @available(iOS, obsoleted: 13, message: "This function should not be used in iOS version 13 and above")
    public init(accessGroup: String,
                client: Client,
                env: ClientConfiguration.Environment, // TODO: Currently used to decide language.
                withMFA: MFAType? = nil,
                loginHint: String? = nil,
                extraScopeValues: Set<String> = [],
                completion: @escaping LoginResultHandler) {
        self.keychainSessionStorage = KeychainSessionStorage(service: Client.keychainServiceName, accessGroup: accessGroup)
        self.client = client
        
        self.env = env
        self.withMFA = withMFA
        self.loginHint = loginHint
        self.extraScopeValues = extraScopeValues
        self.completion = completion
    }
    
    @available(iOS 13.0, *)
    public init(accessGroup: String,
                client: Client,
                env: ClientConfiguration.Environment, // TODO: Currently used to decide language.
                withMFA: MFAType? = nil,
                loginHint: String? = nil,
                extraScopeValues: Set<String> = [],
                withSSO: Bool = true,
                completion: @escaping LoginResultHandler) {
        self.keychainSessionStorage = KeychainSessionStorage(service: Client.keychainServiceName, accessGroup: accessGroup)
        self.client = client
        
        self.env = env
        self.withMFA = withMFA
        self.loginHint = loginHint
        self.extraScopeValues = extraScopeValues
        self.completion = completion
        self.withSSO = withSSO
    }
    
    // MARK: -
    
    // TODO: THIS IS JUST FOR TESTING.
    public func storeRealUser(user:User, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let tokens = user.tokens else {
            completion(.failure(NSError(domain: "UserTokens is nil", code: 1, userInfo: [:])))
            return
        }
        let sessionToStore = UserSession(clientId: user.client.configuration.clientId, userTokens: tokens, updatedAt: Date())
        keychainSessionStorage?.store(sessionToStore, completion: completion)
    }
    
    // TODO: THIS IS JUST FOR TESTING.
    public func storeInSharedKeychain(clientId: String, aStringValue: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let idTokenClaims = IdTokenClaims(iss: "sas", sub: "userUuid", userId: "12345", aud: ["client1"], exp: Date().timeIntervalSince1970 + 3600, nonce: "testNonce", amr: nil)
        
        let userTokens = UserTokens(accessToken: aStringValue , refreshToken: aStringValue, idToken: aStringValue, idTokenClaims: idTokenClaims)
        let sessionToStore = UserSession(clientId: clientId, userTokens: userTokens, updatedAt: Date())
        keychainSessionStorage?.store(sessionToStore, completion: completion)
    }
    
    public func getSimplifiedLogin(completion: @escaping (Result<UIViewController, Error>) -> Void) throws {
        let latestUserSession = self.keychainSessionStorage?.getAll()
            .sorted { $0.updatedAt > $1.updatedAt }
            .first
        
        guard let sLatestUserSession = latestUserSession else {
            throw SimplifiedLoginError.noLoggedInSessionInSharedKeychain
        }
        
        let user = User(client: client, tokens: sLatestUserSession.userTokens)
        self.user = user
        
        user.userContextFromToken { result in
            switch result {
            case .success(let userContextResponse):
                self.fetchProfile(user: user, userContext: userContextResponse, completion: completion)
            case .failure(let error):
                print("Some error happened \(error)")
                completion(.failure(error))
            }
        }
    }
    
    private func fetchProfile(user: User, userContext: UserContextFromTokenResponse, completion: @escaping (Result<UIViewController, Error>) -> Void) {
        
        user.fetchProfileData { result in
            switch result {
            case .success(_): // TODO: profileResponse and userContext need to be passed to factory when building SimplifiedLogin ViewController
                DispatchQueue.main.async {
                    let simplifiedLoginViewController: UIViewController
                    if #available(iOS 13.0, *) {
                        simplifiedLoginViewController = SimplifiedLoginUIFactory.buildViewController(client: self.client,
                                                                                                     env: self.env,
                                                                                                     withMFA: self.withMFA,
                                                                                                     loginHint: self.loginHint,
                                                                                                     extraScopeValues: self.extraScopeValues,
                                                                                                     withSSO: self.withSSO,
                                                                                                     completion: self.completion)
                    } else {
                        simplifiedLoginViewController = SimplifiedLoginUIFactory.buildViewController(client: self.client,
                                                                                                     env: self.env,
                                                                                                     withMFA: self.withMFA,
                                                                                                     loginHint: self.loginHint,
                                                                                                     extraScopeValues: self.extraScopeValues,
                                                                                                     completion: self.completion)
                    }
                    
                    completion(.success(simplifiedLoginViewController))
                }
            case .failure(let error):
                print("Some error happened \(error)")
                completion(.failure(error))
            }
        }
    }
}

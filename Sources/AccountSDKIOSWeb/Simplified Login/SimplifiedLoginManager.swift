import UIKit
import AuthenticationServices

public final class SimplifiedLoginManager {
    public enum SimplifiedLoginError: Error {
        case noLoggedInSessionInSharedKeychain
        case noClientNameFound
    }
    
    private let isPad: Bool = UIDevice.current.userInterfaceIdiom == .pad
    
    var keychainSessionStorage: SessionStorage?
    let client: Client
    var fetcher: SimplifiedLoginFetching?
    
    // Properties for building SimplifiedLoginViewController
    let withMFA: MFAType?
    let loginHint: String?
    let extraScopeValues: Set<String>
    let completion: LoginResultHandler
    var withSSO: Bool = true
    
    private var _contextProvider: Any? = nil
    @available(iOS 13.0, *)
    fileprivate var context: ASWebAuthenticationPresentationContextProviding {
        if _contextProvider == nil {
            _contextProvider = ASWebAuthSessionContextProvider()
        }
        return _contextProvider as! ASWebAuthSessionContextProvider
    }
    
    @available(iOS, obsoleted: 13, message: "This function should not be used in iOS version 13 and above")
    public init(accessGroup: String,
                client: Client,
                withMFA: MFAType? = nil,
                loginHint: String? = nil,
                extraScopeValues: Set<String> = [],
                completion: @escaping LoginResultHandler) {
        self.keychainSessionStorage = KeychainSessionStorage(service: Client.keychainServiceName, accessGroup: accessGroup)
        self.client = client
        
        self.withMFA = withMFA
        self.loginHint = loginHint
        self.extraScopeValues = extraScopeValues
        self.completion = completion
    }
    
    @available(iOS 13.0, *)
    public init(accessGroup: String,
                client: Client,
                contextProvider: ASWebAuthenticationPresentationContextProviding,
                env: ClientConfiguration.Environment, // TODO: Currently used to decide language.
                withMFA: MFAType? = nil,
                loginHint: String? = nil,
                extraScopeValues: Set<String> = [],
                withSSO: Bool = true,
                completion: @escaping LoginResultHandler) {
        self.keychainSessionStorage = KeychainSessionStorage(service: Client.keychainServiceName, accessGroup: accessGroup)
        self.client = client
        
        self.withMFA = withMFA
        self.loginHint = loginHint
        self.extraScopeValues = extraScopeValues
        self.completion = completion
        self.withSSO = withSSO
        self._contextProvider = contextProvider

    }
}

extension SimplifiedLoginManager {
    /**
     Prepere and configure Simplified Login View Controller which should be shown modaly

     - parameter clientName: optional client name visible in footer view of Simplified Login. If not provided CFBundleDisplayName is used by default
     - parameter completion: callback that receives the UIViewController for Simplified Login or an error in case of failure
     */
    public func getSimplifiedLogin(_ clientName: String? = nil, completion: @escaping (Result<UIViewController, Error>) -> Void) {
        guard let latestUserSession = self.keychainSessionStorage?.getLatestSession() else {
            completion(.failure(SimplifiedLoginError.noLoggedInSessionInSharedKeychain))
            return
        }
        guard let clientName = (clientName != nil) ? clientName! : Bundle.applicationName() else {
            SchibstedAccountLogger.instance.error("Please configure application display name or pass visibleClientName parameter")
            completion(.failure(SimplifiedLoginError.noClientNameFound))
            return
        }
        
        let user = User(client: client, tokens: latestUserSession.userTokens)
        let fetcher = SimplifiedLoginFetcher(user: user)
        self.fetcher = fetcher
        
        self.fetcher?.fetchData() { result in
            switch result {
            case .success(let fetchedData):
                DispatchQueue.main.async {
                    let simplifiedLoginViewController = self.makeViewController(clientName, assertionFetcher: fetcher, simplifiedLoginData: fetchedData)
                    completion(.success(simplifiedLoginViewController))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func makeViewController(_ clientName: String, assertionFetcher: SimplifiedLoginFetching, simplifiedLoginData: SimplifiedLoginFetchedData) -> UIViewController {
        let simplifiedLoginViewController: UIViewController
        if #available(iOS 13.0, *) {
            simplifiedLoginViewController = SimplifiedLoginUIFactory.buildViewController(client: self.client,
                                                                                         contextProvider: self.context,
                                                                                         assertionFetcher: assertionFetcher,
                                                                                         userContext: simplifiedLoginData.context,
                                                                                         userProfileResponse: simplifiedLoginData.profile,
                                                                                         clientName: clientName,
                                                                                         withMFA: self.withMFA,
                                                                                         loginHint: self.loginHint,
                                                                                         extraScopeValues: self.extraScopeValues,
                                                                                         withSSO: self.withSSO,
                                                                                         completion: self.completion)
        } else {
            simplifiedLoginViewController = SimplifiedLoginUIFactory.buildViewController(client: self.client,
                                                                                         assertionFetcher: assertionFetcher,
                                                                                         userContext: simplifiedLoginData.context,
                                                                                         userProfileResponse: simplifiedLoginData.profile,
                                                                                         clientName: clientName,
                                                                                         withMFA: self.withMFA,
                                                                                         loginHint: self.loginHint,
                                                                                         extraScopeValues: self.extraScopeValues,
                                                                                         completion: self.completion)
        }
        if self.isPad {
            simplifiedLoginViewController.modalPresentationStyle = .formSheet
            simplifiedLoginViewController.preferredContentSize = .init(width: 450, height: 424)
        }
        
        return simplifiedLoginViewController
    }
}

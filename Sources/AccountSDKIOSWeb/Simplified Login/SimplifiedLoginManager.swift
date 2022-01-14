import UIKit
import AuthenticationServices

public final class SimplifiedLoginManager {
    public enum SimplifiedLoginError: Error {
        case noLoggedInSessionInSharedKeychain
        case noClientNameFound
        case noVisibleViewControllerFound
    }
    
    static let isPad: Bool = UIDevice.current.userInterfaceIdiom == .pad
    
    let client: Client
    var fetcher: SimplifiedLoginFetching
    
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
    convenience public init(client: Client,
                withMFA: MFAType? = nil,
                loginHint: String? = nil,
                extraScopeValues: Set<String> = [],
                completion: @escaping LoginResultHandler) {
        
        let fetcher = SimplifiedLoginFetcher(client: client)
        self.init(client: client, withMFA: withMFA, loginHint: loginHint, extraScopeValues: extraScopeValues, completion: completion, fetcher: fetcher)
    }
    
    @available(iOS, obsoleted: 13, message: "This function should not be used in iOS version 13 and above")
    init(client: Client,
                     withMFA: MFAType? = nil,
                     loginHint: String? = nil,
                     extraScopeValues: Set<String> = [],
                     completion: @escaping LoginResultHandler,
                     fetcher: SimplifiedLoginFetching) {
        self.client = client
        self.withMFA = withMFA
        self.loginHint = loginHint
        self.extraScopeValues = extraScopeValues
        self.completion = completion
        self.fetcher = SimplifiedLoginFetcher(client: client)
    }
    
    @available(iOS 13.0, *)
    convenience public init(client: Client,
                contextProvider: ASWebAuthenticationPresentationContextProviding,
                env: ClientConfiguration.Environment, // TODO: Currently used to decide language.
                withMFA: MFAType? = nil,
                loginHint: String? = nil,
                extraScopeValues: Set<String> = [],
                withSSO: Bool = true,
                completion: @escaping LoginResultHandler) {
        let fetcher = SimplifiedLoginFetcher(client: client)
        self.init(client: client, contextProvider: contextProvider, env: env, withMFA: withMFA, loginHint: loginHint, extraScopeValues: extraScopeValues, withSSO: withSSO, completion: completion, fetcher: fetcher)
    }
    
    @available(iOS 13.0, *)
    init(client: Client,
                contextProvider: ASWebAuthenticationPresentationContextProviding,
                env: ClientConfiguration.Environment, // TODO: Currently used to decide language.
                withMFA: MFAType? = nil,
                loginHint: String? = nil,
                extraScopeValues: Set<String> = [],
                withSSO: Bool = true,
                completion: @escaping LoginResultHandler,
                fetcher: SimplifiedLoginFetching) {
        self.client = client
        self.withMFA = withMFA
        self.loginHint = loginHint
        self.extraScopeValues = extraScopeValues
        self.completion = completion
        self.withSSO = withSSO
        self._contextProvider = contextProvider
        self.fetcher = fetcher
    }
}

extension SimplifiedLoginManager {
    
    /**
     Prepare and configure Simplified Login View Controller which should be shown modally

     - parameter clientName: optional client name visible in footer view of Simplified Login. If not provided CFBundleDisplayName is used by default
     - parameter completion: callback that receives the UIViewController for Simplified Login or an error in case of failure
     */
    public func requestSimplifiedLogin(_ clientName: String? = nil, window: UIWindow? = nil, completion: @escaping (Result<Void, Error>) -> Void) {
       
        guard let clientName = (clientName != nil) ? clientName! : Bundle.applicationName() else {
            SchibstedAccountLogger.instance.error("Please configure application display name or pass visibleClientName parameter")
            completion(.failure(SimplifiedLoginError.noClientNameFound))
            return
        }
        
        self.fetcher.fetchData() { result in
            switch result {
            case .success(let fetchedData):
                DispatchQueue.main.async {
                    let keyWindow = (window != nil) ? window : KeyWindow.get()
                    let simplifiedLoginViewController = self.makeViewController(clientName, window: keyWindow, simplifiedLoginData: fetchedData)

                    if let visibleVC = keyWindow?.visibleViewController {
                        visibleVC.present(simplifiedLoginViewController, animated: true, completion: nil)
                        completion(.success())
                        return
                    }
                    completion(.failure(SimplifiedLoginError.noVisibleViewControllerFound))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func makeViewController(_ clientName: String, window: UIWindow? = nil, simplifiedLoginData: SimplifiedLoginFetchedData) -> UIViewController {
        let simplifiedLoginViewController: UIViewController
        if #available(iOS 13.0, *) {
            simplifiedLoginViewController = SimplifiedLoginUIFactory.buildViewController(client: self.client,
                                                                                         contextProvider: self.context,
                                                                                         assertionFetcher: self.fetcher,
                                                                                         userContext: simplifiedLoginData.context,
                                                                                         userProfileResponse: simplifiedLoginData.profile,
                                                                                         clientName: clientName,
                                                                                         window: window,
                                                                                         withMFA: self.withMFA,
                                                                                         loginHint: self.loginHint,
                                                                                         extraScopeValues: self.extraScopeValues,
                                                                                         withSSO: self.withSSO,
                                                                                         completion: self.completion)
        } else {
            simplifiedLoginViewController = SimplifiedLoginUIFactory.buildViewController(client: self.client,
                                                                                         assertionFetcher: self.fetcher,
                                                                                         userContext: simplifiedLoginData.context,
                                                                                         userProfileResponse: simplifiedLoginData.profile,
                                                                                         clientName: clientName,
                                                                                         window: window,
                                                                                         withMFA: self.withMFA,
                                                                                         loginHint: self.loginHint,
                                                                                         extraScopeValues: self.extraScopeValues,
                                                                                         completion: self.completion)
        }
        if Self.isPad {
            simplifiedLoginViewController.modalPresentationStyle = .formSheet
            simplifiedLoginViewController.preferredContentSize = .init(width: 450, height: 424)
        }
        
        return simplifiedLoginViewController
    }
}

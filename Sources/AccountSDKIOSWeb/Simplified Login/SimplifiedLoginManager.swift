import UIKit
import AuthenticationServices

public final class SimplifiedLoginManager {
    public enum SimplifiedLoginError: Error {
        case noLoggedInSessionInSharedKeychain
        case noClientNameFound
        case noVisibleViewControllerFound
    }

    let client: Client
    var fetcher: SimplifiedLoginFetching

    // Properties for building SimplifiedLoginViewController
    let withMFA: MFAType?
    let loginHint: String?
    let extraScopeValues: Set<String>
    let completion: LoginResultHandler
    var withSSO: Bool = true

    private var _contextProvider: Any?
    @available(iOS 13.0, *)
    fileprivate var context: ASWebAuthenticationPresentationContextProviding {
        if _contextProvider == nil {
            _contextProvider = ASWebAuthSessionContextProvider()
        }
        // swiftlint:disable force_cast
        return _contextProvider as! ASWebAuthSessionContextProvider
    }

    @available(iOS, deprecated: 13, message: "This function should not be used in iOS version 13 and above")
    convenience public init(client: Client,
                            withMFA: MFAType? = nil,
                            loginHint: String? = nil,
                            extraScopeValues: Set<String> = [],
                            completion: @escaping LoginResultHandler) {

        let fetcher = SimplifiedLoginFetcher(client: client)
        self.init(client: client,
                  withMFA: withMFA,
                  loginHint: loginHint,
                  extraScopeValues: extraScopeValues,
                  fetcher: fetcher,
                  completion: completion)
    }

    @available(iOS, deprecated: 13, message: "This function should not be used in iOS version 13 and above")
    init(client: Client,
         withMFA: MFAType? = nil,
         loginHint: String? = nil,
         extraScopeValues: Set<String> = [],
         fetcher: SimplifiedLoginFetching,
         completion: @escaping LoginResultHandler) {
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
        self.init(client: client,
                  contextProvider: contextProvider,
                  env: env,
                  withMFA: withMFA,
                  loginHint: loginHint,
                  extraScopeValues: extraScopeValues,
                  withSSO: withSSO,
                  fetcher: fetcher,
                  completion: completion)
    }

    @available(iOS 13.0, *)
    init(client: Client,
         contextProvider: ASWebAuthenticationPresentationContextProviding,
         env: ClientConfiguration.Environment, // TODO: Currently used to decide language.
         withMFA: MFAType? = nil,
         loginHint: String? = nil,
         extraScopeValues: Set<String> = [],
         withSSO: Bool = true,
         fetcher: SimplifiedLoginFetching,
         completion: @escaping LoginResultHandler) {
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
     Prepares and presents the Simplified Login View Controller modally. If a shared user session is found in the shared keychain this function will present a viewcontroller and then retains that shared user until requestSimplifiedLogin(...) is called again
     
     - parameter clientName: optional client name visible in footer view of Simplified Login. If not provided CFBundleDisplayName is used by default
     - parameter uiVersion: there are three defined version of Simplified Login overlay (prepared for tests)
     - parameter window: window used to present SimplifiedLoginViewController
     - parameter completion: callback that receives the UIViewController for Simplified Login or an error in case of failure
     */
    public func requestSimplifiedLogin(_ clientName: String? = nil,
                                       uiVersion: SimplifiedLoginUIVersion = .minimal,
                                       window: UIWindow? = nil,
                                       completion: @escaping (Result<Void, Error>) -> Void) {

        guard let clientName = (clientName != nil) ? clientName! : Bundle.applicationName() else {
            SchibstedAccountLogger.instance
                .error("Please configure application display name or pass visibleClientName parameter")
            completion(.failure(SimplifiedLoginError.noClientNameFound))
            return
        }

        self.fetcher.fetchData { result in
            switch result {
            case .success(let fetchedData):
                DispatchQueue.main.async {
                    let keyWindow = (window != nil) ? window : KeyWindow.get()
                    let simplifiedLoginViewController =
                    self.makeViewController(clientName,
                                            uiVersion: uiVersion,
                                            window: keyWindow,
                                            simplifiedLoginData: fetchedData)

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

    func makeViewController(_ clientName: String,
                            uiVersion: SimplifiedLoginUIVersion = .minimal,
                            window: UIWindow? = nil,
                            simplifiedLoginData: SimplifiedLoginFetchedData) -> UIViewController {
        let viewController: UIViewController
        if #available(iOS 13.0, *) {
            viewController = SimplifiedLoginUIFactory
                .buildViewController(client: self.client,
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
                                     uiVersion: uiVersion,
                                     completion: self.completion)
        } else {
            viewController = SimplifiedLoginUIFactory
                .buildViewController(client: self.client,
                                     assertionFetcher: self.fetcher,
                                     userContext: simplifiedLoginData.context,
                                     userProfileResponse: simplifiedLoginData.profile,
                                     clientName: clientName,
                                     window: window,
                                     withMFA: self.withMFA,
                                     loginHint: self.loginHint,
                                     extraScopeValues: self.extraScopeValues,
                                     uiVersion: uiVersion,
                                     completion: self.completion)
        }

        return viewController
    }
}

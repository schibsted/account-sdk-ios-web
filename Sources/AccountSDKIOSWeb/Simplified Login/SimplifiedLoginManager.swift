//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

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
    let state: String?
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
        return _contextProvider as! ASWebAuthSessionContextProvider // swiftlint:disable:this force_cast
    }

    @available(iOS, deprecated: 13, message: "This function should not be used in iOS version 13 and above")
    convenience public init(client: Client,
                            withMFA: MFAType? = nil,
                            state: String?,
                            loginHint: String? = nil,
                            extraScopeValues: Set<String> = [],
                            completion: @escaping LoginResultHandler) {

        let fetcher = SimplifiedLoginFetcher(client: client)
        self.init(client: client,
                  withMFA: withMFA,
                  state: state,
                  loginHint: loginHint,
                  extraScopeValues: extraScopeValues,
                  fetcher: fetcher,
                  completion: completion)
    }

    @available(iOS, deprecated: 13, message: "This function should not be used in iOS version 13 and above")
    init(client: Client,
         withMFA: MFAType? = nil,
         state: String? = nil,
         loginHint: String? = nil,
         extraScopeValues: Set<String> = [],
         fetcher: SimplifiedLoginFetching,
         completion: @escaping LoginResultHandler) {
        self.client = client
        self.withMFA = withMFA
        self.state = state
        self.loginHint = loginHint
        self.extraScopeValues = extraScopeValues
        self.completion = completion
        self.fetcher = SimplifiedLoginFetcher(client: client)
    }

    @available(iOS 13.0, *)
    convenience public init(client: Client,
                            contextProvider: ASWebAuthenticationPresentationContextProviding,
                            withMFA: MFAType? = nil,
                            state: String? = nil,
                            loginHint: String? = nil,
                            extraScopeValues: Set<String> = [],
                            withSSO: Bool = true,
                            completion: @escaping LoginResultHandler) {
        let fetcher = SimplifiedLoginFetcher(client: client)
        self.init(client: client,
                  contextProvider: contextProvider,
                  withMFA: withMFA,
                  state: state,
                  loginHint: loginHint,
                  extraScopeValues: extraScopeValues,
                  withSSO: withSSO,
                  fetcher: fetcher,
                  completion: completion)
    }

    @available(iOS 13.0, *)
    init(client: Client,
         contextProvider: ASWebAuthenticationPresentationContextProviding,
         withMFA: MFAType? = nil,
         state: String? = nil,
         loginHint: String? = nil,
         extraScopeValues: Set<String> = [],
         withSSO: Bool = true,
         fetcher: SimplifiedLoginFetching,
         completion: @escaping LoginResultHandler) {
        self.client = client
        self.withMFA = withMFA
        self.state = state
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
     
     - parameter window: window used to present SimplifiedLoginViewController
     - parameter completion: callback that receives the UIViewController for Simplified Login or an error in case of failure
     */
    public func requestSimplifiedLogin(_ window: UIWindow? = nil,
                                       completion: @escaping (Result<Void, Error>) -> Void) {
        self.fetcher.fetchData { result in
            switch result {
            case .success(let fetchedData):
                DispatchQueue.main.async {
                    let keyWindow = (window != nil) ? window : KeyWindow.get()
                    let simplifiedLoginViewController =
                    self.makeViewController(keyWindow,
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

    func makeViewController(_ window: UIWindow? = nil,
                            simplifiedLoginData: SimplifiedLoginFetchedData) -> UIViewController {
        let viewController: UIViewController
        if #available(iOS 13.0, *) {
            viewController = SimplifiedLoginUIFactory
                .buildViewController(client: self.client,
                                     contextProvider: self.context,
                                     assertionFetcher: self.fetcher,
                                     userContext: simplifiedLoginData.context,
                                     userProfileResponse: simplifiedLoginData.profile,
                                     window: window,
                                     withMFA: self.withMFA,
                                     state: self.state,
                                     loginHint: self.loginHint,
                                     extraScopeValues: self.extraScopeValues,
                                     withSSO: self.withSSO,
                                     completion: self.completion)
        } else {
            viewController = SimplifiedLoginUIFactory
                .buildViewController(client: self.client,
                                     assertionFetcher: self.fetcher,
                                     userContext: simplifiedLoginData.context,
                                     userProfileResponse: simplifiedLoginData.profile,
                                     window: window,
                                     withMFA: self.withMFA,
                                     state: self.state,
                                     loginHint: self.loginHint,
                                     extraScopeValues: self.extraScopeValues,
                                     completion: self.completion)
        }

        return viewController
    }
}

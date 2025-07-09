//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import UIKit
import AuthenticationServices

@MainActor
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
    let xDomainId: UUID?
    let extraScopeValues: Set<String>
    let completion: LoginResultHandler
    var withSSO: Bool = true

    private var _contextProvider: Any?

    fileprivate var context: ASWebAuthenticationPresentationContextProviding {
        if _contextProvider == nil {
            _contextProvider = ASWebAuthSessionContextProvider()
        }
        return _contextProvider as! ASWebAuthSessionContextProvider // swiftlint:disable:this force_cast
    }

    convenience public init(
        client: Client,
        contextProvider: ASWebAuthenticationPresentationContextProviding,
        withMFA: MFAType? = nil,
        state: String? = nil,
        loginHint: String? = nil,
        xDomainId: UUID? = nil,
        extraScopeValues: Set<String> = [],
        withSSO: Bool = true,
        completion: @escaping LoginResultHandler
    ) {
        let fetcher = SimplifiedLoginFetcher(client: client)
        self.init(
            client: client,
            contextProvider: contextProvider,
            withMFA: withMFA,
            state: state,
            loginHint: loginHint,
            xDomainId: xDomainId,
            extraScopeValues: extraScopeValues,
            withSSO: withSSO,
            fetcher: fetcher,
            completion: completion
        )
    }

    init(
        client: Client,
        contextProvider: ASWebAuthenticationPresentationContextProviding,
        withMFA: MFAType? = nil,
        state: String? = nil,
        loginHint: String? = nil,
        xDomainId: UUID? = nil,
        extraScopeValues: Set<String> = [],
        withSSO: Bool = true,
        fetcher: SimplifiedLoginFetching,
        completion: @escaping LoginResultHandler
    ) {
        self.client = client
        self.withMFA = withMFA
        self.state = state
        self.loginHint = loginHint
        self.xDomainId = xDomainId
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

    func makeViewController(
        _ window: UIWindow? = nil,
        simplifiedLoginData: SimplifiedLoginFetchedData
    ) -> UIViewController {
        SimplifiedLoginUIFactory
            .buildViewController(
                client: self.client,
                contextProvider: self.context,
                assertionFetcher: self.fetcher,
                userContext: simplifiedLoginData.context,
                userProfileResponse: simplifiedLoginData.profile,
                window: window,
                withMFA: self.withMFA,
                state: self.state,
                loginHint: self.loginHint,
                xDomainId: self.xDomainId,
                extraScopeValues: self.extraScopeValues,
                withSSO: self.withSSO,
                completion: self.completion
            )
    }
}

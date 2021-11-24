import UIKit

struct SimplifiedLoginUIFactory {

    @available(iOS, obsoleted: 13, message: "This function should not be used in iOS version 13 and above")
    static func buildViewController(client: Client,
                                    withMFA: MFAType? = nil,
                                    loginHint: String? = nil,
                                    extraScopeValues: Set<String> = [],
                                    userContext: UserContextFromTokenResponse,
                                    profileResponse: UserProfileResponse,
                                    completion: @escaping LoginResultHandler) -> UIViewController {
        
        let viewModel = SimplifiedLoginViewModel(client: client, locale: profileResponse.locale)! // TODO: throw error
        viewModel.onClickedSwitchAccount = { // TODO: need to be tested with iOS 12
            viewModel.asWebAuthenticationSession = client.getLoginSession(withMFA: withMFA,
                                                                          loginHint: loginHint,
                                                                          extraScopeValues: extraScopeValues,
                                                                          completion: completion) //
            viewModel.asWebAuthenticationSession?.start()
        }
        
        return commonSetup(viewModel: viewModel)
    }
    
    @available(iOS 13.0, *)
    static func buildViewController(client: Client,
                                    withMFA: MFAType? = nil,
                                    loginHint: String? = nil,
                                    extraScopeValues: Set<String> = [],
                                    withSSO: Bool = true,
                                    userContext: UserContextFromTokenResponse,
                                    profileResponse: UserProfileResponse,
                                    completion: @escaping LoginResultHandler) -> UIViewController {
        
        let viewModel = SimplifiedLoginViewModel(client: client, locale: profileResponse.locale)! // TODO: throw error
        viewModel.onClickedSwitchAccount = {
            let context = ASWebAuthSessionContextProvider()
            viewModel.asWebAuthenticationSession = client.getLoginSession(contextProvider: context,
                                                                          withMFA: withMFA,
                                                                          loginHint: loginHint,
                                                                          extraScopeValues: extraScopeValues,
                                                                          withSSO: withSSO,
                                                                          completion: completion)
            viewModel.asWebAuthenticationSession?.start()
        }
        
        return commonSetup(viewModel: viewModel)
    }
    
    private static func commonSetup(viewModel: SimplifiedLoginViewModel) -> UIViewController {
        let s = SimplifiedLoginViewController(viewModel: viewModel )
        let nc = UINavigationController()
        nc.pushViewController(s, animated: false)
        
        let url = URL(string: viewModel.localisation.privacyPolicyURL)!
        let webVC = WebViewController()
        
        viewModel.onClickedContinueAsUser = {} // TODO:
        
        viewModel.onClickedContinueWithoutLogin = {
            nc.dismiss(animated: true, completion: nil)
        }
        
        viewModel.onClickedPrivacyPolicy = {
            webVC.loadURL(url)
            nc.pushViewController(webVC, animated: true)
        }
        
        return nc
    }
}

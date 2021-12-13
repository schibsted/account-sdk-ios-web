import UIKit

struct SimplifiedLoginUIFactory {

    @available(iOS, obsoleted: 13, message: "This function should not be used in iOS version 13 and above")
    static func buildViewController(client: Client,
                                    assertionFetcher: SimplifiedLoginFetching,
                                    userContext: UserContextFromTokenResponse,
                                    userProfileResponse: UserProfileResponse,
                                    clientName: String,
                                    withMFA: MFAType? = nil,
                                    loginHint: String? = nil,
                                    extraScopeValues: Set<String> = [],
                                    completion: @escaping LoginResultHandler) -> UIViewController {
        
        let imageDataModel = ConcreteSimplifiedLoginNamedImageData(env: client.configuration.env)
        let userDataModel = ConcreteSimplifiedLoginUserData(userContext: userContext, userProfileResponse: userProfileResponse)
        let localizationModel = SimplifiedLoginLocalizationModel()
        
        let viewModel = SimplifiedLoginViewModel(imageDataModel: imageDataModel, userDataModel: userDataModel, localizationModel: localizationModel, visibleClientName: clientName)
        
        viewModel.onClickedSwitchAccount = { // TODO: need to be tested with iOS 12
            viewModel.asWebAuthenticationSession = client.getLoginSession(withMFA: withMFA,
                                                                          loginHint: loginHint,
                                                                          extraScopeValues: extraScopeValues,
                                                                          completion: completion)
            viewModel.asWebAuthenticationSession?.start()
        }
        
        return commonSetup(completion: completion, client: client, assertionFetcher: assertionFetcher, viewModel: viewModel)
    }
    
    @available(iOS 13.0, *)
    static func buildViewController(client: Client,
                                    assertionFetcher: SimplifiedLoginFetching,
                                    userContext: UserContextFromTokenResponse,
                                    userProfileResponse: UserProfileResponse,
                                    clientName: String,
                                    withMFA: MFAType? = nil,
                                    loginHint: String? = nil,
                                    extraScopeValues: Set<String> = [],
                                    withSSO: Bool = true,
                                    completion: @escaping LoginResultHandler) -> UIViewController {
       
        let imageDataModel = ConcreteSimplifiedLoginNamedImageData(env: client.configuration.env)
        let userDataModel = ConcreteSimplifiedLoginUserData(userContext: userContext, userProfileResponse: userProfileResponse)
        let localizationModel = SimplifiedLoginLocalizationModel()
        let viewModel = SimplifiedLoginViewModel(imageDataModel: imageDataModel, userDataModel: userDataModel, localizationModel: localizationModel, visibleClientName: clientName)
        
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
        
        return commonSetup(completion: completion, client: client, assertionFetcher: assertionFetcher, viewModel: viewModel)
    }
    
    private static func commonSetup(completion: @escaping LoginResultHandler, client: Client, assertionFetcher: SimplifiedLoginFetching,  viewModel: SimplifiedLoginViewModel) -> UIViewController {
        let s = SimplifiedLoginViewController(viewModel: viewModel )
        let nc = UINavigationController()
        nc.pushViewController(s, animated: false)
        
        let url = URL(string: viewModel.localizationModel.privacyPolicyURL)!
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

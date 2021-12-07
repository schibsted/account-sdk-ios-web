import Foundation
import AuthenticationServices

protocol SimplifiedLoginViewModelAuthenticator {
    var asWebAuthenticationSession: ASWebAuthenticationSession? { get set }
}

protocol SimplifiedLoginUserActionable {
    var onClickedContinueWithoutLogin: (() -> Void)? { get set}
    var onClickedSwitchAccount: (() -> Void)? { get set}
    var onClickedPrivacyPolicy: (() -> Void)?  { get set }
    var onClickedContinueAsUser: (() -> Void)? { get set} // TODO:
    func send(action: SimplifiedLoginViewController.UserAction)
}

extension SimplifiedLoginUserActionable {
    func send(action: SimplifiedLoginViewController.UserAction){
        switch action {
        case .clickedContinueAsUser:
            self.onClickedContinueAsUser?()
        case .clickedLoginWithDifferentAccount:
            self.onClickedSwitchAccount?()
        case .clickedContinueWithoutLogin:
            self.onClickedContinueWithoutLogin?()
        case .clickedClickPrivacyPolicy:
            self.onClickedPrivacyPolicy?()
        }
    }
}

class SimplifiedLoginViewModel: SimplifiedLoginUserActionable, SimplifiedLoginViewModelAuthenticator {
    
    let clientName = "Finn" // TODO: Need to be fetched
    
    let imageDataModel: SimplifiedLoginNamedImageData
    var schibstedLogoName: String { return imageDataModel.schibstedLogoName }
    var iconNames: [String] { return imageDataModel.iconNames }
    
    let userData: SimplifiedLoginViewModelUserData
    var displayName: String { return userData.userContext.display_text }
    var initials: String {
        let firstName  = userData.userProfileResponse.name?.givenName ?? ""
        let lastName = userData.userProfileResponse.name?.familyName ?? ""
        let initials = "\(firstName.first?.uppercased() ?? "")\(lastName.first?.uppercased() ?? "")"
        return initials
    }
    
    init(imageDataModel: SimplifiedLoginNamedImageData, userDataModel: SimplifiedLoginViewModelUserData) {
        self.imageDataModel = imageDataModel
        self.userData = userDataModel
    }
    
    // MARK: SimplifiedLoginViewModelAuthenticator
    
    var asWebAuthenticationSession: ASWebAuthenticationSession?

    // MARK: SimplifiedLoginUserActionableSimplified Login User Actions
    
    var onClickedContinueWithoutLogin: (() -> Void)?
    var onClickedSwitchAccount: (() -> Void)?
    var onClickedPrivacyPolicy: (() -> Void)?
    var onClickedContinueAsUser: (() -> Void)? // TODO:
}

extension SimplifiedLoginViewModel {
    
    var continueToLogIn: String {
        return Localization.SimplifiedLogin.continueToLogIn.localizedString
    }
    
    var schibstedTitle: String {
        return Localization.SimplifiedLogin.schibstedTitle.localizedString
    }
    
    var continueWithoutLogin: String {
        return Localization.SimplifiedLogin.continueWithoutLogin.localizedString
    }
    
    var explanationText: String {
        return Localization.SimplifiedLogin.explanationText.localizedString
    }
    
    var privacyPolicyTitle: String {
        return Localization.SimplifiedLogin.privacyPolicyTitle.localizedString
    }
    
    var privacyPolicyURL: String {
        return Localization.SimplifiedLogin.privacyPolicyURL.localizedString
    }
    
    var switchAccount: String {
        return Localization.SimplifiedLogin.switchAccount.localizedString
    }
    
    var notYouTitle: String {
        return Localization.SimplifiedLogin.notYouTitle.localizedString
    }
    
    var continuAsButtonTitle: String {
        return Localization.SimplifiedLogin.continuAsButtonTitle.localizedString
    }
}

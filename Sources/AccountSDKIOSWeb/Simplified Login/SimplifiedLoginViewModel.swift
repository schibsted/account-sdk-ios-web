import Foundation
import AuthenticationServices

class SimplifiedLoginViewModel {
    let env: ClientConfiguration.Environment
    let userContext: UserContextFromTokenResponse
    let userProfileResponse: UserProfileResponse
    let schibstedLogoName = "sch-logo"
    
    var iconNames: [String] {
        let orderedIconNames: [String]
        switch env {
        case .proCom:
            orderedIconNames = ["Blocket", "Aftonbladet", "SVD", "Omni", "TvNu"]
        case .proNo:
            orderedIconNames = ["Finn", "VG", "Aftenposten", "E24", "BergensTidene"]
        case .proFi:
            orderedIconNames = ["Tori", "Oikotie", "Hintaopas", "Lendo", "Rakentaja"]
        case .proDk, .pre:
            orderedIconNames = ["Blocket", "Aftonbladet", "SVD", "Omni", "TvNu"] // Swedish icons as default
        }
        return orderedIconNames
    }
    
    var displayName: String {
        return userContext.display_text
    }
    
    var initials: String {
        let firstName  = userProfileResponse.name?.givenName ?? ""
        let lastName = userProfileResponse.name?.familyName ?? ""
        let initials = "\(firstName.first?.uppercased() ?? "")\(lastName.first?.uppercased() ?? "")"
        return initials
    }
    
    let clientName = "Finn" // TODO: Need to be fetched

    var asWebAuthenticationSession: ASWebAuthenticationSession?
    
    init(env: ClientConfiguration.Environment, userContext: UserContextFromTokenResponse, userProfileResponse: UserProfileResponse) {
        self.env = env
        self.userContext = userContext
        self.userProfileResponse = userProfileResponse
    }
    
    // MARK: Simplified Login User Actions
    
    var onClickedContinueWithoutLogin: (() -> Void)?
    var onClickedSwitchAccount: (() -> Void)?
    var onClickedPrivacyPolicy: (() -> Void)?
    var onClickedContinueAsUser: (() -> Void)? // TODO:
    
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

extension SimplifiedLoginViewModel {
    enum Localization: String {
        case schibstedTitle = "SimplifiedWidget.schibstedAccount"
        case continueWithoutLogin = "SimplifiedWidget.continueWithoutLogin"
        case explanationText = "SimplifiedWidget.footer"
        case privacyPolicyTitle = "SimplifiedWidget.privacyPolicy"
        case privacyPolicyURL = "SimplifiedWidget.privacyPolicyLink"
        case switchAccount = "SimplifiedWidget.loginWithDifferentAccount"
        case notYouTitle = "SimplifiedWidget.notYou"
        case continuAsButtonTitle = "SimplifiedWidget.continueAs"
        
        var localizedString: String{
            return self.rawValue.localized()
        }
    }
    
    var schibstedTitle: String {
        return Localization.schibstedTitle.localizedString
    }
    
    var continueWithoutLogin: String {
        return Localization.continueWithoutLogin.localizedString
    }
    
    var explanationText: String {
        return Localization.explanationText.localizedString
    }
    
    var privacyPolicyTitle: String {
        return Localization.privacyPolicyTitle.localizedString
    }
    
    var privacyPolicyURL: String {
        return Localization.privacyPolicyURL.localizedString
    }
    
    var switchAccount: String {
        return Localization.switchAccount.localizedString
    }
    
    var notYouTitle: String {
        return Localization.notYouTitle.localizedString
    }
    
    var continuAsButtonTitle: String {
        return Localization.continuAsButtonTitle.localizedString
    }
}

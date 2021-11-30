import Foundation
import AuthenticationServices

class SimplifiedLoginViewModel {
    
    var onClickedContinueWithoutLogin: (() -> Void)?
    var onClickedSwitchAccount: (() -> Void)?
    var onClickedPrivacyPolicy: (() -> Void)?
    var onClickedContinueAsUser: (() -> Void)? // TODO:
    
    var iconNames: [String]
    let schibstedLogoName = "sch-logo"
    
    let displayName = "Daniel.User" // TODO: Need to be fetched
    let clientName = "Finn" // TODO: Need to be fetched
    
    let client: Client
    var asWebAuthenticationSession: ASWebAuthenticationSession?
    
    init(client: Client, env: ClientConfiguration.Environment) {
        
        self.client = client
        
        let orderedIconNames: [String]
        switch env {
        case .proCom:
            orderedIconNames = ["Blocket", "Aftonbladet", "SVD", "Omni", "TvNu"]
        case .proNo:
            orderedIconNames = ["Finn", "VG", "Aftenposten", "E24", "BergensTidene"]
        case .proFi:
            orderedIconNames = ["Tori", "Oikotie", "Hintaopas", "Lendo", "Rakentaja"]
        case .proDk:
            orderedIconNames = ["Tori", "Oikotie", "Hintaopas", "Lendo", "Rakentaja"] //TODO: NEED DK 5 brands with icons
        case .pre:
            orderedIconNames = ["Blocket", "Aftonbladet", "SVD", "Omni", "TvNu"] // Using SV icons
        }
        
        self.iconNames = orderedIconNames
    }
    
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
        case continueToLogIn = "SimplifiedWidget.continueToLogIn"
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
    
    var continueToLogIn: String {
        return Localization.continueToLogIn.localizedString
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

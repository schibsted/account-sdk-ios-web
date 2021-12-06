import Foundation
import AuthenticationServices

protocol SimplifiedLoginViewModelUserData {
    var userContext: UserContextFromTokenResponse { get }
    var userProfileResponse: UserProfileResponse { get }
    var displayName: String { get }
    var initials: String { get }
}

protocol SimplifiedLoginNamedImageData {
    var env: ClientConfiguration.Environment { get }
    var iconNames: [String] { get }
    var schibstedLogoName: String { get }
}

extension SimplifiedLoginNamedImageData {
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
}

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

class SimplifiedLoginViewModel: SimplifiedLoginUserActionable, SimplifiedLoginViewModelUserData, SimplifiedLoginNamedImageData, SimplifiedLoginViewModelAuthenticator {
    
    let clientName = "Finn" // TODO: Need to be fetched
    
    init(env: ClientConfiguration.Environment, userContext: UserContextFromTokenResponse, userProfileResponse: UserProfileResponse) {
        self.env = env
        self.userContext = userContext
        self.userProfileResponse = userProfileResponse
    }
    
    // MARK: SimplifiedLoginViewModelAuthenticator
    
    var asWebAuthenticationSession: ASWebAuthenticationSession?
    
    // MARK: SimplifiedLoginNamedImageData
    
    var env: ClientConfiguration.Environment
    var schibstedLogoName: String = "sch-logo"
    
    // MARK: SimplifiedLoginViewModelUserData
    
    let userContext: UserContextFromTokenResponse
    let userProfileResponse: UserProfileResponse
    var displayName: String {
        return userContext.display_text
    }
    var initials: String {
        let firstName  = userProfileResponse.name?.givenName ?? ""
        let lastName = userProfileResponse.name?.familyName ?? ""
        let initials = "\(firstName.first?.uppercased() ?? "")\(lastName.first?.uppercased() ?? "")"
        return initials
    }

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

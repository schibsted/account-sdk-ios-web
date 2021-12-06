import Foundation

enum Localization {
    enum SimplifiedLogin: String{
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
}

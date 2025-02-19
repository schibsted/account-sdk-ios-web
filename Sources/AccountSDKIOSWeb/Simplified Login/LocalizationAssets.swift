//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

enum Localization {
    enum SimplifiedLogin: String {
        case loginIncentive = "SimplifiedWidget.loginIncentive"
        case continueWithoutLogin = "SimplifiedWidget.continueWithoutLogin"
        case shortExplanationText = "SimplifiedWidget.shortFooter"
        case privacyPolicyTitle = "SimplifiedWidget.privacyPolicy"
        case privacyPolicyURL = "SimplifiedWidget.privacyPolicyLink"
        case switchAccount = "SimplifiedWidget.loginWithDifferentAccount"
        case notYouTitle = "SimplifiedWidget.notYou"
        case continuAsButtonTitle = "SimplifiedWidget.continueAs"

        var localizedString: String {
            return self.rawValue.localized()
        }
    }
}

struct SimplifiedLoginLocalizationModel {

    var loginIncentive: String {
        return Localization.SimplifiedLogin.loginIncentive.localizedString
    }

    var continueWithoutLogin: String {
        return Localization.SimplifiedLogin.continueWithoutLogin.localizedString
    }

    var shortExplanationText: String {
        return Localization.SimplifiedLogin.shortExplanationText.localizedString
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

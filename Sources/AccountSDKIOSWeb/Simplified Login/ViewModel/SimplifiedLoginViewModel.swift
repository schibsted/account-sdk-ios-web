//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation
import AuthenticationServices

protocol SimplifiedLoginViewModelAuthenticator {
    var asWebAuthenticationSession: ASWebAuthenticationSession? { get set }
}

protocol SimplifiedLoginUserActionable {
    var onClickedContinueWithoutLogin: (() -> Void)? { get set}
    var onClickedSwitchAccount: (() -> Void)? { get set}
    var onClickedPrivacyPolicy: (() -> Void)? { get set }
    var onClickedContinueAsUser: (() -> Void)? { get set}
    func send(action: SimplifiedLoginViewController.UserAction)
}

extension SimplifiedLoginUserActionable {
    func send(action: SimplifiedLoginViewController.UserAction) {
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

    let clientName: String

    let localizationModel: SimplifiedLoginLocalizationModel

    let imageDataModel: SimplifiedLoginNamedImageData
    var schibstedLogoName: String { return imageDataModel.schibstedLogoName }
    var iconNames: [String] { return imageDataModel.iconNames }

    let userData: SimplifiedLoginViewModelUserData
    var displayName: String {
        if let firstName  = userData.userProfileResponse.name?.givenName,
           let lastName = userData.userProfileResponse.name?.familyName,
           !firstName.isEmpty,
           !lastName.isEmpty {
            return "\(firstName) \(lastName)"
        } else {
            return userData.userContext.display_text
        }
    }

    var email: String { userData.userProfileResponse.email ?? "" }

    var initials: String {
        let firstName  = userData.userProfileResponse.name?.givenName ?? ""
        let lastName = userData.userProfileResponse.name?.familyName ?? ""

        let shouldUseName = !firstName.isEmpty && !lastName.isEmpty
        if shouldUseName {
            let initials = "\(firstName.first?.uppercased() ?? "")\(lastName.first?.uppercased() ?? "")"
            return initials
        }

        let displayNameIntital = displayName.first?.uppercased() ?? ""
        return displayNameIntital
    }

    init(imageDataModel: SimplifiedLoginNamedImageData,
         userDataModel: SimplifiedLoginViewModelUserData,
         localizationModel: SimplifiedLoginLocalizationModel,
         visibleClientName: String) {
        self.localizationModel = localizationModel
        self.imageDataModel = imageDataModel
        self.userData = userDataModel
        self.clientName = visibleClientName
    }

    // MARK: SimplifiedLoginViewModelAuthenticator

    var asWebAuthenticationSession: ASWebAuthenticationSession?

    // MARK: SimplifiedLoginUserActionableSimplified Login User Actions

    var onClickedContinueWithoutLogin: (() -> Void)?
    var onClickedSwitchAccount: (() -> Void)?
    var onClickedPrivacyPolicy: (() -> Void)?
    var onClickedContinueAsUser: (() -> Void)?
}

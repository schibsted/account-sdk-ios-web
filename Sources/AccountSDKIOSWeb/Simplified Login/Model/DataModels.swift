//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation
import UIKit

protocol SimplifiedLoginViewModelUserData {
    var userContext: UserContextFromTokenResponse { get }
    var userProfileResponse: UserProfileResponse { get }
}

struct ConcreteSimplifiedLoginUserData: SimplifiedLoginViewModelUserData {
    var userContext: UserContextFromTokenResponse
    var userProfileResponse: UserProfileResponse
}

protocol SimplifiedLoginNamedImageData {
    var env: ClientConfiguration.Environment { get }
    var icons: [UIImage] { get }
    var schibstedLogo: UIImage { get }
}

struct ConcreteSimplifiedLoginNamedImageData: SimplifiedLoginNamedImageData {
    var env: ClientConfiguration.Environment
    var schibstedLogo: UIImage = .schibstedLogo
}

extension SimplifiedLoginNamedImageData {
    var icons: [UIImage] {
        switch env {
        case .proCom:
            [.logoAb, .logoSvd, .logoOmni, .logoPodme, .logoTvnu]
        case .proNo:
            [.logoVg, .logoAp, .logoE24, .logoBt, .logoPodme, .logoSa, .logoVgsport]
        case .proFi:
            [.logoPodme]
        case .proDk:
            []
        case .pre:
            [.logoAb, .logoSvd, .logoOmni, .logoPodme, .logoTvnu] // Swedish icons as default
        }
    }
}

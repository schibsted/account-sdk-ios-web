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
    var schibstedLogoName: String { get }
}

struct ConcreteSimplifiedLoginNamedImageData: SimplifiedLoginNamedImageData {
    var env: ClientConfiguration.Environment
    var schibstedLogoName: String = "sch-logo"
}

extension SimplifiedLoginNamedImageData {
    var icons: [UIImage] {
        switch env {
        case .proCom:
            [.aftonbladet, .svD, .omni, .podMe, .tvNu]
        case .proNo:
            [.VG, .aftenposten, .E_24, .BT, .podMe, .stavangerAftenblad, .vgSport]
        case .proFi:
            [.podMe]
        case .proDk:
            []
        case .pre:
            [.aftonbladet, .svD, .omni, .podMe, .tvNu] // Swedish icons as default
        }
    }
}

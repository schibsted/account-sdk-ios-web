//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

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
    var iconNames: [String] { get }
    var schibstedLogoName: String { get }
}

struct ConcreteSimplifiedLoginNamedImageData: SimplifiedLoginNamedImageData {
    var env: ClientConfiguration.Environment
    var schibstedLogoName: String = "sch-logo"
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
            orderedIconNames = ["Tori", "Oikotie", "Qasa", "PodMe", "Rakentaja"]
        case .proDk:
            orderedIconNames = ["dba", "Bilbasen"]
        case .pre:
            orderedIconNames = ["Blocket", "Aftonbladet", "SVD", "Omni", "TvNu"] // Swedish icons as default
        case .dev:
            orderedIconNames = ["Blocket", "Aftonbladet", "SVD", "Omni", "TvNu"] // Swedish icons as default
        }
        return orderedIconNames
    }
}

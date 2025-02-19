//
// Copyright © 2025 Schibsted.
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
            orderedIconNames = ["Aftonbladet", "SVD", "Omni", "PodMe", "TvNu"]
        case .proNo:
            orderedIconNames = ["VG", "Aftenposten", "E24", "PodMe", "BergensTidene"]
        case .proFi:
            orderedIconNames = ["PodMe"]
        case .proDk:
            orderedIconNames = ["dba", "Bilbasen"]
        case .pre:
            orderedIconNames = ["Aftonbladet", "SVD", "Omni", "PodMe", "TvNu"] // Swedish icons as default
        }
        return orderedIconNames
    }
}

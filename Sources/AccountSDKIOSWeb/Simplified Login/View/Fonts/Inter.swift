//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import UIKit

// Inter is an Open Font, see https://github.com/rsms/inter
enum Inter: String, CaseIterable {
    case bold = "Inter-Bold"
    case medium = "Inter-Medium"
    case regular = "Inter-Regular"
    case semiBold = "Inter-SemiBold"

    var systemWeight: UIFont.Weight {
        switch self {
        case .bold:
            return .bold
        case .medium:
            return .medium
        case .regular:
            return .regular
        case .semiBold:
            return .semibold
        }
    }
}

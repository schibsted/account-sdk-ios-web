//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation
import UIKit

enum SchibstedColor {
    case blue
    case lightGray
    case textDarkGray
    case textLightGray
    case lineGray
}

extension SchibstedColor {
    var value: UIColor {
        switch self {
        case .blue:
            return UIColor(red: 50/255, green: 116/255, blue: 212/255, alpha: 1)
        case .lightGray:
            return UIColor(red: 249/255, green: 249/255, blue: 250/255, alpha: 1)
        case .textDarkGray:
            return UIColor(red: 53/255, green: 52/255, blue: 58/255, alpha: 1)
        case .textLightGray:
            return UIColor(red: 102/255, green: 101/255, blue: 108/255, alpha: 1)
        case .lineGray:
            return UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.12)
        }
    }
}

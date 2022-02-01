import Foundation
import UIKit

enum SchibstedColor {
    case blue
    case lightGrey
    case textDarkGrey
    case textLightGrey
}

extension SchibstedColor {
    var value: UIColor {
        get {
            switch self {
            case .blue:
                return UIColor(red: 50/255, green: 116/255, blue: 212/255, alpha: 1)
            case .lightGrey:
                return UIColor(red: 249/255, green: 249/255, blue: 250/255, alpha: 1)
            case .textDarkGrey:
                return UIColor(red: 53/255, green: 52/255, blue: 58/255, alpha: 1)
            case .textLightGrey:
                return UIColor(red: 102/255, green: 101/255, blue: 108/255, alpha: 1)
            }
        }
    }
}

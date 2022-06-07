//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import UIKit

extension UIFont {
    static func preferredCustomFont(_ fontFamily: Inter, textStyle: UIFont.TextStyle) -> UIFont {
        let systemDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)

        let customFontDescriptor = UIFontDescriptor.init(
            fontAttributes: [UIFontDescriptor.AttributeName.family: fontFamily.rawValue,
                             UIFontDescriptor.AttributeName.size: systemDescriptor.pointSize])
        return UIFont(descriptor: customFontDescriptor, size: 0)
    }
}

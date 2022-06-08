//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import UIKit

extension UIFont {
    static func preferredCustomFont(_ fontName: Inter, textStyle: UIFont.TextStyle) -> UIFont {
        guard UIFont.fontNames(forFamilyName: "Inter").contains(fontName.rawValue) else {
            return UIFont.preferredFont(forTextStyle: textStyle)
        }

        let systemDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)
        let customFontDescriptor = UIFontDescriptor(
            fontAttributes: [UIFontDescriptor.AttributeName.visibleName: fontName.rawValue,
                             UIFontDescriptor.AttributeName.size: systemDescriptor.pointSize])
        return UIFont(descriptor: customFontDescriptor, size: 0)
    }
}

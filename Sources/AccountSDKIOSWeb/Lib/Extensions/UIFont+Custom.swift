//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import UIKit

extension UIFont {
    static func preferredCustomFont(_ fontName: Inter, textStyle: UIFont.TextStyle) -> UIFont {
        let systemDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)

        guard UIFont.fontNames(forFamilyName: "Inter").contains(fontName.rawValue) else {
            let font = UIFont.systemFont(ofSize: systemDescriptor.pointSize, weight: fontName.systemWeight)
            let metrics = UIFontMetrics(forTextStyle: textStyle)
            return metrics.scaledFont(for: font)
        }

        let customFontDescriptor = UIFontDescriptor(
            fontAttributes: [UIFontDescriptor.AttributeName.visibleName: fontName.rawValue,
                             UIFontDescriptor.AttributeName.size: systemDescriptor.pointSize])
        return UIFont(descriptor: customFontDescriptor, size: 0)
    }
}

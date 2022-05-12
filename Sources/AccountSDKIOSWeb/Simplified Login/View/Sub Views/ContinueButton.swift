//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import UIKit

class ContinueButton: UIButton {
    let viewModel: SimplifiedLoginViewModel
    let isExtended: Bool

    init(viewModel: SimplifiedLoginViewModel, extended: Bool = true) {
        self.viewModel = viewModel
        self.isExtended = extended
        super.init(frame: .zero)
    
        var title = "\(viewModel.localizationModel.continuAsButtonTitle) \(viewModel.displayName)"
        titleLabel?.textAlignment = .center
        if isExtended {
            title += "\n\(viewModel.email)"
            titleLabel?.textAlignment = .left
        }

        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        layer.cornerRadius = 25
        titleLabel?.font = UIFont.preferredFont(forTextStyle: .callout)
        titleLabel?.adjustsFontForContentSizeCategory = true
        titleLabel?.lineBreakMode = .byWordWrapping
        titleLabel?.translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = SchibstedColor.blue.value
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

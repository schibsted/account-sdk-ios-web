//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import UIKit

final class ContinueButton: UIButton {
    private let viewModel: SimplifiedLoginViewModel

    private lazy var title: String = {
        return "\(viewModel.localizationModel.continuAsButtonTitle) \(viewModel.displayName)"
    }()

    private lazy var internalConstraints: [NSLayoutConstraint] = {
        [heightAnchor.constraint(greaterThanOrEqualToConstant: 48),
         titleLabel!.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 47)]
    }()

    init(viewModel: SimplifiedLoginViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        titleLabel?.adjustsFontForContentSizeCategory = true
        titleLabel?.translatesAutoresizingMaskIntoConstraints = false
        titleLabel?.lineBreakMode = .byTruncatingTail
        setTitleColor(.white, for: .normal)
        backgroundColor = SchibstedColor.blue.value
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 24
        titleLabel?.font = UIFont.preferredCustomFont(.medium, textStyle: .callout)
        titleLabel?.textAlignment = .center
        setTitle(title, for: .normal)
    }
}

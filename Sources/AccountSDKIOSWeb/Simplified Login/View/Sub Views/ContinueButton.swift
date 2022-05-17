//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import UIKit

final class ContinueButton: UIButton {
    private let viewModel: SimplifiedLoginViewModel
    private let isExtended: Bool

    private lazy var title: String = {
        return "\(viewModel.localizationModel.continuAsButtonTitle) \(viewModel.displayName)"
    }()

    private lazy var avatarView: UIView = {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 40, height: 40)))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 20
        view.backgroundColor = .white.withAlphaComponent(0.2)

        return view
    }()

    private lazy var initialsLabel: UILabel = {
        let view = UILabel()
        view.text = viewModel.initials
        view.isAccessibilityElement = false
        view.font = UIFont.boldSystemFont(ofSize: 17)
        view.textAlignment = .center
        view.textColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private lazy var internalConstraints: [NSLayoutConstraint] = {
        [initialsLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
         initialsLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
         avatarView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
         avatarView.centerYAnchor.constraint(equalTo: centerYAnchor),
         avatarView.widthAnchor.constraint(equalToConstant: 40),
         avatarView.heightAnchor.constraint(equalToConstant: 40),
         titleLabel!.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 10),
         titleLabel!.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 3),
         titleLabel!.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -3)
        ]
    }()

    init(viewModel: SimplifiedLoginViewModel) {
        self.viewModel = viewModel
        self.isExtended = viewModel.shouldUseCombinedButtonView
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        titleLabel?.adjustsFontForContentSizeCategory = true
        titleLabel?.lineBreakMode = .byWordWrapping
        titleLabel?.translatesAutoresizingMaskIntoConstraints = false
        setTitleColor(.white, for: .normal)
        backgroundColor = SchibstedColor.blue.value
        translatesAutoresizingMaskIntoConstraints = false

        isExtended ? extendedSetup() : basicSetup()
    }

    private func basicSetup() {
        layer.cornerRadius = 25
        titleLabel?.font = UIFont.preferredFont(forTextStyle: .callout).bold()
        titleLabel?.textAlignment = .center
        setTitle(title, for: .normal)
    }

    private func extendedSetup() {
        layer.cornerRadius = 27
        titleLabel?.font = UIFont.preferredFont(forTextStyle: .footnote)
        titleLabel?.textAlignment = .left

        let extendedTitle = title + "\n\(viewModel.email)"
        let attributedString = NSMutableAttributedString(string: extendedTitle)
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: .callout).bold()]
        let boldedRange = NSRange(attributedString.string.range(of: "\(title)")!, in: attributedString.string)
        attributedString.addAttributes(attributes, range: boldedRange)
        setAttributedTitle(attributedString, for: .normal)

        avatarView.addSubview(initialsLabel)
        addSubview(avatarView)
        NSLayoutConstraint.activate(internalConstraints)
    }
}

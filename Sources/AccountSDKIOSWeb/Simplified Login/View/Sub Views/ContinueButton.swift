//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import UIKit

final class ContinueButton: UIButton {
    private let viewModel: SimplifiedLoginViewModel

    private lazy var title: String = {
        return "\(viewModel.localizationModel.continuAsButtonTitle) \(viewModel.displayName)"
    }()

    private lazy var avatarView: UIView = {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 40, height: 40)))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 20
        view.backgroundColor = .white.withAlphaComponent(0.2)
        view.isUserInteractionEnabled = false
        return view
    }()

    private lazy var initialsLabel: UILabel = {
        let view = UILabel()
        view.text = viewModel.initials
        view.isAccessibilityElement = false
        view.font = UIFont(name: Inter.bold.rawValue, size: 17)
        view.textAlignment = .center
        view.textColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private lazy var nameTitleLabel: UILabel = {
        let view = UILabel()
        view.text = title
        view.isAccessibilityElement = false
        view.font = UIFont.preferredCustomFont(.semiBold, textStyle: .body)
        view.textAlignment = .left
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        view.textColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        return view
    }()

    private lazy var combinedTitleView: UIStackView = {
        let view = UIStackView()
        view.alignment = .leading
        view.axis = .vertical
        view.distribution = .fill
        view.spacing = 1
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        return view
    }()

    private lazy var emailLabel: UILabel = {
        let view = UILabel()
        view.text = viewModel.email
        view.isAccessibilityElement = false
        view.font = UIFont.preferredCustomFont(.regular, textStyle: .subheadline)
        view.textAlignment = .left
        view.lineBreakMode = .byTruncatingTail
        view.numberOfLines = 1
        view.textColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        return view
    }()

    private lazy var internalConstraints: [NSLayoutConstraint] = {
        [initialsLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
         initialsLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
         avatarView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
         avatarView.centerYAnchor.constraint(equalTo: centerYAnchor),
         avatarView.widthAnchor.constraint(equalToConstant: 40),
         avatarView.heightAnchor.constraint(equalToConstant: 40),
         combinedTitleView.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 8),
         combinedTitleView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
         combinedTitleView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
         combinedTitleView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -26),
         heightAnchor.constraint(greaterThanOrEqualToConstant: 56)
        ]
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

        viewModel.shouldUseCombinedButtonView ? extendedSetup() : basicSetup()
    }

    private func basicSetup() {
        layer.cornerRadius = 24
        titleLabel?.font = UIFont.preferredCustomFont(.medium, textStyle: .callout)
        titleLabel?.textAlignment = .center
        setTitle(title, for: .normal)

        NSLayoutConstraint.activate([
            titleLabel!.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 47),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 48)])
    }

    private func extendedSetup() {
        layer.cornerRadius = 28
        avatarView.addSubview(initialsLabel)
        addSubview(avatarView)
        combinedTitleView.addArrangedSubview(nameTitleLabel)
        combinedTitleView.addArrangedSubview(emailLabel)
        addSubview(combinedTitleView)
        NSLayoutConstraint.activate(internalConstraints)
    }
}

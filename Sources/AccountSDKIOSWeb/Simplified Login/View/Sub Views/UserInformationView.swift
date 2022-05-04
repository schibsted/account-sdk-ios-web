//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import UIKit

class UserInformationView: UIView {
    let viewModel: SimplifiedLoginViewModel
    private let isPhone: Bool = UIDevice.current.userInterfaceIdiom == .phone

    lazy var internalConstraints: [NSLayoutConstraint] = {
        return [avatarView.heightAnchor.constraint(equalToConstant: 48),
                avatarView.widthAnchor.constraint(equalToConstant: 48),
                avatarView.leadingAnchor.constraint(lessThanOrEqualTo: leadingAnchor, constant: isPhone ? 45 : 15),
                avatarView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 10),
                initialsLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
                initialsLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
                nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
                nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 16),
                nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
                emailLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 16),
                emailLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
                emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
                emailLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        ]
    }()

    // MARK: User information

    private lazy var avatarView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 23
        view.backgroundColor = SchibstedColor.blue.value

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

    private lazy var nameLabel: UILabel = {
        let view = UILabel()
        view.text = viewModel.displayName
        view.font = UIFont.preferredFont(forTextStyle: .callout).bold()
        view.textAlignment = .left
        view.lineBreakMode = .byWordWrapping
        view.numberOfLines = 0
        view.sizeToFit()
        view.textColor = SchibstedColor.textDarkGray.value
        view.translatesAutoresizingMaskIntoConstraints = false
        view.adjustsFontForContentSizeCategory = true

        return view
    }()

    private lazy var emailLabel: UILabel = {
        let view = UILabel()
        view.text = viewModel.email
        view.font = UIFont.preferredFont(forTextStyle: .footnote)
        view.textAlignment = .left
        view.lineBreakMode = .byCharWrapping
        view.numberOfLines = 0
        view.sizeToFit()
        view.textColor = SchibstedColor.textLightGray.value
        view.translatesAutoresizingMaskIntoConstraints = false
        view.adjustsFontForContentSizeCategory = true

        return view
    }()

    init(viewModel: SimplifiedLoginViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        avatarView.addSubview(initialsLabel)
        addSubview(avatarView)
        addSubview(nameLabel)
        addSubview(emailLabel)
    }

    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

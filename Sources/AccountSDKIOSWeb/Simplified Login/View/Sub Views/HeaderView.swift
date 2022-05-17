//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import UIKit

class HeaderView: UIView {
    private let isPad: Bool = UIDevice.current.userInterfaceIdiom == .pad
    let viewModel: SimplifiedLoginViewModel

    private lazy var loginWithOneClickLabel: UILabel = {
        let view = UILabel()
        view.text = viewModel.localizationModel.loginWithOneClick
        view.font = UIFont.preferredFont(forTextStyle: .body).bold()
        view.textAlignment = .center
        view.lineBreakMode = .byWordWrapping
        view.numberOfLines = 0
        view.sizeToFit()
        view.textColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        view.adjustsFontForContentSizeCategory = true
        return view
    }()

    private lazy var grayLine: UIView = {
        let view = UIView()
        view.backgroundColor = SchibstedColor.lineGray.value
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = isPad ? true : false
        return view
    }()

    lazy var internalConstraints: [NSLayoutConstraint] = {
        return [loginWithOneClickLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                loginWithOneClickLabel.topAnchor.constraint(equalTo: topAnchor),
                loginWithOneClickLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                loginWithOneClickLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                grayLine.topAnchor.constraint(lessThanOrEqualTo: loginWithOneClickLabel.bottomAnchor, constant: 10),
                grayLine.heightAnchor.constraint(lessThanOrEqualToConstant: 1),
                grayLine.leadingAnchor.constraint(equalTo: leadingAnchor),
                grayLine.trailingAnchor.constraint(equalTo: trailingAnchor),
                grayLine.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
    }()

    init(viewModel: SimplifiedLoginViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isHidden = (viewModel.shouldUseHeadingCopyView || viewModel.shouldUseCombinedButtonView) ? false : true
        addSubview(loginWithOneClickLabel)
        addSubview(grayLine)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

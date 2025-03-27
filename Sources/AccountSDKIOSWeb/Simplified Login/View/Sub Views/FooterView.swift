//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import UIKit
import SwiftUI

class FooterView: UIStackView {
    let viewModel: SimplifiedLoginViewModel

    lazy var internalConstraints: [NSLayoutConstraint] = {
        let popularBrandsHeights = popularBrandsImageViews.map { $0.heightAnchor.constraint(equalToConstant: 36) }
        let popularBrandsWidths = popularBrandsImageViews.map { $0.widthAnchor.constraint(equalToConstant: 36) }
        return popularBrandsWidths +
        popularBrandsHeights +
        [schibstedIconImageView.heightAnchor.constraint(equalToConstant: 16),
         schibstedIconImageView.widthAnchor.constraint(equalToConstant: 100)
        ]
    }()

    // Eco system

    private lazy var ecoSystemBarStackView: UIStackView = {
        let view = UIStackView()
        view.alignment = .center
        view.axis = .horizontal
        view.distribution = .fill
        view.spacing = 20
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private lazy var schibstedIconImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(
            named: viewModel.schibstedLogoName,
            in: Bundle.module,
            compatibleWith: nil
        )
        view.contentMode = .center
        view.contentMode = .scaleAspectFill
        return view
    }()

    private lazy var popularBrandsStackView: UIStackView = {
        let view = UIStackView()
        view.alignment = .center
        view.axis = .horizontal
        view.distribution = .fill
        view.spacing = -11
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private lazy var popularBrandsImageViews: [UIImageView] = {
        var views = [UIImageView]()
        for imageName in viewModel.iconNames {
            views.append(getRoundedImageView(name: imageName))
        }

        return views
    }()

    // Privacy

    private lazy var explanationLabel: UILabel = {
        let localizedString = String.localizedStringWithFormat(
                viewModel.localizationModel.shortExplanationText)
        let view = UILabel.paragraphLabel(localizedString: localizedString)
        return view
    }()

    lazy var privacyURLButton: UIButton = {
        let view = UIButton()
        let attributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .font: UIFont.preferredCustomFont(.regular, textStyle: .subheadline),
            .foregroundColor: SchibstedColor.textDarkGray.value
        ]
        let attributedText = NSAttributedString(string: viewModel.localizationModel.privacyPolicyTitle,
                                                 attributes: attributes)

        view.translatesAutoresizingMaskIntoConstraints = false
        view.titleLabel?.adjustsFontForContentSizeCategory = true
        view.titleLabel?.numberOfLines = 0
        view.titleLabel?.lineBreakMode = .byWordWrapping
        view.setAttributedTitle(attributedText, for: .normal)

        return view
    }()

    init(viewModel: SimplifiedLoginViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)

        backgroundColor = SchibstedColor.lightGray.value
        alignment = .center
        axis = .vertical
        distribution = .fill
        spacing = 12
        layer.cornerRadius = 12
        translatesAutoresizingMaskIntoConstraints = false
        layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 12, right: 16)
        isLayoutMarginsRelativeArrangement = true

        // Ecosystem
        for item in popularBrandsImageViews {
            popularBrandsStackView.addArrangedSubview(item)
        }
        popularBrandsStackView.reverseSubviewsZIndex()

        ecoSystemBarStackView.addArrangedSubview(popularBrandsStackView)
        ecoSystemBarStackView.addArrangedSubview(schibstedIconImageView)
        self.addArrangedSubview(ecoSystemBarStackView)

        // Privacy and Explanation
        self.addArrangedSubview(explanationLabel)
        self.addArrangedSubview(privacyURLButton)
    }

    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func getRoundedImageView(name: String) -> UIImageView {
        let view = UIImageView()
        view.layer.masksToBounds = true
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.cornerRadius = 18
        view.clipsToBounds = true
        view.image = UIImage(named: name, in: Bundle.module, compatibleWith: nil)
        return view
    }
}

private extension UIStackView {
    func reverseSubviewsZIndex(setNeedsLayout: Bool = true) {
        let stackedViews = self.arrangedSubviews
        stackedViews.forEach {
            self.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        stackedViews.reversed().forEach(addSubview(_:))
        stackedViews.forEach(addArrangedSubview(_:))

        if setNeedsLayout {
            stackedViews.forEach { $0.setNeedsLayout() }
        }
    }
}

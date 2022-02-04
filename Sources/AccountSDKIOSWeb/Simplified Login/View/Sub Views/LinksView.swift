import UIKit

class LinksView: UIView {
    let viewModel: SimplifiedLoginViewModel
    
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    init(viewModel: SimplifiedLoginViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        differentAccountStackView.addArrangedSubview(notYouLabel)
        differentAccountStackView.addArrangedSubview(loginWithDifferentAccountButton)
        differentAccountStackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(differentAccountStackView)
        addSubview(continueWithoutLoginButton)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    lazy var internalConstraints: [NSLayoutConstraint] = {
        return [
            differentAccountStackView.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            differentAccountStackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            differentAccountStackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            differentAccountStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            continueWithoutLoginButton.topAnchor.constraint(equalTo: differentAccountStackView.bottomAnchor, constant: 6),
            continueWithoutLoginButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
            continueWithoutLoginButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            continueWithoutLoginButton.trailingAnchor.constraint(equalTo: trailingAnchor),
        ]
    }()
    
    lazy var continueWithoutLoginButton: UIButton = {
        let button = UIButton()
        let attributes:  [NSAttributedString.Key: Any] = [
            .underlineStyle : NSUnderlineStyle.single.rawValue,
            .font: UIFont.preferredFont(forTextStyle: .callout),
            .foregroundColor: SchibstedColor.blue.value
        ]
        let attributedText = NSAttributedString(string: viewModel.localizationModel.continueWithoutLogin,
                                                attributes: attributes)
        button.setAttributedTitle(attributedText, for: .normal)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var loginWithDifferentAccountButton: UIButton = {
        let button = UIButton()
        let attributes:  [NSAttributedString.Key: Any] = [
            .underlineStyle : NSUnderlineStyle.single.rawValue,
            .font: UIFont.preferredFont(forTextStyle: .callout),
            .foregroundColor: SchibstedColor.blue.value
        ]
        let attributedText = NSAttributedString(string: viewModel.localizationModel.switchAccount,
                                                attributes: attributes)
        button.setAttributedTitle(attributedText, for: .normal)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var notYouLabel: UILabel = {
        let view = UILabel()
        view.text = viewModel.localizationModel.notYouTitle
        view.font = UIFont.preferredFont(forTextStyle: .callout)
        view.textAlignment = .center
        view.adjustsFontForContentSizeCategory = true
        view.textColor = SchibstedColor.textLightGrey.value
        view.numberOfLines = 0
        view.lineBreakMode = .byWordWrapping
        view.sizeToFit()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var differentAccountStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .fill
        view.spacing = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
}

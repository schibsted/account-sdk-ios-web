import UIKit

class LinksView: UIView {
    let viewModel: SimplifiedLoginViewModel
    
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    init(viewModel: SimplifiedLoginViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        addSubview(differentAccountView)
        differentAccountView.addSubview(notYouLabel)
        differentAccountView.addSubview(loginWithDifferentAccountButton)
        addSubview(continueWithoutLoginButton)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    lazy var internalConstraints: [NSLayoutConstraint] = {
        return [
            differentAccountView.topAnchor.constraint(equalTo: topAnchor),
            differentAccountView.centerXAnchor.constraint(equalTo: centerXAnchor),
            differentAccountView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            differentAccountView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            notYouLabel.leadingAnchor.constraint(greaterThanOrEqualTo: differentAccountView.leadingAnchor),
            notYouLabel.topAnchor.constraint(equalTo: differentAccountView.topAnchor, constant: 2),
            notYouLabel.bottomAnchor.constraint(equalTo: differentAccountView.bottomAnchor, constant: 2),
            notYouLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
            loginWithDifferentAccountButton.leadingAnchor.constraint(equalTo: notYouLabel.trailingAnchor, constant: 5),
            loginWithDifferentAccountButton.topAnchor.constraint(equalTo: differentAccountView.topAnchor, constant: 2),
            loginWithDifferentAccountButton.bottomAnchor.constraint(equalTo: differentAccountView.bottomAnchor, constant: 2),
            loginWithDifferentAccountButton.centerYAnchor.constraint(equalTo: notYouLabel.centerYAnchor),
            loginWithDifferentAccountButton.trailingAnchor.constraint(lessThanOrEqualTo: differentAccountView.trailingAnchor, constant: -10),
            continueWithoutLoginButton.topAnchor.constraint(equalTo: differentAccountView.bottomAnchor, constant: 10),
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
        view.textColor = SchibstedColor.textLightGray.value
        view.numberOfLines = 0
        view.lineBreakMode = .byWordWrapping
        view.sizeToFit()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var differentAccountView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
}

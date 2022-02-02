import UIKit

class LinksView: UIStackView {
    let viewModel: SimplifiedLoginViewModel
    
    lazy var internalConstraints: [NSLayoutConstraint] = {
        return [differentAccountStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
                differentAccountStackView.topAnchor.constraint(equalTo: topAnchor),
                continueWithoutLoginButton.centerXAnchor.constraint(equalTo: centerXAnchor),
                continueWithoutLoginButton.topAnchor.constraint(equalTo: differentAccountStackView.bottomAnchor, constant: 16)
        ]
    }()
    
    private lazy var differentAccountStackView: UIStackView = {
        let view = UIStackView()
        view.alignment = .center
        view.axis = .horizontal
        view.distribution = .fill
        view.spacing = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var notYouLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.text = viewModel.localizationModel.notYouTitle
        view.font = UIFont.systemFont(ofSize: 16)
        view.textAlignment = .center
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = SchibstedColor.textLightGrey.value
        
        return view
    }()
    
    lazy var continueWithoutLoginButton: UIButton = {
        let button = UIButton()
        let attributes:  [NSAttributedString.Key: Any] = [ .underlineStyle : NSUnderlineStyle.single.rawValue,
                                                           .font: UIFont.systemFont(ofSize: 16),
                                                           .foregroundColor: SchibstedColor.blue.value
        ]
        let attributedText = NSAttributedString(string: viewModel.localizationModel.continueWithoutLogin,
                                                attributes: attributes)
        button.setAttributedTitle(attributedText, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var loginWithDifferentAccountButton: UIButton = {
        let button = UIButton()
        let attributes:  [NSAttributedString.Key: Any] = [ .underlineStyle : NSUnderlineStyle.single.rawValue,
                                                           .font: UIFont.systemFont(ofSize: 16),
                                                           .foregroundColor: SchibstedColor.blue.value
        ]
        let attributedText = NSAttributedString(string: viewModel.localizationModel.switchAccount,
                                                attributes: attributes)
        button.setAttributedTitle(attributedText, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(viewModel: SimplifiedLoginViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        differentAccountStackView.addArrangedSubview(notYouLabel)
        differentAccountStackView.addArrangedSubview(loginWithDifferentAccountButton)
        
        addArrangedSubview(differentAccountStackView)
        addArrangedSubview(continueWithoutLoginButton)
    }
    
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

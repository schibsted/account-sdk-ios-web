import UIKit

class LinksView: UIStackView {
    let viewModel: SimplifiedLoginViewModel

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
        view.text = viewModel.notYouTitle
        view.font = UIFont.systemFont(ofSize: 14)
        view.textAlignment = .center
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = UIColor(red: 102/255, green: 101/255, blue: 108/255, alpha: 1)
        
        return view
    }()
    
    lazy var continueWithoutLoginButton: UIButton = {
        let button = UIButton()
        let attributes:  [NSAttributedString.Key: Any] = [ .underlineStyle : NSUnderlineStyle.single.rawValue,
                                                           .font: UIFont.systemFont(ofSize: 14),
                                                           .foregroundColor: UIColor(red: 53/255, green: 52/255, blue: 58/255, alpha: 1)
        ]
        let attributedText = NSAttributedString(string: viewModel.continueWithoutLogin,
                                                 attributes: attributes)
        button.setAttributedTitle(attributedText, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var loginWithDifferentAccountButton: UIButton = {
        let button = UIButton()
        let attributes:  [NSAttributedString.Key: Any] = [ .underlineStyle : NSUnderlineStyle.single.rawValue,
                                                           .font: UIFont.systemFont(ofSize: 14),
                                                           .foregroundColor: UIColor(red: 53/255, green: 52/255, blue: 58/255, alpha: 1)
        ]
        let attributedText = NSAttributedString(string: viewModel.switchAccount, // TODO: Need localisation "Log in with different account"
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

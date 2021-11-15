import UIKit

class UserInformationView: UIStackView {
    let viewModel: SimplifiedLoginViewModel
    
    lazy var internalConstraints: [NSLayoutConstraint] = {
        return [avatarView.heightAnchor.constraint(equalToConstant: 48),
                avatarView.widthAnchor.constraint(equalToConstant: 48),
                initialsLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
                initialsLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor)
        ]
    }()
    
    // MARK: User information
    
    private lazy var avatarView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 23 // Do better
        view.backgroundColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)
        
        return view
    }()
    
    private lazy var initialsLabel: UILabel = {
        let view = UILabel()
        view.text = "DE" // TODO: How do we get Initials
        view.font = UIFont.boldSystemFont(ofSize: 17)
        view.textAlignment = .center
        view.textColor = UIColor(red: 53/255, green: 52/255, blue: 58/255, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    
    private lazy var nameLabel: UILabel = {
        let view = UILabel()
        view.text = viewModel.displayName
        view.font = UIFont.boldSystemFont(ofSize: 15)
        view.textAlignment = .center
        view.textColor = UIColor(red: 53/255, green: 52/255, blue: 58/255, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private lazy var schibstedTitleLabel: UILabel = {
        let view = UILabel()
        view.text = viewModel.localisation.schibstedTitle
        view.textAlignment = .center
        view.font = UIFont.systemFont(ofSize: 15)

        view.textColor = UIColor(red: 102/255, green: 101/255, blue: 108/255, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(viewModel: SimplifiedLoginViewModel) {
        self.viewModel = viewModel
        
        super.init(frame: .zero)
        avatarView.addSubview(initialsLabel)
        addArrangedSubview(avatarView)
        addArrangedSubview(nameLabel)
        addArrangedSubview(schibstedTitleLabel)
    }
    
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

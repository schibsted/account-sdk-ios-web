import UIKit

class UserInformationView: UIStackView {
    let viewModel: SimplifiedLoginViewModel
    
    lazy var internalConstraints: [NSLayoutConstraint] = {
        return [avatarView.heightAnchor.constraint(equalToConstant: 48),
                avatarView.widthAnchor.constraint(equalToConstant: 48),
                avatarView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 45),
                initialsLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
                initialsLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
                nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
                nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 16),
                emailLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 16),
                emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
                emailLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5)
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
        view.font = UIFont.boldSystemFont(ofSize: 17)
        view.textAlignment = .center
        view.textColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    
    private lazy var nameLabel: UILabel = {
        let view = UILabel()
        view.text = viewModel.displayName
        view.font = UIFont.boldSystemFont(ofSize: 15)
        view.textAlignment = .left
        view.textColor = SchibstedColor.textDarkGrey.value
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()
    
    private lazy var emailLabel: UILabel = {
        let view = UILabel()
        view.text = viewModel.email
        view.font = UIFont.systemFont(ofSize: 15)
        view.textAlignment = .left
        view.textColor = SchibstedColor.textLightGrey.value
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    init(viewModel: SimplifiedLoginViewModel) {
        self.viewModel = viewModel
        
        super.init(frame: .zero)
        avatarView.addSubview(initialsLabel)
        addSubview(avatarView)
        addSubview(nameLabel)
        addSubview(emailLabel)
    }
    
    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

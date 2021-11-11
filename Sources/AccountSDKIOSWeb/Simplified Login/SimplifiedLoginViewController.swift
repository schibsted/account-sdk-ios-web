import SwiftUI
import UIKit

public class SimplifiedLoginViewController: UIViewController {
        
    private lazy var userInformationView: UserInformationView = {
        let view = UserInformationView()
        view.alignment = .center
        view.axis = .vertical
        view.distribution = .fill
        view.spacing = 8
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false

        view.layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)
        view.isLayoutMarginsRelativeArrangement = true
        return view
    }()
    
    // MARK: Primary button
    
    private lazy var primaryButton: UIButton = {
        let button = UIButton()
        button.setTitle("Continue as Daniel.Echegaray", for: .normal) // put display_text here
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.backgroundColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()
    
    // MARK: Links
    
    private lazy var linksView: LinksView = {
        let view = LinksView()
        view.alignment = .center
        view.axis = .vertical
        view.distribution = .fill
        view.spacing = 20
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false

        view.layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)
        view.isLayoutMarginsRelativeArrangement = true
        return view
    }()
    
    // MARK: Footer
    
    private lazy var footerStackView: FooterView = {
        let view = FooterView()
        view.alignment = .center
        view.axis = .vertical
        view.distribution = .fill
        view.spacing = 12
        view.layer.cornerRadius = 12
        
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 250/255, alpha: 1)
        
        view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 12, right: 16)
        view.isLayoutMarginsRelativeArrangement = true
        return view
    }()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .white
        
        // Main view
        view.addSubview(userInformationView)
        view.addSubview(primaryButton)
        view.addSubview(linksView)
        view.addSubview(footerStackView)
        

        // Constraints
        let margin = view.layoutMarginsGuide
        
        let allConstraints =  userInformationView.internalConstraints + footerStackView.internalConstraints + [
            // UserInformation
            userInformationView.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
            userInformationView.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
            userInformationView.topAnchor.constraint(lessThanOrEqualTo: margin.topAnchor, constant: 57),
            
            // Primary button
            primaryButton.topAnchor.constraint(lessThanOrEqualTo: userInformationView.bottomAnchor, constant: 45),
            primaryButton.centerXAnchor.constraint(equalTo: userInformationView.centerXAnchor),
            primaryButton.heightAnchor.constraint(equalToConstant: 48),
            primaryButton.widthAnchor.constraint(equalToConstant: 343),
            primaryButton.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
            primaryButton.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
            
            // Links View
            linksView.topAnchor.constraint(lessThanOrEqualTo: primaryButton.bottomAnchor, constant: 53),
//            linksView.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
            linksView.centerXAnchor.constraint(equalTo: primaryButton.centerXAnchor),
            
            // Footer
            footerStackView.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
            footerStackView.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
            footerStackView.bottomAnchor.constraint(equalTo: margin.bottomAnchor),

        ]
        
        NSLayoutConstraint.activate(allConstraints)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#if DEBUG
@available(iOS 13.0.0, *)
struct SimplifiedLoginViewController_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SimplifiedLoginViewControllerRepresentable()
        }
    }
}

@available(iOS 13.0.0, *)
struct SimplifiedLoginViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> SimplifiedLoginViewController {
        let s = SimplifiedLoginViewController()
        return s
    }
    
    func updateUIViewController(_ uiViewController: SimplifiedLoginViewController, context: Context) {
    }
    
    typealias UIViewControllerType = SimplifiedLoginViewController
}
#endif

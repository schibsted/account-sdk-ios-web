import AuthenticationServices
import SwiftUI
import UIKit

class SimplifiedLoginViewController: UIViewController {
    
    private var viewModel: SimplifiedLoginViewModel
    private let isPhone: Bool = UIDevice.current.userInterfaceIdiom == .phone
    private var containerView = UIView()
    private var originalTransform: CGAffineTransform?
    
    private lazy var userInformationView: UserInformationView = {
        let view = UserInformationView(viewModel: viewModel)
        view.alignment = .center
        view.axis = .vertical
        view.distribution = .fill
        view.spacing = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)
        view.isLayoutMarginsRelativeArrangement = true
        return view
    }()
    
    // MARK: Primary button
    
    private lazy var primaryButton: UIButton = {
        let button = UIButton()
        let title = "\(viewModel.localizationModel.continuAsButtonTitle) \(viewModel.displayName)"
        
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = SchibstedColor.blue.value
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    // MARK: Links
    
    private lazy var linksView: LinksView = {
        let view = LinksView(viewModel: viewModel)
        view.alignment = .center
        view.axis = .vertical
        view.distribution = .fillEqually
        view.spacing =  0
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.layoutMargins = UIEdgeInsets(top: isPhone ? 8 : 0, left: 0, bottom: 16, right: 0)
        view.isLayoutMarginsRelativeArrangement = true
        return view
    }()
    
    // MARK: Footer
    
    private lazy var footerStackView: FooterView = {
        let view = FooterView(viewModel: viewModel)
        view.alignment = .center
        view.axis = .vertical
        view.distribution = .fill
        view.spacing = 12
        view.layer.cornerRadius = 12
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = SchibstedColor.lightGrey.value
        
        view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 12, right: 16)
        view.isLayoutMarginsRelativeArrangement = true
        return view
    }()
    
    init(viewModel: SimplifiedLoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = isPhone ? .black.withAlphaComponent(0.6) : .white
        
        if isPhone {
            let y = view.frame.height - 489 + 25
            containerView.frame = CGRect(x: 0, y: y, width: UIScreen.main.bounds.width, height: 489)
            containerView.translatesAutoresizingMaskIntoConstraints = false
            
            originalTransform = containerView.transform
            containerView.layer.cornerRadius = 10
            containerView.backgroundColor = .white
            containerView.addSubview(userInformationView)
            containerView.addSubview(primaryButton)
            containerView.addSubview(linksView)
            containerView.addSubview(footerStackView)
            view.addSubview(containerView)
            
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan(sender:)))
            containerView.addGestureRecognizer(panGestureRecognizer)
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap(sender:)))
            view.addGestureRecognizer(tapGestureRecognizer)
        } else {
            view.addSubview(userInformationView)
            view.addSubview(primaryButton)
            view.addSubview(linksView)
            view.addSubview(footerStackView)
        }
        
        primaryButton.addTarget(self, action: #selector(SimplifiedLoginViewController.primaryButtonClicked), for: .touchUpInside)
        linksView.loginWithDifferentAccountButton.addTarget(self, action: #selector(SimplifiedLoginViewController.loginWithDifferentAccountClicked), for: .touchUpInside)
        linksView.continueWithoutLoginButton.addTarget(self, action: #selector(SimplifiedLoginViewController.continueWithoutLoginClicked), for: .touchUpInside)
        footerStackView.privacyURLButton.addTarget(self, action: #selector(SimplifiedLoginViewController.privacyPolicyClicked), for: .touchUpInside)
        
        isPhone ? setupiPhoneConstraints() : setupiPadConstraints()
    }
    
    func setupiPhoneConstraints() {
        
        let margin = view.layoutMarginsGuide
        
        let buttonWidth = primaryButton.widthAnchor.constraint(equalToConstant: 343)
        buttonWidth.priority = .defaultLow
        let buttonLead = primaryButton.leadingAnchor.constraint(equalTo: margin.leadingAnchor, constant: 4)
        let buttonTrail = primaryButton.trailingAnchor.constraint(equalTo: margin.trailingAnchor, constant: -4)
        let allConstraints =  userInformationView.internalConstraints + footerStackView.internalConstraints + linksView.internalConstraints + [
            // UserInformation
            userInformationView.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
            userInformationView.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
            userInformationView.topAnchor.constraint(lessThanOrEqualTo: containerView.topAnchor, constant: 35),
            userInformationView.topAnchor.constraint(greaterThanOrEqualTo: containerView.topAnchor, constant: 10),
            
            // Primary button
            primaryButton.topAnchor.constraint(lessThanOrEqualTo: userInformationView.bottomAnchor, constant: -25),
            primaryButton.centerXAnchor.constraint(equalTo: userInformationView.centerXAnchor),
            primaryButton.heightAnchor.constraint(equalToConstant: 48),
            buttonWidth,
            buttonLead,
            buttonTrail,
            // Links View
            linksView.topAnchor.constraint(lessThanOrEqualTo: primaryButton.bottomAnchor, constant: 15),
            linksView.centerXAnchor.constraint(equalTo: primaryButton.centerXAnchor),
            linksView.bottomAnchor.constraint(equalTo: footerStackView.topAnchor),
            linksView.heightAnchor.constraint(equalToConstant: 120),
            
            // Footer
            footerStackView.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
            footerStackView.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
            footerStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -45),
            footerStackView.heightAnchor.constraint(equalToConstant: 185),
            
            // Container View
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 25),
            containerView.heightAnchor.constraint(equalToConstant: 520),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ]
        
        NSLayoutConstraint.activate(allConstraints)
    }
    
    func setupiPadConstraints() {
        
        let margin = view.layoutMarginsGuide
        let allConstraints =  userInformationView.internalConstraints + footerStackView.internalConstraints + linksView.internalConstraints + [
            // UserInformation
            userInformationView.leadingAnchor.constraint(equalTo: margin.leadingAnchor, constant: 30),
            userInformationView.trailingAnchor.constraint(equalTo: margin.trailingAnchor, constant: -30),
            userInformationView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: 10),

            // Primary button
            primaryButton.topAnchor.constraint(equalTo: userInformationView.bottomAnchor, constant: 80),
            primaryButton.centerXAnchor.constraint(equalTo: userInformationView.centerXAnchor),
            primaryButton.heightAnchor.constraint(equalToConstant: 48),
            primaryButton.widthAnchor.constraint(equalToConstant: 326),
            
            // Links View
            linksView.topAnchor.constraint(lessThanOrEqualTo: primaryButton.bottomAnchor, constant: 10),
            linksView.centerXAnchor.constraint(equalTo: primaryButton.centerXAnchor),
            linksView.bottomAnchor.constraint(equalTo: footerStackView.topAnchor, constant: 0),
            
            // Footer
            footerStackView.centerXAnchor.constraint(equalTo: userInformationView.centerXAnchor),
            footerStackView.heightAnchor.constraint(equalToConstant: 162),
            footerStackView.widthAnchor.constraint(equalToConstant: 394),
            footerStackView.bottomAnchor.constraint(equalTo: margin.bottomAnchor, constant: -30),
        ]
        NSLayoutConstraint.activate(allConstraints)
    }
    
    @objc
    private func didTap(sender: UITapGestureRecognizer) {
        let location = sender.location(in: containerView)
        if location.y < 0 {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc
    private func didPan(sender: UIPanGestureRecognizer) {
        if sender.state == .ended {
            let location = sender.location(in: view)
            if location.y >= 0.7 * UIScreen.main.bounds.height {
                UIView.animate(withDuration: 0.3) {
                    self.view.backgroundColor = .clear
                }
                self.dismiss(animated: true, completion: nil)
            } else if let originalTransform = originalTransform {
                UIView.animate(withDuration: 0.3) {
                    self.containerView.transform = originalTransform
                    sender.setTranslation(.zero, in: self.containerView)
                }
            }
        }
        
        let translation = sender.translation(in: view)
        
        guard translation.y > 0 else {
            return
        }
        
        containerView.transform = containerView.transform.translatedBy(x: .zero, y: translation.y)
        sender.setTranslation(.zero, in: containerView)
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        get {
            .portrait
        }
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            isPhone ? .portrait : .all
        }
    }
}

extension SimplifiedLoginViewController {
    
    @objc func primaryButtonClicked() { viewModel.send(action: .clickedContinueAsUser) }
    @objc func loginWithDifferentAccountClicked() { viewModel.send(action: .clickedLoginWithDifferentAccount) }
    @objc func continueWithoutLoginClicked() { viewModel.send(action: .clickedContinueWithoutLogin) }
    @objc func privacyPolicyClicked() { viewModel.send(action: .clickedClickPrivacyPolicy) }
    
    enum UserAction {
        case clickedContinueAsUser
        case clickedLoginWithDifferentAccount
        case clickedContinueWithoutLogin
        case clickedClickPrivacyPolicy
    }
}

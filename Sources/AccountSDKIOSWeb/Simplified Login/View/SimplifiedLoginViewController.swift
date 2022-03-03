import AuthenticationServices
import SwiftUI
import UIKit

class SimplifiedLoginViewController: UIViewController {
    
    private var viewModel: SimplifiedLoginViewModel
    private let isPhone: Bool = UIDevice.current.userInterfaceIdiom == .phone
    private var containerView = UIView()
    private var scrollView = UIScrollView()
    private var originalTransform: CGAffineTransform?
    private var bottomConstraint: NSLayoutConstraint?

    let tracker: TrackingEventsHandler?
    let trackerScreenID: TrackingEvent.Screen = .simplifiedLogin
    
    private lazy var userInformationView: UserInformationView = {
        let view = UserInformationView(viewModel: viewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)
        return view
    }()
    
    // MARK: Primary button
    
    private lazy var primaryButton: UIButton = {
        let button = UIButton()
        let title = "\(viewModel.localizationModel.continuAsButtonTitle) \(viewModel.displayName)"
        
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .callout)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = SchibstedColor.blue.value
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    // MARK: Links
    
    private lazy var linksView: LinksView = {
        let view = LinksView(viewModel: viewModel)
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
    
    init(viewModel: SimplifiedLoginViewModel, tracker: TrackingEventsHandler?) {
        self.viewModel = viewModel
        self.tracker = tracker
        super.init(nibName: nil, bundle: nil)
        
        if isPhone {
            modalPresentationStyle = .overFullScreen
            modalTransitionStyle = .crossDissolve
        } else {
            modalPresentationStyle = .formSheet
            preferredContentSize = .init(width: 450, height: 474)
        }
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
            
            scrollView.frame = CGRect(x: 0, y: 20, width: containerView.frame.size.width, height: containerView.frame.size.height)
            
            if #available(iOS 13.0, *) {
                scrollView.automaticallyAdjustsScrollIndicatorInsets = false
            } else {
                scrollView.contentInsetAdjustmentBehavior = .never
            }
            
            scrollView.addSubview(userInformationView)
            scrollView.addSubview(primaryButton)
            scrollView.addSubview(linksView)
            scrollView.addSubview(footerStackView)
            containerView.addSubview(scrollView)
            
            view.addSubview(containerView)
            bottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 525)
            
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan(sender:)))
            view.addGestureRecognizer(panGestureRecognizer)
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap(sender:)))
            view.addGestureRecognizer(tapGestureRecognizer)
        } else {
            scrollView.frame = CGRect(x: 0, y: 0, width: 450, height: 474)
            scrollView.addSubview(userInformationView)
            scrollView.addSubview(primaryButton)
            scrollView.addSubview(linksView)
            scrollView.addSubview(footerStackView)
            view.addSubview(scrollView)
        }
        
        primaryButton.addTarget(self, action: #selector(SimplifiedLoginViewController.primaryButtonClicked), for: .touchUpInside)
        linksView.loginWithDifferentAccountButton.addTarget(self, action: #selector(SimplifiedLoginViewController.loginWithDifferentAccountClicked), for: .touchUpInside)
        linksView.continueWithoutLoginButton.addTarget(self, action: #selector(SimplifiedLoginViewController.continueWithoutLoginClicked), for: .touchUpInside)
        footerStackView.privacyURLButton.addTarget(self, action: #selector(SimplifiedLoginViewController.privacyPolicyClicked), for: .touchUpInside)
        
        isPhone ? setupiPhoneConstraints() : setupiPadConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tracker?.interaction(.view, with: trackerScreenID)
        animateShowingOverlay()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        tracker?.interaction(.hide, with: trackerScreenID)
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
            userInformationView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            userInformationView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),

            // Primary button
            primaryButton.topAnchor.constraint(equalTo: userInformationView.bottomAnchor, constant: 20),
            primaryButton.centerXAnchor.constraint(equalTo: userInformationView.centerXAnchor),
            primaryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 48),
            buttonWidth,
            buttonLead,
            buttonTrail,
            
            // Links View
            linksView.topAnchor.constraint(lessThanOrEqualTo: primaryButton.bottomAnchor, constant: 15),
            linksView.centerXAnchor.constraint(equalTo: primaryButton.centerXAnchor),
            linksView.bottomAnchor.constraint(greaterThanOrEqualTo: footerStackView.topAnchor, constant: -20),
            linksView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            linksView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            
            // Footer
            footerStackView.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
            footerStackView.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
            footerStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -25),
            footerStackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 185),
            
            // Container View
            (bottomConstraint != nil) ? bottomConstraint! : containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 525),
            containerView.heightAnchor.constraint(equalToConstant: 520),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(allConstraints)
    }
    
    func setupiPadConstraints() {
        
        let allConstraints =  userInformationView.internalConstraints + footerStackView.internalConstraints + linksView.internalConstraints + [
            // UserInformation
            userInformationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userInformationView.topAnchor.constraint(greaterThanOrEqualTo: scrollView.topAnchor, constant: 35),
            userInformationView.widthAnchor.constraint(lessThanOrEqualToConstant: 394),

            // Primary button
            primaryButton.topAnchor.constraint(equalTo: userInformationView.bottomAnchor, constant: 30),
            primaryButton.centerXAnchor.constraint(equalTo: userInformationView.centerXAnchor),
            primaryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 48),
            primaryButton.widthAnchor.constraint(equalToConstant: 326),
            
            // Links View
            linksView.topAnchor.constraint(lessThanOrEqualTo: primaryButton.bottomAnchor, constant: 10),
            linksView.centerXAnchor.constraint(equalTo: primaryButton.centerXAnchor),
            linksView.bottomAnchor.constraint(equalTo: footerStackView.topAnchor, constant: -20),
            linksView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10),
            linksView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -10),
            linksView.widthAnchor.constraint(lessThanOrEqualToConstant: 394),
            
            // Footer
            footerStackView.centerXAnchor.constraint(equalTo: userInformationView.centerXAnchor),
            footerStackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 162),
            footerStackView.widthAnchor.constraint(equalToConstant: 394),
            footerStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -10),
            
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        NSLayoutConstraint.activate(allConstraints)
    }
    
    private func animateShowingOverlay() {
        guard isPhone else {
            return
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            if var bottomConstraint = self.bottomConstraint {
                NSLayoutConstraint.deactivate([bottomConstraint])
                bottomConstraint = self.containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 25)
                NSLayoutConstraint.activate([bottomConstraint])
                self.view.layoutIfNeeded()
            }
        }
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
    
    @objc func primaryButtonClicked() {
        tracker?.engagement(.click(on: .continueAsButton), in: trackerScreenID)
        viewModel.send(action: .clickedContinueAsUser)
    }
    @objc func loginWithDifferentAccountClicked() {
        tracker?.engagement(.click(on: .switchAccount), in: trackerScreenID)
        viewModel.send(action: .clickedLoginWithDifferentAccount)
    }
    @objc func continueWithoutLoginClicked() {
        tracker?.engagement(.click(on: .conitnueWithoutLogginIn), in: trackerScreenID)
        viewModel.send(action: .clickedContinueWithoutLogin)
    }
    @objc func privacyPolicyClicked() {
        tracker?.engagement(.click(on: .privacyPolicy), in: trackerScreenID)
        viewModel.send(action: .clickedClickPrivacyPolicy)
    }
    
    enum UserAction {
        case clickedContinueAsUser
        case clickedLoginWithDifferentAccount
        case clickedContinueWithoutLogin
        case clickedClickPrivacyPolicy
    }
}

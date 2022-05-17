//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import AuthenticationServices
import SwiftUI
import UIKit

class SimplifiedLoginViewController: UIViewController {

    private var viewModel: SimplifiedLoginViewModel
    private var containerView = UIView()
    private var scrollView = UIScrollView()
    private var originalTransform: CGAffineTransform?
    private var bottomConstraint: NSLayoutConstraint?

    let trackerScreenID: TrackingEvent.Screen = .simplifiedLogin

    // MARK: User Information view
    private lazy var userInformationView: UserInformationView = {
        UserInformationView(viewModel: viewModel)
    }()

    // MARK: Primary button
    private lazy var continueButton: UIButton = {
        ContinueButton(viewModel: viewModel)
    }()

    // MARK: Links
    private lazy var linksView: LinksView = {
        LinksView(viewModel: viewModel)
    }()

    // MARK: Header
    private lazy var headerView: HeaderView = {
        HeaderView(viewModel: viewModel)
    }()

    // MARK: Explanatory
    private lazy var explanatoryView: ExplanatoryView = {
        ExplanatoryView(viewModel: viewModel)
    }()

    // MARK: Footer
    private lazy var footerStackView: FooterView = {
        FooterView(viewModel: viewModel)
    }()

    init(viewModel: SimplifiedLoginViewModel) {
        self.viewModel = viewModel
        SchibstedAccountLogger.instance.info("Initialize Simplified login version: \(viewModel.uiVersion.rawValue)")
        super.init(nibName: nil, bundle: nil)

        if viewModel.isPhone {
            modalPresentationStyle = .overFullScreen
            modalTransitionStyle = .crossDissolve
        } else {
            modalPresentationStyle = .formSheet
            preferredContentSize = .init(width: 450, height: (viewModel.shouldUseMinimalView || viewModel.shouldUseCombinedButtonView) ? 454 : 524)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = viewModel.isPhone ? .black.withAlphaComponent(0.6) : .white

        configureForIphone()
        configureForIpad()
        setupButtonTargets()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.tracker?.interaction(.open, with: trackerScreenID, additionalFields: [.uiVersion(viewModel.uiVersion)])
        animateShowingOverlay()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    private func configureForIphone() {
        guard viewModel.isPhone else {
            return
        }

        let height = 459 + ((!viewModel.shouldUseMinimalView || !viewModel.shouldUseCombinedButtonView) ? 46 : 0)
        let y = Int(view.frame.height) - height + 25 // swiftlint:disable:this identifier_name
        containerView.frame = CGRect(x: 0, y: y, width: Int(UIScreen.main.bounds.width), height: height)
        containerView.translatesAutoresizingMaskIntoConstraints = false

        originalTransform = containerView.transform
        containerView.layer.cornerRadius = 10
        containerView.backgroundColor = .white

        scrollView.frame = CGRect(x: 0,
                                  y: 20,
                                  width: containerView.frame.size.width,
                                  height: containerView.frame.size.height)

        if #available(iOS 13.0, *) {
            scrollView.automaticallyAdjustsScrollIndicatorInsets = false
        } else {
            scrollView.contentInsetAdjustmentBehavior = .never
        }

        scrollView.addSubview(headerView)
        scrollView.addSubview(userInformationView)
        scrollView.addSubview(explanatoryView)
        scrollView.addSubview(continueButton)
        scrollView.addSubview(linksView)
        scrollView.addSubview(footerStackView)
        containerView.addSubview(scrollView)

        view.addSubview(containerView)
        bottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 525)

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan(sender:)))
        view.addGestureRecognizer(panGestureRecognizer)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap(sender:)))
        view.addGestureRecognizer(tapGestureRecognizer)

        setupiPhoneConstraints()
    }

    private func configureForIpad() {
        guard !viewModel.isPhone else {
            return
        }

        let overlayHeight = (viewModel.shouldUseMinimalView || viewModel.shouldUseCombinedButtonView) ? 454 : 500
        scrollView.frame = CGRect(x: 0, y: 0, width: 450, height: overlayHeight)
        scrollView.addSubview(headerView)
        scrollView.addSubview(userInformationView)
        scrollView.addSubview(explanatoryView)
        scrollView.addSubview(continueButton)
        scrollView.addSubview(linksView)
        scrollView.addSubview(footerStackView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        setupiPadConstraints()
    }

    private func setupButtonTargets() {
        let primaryButtonSelector = #selector(SimplifiedLoginViewController.primaryButtonClicked)
        let switchAccountSelector = #selector(SimplifiedLoginViewController.loginWithDifferentAccountClicked)
        let continueWithoutLoginSelector = #selector(SimplifiedLoginViewController.continueWithoutLoginClicked)
        let privacyPolicySelector = #selector(SimplifiedLoginViewController.privacyPolicyClicked)

        continueButton.addTarget(self, action: primaryButtonSelector, for: .touchUpInside)
        linksView.loginWithDifferentAccountButton.addTarget(self, action: switchAccountSelector, for: .touchUpInside)
        linksView.continueWithoutLoginButton.addTarget(self, action: continueWithoutLoginSelector, for: .touchUpInside)
        footerStackView.privacyURLButton.addTarget(self, action: privacyPolicySelector, for: .touchUpInside)
    }

    private func setupiPhoneConstraints() { // swiftlint:disable:this function_body_length
        let margin = view.layoutMarginsGuide
        let buttonWidth = continueButton.widthAnchor.constraint(equalToConstant: 343)
        buttonWidth.priority = .defaultLow
        let buttonLead = continueButton.leadingAnchor.constraint(equalTo: margin.leadingAnchor, constant: 4)
        let buttonTrail = continueButton.trailingAnchor.constraint(equalTo: margin.trailingAnchor, constant: -4)
        let containerViewBottomConstraint = containerView.bottomAnchor.constraint(
            equalTo: view.bottomAnchor,
            constant: (viewModel.shouldUseMinimalView || viewModel.shouldUseCombinedButtonView) ? 495 : 525)

        var allConstraints = [NSLayoutConstraint]()
        allConstraints.append(contentsOf: commonConstraints())

        allConstraints += [
            // Header View
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.topAnchor.constraint(equalTo: scrollView.topAnchor),

            // UserInformation
            userInformationView.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
            userInformationView.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
            userInformationView.topAnchor.constraint(equalTo: headerView.bottomAnchor,
                                                     constant: viewModel.shouldUseHeadingCopyView ? 15 : 5),
            userInformationView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0),

            // Explanatory view
            explanatoryView.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
            explanatoryView.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
            explanatoryView.topAnchor.constraint(equalTo: userInformationView.bottomAnchor,
                                                 constant: viewModel.shouldUseExplanatoryView ? 20 : 0),

            // Primary button
            continueButton.topAnchor.constraint(equalTo: explanatoryView.bottomAnchor, constant: viewModel.shouldUseCombinedButtonView ? 10 : 20),
            continueButton.centerXAnchor.constraint(equalTo: userInformationView.centerXAnchor),
            continueButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 48),
            buttonWidth,
            buttonLead,
            buttonTrail,

            // Links View
            linksView.topAnchor.constraint(lessThanOrEqualTo: continueButton.bottomAnchor, constant: 15),
            linksView.centerXAnchor.constraint(equalTo: continueButton.centerXAnchor),
            linksView.bottomAnchor.constraint(greaterThanOrEqualTo: footerStackView.topAnchor, constant: -15),
            linksView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            linksView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),

            // Footer
            footerStackView.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
            footerStackView.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
            footerStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -25),
            footerStackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 165),

            // Container View
            (bottomConstraint != nil) ? bottomConstraint! : containerViewBottomConstraint,
            containerView.heightAnchor.constraint(equalToConstant: viewModel.shouldUseMinimalView ? 480 : viewModel.shouldUseCombinedButtonView ? 465 : 520),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // Scroll View
            scrollView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ]

        NSLayoutConstraint.activate(allConstraints)
    }

    private func setupiPadConstraints() {
        let conitnueButtonTop: CGFloat = viewModel.shouldUseExplanatoryView ? 15 : viewModel.shouldUseCombinedButtonView ? 0 : 30

        var allConstraints = [NSLayoutConstraint]()
        allConstraints.append(contentsOf: commonConstraints())

        allConstraints += [
            // Header View
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.topAnchor.constraint(equalTo: scrollView.topAnchor,
                                            constant: (viewModel.shouldUseHeadingCopyView || viewModel.shouldUseCombinedButtonView) ? 25 : 0),

            // UserInformation
            userInformationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userInformationView.topAnchor.constraint(greaterThanOrEqualTo: headerView.bottomAnchor,
                                                     constant: (viewModel.shouldUseHeadingCopyView || viewModel.shouldUseCombinedButtonView) ? 15 : 35),
            userInformationView.widthAnchor.constraint(lessThanOrEqualToConstant: 394),

            // Explanatory view
            explanatoryView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            explanatoryView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            explanatoryView.topAnchor.constraint(equalTo: userInformationView.bottomAnchor,
                                                 constant: viewModel.shouldUseExplanatoryView ? 15 : 0),

            // Primary button
            continueButton.topAnchor.constraint(equalTo: explanatoryView.bottomAnchor,
                                                constant: conitnueButtonTop),
            continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            continueButton.heightAnchor.constraint(greaterThanOrEqualToConstant: viewModel.shouldUseCombinedButtonView ? 56 : 48),
            continueButton.widthAnchor.constraint(lessThanOrEqualToConstant: 326),
            continueButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 290),
            continueButton.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),

            // Links View
            linksView.topAnchor.constraint(lessThanOrEqualTo: continueButton.bottomAnchor, constant: 10),
            linksView.centerXAnchor.constraint(equalTo: continueButton.centerXAnchor),
            linksView.bottomAnchor.constraint(equalTo: footerStackView.topAnchor, constant: -20),
            linksView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10),
            linksView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -10),

            // Footer
            footerStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            footerStackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 180),
            footerStackView.widthAnchor.constraint(lessThanOrEqualToConstant: 394),
            footerStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -10),
            footerStackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            footerStackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),

            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]

        NSLayoutConstraint.activate(allConstraints)
    }

    private func commonConstraints() -> [NSLayoutConstraint] {
        var constraints = userInformationView.internalConstraints +
        footerStackView.internalConstraints + linksView.internalConstraints +
        headerView.internalConstraints + explanatoryView.internalConstraints

        if viewModel.shouldUseHeadingCopyView {
            constraints.append(headerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 36))
            constraints.append(explanatoryView.heightAnchor.constraint(equalToConstant: 0))
        } else if viewModel.shouldUseExplanatoryView {
            constraints.append(headerView.heightAnchor.constraint(equalToConstant: 0))
            constraints.append(explanatoryView.heightAnchor.constraint(greaterThanOrEqualToConstant: 48))
        } else if viewModel.shouldUseCombinedButtonView {
            constraints.append(headerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 36))
            constraints.append(explanatoryView.heightAnchor.constraint(equalToConstant: 0))
            let userInformationHeight = userInformationView.heightAnchor.constraint(equalToConstant: 0)
            userInformationHeight.priority = .defaultHigh
            constraints.append(userInformationHeight)
        } else {
            constraints.append(headerView.heightAnchor.constraint(equalToConstant: 0))
            constraints.append(explanatoryView.heightAnchor.constraint(equalToConstant: 0))
        }
        return constraints
    }

    private func animateShowingOverlay() {
        guard viewModel.isPhone else {
            return
        }

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            if var bottomConstraint = self.bottomConstraint {
                NSLayoutConstraint.deactivate([bottomConstraint])
                bottomConstraint = self.containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor,
                                                                              constant: 25)
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
            viewModel.tracker?.interaction(.close, with: trackerScreenID, additionalFields: [.uiVersion(viewModel.uiVersion)])
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
                viewModel.tracker?.interaction(.close, with: trackerScreenID, additionalFields: [.uiVersion(viewModel.uiVersion)])
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
        return .portrait
    }

    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return viewModel.isPhone ? .portrait : .all
    }
}

extension SimplifiedLoginViewController {

    @objc func primaryButtonClicked() {
        viewModel.tracker?.engagement(.click(on: .continueAsButton),
                            in: trackerScreenID,
                            additionalFields: [.uiVersion(viewModel.uiVersion)])
        viewModel.send(action: .clickedContinueAsUser)
    }
    @objc func loginWithDifferentAccountClicked() {
        viewModel.tracker?.engagement(.click(on: .switchAccount), in: trackerScreenID, additionalFields: [.uiVersion(viewModel.uiVersion)])
        viewModel.send(action: .clickedLoginWithDifferentAccount)
    }
    @objc func continueWithoutLoginClicked() {
        viewModel.tracker?.engagement(.click(on: .conitnueWithoutLogginIn),
                            in: trackerScreenID,
                            additionalFields: [.uiVersion(viewModel.uiVersion)])
        viewModel.tracker?.interaction(.close, with: trackerScreenID, additionalFields: [.uiVersion(viewModel.uiVersion)])
        viewModel.send(action: .clickedContinueWithoutLogin)
    }
    @objc func privacyPolicyClicked() {
        viewModel.tracker?.engagement(.click(on: .privacyPolicy),
                            in: trackerScreenID,
                            additionalFields: [.uiVersion(viewModel.uiVersion)])
        viewModel.send(action: .clickedClickPrivacyPolicy)
    }

    enum UserAction {
        case clickedContinueAsUser
        case clickedLoginWithDifferentAccount
        case clickedContinueWithoutLogin
        case clickedClickPrivacyPolicy
    }
}

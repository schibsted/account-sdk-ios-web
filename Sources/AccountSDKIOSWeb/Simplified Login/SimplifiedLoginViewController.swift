import SwiftUI
import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {

    let webView: WKWebView
    
    override func loadView() {
        webView.navigationDelegate = self
        view = webView
    }
    
    init(url: URL) {
        webView = WKWebView()
        webView.load(URLRequest(url: url))
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

public struct SimplifiedLoginUIFactory {

    @available(iOS, obsoleted: 13, message: "This function should not be used in iOS version 13 and above")
    public static func buildViewController(client: Client,
                                           env: ClientConfiguration.Environment, // TODO: Currently used to decide language.
                                           withMFA: MFAType? = nil,
                                           loginHint: String? = nil,
                                           extraScopeValues: Set<String> = [],
                                           completion: @escaping LoginResultHandler) -> UIViewController {
        let viewModel = SimplifiedLoginViewModel(client: client, env: env)! // TODO: throw error
        let s = SimplifiedLoginViewController(viewModel: viewModel )
        
        viewModel.onClickedContinueAsUser = {} // TODO:
        viewModel.onClickedSwitchAccount = {
            viewModel.asWebAuthenticationSession = client.getLoginSession(withMFA: withMFA,
                                                                          loginHint: loginHint,
                                                                          extraScopeValues: extraScopeValues,
                                                                          completion: completion)
            viewModel.asWebAuthenticationSession?.start()
        }
        viewModel.onClickedContinueWithoutLogin = {
            s.dismiss(animated: true, completion: nil)
        }
        
        viewModel.onClickedPrivacyPolicy = {
            let url = URL(string: viewModel.localisation.privacyPolicyURL)!
            let webVC = WebViewController(url: url)
            s.present(webVC, animated: false, completion: nil) // TODO: NEED to present in NC
        }
        
        return s
    }
    
    @available(iOS 13.0, *)
    public static func buildViewController(client: Client,
                                           env: ClientConfiguration.Environment, // TODO: Currently used to decide language.
                                           withMFA: MFAType? = nil,
                                           loginHint: String? = nil,
                                           extraScopeValues: Set<String> = [],
                                           withSSO: Bool = true,
                                           completion: @escaping LoginResultHandler) -> UIViewController {
        let viewModel = SimplifiedLoginViewModel(client: client, env: env)! // TODO: throw error
        let s = SimplifiedLoginViewController(viewModel: viewModel )
        
        viewModel.onClickedContinueAsUser = {} // TODO:
        viewModel.onClickedSwitchAccount = {
            let context = ASWebAuthSessionContextProvider()
            viewModel.asWebAuthenticationSession = client.getLoginSession(contextProvider: context,
                                                                          withMFA: withMFA,
                                                                          loginHint: loginHint,
                                                                          extraScopeValues: extraScopeValues,
                                                                          withSSO: withSSO,
                                                                          completion: completion)
            viewModel.asWebAuthenticationSession?.start()
        }
        
        viewModel.onClickedContinueWithoutLogin = {
            s.dismiss(animated: true, completion: nil)
        }
        
        viewModel.onClickedPrivacyPolicy = {
            let url = URL(string: viewModel.localisation.privacyPolicyURL)!
            let webVC = WebViewController(url: url)
            s.present(webVC, animated: false, completion: nil) // TODO: NEED to present in NC
        }
        
        return s
    }
}

class SimplifiedLoginViewModel {
    
    var onClickedContinueWithoutLogin: (() -> Void)?
    var onClickedSwitchAccount: (() -> Void)?
    var onClickedPrivacyPolicy: (() -> Void)?
    var onClickedContinueAsUser: (() -> Void)? // TODO:
    
    var localisation: Localisation
    var iconNames: [String]
    let schibstedLogoName = "sch-logo"
    
    let displayName = "Daniel.User" // TODO: Need to be fetched
    let clientName = "Finn" // TODO: Need to be fetched
    
    let client: Client
    var asWebAuthenticationSession: ASWebAuthenticationSession?
    
    init?(client: Client, env: ClientConfiguration.Environment) {
        
        self.client = client
        
        let resourceName: String
        let orderedIconNames: [String]
        switch env {
        case .proCom:
            resourceName = "for_use_simplified-widget_translations_sv"
            orderedIconNames = ["Blocket", "Aftonbladet", "SVD", "Omni", "TvNu"]
        case .proNo:
            resourceName = "for_use_simplified-widget_translations_nb"
            orderedIconNames = ["Finn", "VG", "Aftenposten", "E24", "BergensTidene"]
        case .proFi:
            resourceName = "for_use_simplified-widget_translations_fi"
            orderedIconNames = ["Tori", "Oikotie", "Hintaopas", "Lendo", "Rakentaja"]
        case .proDk:
            resourceName = "for_use_simplified-widget_translations_da"
            orderedIconNames = ["Tori", "Oikotie", "Hintaopas", "Lendo", "Rakentaja"] //TODO: NEED DK 5 brands with icons
        case .pre:
            resourceName = "simplified-widget_translations_en"
            orderedIconNames = ["Blocket", "Aftonbladet", "SVD", "Omni", "TvNu"] // Using SV icons
        }
        
        let decoder = JSONDecoder()
        guard let url = Bundle(for: SimplifiedLoginViewController.self).url(forResource: resourceName, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let localisation = try? decoder.decode(Localisation.self, from: data)
        else {
            return nil
        }
        
        self.localisation = localisation
        self.iconNames = orderedIconNames
    }
    
    func send(action: SimplifiedLoginViewController.UserAction){
        switch action {
        case .clickedContinueAsUser:
            self.onClickedContinueAsUser?()
        case .clickedLoginWithDifferentAccount:
            self.onClickedSwitchAccount?()
        case .clickedContinueWithoutLogin:
            self.onClickedContinueWithoutLogin?()
        case .clickedClickPrivacyPolicy:
            self.onClickedPrivacyPolicy?()
        }
    }
    
    struct Localisation: Codable {
        var schibstedTitle: String
        var continueWithoutLogin: String
        var explanationText: String
        var privacyPolicyTitle: String
        var privacyPolicyURL: String
        var switchAccount: String
        var notYouTitle: String
        var continuAsButtonTitle: String
        
        enum CodingKeys: String, CodingKey {
            case schibstedTitle = "SimplifiedWidget.schibstedAccount"
            case continueWithoutLogin = "SimplifiedWidget.continueWithoutLogin"
            case explanationText = "SimplifiedWidget.footer"
            case privacyPolicyTitle = "SimplifiedWidget.privacyPolicy"
            case privacyPolicyURL = "SimplifiedWidget.privacyPolicyLink"
            case switchAccount = "SimplifiedWidget.loginWithDifferentAccount"
            case notYouTitle = "SimplifiedWidget.notYou"
            case continuAsButtonTitle = "SimplifiedWidget.continueAs"
        }
    }
}

public class SimplifiedLoginViewController: UIViewController {
    
    private var viewModel: SimplifiedLoginViewModel
    
    private lazy var userInformationView: UserInformationView = {
        let view = UserInformationView(viewModel: viewModel)
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
        let title = "\(viewModel.localisation.continuAsButtonTitle) \(viewModel.displayName)"
        
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.backgroundColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()
    
    // MARK: Links
    
    private lazy var linksView: LinksView = {
        let view = LinksView(viewModel: viewModel)
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
        let view = FooterView(viewModel: viewModel)
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
    
    init(viewModel: SimplifiedLoginViewModel) {
        
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = .white
        
        // Main view
        view.addSubview(userInformationView)
        view.addSubview(primaryButton)
        view.addSubview(linksView)
        view.addSubview(footerStackView)
        setupConstraints()
        
        primaryButton.addTarget(self, action: #selector(SimplifiedLoginViewController.primaryButtonClicked), for: .touchUpInside)
        linksView.loginWithDifferentAccountButton.addTarget(self, action: #selector(SimplifiedLoginViewController.loginWithDifferentAccountClicked), for: .touchUpInside)
        linksView.continueWithoutLoginButton.addTarget(self, action: #selector(SimplifiedLoginViewController.continueWithoutLoginClicked), for: .touchUpInside)
//        footerStackView.privacyURLLabel.addTarget(self, action: #selector(SimplifiedLoginViewController.privacyPolicyClicked), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        
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
            linksView.centerXAnchor.constraint(equalTo: primaryButton.centerXAnchor),
            
            // Footer
            footerStackView.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
            footerStackView.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
            footerStackView.bottomAnchor.constraint(equalTo: margin.bottomAnchor),

        ]
        
        NSLayoutConstraint.activate(allConstraints)
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

#if DEBUG
@available(iOS 13.0.0, *)
struct SimplifiedLoginViewController_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SimplifiedLoginViewControllerRepresentable()
        }
    }
}


import AuthenticationServices
@available(iOS 13.0.0, *)
public struct SimplifiedLoginViewControllerRepresentable: UIViewControllerRepresentable {
    public init(){}
    @State var asWebAuthenticationSession: ASWebAuthenticationSession?
    
    public func makeUIViewController(context: Context) -> SimplifiedLoginViewController {
        let clientRedirectURI = URL(string: "com.sdk-example.pre.602504e1b41fa31789a95aa7:/login")!
        let clientConfiguration = ClientConfiguration(environment: .pre,
                                                      clientId: "602504e1b41fa31789a95aa7",
                                                      redirectURI: clientRedirectURI)
        let client = Client(configuration: clientConfiguration)
        
        let completion: LoginResultHandler = { result in
            switch result {
            case .success(let user):
                print("Success - logged in as \(user.uuid ?? ""), tokens: \(user.tokens?.description ?? "")")
                
            case .failure(let error):
                print(error)
            }
        }
        
        let s = SimplifiedLoginUIFactory.buildViewController(client: client,
                                                             env: .pre,
                                                             completion: completion) as! SimplifiedLoginViewController
        
        return s
    }
    
    public func updateUIViewController(_ uiViewController: SimplifiedLoginViewController, context: Context) {
    }
    
    public typealias UIViewControllerType = SimplifiedLoginViewController
}

#endif


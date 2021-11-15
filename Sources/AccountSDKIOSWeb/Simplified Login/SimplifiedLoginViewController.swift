import SwiftUI
import UIKit

public struct SimplifiedLoginViewModel {
    var localisation: Localisation
    var iconNames: [String]
    let schibstedLogoName = "sch-logo"
    
    let displayName = "Daniel.User" // TODO: Need to be fetched
    let clientName = "Finn" // TODO: Need to be fetched
    
    init?(env: ClientConfiguration.Environment){
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
    
    public init(viewModel: SimplifiedLoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = .white
        
        // Main view
        view.addSubview(userInformationView)
        view.addSubview(primaryButton)
        view.addSubview(linksView)
        view.addSubview(footerStackView)
        setupConstraints()
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
        let s = SimplifiedLoginViewController(viewModel: SimplifiedLoginViewModel(env: .pre)!)
        return s
    }
    
    func updateUIViewController(_ uiViewController: SimplifiedLoginViewController, context: Context) {
    }
    
    typealias UIViewControllerType = SimplifiedLoginViewController
}
#endif

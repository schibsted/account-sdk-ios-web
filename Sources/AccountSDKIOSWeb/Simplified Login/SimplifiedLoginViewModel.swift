import Foundation
import AuthenticationServices

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
        guard let url = Bundle.resourceBundle(for: SimplifiedLoginViewModel.self).url(forResource: resourceName, withExtension: "json"),
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

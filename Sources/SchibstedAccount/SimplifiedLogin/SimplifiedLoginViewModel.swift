//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

#if os(iOS)

import SwiftUI
import AuthenticationServices
import Logging
import Combine

/// View Model for the Simplified Login View.
@MainActor
public final class SimplifiedLoginViewModel: ObservableObject, Identifiable {
    private let logger = Logger(label: "SchibstedAuthenticator")
    private let displayText: String
    private let profile: SchibstedAuthenticatorUserProfile?
    private let authenticator: SchibstedAuthenticating
    private var cancellables = Set<AnyCancellable>()
    private var didAppear = false
    private weak var tracking: SchibstedAuthenticatorTracking?

    @Published private(set) var state: SchibstedAuthenticatorState = .loggedOut

    public init(
        displayText: String,
        profile: SchibstedAuthenticatorUserProfile?,
        tracking: SchibstedAuthenticatorTracking?,
        authenticator: SchibstedAuthenticating
    ) {
        self.displayText = displayText
        self.profile = profile
        self.tracking = tracking
        self.authenticator = authenticator
    }

    var displayName: String {
        guard let profile else {
            return displayText
        }

        guard let firstName = profile.name?.givenName,
              let lastName = profile.name?.familyName,
              !firstName.isEmpty, !lastName.isEmpty else {
            return profile.displayName
        }

        return "\(firstName) \(lastName)"
    }

    var initials: String {
        displayName
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
            .map { "\($0)" }
            .joined(separator: "")
    }

    var email: String? {
        profile?.email
    }

    func load() {
        authenticator.state
            .sink { [weak self] state in
                self?.state = state
            }
            .store(in: &cancellables)
    }

    func trackOnAppear() async {
        guard !didAppear else { return }
        didAppear = true
        await tracking?.trackSimplifiedLoginPresented()
    }

    func trackOnDisappear() async {
        guard didAppear else { return }
        await tracking?.trackSimplifiedLoginDismissed()
    }

    func trackContinueWithoutLogin() async {
        await tracking?.trackSimplifiedLoginContinueWithoutLogin()
    }

    func trackOpenedPrivacyPolicy() async {
        await tracking?.trackSimplifiedLoginOpenedPrivacyPolicy()
    }

    func login(
        presentationContextProvider: ASWebAuthenticationPresentationContextProviding
    ) async {
        let xDomainId = UUID()

        await tracking?.trackSimplifiedLoginSwitchAccount(xDomainId: xDomainId)

        do {
            try await authenticator.login(
                presentationContextProvider: presentationContextProvider,
                xDomainId: xDomainId
            )
        } catch {
            logger.error("Failed to login. Error: \(error)")
        }
    }

    func continueAs(
        presentationContextProvider: ASWebAuthenticationPresentationContextProviding
    ) async {
        let xDomainId = UUID()

        await tracking?.trackSimplifiedLoginContinueAs(xDomainId: xDomainId)

        do {
            let assertion = try await authenticator.assertionForSimplifiedLogin()

            try await authenticator.login(
                presentationContextProvider: presentationContextProvider,
                prefersEphemeralWebBrowserSession: true,
                multifactorAuthentication: nil,
                assertion: assertion,
                xDomainId: xDomainId
            )
        } catch {
            logger.error("Failed to continue-as user. Error: \(error)")
        }
    }

    var privacyPolicyURL: URL {
        authenticator.environment.privacyPolicyURL
    }

    var strings: Strings {
        switch authenticator.environment {
        case .sweden, .pre: Strings.swedish
        case .norway: Strings.norwegian
        case .finland: Strings.finnish
        }
    }

    var logos: [UIImage] {
        switch authenticator.environment {
        case .sweden, .pre:
            [.logoAb, .logoSvd, .logoOmni, .logoPodme, .logoTvnu]
        case .norway:
            [.logoVg, .logoAp, .logoE24, .logoBt, .logoPodme, .logoSa, .logoVgsport]
        case .finland:
            [.logoPodme]
        }
    }
}

// We're intentionally not using a xcstrings file for localization
// as we want the strings to match the configured environment
// rather than the locale of the users device.
struct Strings: Sendable {
    let continueAs: String
    let continueWithoutLogin: String
    let footerText: String
    let loginIncentive: String
    let notYou: String
    let privacyPolicy: String
    let switchAccount: String

    static let swedish = Strings(
        continueAs: "Fortsätt som",
        continueWithoutLogin: "Fortsätt utan att logga in",
        footerText: "Med ett Schibsted-konto kan du logga in på alla Schibsted-tjänster.",
        loginIncentive: "Du är redan inloggad på en av Schibsteds tjänster. Fortsätt med ett klick.",
        notYou: "Inte du?",
        privacyPolicy: "Personuppgiftspolicy",
        switchAccount: "Byt konto"
    )

    static let norwegian = Strings(
        continueAs: "Fortsett som",
        continueWithoutLogin: "Fortsett uten å logge inn",
        footerText: "Med Schibsted-konto kan du logge inn på alle Schibsted-tjenester.",
        loginIncentive: "Du er allerede logget på en av Schibsteds tjenester. Fortsett med ett klikk.",
        notYou: "Ikke deg?",
        privacyPolicy: "Personvernerklæring",
        switchAccount: "Bytt konto"
    )

    static let finnish = Strings(
        continueAs: "Jatka käyttäjänä",
        continueWithoutLogin: "Jatka kirjautumatta sisään",
        footerText: "Schibsted-tilillä voit kirjautua sisään kaikkiin Schibsted-palveluihin.",
        loginIncentive: "Olet jo kirjautunut sisään yhteen Schibsted-palveluista. Jatka yhdellä napsautuksella.",
        notYou: "Väärä käyttäjä?",
        privacyPolicy: "Tietosuoja",
        switchAccount: "Vaihda tiliä"
    )
}

#endif

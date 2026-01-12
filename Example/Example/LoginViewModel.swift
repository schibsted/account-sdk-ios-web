//
// Copyright © 2026 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Combine
import SchibstedAccount
import SwiftUI
import AuthenticationServices
import Logging

@MainActor
@Observable
final class LoginViewModel {
    private let logger = Logger(label: "LoginViewModel")
    private var cancellables = Set<AnyCancellable>()
    private let authenticator = SchibstedAuthenticator(
        environment: .pre,
        clientId: "602504e1b41fa31789a95aa7",
        appIdentifierPrefix: nil,
        redirectURI: URL(string: "com.sdk-example.pre.602504e1b41fa31789a95aa7:/login")!
    )

    private(set) var state: SchibstedAuthenticatorState = .loggedOut
    private(set) var profile: SchibstedAuthenticatorUserProfile?
    private(set) var webSessionURL: URL?
    private(set) var oneTimeCode: String?

    func load() async {
        switch authenticator.state.value {
        case .loggedIn:
            do {
                profile = try await authenticator.userProfile()
            } catch {
                logger.error("Failed to get profile. Error: \(error)")
            }
        default:
            break
        }

        authenticator.state
            .sink { [weak self] state in
                self?.state = state
            }
            .store(in: &cancellables)
    }

    func login(
        presentationContextProvider: ASWebAuthenticationPresentationContextProviding
    ) async {
        do {
            try await authenticator.login(presentationContextProvider: presentationContextProvider)
            profile = try await authenticator.userProfile()
        } catch {
            logger.error("Failed to login. Error: \(error)")
        }
    }

    func logout() {
        do {
            try authenticator.logout()
            cleanup()
        } catch {
            logger.error("Failed to logout. Error: \(error)")
        }
    }

    func requestSimplifiedLogin() async -> SimplifiedLoginView? {
        guard case .loggedOut = authenticator.state.value else {
            return nil
        }

        do {
            return try await authenticator.requestSimplifiedLogin()
        } catch {
            logger.error("Failed to request simplified login. Error: \(error)")
            return nil
        }
    }

    func requestWebSessionURL() async {
        do {
            webSessionURL = try await authenticator.webSessionURL()
        } catch {
            logger.error("Failed to request web session URL. Error: \(error)")
        }
    }

    func requestOneTimeCode() async {
        do {
            oneTimeCode = try await authenticator.oneTimeCode()
        } catch {
            logger.error("Failed to request web session URL. Error: \(error)")
        }
    }

    private func cleanup() {
        webSessionURL = nil
        oneTimeCode = nil
    }
}

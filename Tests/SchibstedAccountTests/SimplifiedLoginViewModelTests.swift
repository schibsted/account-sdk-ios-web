// 
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

#if os(iOS)

import Testing
import Foundation
import Combine

@testable import SchibstedAccount

@Suite(.serialized)
@MainActor
final class SimplifiedLoginViewModelTests {
    private let urlSession = FakeURLSession()
    private let presentationContextProvider = WebAuthenticationPresentationContext()
    private let tracker = FakeSchibstedAuthenticatorTracker()
    private var cancellables = Set<AnyCancellable>()

    @Test(arguments: [
        (SchibstedAuthenticatorUserProfile.withName, "Rincewind Wizzard"),
        (SchibstedAuthenticatorUserProfile.withoutName, "Rincewind the Wizzard"),
        (nil, "Rincewind")
    ])
    func displayName(
        profile: SchibstedAuthenticatorUserProfile?,
        expectedDisplayName: String
    ) {
        let viewModel = SimplifiedLoginViewModel(
            displayText: "Rincewind",
            profile: profile,
            tracking: nil,
            authenticator: authenticator()
        )

        #expect(viewModel.displayName == expectedDisplayName)
    }

    @Test
    func initials() {
        let viewModel = viewModel()
        #expect(viewModel.initials == "RW")
    }

    @Test
    func email() {
        let viewModel = viewModel()
        #expect(viewModel.email == "rincewind@unseen-university.am")
    }

    @Test("should return expected privacy policy based on the environment", arguments: [
        SchibstedAuthenticatorEnvironment.sweden,
        SchibstedAuthenticatorEnvironment.norway,
        SchibstedAuthenticatorEnvironment.finland,
        SchibstedAuthenticatorEnvironment.pre
    ])
    func privacyPolicyURL(
        environment: SchibstedAuthenticatorEnvironment
    ) {
        let viewModel = viewModel(environment: environment)
        #expect(viewModel.privacyPolicyURL == environment.privacyPolicyURL)
    }

    @Test("observe the authenticator and update the view model state when the authenticator state changes")
    func load() async {
        let authenticator = authenticator()
        let viewModel = viewModel(authenticator: authenticator)
        let expectation = TestExpectation(expectedFulfillmentCount: 2)

        viewModel.$state
            .dropFirst()
            .sink { _ in
                Task {
                    await expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.load()

        authenticator.state.value = .loggingIn

        await expectation.wait(timeout: 3.0)

        #expect(viewModel.state.isLoggingIn)
    }

    @Test("should login without ephemeral session and no assertion")
    func login() async {
        let authenticator = authenticator()
        let viewModel = viewModel(authenticator: authenticator)

        await confirmation { confirmation in
            authenticator.didLogin = { _, prefersEphemeralWebBrowserSession, _, assertion, _ in
                #expect(prefersEphemeralWebBrowserSession == false)
                #expect(assertion == nil)

                confirmation()

                return SchibstedAuthenticatorUser(
                    tokens: .fake(),
                    sdrn: "sdrn:schibsted:user:userId"
                )
            }

            await viewModel.login(presentationContextProvider: presentationContextProvider)
        }

        #expect(tracker.trackedSimplifiedLoginSwitchAccount)
    }

    @Test("should login with ephemeral session and assertion")
    func continueAs() async {
        let authenticator = authenticator()
        let viewModel = viewModel(authenticator: authenticator)

        await confirmation { confirmation in
            authenticator.didLogin = { _, prefersEphemeralWebBrowserSession, _, assertion, _ in
                #expect(prefersEphemeralWebBrowserSession == true)
                #expect(assertion == authenticator.simplifiedLoginAssertion)

                confirmation()

                return SchibstedAuthenticatorUser(
                    tokens: .fake(),
                    sdrn: "sdrn:schibsted:user:userId"
                )
            }

            await viewModel.continueAs(presentationContextProvider: presentationContextProvider)
        }

        #expect(tracker.trackedSimplifiedLoginContinueAs)
    }

    @Test("should track presenting the simplified login")
    func trackOnAppear() async {
        let authenticator = authenticator()
        let viewModel = viewModel(authenticator: authenticator)

        await viewModel.trackOnAppear()

        #expect(tracker.trackedSimplifiedLoginPresented)
    }

    @Test("should track dismissing the simplified login")
    func trackOnDisappear() async {
        let authenticator = authenticator()
        let viewModel = viewModel(authenticator: authenticator)
        await viewModel.trackOnAppear()

        await viewModel.trackOnDisappear()

        #expect(tracker.trackedSimplifiedLoginDismissed)
    }

    @Test("should track clicking continue-without-login")
    func trackContinueWithoutLogin() async {
        let authenticator = authenticator()
        let viewModel = viewModel(authenticator: authenticator)

        await viewModel.trackContinueWithoutLogin()

        #expect(tracker.trackedSimplifiedLoginContinueWithoutLogin)
    }

    @Test("should track the privacy policy being opened")
    func trackOpenedPrivacyPolicy() async {
        let authenticator = authenticator()
        let viewModel = viewModel(authenticator: authenticator)

        await viewModel.trackOpenedPrivacyPolicy()

        #expect(tracker.trackedSimplifiedLoginOpenedPrivacyPolicy)
    }

    private func authenticator(
        environment: SchibstedAuthenticatorEnvironment = .sweden
    ) -> FakeSchibstedAuthenticator {
        FakeSchibstedAuthenticator(
            environment: environment,
            clientId: "unitTests",
            redirectURI: URL(string: "com.schibsted.unitTests:/login")!,
            urlSession: urlSession
        )
    }

    private func viewModel(
        environment: SchibstedAuthenticatorEnvironment = .sweden
    ) -> SimplifiedLoginViewModel {
        viewModel(
            authenticator: authenticator(environment: environment)
        )
    }

    private func viewModel(
        authenticator: SchibstedAuthenticating
    ) -> SimplifiedLoginViewModel {
        SimplifiedLoginViewModel(
            displayText: "Rincewind",
            profile: .withName,
            tracking: tracker,
            authenticator: authenticator
        )
    }
}

#endif

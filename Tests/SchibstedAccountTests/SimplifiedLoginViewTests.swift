// 
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

#if os(iOS)

import Testing
import Foundation
import SwiftUI
import SnapshotTesting

@testable import SchibstedAccount

@Suite(.snapshots)
@MainActor
struct SimplifiedLoginViewTests {
    @Test(arguments: [
        (SchibstedAuthenticatorEnvironment.sweden, UIUserInterfaceStyle.light),
        (SchibstedAuthenticatorEnvironment.sweden, UIUserInterfaceStyle.dark),
        (SchibstedAuthenticatorEnvironment.norway, UIUserInterfaceStyle.light),
        (SchibstedAuthenticatorEnvironment.norway, UIUserInterfaceStyle.dark),
        (SchibstedAuthenticatorEnvironment.finland, UIUserInterfaceStyle.light),
        (SchibstedAuthenticatorEnvironment.finland, UIUserInterfaceStyle.dark)
    ])
    @available(iOS 17.0, *)
    func simplifiedLoginView(
        environment: SchibstedAuthenticatorEnvironment,
        userInterfaceStyle: UIUserInterfaceStyle
    ) {
        let simplifiedLoginView = SimplifiedLoginView(
            viewModel: SimplifiedLoginViewModel(
                displayText: "Claus Jørgensen",
                profile: SchibstedAuthenticatorUserProfile(
                    uuid: UUID(),
                    userId: "12345789",
                    email: "claus.joergensen@schibsted.com",
                    displayName: "Claus Jørgensen"
                ),
                tracking: nil,
                authenticator: FakeSchibstedAuthenticator(
                    environment: environment,
                    clientId: "clientId",
                    redirectURI: URL(string: "clientId:/login")!,
                    urlSession: FakeURLSession()
                )
            )
        )

        let hostingController = UIHostingController(rootView: simplifiedLoginView)

        assertSnapshot(
            of: hostingController,
            as: .image(
                on: .init(
                    size: CGSize(width: 414, height: 400),
                    traits: UITraitCollection { mutableTraits in
                        mutableTraits.userInterfaceStyle = userInterfaceStyle
                        mutableTraits.verticalSizeClass = .regular
                    }
                ),
                perceptualPrecision: 0.98
            ),
            named: "\(environment)-\(userInterfaceStyle == .dark ? "dark" : "light")",
            testName: "simplifiedLoginView"
        )
    }
}

#endif

//
// Copyright © 2026 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import SwiftUI
import SchibstedAccount

struct LoginView: View {
    private let presentationContextProvider = WebAuthenticationPresentationContext()
    private let viewModel = LoginViewModel()
    @State private var simplifiedLoginView: SimplifiedLoginView?

    var body: some View {
        VStack(spacing: 16) {
            switch viewModel.state {
            case .loggingIn:
                ProgressView()
                    .controlSize(.large)
            case .loggedIn:
                Image(systemName: "person.circle")
                    .resizable()
                    .frame(width: 48, height: 48)
                    .accessibilityHidden(true)

                if let profile = viewModel.profile {
                    Text(profile.displayName)
                        .font(.system(.largeTitle))

                    if let email = profile.email {
                        Text(email)
                            .font(.system(.headline))
                    }
                }

                if let webSessionURL = viewModel.webSessionURL {
                    Text(webSessionURL.absoluteString)
                        .font(.system(.subheadline))
                }

                if let oneTimeCode = viewModel.oneTimeCode {
                    Text(oneTimeCode)
                        .font(.system(.subheadline))
                }

                Button {
                    viewModel.logout()
                } label: {
                    Text("Logout")
                }
                .buttonStyle(.borderedProminent)

                Button {
                    Task {
                        await viewModel.requestWebSessionURL()
                    }
                } label: {
                    Text("Request Web Session URL")
                }
                .buttonStyle(.borderedProminent)

                Button {
                    Task {
                        await viewModel.requestOneTimeCode()
                    }
                } label: {
                    Text("Request One Time Code")
                }
                .buttonStyle(.borderedProminent)
            case .loggedOut:
                Button {
                    Task {
                        await viewModel.login(presentationContextProvider: presentationContextProvider)
                    }
                } label: {
                    Label {
                        Text("Login")
                    } icon: {
                        Image(systemName: "person.crop.circle")
                            .accessibilityHidden(true)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .sheet(item: $simplifiedLoginView) { simplifiedLoginView in
            simplifiedLoginView
        }
        .task {
            await viewModel.load()

            simplifiedLoginView = await viewModel.requestSimplifiedLogin()
        }
    }
}

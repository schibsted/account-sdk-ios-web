//
// Copyright © 2026 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

#if os(iOS)

import SwiftUI

/// Simplified Login View.
public struct SimplifiedLoginView: View, Identifiable {
    public let id = UUID()

    @Environment(\.sizeCategory) private var sizeCategory
    @Environment(\.dismiss) private var dismiss

    private let presentationContextProvider = WebAuthenticationPresentationContext()
    private let viewModel: SimplifiedLoginViewModel

    public init(viewModel: SimplifiedLoginViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack(spacing: 15) {
                    if !sizeCategory.isAccessibilityCategory {
                        VStack(spacing: 0) {
                            Text(viewModel.initials)
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .frame(width: 48, height: 48)
                        .background(.simplifiedLoginBlue)
                        .clipShape(Circle())
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.displayName)
                            .font(.system(.subheadline, weight: .semibold))
                            .foregroundStyle(.simplifiedLoginDarkGrayText)

                        if let email = viewModel.email {
                            Text(verbatim: email)
                                .font(.system(.subheadline))
                                .foregroundStyle(.simplifiedLoginLightGrayText)
                        }
                    }
                }

                Text(viewModel.strings.loginIncentive)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.system(.subheadline))
                    .foregroundStyle(.simplifiedLoginLightGrayText)
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
                    .padding(.horizontal, 20)

                switch viewModel.state {
                case .loggedOut:
                    Button {
                        Task {
                            await viewModel.continueAs(
                                presentationContextProvider: presentationContextProvider
                            )
                            dismiss()
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Text("\(viewModel.strings.continueAs) \(viewModel.displayName)")
                                .font(.system(.callout, weight: .medium))
                                .padding(.vertical, 6)
                            Spacer()
                        }
                        .frame(maxWidth: 500)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .tint(.simplifiedLoginBlue)
                    .padding(.top, 20)
                case .loggingIn:
                    ProgressView()
                        .controlSize(.large)
                        .padding(.top, 20)
                case .loggedIn:
                    EmptyView()
                }

                HStack {
                    Text(viewModel.strings.notYou)
                        .font(.system(.subheadline))
                        .foregroundStyle(.simplifiedLoginLightGrayText)

                    Button {
                        Task {
                            await viewModel.login(
                                presentationContextProvider: presentationContextProvider
                            )
                            dismiss()
                        }
                    } label: {
                        Text(viewModel.strings.switchAccount)
                            .font(.system(.subheadline))
                            .foregroundStyle(.simplifiedLoginBlue)
                            .underline()
                    }
                }
                .padding(.top, 16)

                Button {
                    Task {
                        await viewModel.trackContinueWithoutLogin()
                    }
                    dismiss()
                } label: {
                    Text(viewModel.strings.continueWithoutLogin)
                        .font(.system(.subheadline))
                        .foregroundStyle(.simplifiedLoginBlue)
                        .underline()
                }
                .padding(.top, 8)

                VStack {
                    VStack(spacing: 12) {
                        HStack(spacing: 20) {
                            LogosView(logos: viewModel.logos)

                            Image(.schibstedLogo)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 20)
                        }
                        .accessibilityHidden(true)

                        Text(viewModel.strings.footerText)
                            .fixedSize(horizontal: false, vertical: true)
                            .font(.system(.subheadline))
                            .foregroundStyle(.simplifiedLoginLightGrayText)
                            .multilineTextAlignment(.center)

                        Button {
                            Task {
                                await viewModel.trackOpenedPrivacyPolicy()
                            }

                            UIApplication.shared.open(viewModel.privacyPolicyURL)
                        } label: {
                            Text(viewModel.strings.privacyPolicy)
                                .font(.system(.subheadline))
                                .foregroundStyle(.simplifiedLoginDarkGrayText)
                                .underline()
                        }
                    }
                    .padding(16)
                }
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.top, 16)
            }
            .padding(16)
            .scrollBounceBehaviorBasedOnSize()
        }
        .presentationDetents(presentationDetent)
        .onAppear {
            Task {
                await viewModel.trackOnAppear()
            }
        }
        .onDisappear {
            Task {
                await viewModel.trackOnDisappear()
            }
        }
    }

    private var presentationDetent: Set<PresentationDetent> {
        if sizeCategory > .large {
            return [.large]
        }

        if UIDevice.current.userInterfaceIdiom == .pad {
            return [PresentationDetent.height(400), .large]
        }

        return [.medium, .large]
    }
}

private struct LogosView: View {
    let logos: [UIImage]

    var body: some View {
        HStack(spacing: -11) {
            ForEach(Array(logos.enumerated()), id: \.element) { i, logo in
                Image(uiImage: logo)
                    .resizable()
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.white, lineWidth: 1)
                    )
                    .zIndex(Double(-i))
            }
        }
        .accessibilityHidden(true)
    }
}

private extension View {
    func scrollBounceBehaviorBasedOnSize() -> some View {
        modifier(ScrollBounceBehaviorBasedOnSizeViewModifier())
    }
}

// swiftlint:disable:next type_name
private struct ScrollBounceBehaviorBasedOnSizeViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.4, *) {
            content.scrollBounceBehavior(.basedOnSize)
        } else {
            content
        }
    }
}

#endif

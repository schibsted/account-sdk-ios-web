//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

public protocol TrackingEventsHandler: AnyObject {
    var clientConfiguration: ClientConfiguration? { get set }
    var loginID: String? { get set }
    var merchantID: String? { get set }

    func interaction(_ interaction: TrackingEvent.Interaction, with screen: TrackingEvent.Screen, additionalFields: [TrackingEvent.AdditionalField])
    func engagement(_ engagement: TrackingEvent.Engagement, in screen: TrackingEvent.Screen, additionalFields: [TrackingEvent.AdditionalField])
    func error(_ errorType: TrackingEvent.ErrorType, in screen: TrackingEvent.Screen)
}

extension TrackingEventsHandler {
    func interaction(_ interaction: TrackingEvent.Interaction, with screen: TrackingEvent.Screen) {
        self.interaction(interaction, with: screen, additionalFields: [])
    }
    func engagement(_ engagement: TrackingEvent.Engagement, in screen: TrackingEvent.Screen) {
        self.engagement(engagement, in: screen, additionalFields: [])
    }
}

public enum TrackingEvent {
    public enum Screen {
        case simplifiedLogin
        case webBrowser
        case noScreen
    }

    public enum Interaction {
        case open
        case close
    }

    public enum UIElement {
        case continueAsButton
        case switchAccount
        case conitnueWithoutLogginIn
        case privacyPolicy
        case cancel
    }

    public enum Engagement {
        case click(on: UIElement) // swiftlint:disable:this identifier_name
    }

    public enum ErrorType {
        case tokenValidation(IdTokenValidationError)
        case signatureValidation(SignatureValidationError)
        case loginError(LoginError)
        case refreshTokenError(RefreshTokenError)
        case httpError(HTTPError)
        case loginStateError(LoginStateError)
        case generic(Error)
    }

    public enum AdditionalField {
        case getLoginSession(MFAType?)
        case sso(Bool)
        case loginHint(String?)
        case withAssertion(Bool)
        case extraScopeValues(Set<String>)
        case uiVersion(SimplifiedLoginUIVersion)
    }
}

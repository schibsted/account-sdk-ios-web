import Foundation

// is it necessary in the new implementation?
public protocol TrackingEventsHandlerDelegate: AnyObject {
    /**
     Should be called when a new JWE is returned

     This is used by the `IdentityUI` to link tracking events between
     the SDK and the Schibsted account backend
     */
    func trackingEventsHandlerDidReceivedJWE(_ jwe: String)
}

public protocol TrackingEventsHandler: AnyObject {
    var delegate: TrackingEventsHandlerDelegate? { get set }

    var clientConfiguration: ClientConfiguration? { get set }
    var mfaVariant: MFAType? {get set}
    var loginID: String? { get set }
    var merchantID: String? { get set }

    func interaction(_ interaction: TrackingEvent.Interaction, with screen: TrackingEvent.Screen)
    func engagement(_ engagement: TrackingEvent.Engagement, in screen: TrackingEvent.Screen)
    func error(_ errorType: TrackingEvent.ErrorType, in screen: TrackingEvent.Screen)
}

extension TrackingEventsHandler {
    func interaction(_ interaction: TrackingEvent.Interaction, with screen: TrackingEvent.Screen) {
        self.interaction(interaction, with: screen)
    }
}

public enum TrackingEvent {
    public enum Screen {
        case simplifiedLogin
    }

    public enum Interaction {
        case view
        case hide
    }

    public enum UIElement {
        case continueAsButton
        case switchAccount
        case conitnueWithoutLogginIn
        case privacyPolicy
    }

    public enum Engagement {
        case click(on: UIElement)
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
}

import Foundation
import Logging

public enum SchibstedAccountLogger {
    /// Common logging instance used by the SDK
    public static var instance = Logger(label: "com.schibsted.account")
}

import Foundation

extension String {
    func localized() -> String {
        NSLocalizedString(self, bundle: Bundle.accountSDK(for: SimplifiedLoginViewModel.self), comment: "")
    }
}

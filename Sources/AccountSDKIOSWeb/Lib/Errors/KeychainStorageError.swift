import Foundation

enum KeychainStorageError: Error {
    case storeError
    case operationError
    case deleteError
    case itemEncodingError
}

extension KeychainStorageError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .storeError:
            return NSLocalizedString("Unable to store the secret", comment: "")
        case .operationError:
            return NSLocalizedString("Unable to fulfill the keychain query", comment: "")
        case .deleteError:
            return NSLocalizedString("Unable to delete the secret", comment: "")
        case .itemEncodingError:
            return NSLocalizedString("Failed to JSON encode user tokens for storage", comment: "")
        }
    }
}

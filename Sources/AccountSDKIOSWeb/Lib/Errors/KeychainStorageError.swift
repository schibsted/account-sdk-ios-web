import Foundation

enum StoreErrorReason: Equatable {
    case keychainError(status: OSStatus)
    case invalidData
}

enum KeychainStorageError: Error, Equatable {
    case storeError(reason: StoreErrorReason)
    case operationError
    case deleteError
    case itemEncodingError
    case entitlementMissing
}

extension KeychainStorageError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .storeError(let reason):
            return NSLocalizedString("Unable to store the secret, reason: \(reason)", comment: "")
        case .operationError:
            return NSLocalizedString("Unable to fulfill the keychain query", comment: "")
        case .deleteError:
            return NSLocalizedString("Unable to delete the secret", comment: "")
        case .itemEncodingError:
            return NSLocalizedString("Failed to JSON encode user tokens for storage", comment: "")
        case .entitlementMissing:
            return NSLocalizedString("Entitlement missing for access group", comment: "")
        }
    }
}

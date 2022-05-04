//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

extension String {
    func localized() -> String {
        NSLocalizedString(self, bundle: Bundle.accountSDK(for: SimplifiedLoginViewModel.self), comment: "")
    }
}

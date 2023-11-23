//
// Copyright © 2023 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation
extension String {
    func sha256Hexdigest() -> String? {
        guard let stringData = data(using: String.Encoding.utf8) else {
            return nil
        }
        return stringData.sha256Hexdigest()
    }
}

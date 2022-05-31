//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation

internal struct StringOrIgnore: Codable, Equatable {
    let value: String?
}

extension StringOrIgnore {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.value = try? container.decode(String.self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        guard let stringValue = value else {
            try container.encode(false)
            return
        }

        try container.encode(stringValue)
    }
}

internal struct StringBool: Codable, Equatable {
    let value: Bool?
    let asString: Bool
}

extension StringBool {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        guard let value = try? container.decode(Bool.self) else {
            let value = try? container.decode(String.self)
            self.value = value == "true"
            asString = true
            return
        }

        self.value = value
        asString = false
    }

    func encode(to encoder: Encoder) throws {
        guard let boolValue = value else {
            return
        }

        var container = encoder.singleValueContainer()
        if asString {
            try container.encode(String(boolValue))
        } else {
            try container.encode(boolValue)
        }
    }
}

internal struct SchibstedAccountAPIResponse<T: Codable>: Codable {
    let data: T
}

struct SessionExchangeResponse: Codable {
    let code: String
}

struct CodeExchangeResponse: Codable {
    let code: String
}

struct UserContextFromTokenResponse: Codable, Equatable {
    let identifier: String
    let displayText: String
    let clientName: String
}

struct SimplifiedLoginAssertionResponse: Codable, Equatable {
    let assertion: String
}

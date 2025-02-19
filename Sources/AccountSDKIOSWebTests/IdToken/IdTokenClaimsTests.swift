//
// Copyright © 2022 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import XCTest
import JOSESwift
@testable import AccountSDKIOSWeb

enum TestJSONEncoder {
    static let instance = jsonEncoder()
    
    private static func jsonEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        return encoder
    }
}

final class IdTokenClaimsTests: XCTestCase {
    private let fixtureJson = Data("""
    {
      "iss": "https://issuer.example.com",
      "sub": "userUuid",
      "legacy_user_id": "12345",
      "aud": ["client1"],
      "exp": 12345,
      "nonce": "testNonce",
      "amr": ["amr1", "amr2"]
    }
    """.utf8)
    private let fixture = IdTokenClaims(iss: "https://issuer.example.com", sub: "userUuid", userId: "12345", aud: ["client1"], exp: 12345, nonce: "testNonce", amr: ["amr1", "amr2"])
    
    

    func testDecodingAllFields() throws {
        let result = try JSONDecoder().decode(IdTokenClaims.self, from: fixtureJson)
        XCTAssertEqual(result, fixture)
    }
    
    func testEncodingAllFields() throws {
        let result = try String(decoding: TestJSONEncoder.instance.encode(fixture), as: UTF8.self)
        XCTAssertEqual(result, String(decoding: try fixtureJson.jsonEncode(), as: UTF8.self))
    }
    
    func testDecodingThrowsWhenMissingRequiredField() throws {
        for key in ["iss", "sub"]  {
            AssertThrowsKeyNotFound(key, decoding: IdTokenClaims.self, from: try fixtureJson.jsonDelete(key: key))
        }
    }
    
    func testDecodingSingleAudienceValue() throws {
        let aud = "client1"
        let result = try JSONDecoder().decode(IdTokenClaims.self,
                                              from: try fixtureJson.jsonReplace(value: aud, forKey: "aud"))
        XCTAssertEqual(result, fixture)
    }
    
    func testDecodingMultipleAudienceValues() throws {
        let result = try JSONDecoder().decode(IdTokenClaims.self, from: fixtureJson)
        XCTAssertEqual(result, fixture)
    }

    func AssertThrowsKeyNotFound<T: Decodable>(_ expectedKey: String, decoding: T.Type, from data: Data) {
        XCTAssertThrowsError(try JSONDecoder().decode(decoding, from: data)) { error in
            if case .keyNotFound(let key, _)? = error as? DecodingError {
                XCTAssertEqual(key.stringValue, expectedKey)
            } else {
                XCTFail("Expected '.keyNotFound(\(expectedKey))' but got \(error)")
            }
        }
    }
}

extension Data {
    func jsonEncode() throws -> Data {
        let decoded = try JSONSerialization.jsonObject(with: self)
        return try JSONSerialization.data(withJSONObject: decoded, options: .sortedKeys)
    }

    func jsonDelete(key: String) throws -> Data {
        let decoded = try JSONSerialization.jsonObject(with: self, options: .mutableContainers) as AnyObject
        decoded.setValue(nil, forKey: key)

        return try JSONSerialization.data(withJSONObject: decoded)
    }
    
    func jsonReplace<T>(value: T?, forKey: String) throws -> Data {
        let decoded = try JSONSerialization.jsonObject(with: self, options: .mutableContainers) as AnyObject
        decoded.setValue(value, forKey: forKey)

        return try JSONSerialization.data(withJSONObject: decoded)
    }
}

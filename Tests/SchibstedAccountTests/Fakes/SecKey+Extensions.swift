// 
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Security
import Testing
import Foundation

@preconcurrency import JOSESwift

extension SecKey {
    static func jwk() throws -> SecKey {
        let keyAttributes = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: 2048
        ] as CFDictionary

        return try #require(SecKeyCreateRandomKey(keyAttributes, nil))
    }

    static func jws(claims: String) throws -> JWS {
        let algorithm = SignatureAlgorithm.RS256
        var header = JWSHeader(algorithm: algorithm)
        header.kid = "test key"

        let payload = Payload(Data(claims.utf8))
        let key = try jwk()
        let signer = Signer(signatureAlgorithm: algorithm, key: key)!

        return try JWS(header: header, payload: payload, signer: signer)
    }
}

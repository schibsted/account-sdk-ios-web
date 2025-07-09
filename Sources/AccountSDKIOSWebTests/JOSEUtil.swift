//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import Foundation
import JOSESwift
@testable import AccountSDKIOSWeb

final class JWSUtil: @unchecked Sendable {
    let publicKey: SecKey!
    let privateKey: SecKey!
    let publicJWK: RSAPublicKey

    init() {
        let keyattribute = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String : 2048
        ] as CFDictionary
        
        var pubKey, privKey: SecKey?
        SecKeyGeneratePair(keyattribute, &pubKey, &privKey)
        publicKey = pubKey
        privateKey = privKey
        publicJWK = try! RSAPublicKey(publicKey: publicKey)
    }

    func createJWS(payload: Data, keyId: String?) -> String {
        let algorithm = SignatureAlgorithm.RS256
        var header = JWSHeader(algorithm: algorithm)
        header.kid = keyId
        
        let payload = Payload(payload)
        let signer = Signer(signatureAlgorithm: algorithm, key: privateKey!)!
        
        let jws = try! JWS(header: header, payload: payload, signer: signer)
        return jws.compactSerializedString
    }

    func createIdToken(claims: IdTokenClaims, keyId: String) -> String {
        let data = try! JSONEncoder().encode(claims)
        return createJWS(payload: data, keyId: keyId)
    }
}

final class StaticJWKS: JWKS {
    private let keys: [String: JWK]
        
    init(keyId: String, rsaPublicKey: SecKey) {
        self.keys = [keyId: try! RSAPublicKey(publicKey: rsaPublicKey)]
    }
    
    init(keyId: String, jwk: JWK) {
        self.keys = [keyId: jwk]
    }
    
    func getKey(withId keyId: String, completion: @escaping (JWK?) -> Void) {
        completion(keys[keyId])
    }
}

import Foundation
import JOSESwift

internal class JWSUtil {
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
        let signer = Signer(signingAlgorithm: algorithm, privateKey: privateKey!)!
        
        let jws = try! JWS(header: header, payload: payload, signer: signer)
        return jws.compactSerializedString
    }
}

import Foundation

internal enum HTTPUtil {
    static let xWWWFormURLEncodedContentType = "application/x-www-form-urlencoded"
    
    private static let formEncodeAllowedCharacters: CharacterSet = {
        let allowedCharacterSet = NSMutableCharacterSet.alphanumeric()
        allowedCharacterSet.addCharacters(in: "*-._ ")
        return allowedCharacterSet as CharacterSet
    }()

    static func formURLEncode(parameters: [String: String]) -> Data? {
        let encoded = parameters.map { key, value in
            let encodedKey = formURLEncodeValue(key)
            let encodedValue = formURLEncodeValue(value)
            return "\(encodedKey)=\(encodedValue)"
        }
        .joined(separator: "&")
        .data(using: .utf8)
        
        return encoded
    }
          
    private static func formURLEncodeValue(_ value: String) -> String {
        let encoded = value.addingPercentEncoding(withAllowedCharacters: HTTPUtil.formEncodeAllowedCharacters) ?? ""
        return encoded.replacingOccurrences(of: " ", with: "+")
    }
}

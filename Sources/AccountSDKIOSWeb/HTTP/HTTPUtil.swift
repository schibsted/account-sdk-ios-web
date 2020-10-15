import Foundation

struct HTTPUtil {
    static let xWWWFormURLEncodedContentType = "application/x-www-form-urlencoded"
    
    private static let formEncodeAllowedCharacters: CharacterSet = {
        let allowedCharacterSet = NSMutableCharacterSet.alphanumeric()
        allowedCharacterSet.addCharacters(in: "*-._ ")
        return allowedCharacterSet as CharacterSet
    }()

    public static func formURLEncode(parameters: [String: String]) -> Data? {
        let encoded = parameters.map { key, value in
            let encodedKey = formURLEncodeValue(key)
            let encodedValue = formURLEncodeValue(value)
            return "\(encodedKey)=\(encodedValue)"
        }
        .joined(separator: "&")
        .data(using: .utf8)
        
        return encoded
    }
    
    public static func basicAuth(username: String, password: String) -> String {
        let encoded = base64URLEncode("\(username):\(password)")
        return "Basic \(encoded)"
    }
      
    private static func formURLEncodeValue(_ value: String) -> String {
        let encoded = value.addingPercentEncoding(withAllowedCharacters: HTTPUtil.formEncodeAllowedCharacters) ?? ""
        return encoded.replacingOccurrences(of: " ", with: "+")
    }
    
    private static func base64URLEncode(_ value: String) -> String {
        guard let data = value.data(using: .utf8) else {
            preconditionFailure("Failed to encode data for base64")
        }

        let result = data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        return result
    }
}

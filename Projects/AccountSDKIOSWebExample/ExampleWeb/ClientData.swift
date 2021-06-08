import Foundation

struct ClientData: Codable {
    let clientId: String = "5a6719bee090171db298db69"
    let redirectURI: String 
    let appTeamId: String?
    
    public static func fromPlist(resource: String) -> ClientData? {
        if let path = Bundle.main.path(forResource: resource, ofType: "plist"),
           let xml = FileManager.default.contents(atPath: path),
           let clientData = try? PropertyListDecoder().decode(ClientData.self, from: xml) {
            return clientData
        }
        
        return nil
    }
}

import Foundation

public extension Bundle {

    static func accountSDK(for frameworkClass: AnyClass) -> Bundle {
        #if SPM
            return Bundle.module
        #endif
        
        guard let moduleName = String(reflecting: frameworkClass).components(separatedBy: ".").first else {
            fatalError("Couldn't determine module name from class \(frameworkClass)")
        }

        let frameworkBundle = Bundle(for: frameworkClass)

        guard let resourceBundleURL = frameworkBundle.url(forResource: moduleName, withExtension: "bundle"),
              let resourceBundle = Bundle(url: resourceBundleURL) else {
            return Bundle(for: SimplifiedLoginViewController.self)
        }
        return resourceBundle
    }
    
    static func applicationName() -> String {
        return (Bundle.main.infoDictionary?["CFBundleName"] as? String) ?? ""
    }
}
 

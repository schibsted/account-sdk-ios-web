import Foundation

#if !SPM
public extension Bundle {

    static func resourceBundle(for frameworkClass: AnyClass) -> Bundle {
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
    
//    static var module: Bundle {
//        Bundle(for: SimplifiedLoginViewController.self)
//    }
}
#endif

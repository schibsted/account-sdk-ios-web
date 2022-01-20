import Foundation
import UIKit


class UINavigationControllerWithLockedOrientation: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //do this just for iphone
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        .portrait
    }

    override var shouldAutorotate: Bool {
        return false
    }
}

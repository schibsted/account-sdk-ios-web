import XCTest
@testable import AccountSDKIOSWeb

final class UIWindowVisibleVCTests: XCTestCase {
    
    
    func testReturnsVisibleViewController() {
        let vc = UIViewController()
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
        
        XCTAssertEqual(window.visibleViewController, vc)
        
    }
    
    func testReturnsVisibleViewControllerFromNavigation() {
        let vc = UIViewController()
        let navigationController = UINavigationController()
        navigationController.pushViewController(vc, animated: false)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        XCTAssertEqual(window.visibleViewController, vc)
        
    }
    
    func testReturnsVisibleViewControllerFromTabBar() {
        let vc = UIViewController()
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [vc]
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        
        XCTAssertEqual(window.visibleViewController, vc)
        
    }
}

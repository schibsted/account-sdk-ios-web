//
// Copyright © 2025 Schibsted.
// Licensed under the terms of the MIT license. See LICENSE in the project root.
//

import XCTest
@testable import AccountSDKIOSWeb

final class UIWindowVisibleVCTests: XCTestCase {
    @MainActor
    func testReturnsVisibleViewController() {
        let vc = UIViewController()
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.makeKeyAndVisible()
    
        XCTAssertEqual(window.visibleViewController, vc)
    }

    @MainActor
    func testReturnsVisibleViewControllerFromNavigation() {
        let vc = UIViewController()
        let navigationController = UINavigationController()
        navigationController.pushViewController(vc, animated: false)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        XCTAssertEqual(window.visibleViewController, vc)
        
    }

    @MainActor
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

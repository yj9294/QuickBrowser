//
//  RootVC.swift
//  QuickBrowser
//
//  Created by yangjian on 2022/8/12.
//

import UIKit

class RootVC: UITabBarController {
    
    lazy var launch: LaunchVC = {
        return LaunchVC()
    }()
    
    lazy var homeVC: HomeVC = {
        return HomeVC()
    }()
    
    lazy var home: UINavigationController = {
        return UINavigationController(rootViewController: homeVC)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewControllers = [launch, home]
        self.tabBar.isHidden = true
        FirebaseManager.logProperty(name: .local, value: Locale.current.regionCode)
        FirebaseManager.logEvent(name: .open)
        FirebaseManager.logEvent(name: .openCold)
    }

    func launching() {
        self.selectedIndex = 0
        launch.beginLaunch()
    }
    
    func launched() {
        self.selectedIndex = 1
        launch.stopLaunch()
    }
}

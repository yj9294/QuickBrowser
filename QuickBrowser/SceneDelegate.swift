//
//  SceneDelegate.swift
//  QuickBrowser
//
//  Created by admin on 8/15/22.
//

import UIKit
import FBSDKCoreKit
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    lazy var rootVC: RootVC = {
        let root = RootVC()
        return root
    }()


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        FirebaseApp.configure()
        
        guard let _ = (scene as? UIWindowScene) else { return }
        scenceDelegate = self
        self.window?.rootViewController = rootVC
        
        guard let url =  connectionOptions.urlContexts.first?.url else {
                return
        }
        
        ApplicationDelegate.shared.application(
                UIApplication.shared,
                open: url,
                sourceApplication: nil,
                annotation: [UIApplication.OpenURLOptionsKey.annotation]
            )
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        if scenceEnterbackground == true {
            FirebaseManager.logEvent(name: .openHot)
        }
        scenceEnterbackground = false
        rootVC.launching()
        if rootVC.presentedViewController != nil {
            if rootVC.presentedViewController?.presentedViewController != nil {
                rootVC.presentedViewController?.presentedViewController?.dismiss(animated: true)
            }
            rootVC.presentedViewController?.dismiss(animated: true)
        }
        CleanAnimationView.clean()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        scenceEnterbackground = true
        CleanAnimationView.clean()
    }


}



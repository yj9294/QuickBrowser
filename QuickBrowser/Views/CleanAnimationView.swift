//
//  CleanAnimationView.swift
//  QuickBrowser
//
//  Created by yangjian on 2022/8/15.
//

import UIKit
import Lottie

class CleanAnimationView: UIView {
    let animationView: AnimationView = AnimationView(name: "cleanAnimation")
    
    func play(completion: (()->Void)? = nil) {
        self.backgroundColor = UIColor(red: 28.0 / 255.0, green: 40.0 / 255.0, blue: 55.0 / 255.0, alpha: 1)
        self.addSubview(animationView)
        let scences: [UIWindowScene] = UIApplication.shared.connectedScenes.filter {
            $0.activationState == .foregroundActive
        }.compactMap {
            $0 as? UIWindowScene
        }
        if let window = scences.first?.windows.first {
            window.addSubview(self)
            self.frame = window.bounds
            animationView.frame = window.bounds
        }
        animationView.play()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.animationView.stop()
            self.removeFromSuperview()
            completion?()
        }
    }
    
    static func clean() {
        let scences: [UIWindowScene] = UIApplication.shared.connectedScenes.filter {
            $0.activationState == .foregroundActive
        }.compactMap {
            $0 as? UIWindowScene
        }
        if let window = scences.first?.windows.first {
            window.subviews.forEach {
                if $0 is Self {
                    $0.removeFromSuperview()
                }
            }
        }
    }
}

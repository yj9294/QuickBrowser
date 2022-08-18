//
//  LaunchVC.swift
//  QuickBrowser
//
//  Created by yangjian on 2022/8/12.
//

import UIKit

class LaunchVC: BaseVC {

    @IBOutlet weak var progressView: UIProgressView!
    
    var progress: Double = 0.0
    var duration: Double = 0.0
    var maxTime: Double = 15.6
    var minTime: Double = 2.5
    var timer: Timer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func beginLaunch() {
        progress = 0.0
        duration = 2.5 / 0.6
        var isShowAd = false
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { [weak self] timer in
            guard let self = self else { return }
            let progress = self.duration / 0.01
            self.progress += 1 / progress
            if self.progress > 1.0 {
                timer.invalidate()
                ADManager.share.show(.interstitial) { _ in
                    rootVC.launched()
                }
            } else {
                self.progressView.progress = Float(self.progress)
            }
            
            if ADManager.share.isLoaded(.interstitial), isShowAd {
                isShowAd = false
                self.duration = 1.0
            }
        })
        
        Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { timer in
            timer.invalidate()
            self.duration = self.maxTime
            isShowAd = true
        }
        
        
        ADManager.share.load(.interstitial)
        ADManager.share.load(.native)
    }
    
    func stopLaunch() {
        self.timer?.invalidate()
    }

}

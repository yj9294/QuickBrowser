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
    var maxTime: Double = 14.0
    var minTime: Double = 2.5
    var timer: Timer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func beginLaunch() {
        progress = 0.0
        duration = minTime
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            let progress = self.duration / 0.01
            self.progress += 1 / progress
            if self.progress > 1.0 {
                rootVC.launched()
            } else {
                self.progressView.progress = Float(self.progress)
            }
        })
    }
    
    func stopLaunch() {
        self.timer?.invalidate()
    }

}

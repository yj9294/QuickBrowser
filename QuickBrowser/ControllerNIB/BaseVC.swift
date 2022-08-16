//
//  BaseVC.swift
//  QuickBrowser
//
//  Created by yangjian on 2022/8/12.
//

import UIKit

class BaseVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        commonInit()
    }
    
    deinit {
        debugPrint("\(self.classForCoder) deinit ✅✅✅✅")
    }

}

extension BaseVC {
    @objc func setupUI() {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @objc func commonInit() {
        
    }
}

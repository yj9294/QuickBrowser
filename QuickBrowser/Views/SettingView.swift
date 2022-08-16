//
//  SettingVC.swift
//  QuickBrowser
//
//  Created by yangjian on 2022/8/15.
//

import UIKit

class SettingView: UIView, NibLoadable {
    
    var completion: (()->Void)? = nil
    var newHandle: (()->Void)? = nil
    var shareHandle: (()->Void)? = nil
    var copyHandle: (()->Void)? = nil
    var rateHandle: (()->Void)? = nil
    var termsHandle: (()->Void)? = nil
    var privacyHandle: (()->Void)? = nil

    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var lineView: UIView!
    
    @IBAction func newAction(_ sender: Any) {
        dismiss()
        newHandle?()
    }
    @IBAction func shareAction(_ sender: Any) {
        dismiss()
        shareHandle?()
    }
    @IBAction func copyAction(_ sender: Any) {
        dismiss()
        copyHandle?()
    }
    @IBAction func rateAction(_ sender: Any) {
        dismiss()
        rateHandle?()
    }
    @IBAction func termsAction(_ sender: Any) {
        dismiss()
        termsHandle?()
    }
    @IBAction func privacyAction(_ sender: Any) {
        dismiss()
        privacyHandle?()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.cornerRadius = 8
        self.contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.lineView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] _ in
            self?.dismiss()
        }
    }
    
    @objc func dismiss() {
        self.removeFromSuperview()
    }
    
    func present(){
        let scences: [UIWindowScene] = UIApplication.shared.connectedScenes.filter {
            $0.activationState == .foregroundActive
        }.compactMap {
            $0 as? UIWindowScene
        }
        if let window = scences.first?.windows.first {
            window.addSubview(self)
            self.frame = window.bounds
        }
    }
}

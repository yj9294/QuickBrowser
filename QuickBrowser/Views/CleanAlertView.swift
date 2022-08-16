//
//  CleanAlertView.swift
//  QuickBrowser
//
//  Created by yangjian on 2022/8/15.
//

import UIKit

class CleanAlertView: UIView, NibLoadable {


    @IBOutlet weak var cancelButton: UIButton!
    
    var completion: (()->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.cancelButton.layer.borderColor = UIColor(red: 194.0 / 255.0 , green: 194.0 / 255.0, blue: 194.0 / 255.0, alpha: 1).cgColor
        self.cancelButton.layer.borderWidth = 1
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] _ in
            self?.dismiss()
        }
    }
    
    @IBAction func cancelAction() {
        dismiss()
    }
    
    @IBAction func certainAction() {
        dismiss()
        completion?()
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

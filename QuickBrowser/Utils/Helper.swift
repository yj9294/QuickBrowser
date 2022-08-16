//
//  Helper.swift
//  QuickBrowser
//
//  Created by yangjian on 2022/8/12.
//

import Foundation
import UIKit

class GradientView: UIView {
    
    @IBInspectable public var isGradient: Bool = false
    @IBInspectable var startColor: UIColor = .white
    @IBInspectable var endColor: UIColor = .white
    @IBInspectable var locations: [NSNumber] = [0 , 1]
    @IBInspectable var startPoint: CGPoint = .zero
    @IBInspectable var endPoint: CGPoint = .zero
     
    private var gradientBGLayer: CAGradientLayer?
     
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientBGLayer?.removeFromSuperlayer()
        if isGradient {
            gradientBGLayer = CAGradientLayer()
            gradientBGLayer!.colors = [startColor.cgColor, endColor.cgColor]
            gradientBGLayer!.locations = locations
            gradientBGLayer!.frame = bounds
            gradientBGLayer!.startPoint = startPoint
            gradientBGLayer!.endPoint = endPoint
            self.layer.insertSublayer(gradientBGLayer!, at: 0)
        }
    }
}

extension String {
    var isUrl: Bool {
        let url = "[a-zA-z]+://.*"
        let predicate = NSPredicate(format: "SELF MATCHES %@", url)
        return predicate.evaluate(with: self)
    }
}

extension UIViewController {
    func alert(_ message: String) {
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        if rootVC.selectedIndex == 1 {
            self.present(alertController, animated: true)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak alertController] in
            alertController?.dismiss(animated: true)
        }
    }
}

protocol NibLoadable {
}

extension NibLoadable where Self: UIView {
    static func loadFromNib(_ nibname: String? = nil) -> Self {
        let loadName = nibname == nil ? "\(self)" : nibname!
        return Bundle.main.loadNibNamed(loadName, owner: nil, options: nil)?.first as! Self
    }
}

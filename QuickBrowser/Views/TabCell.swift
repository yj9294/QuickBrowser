//
//  TabCell.swift
//  QuickBrowser
//
//  Created by yangjian on 2022/8/15.
//

import UIKit
import WebKit

class TabCell: UICollectionViewCell {
    
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    var item: BrowserItem = BrowserItem.navgationItem {
        didSet {
            
            if BrowserManager.defaults.items.count == 1 {
                self.deleteButton.isHidden = true
            } else {
                self.deleteButton.isHidden = false
            }
            
            self.subviews.forEach {
                if $0 is WKWebView {
                    $0.removeFromSuperview()
                }
            }
            
            self.urlLabel.text = item.webView.url?.absoluteString
            if !item.isNavigation{
                self.insertSubview(item.webView, at: 0)
                item.webView.isUserInteractionEnabled = false
            } else {
                self.urlLabel.text = "Home"
            }
        }
    }
    
    var select: Bool = false {
        didSet {
            if select {
                self.layer.borderColor = UIColor(red: 150.0 / 255.0, green: 187.0 / 255.0, blue: 243.0 / 255.0, alpha: 1.0).cgColor
                self.layer.borderWidth = 3
            } else {
                self.layer.borderColor = UIColor.clear.cgColor
            }
        }
    }
    
    var closeHandle: (()->Void)? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
    }
    
    @IBAction func closeAction() {
        closeHandle?()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.item.webView.frame = self.bounds
    }

    static var reuseIdentifier: String {
        return "TabCell"
    }
}

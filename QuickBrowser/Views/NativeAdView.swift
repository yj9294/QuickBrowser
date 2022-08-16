//
//  NativeAdView.swift
//  QuickBrowser
//
//  Created by yangjian on 2022/8/16.
//

import Foundation
import GoogleMobileAds

class NativeAdView: GADNativeAdView {
    
    @IBOutlet weak var placeholderView: UIImageView!
    @IBOutlet weak var adView: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var installLabel: UIButton!

    func refreshUI(ad: GADNativeAd? = nil) {
        self.nativeAd = ad
        self.iconView = self.iconImageView
        self.headlineView = self.titleLabel
        self.bodyView = self.subTitleLabel
        self.callToActionView = self.installLabel
        self.installLabel.setTitle(ad?.callToAction, for: .normal)
        self.iconImageView.image = ad?.icon?.image
        self.titleLabel.text = ad?.headline
        self.subTitleLabel.text = ad?.body
        self.hiddenSubviews(hidden: self.nativeAd == nil)
        if ad == nil {
            self.placeholderView.isHidden = false
        } else {
            self.placeholderView.isHidden = true
        }
    }
    
    func hiddenSubviews(hidden: Bool) {
        self.iconImageView.isHidden = hidden
        self.titleLabel.isHidden = hidden
        self.subTitleLabel.isHidden = hidden
        self.installLabel.isHidden = hidden
        self.adView.isHidden = hidden
    }
}

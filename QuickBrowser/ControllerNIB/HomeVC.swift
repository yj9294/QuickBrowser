//
//  HomeVC.swift
//  QuickBrowser
//
//  Created by yangjian on 2022/8/12.
//

import UIKit
import WebKit
import MobileCoreServices
import AppTrackingTransparency

class HomeVC: BaseVC {
    
    var start: Date = Date()
    
    var willApear = false

    @IBOutlet weak var topView: GradientView!
    @IBOutlet weak var bottomView: GradientView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var tabLabel: UILabel!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var webView: UIView!
    @IBOutlet weak var searchView: UITextField!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var adView: NativeAdView!
    
    var item: BrowserItem {
        BrowserManager.defaults.item
    }
    
    var loadItem: BrowserItem? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            ATTrackingManager.requestTrackingAuthorization { _ in
            }
        }
        self.searchView.addTarget(self, action: #selector(searchAction), for: .valueChanged)
        
        NotificationCenter.default.addObserver(forName: .nativeUpdate, object: nil, queue: .main) { [weak self] noti in
            if let ad = noti.object as? NativeADModel, self?.willApear == true {
                self?.adView.refreshUI(ad: ad.nativeAd)
            } else {
                self?.adView.refreshUI(ad: nil)
            }
        }
    }

    @IBAction func goBackAction(_ sender: Any) {
        if self.item.webView.backForwardList.backList.count == 1 {
            self.backButton.isEnabled = false
        }
        self.item.webView.goBack()
    }
    
    @IBAction func goNextAction(_ sender: Any) {
        if self.item.webView.backForwardList.forwardList.count == 1 {
            self.nextButton.isEnabled = false
        }
        self.item.webView.goForward()
    }
    
    @IBAction func goCleanAction(_ sender: Any) {
        FirebaseManager.logEvent(name: .cleanClick)
        let view = CleanAlertView.loadFromNib()
        view.present()
        view.completion = {
            /// 关闭首页原生动画
            ADManager.share.close(.native)
            /// 开始清理动画
            CleanAnimationView.share.play()
            /// 停止网页加载进度条
            self.refreshSearchButton(false)
            
            /// 广告请求倒计时
            var totalProgres = 0.0
            var duration = 15.6
            Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
                let progress = duration / 0.01
                totalProgres += 1 / progress
                if scenceEnterbackground {
                    timer.invalidate()
                    CleanAnimationView.share.stop()
                    return
                }
                if totalProgres > 1 {
                    timer.invalidate()
                    CleanAnimationView.share.stop()
                    ADManager.share.show(.interstitial) { _ in
                        self.cleanup()
                    }
                }
                if ADManager.share.isLoaded(.interstitial) {
                    duration = 2.5
                }
            }
        }
    }
    
    func cleanup() {
        /// 清理成功完成预加载
        ADManager.share.load(.native)
        ADManager.share.load(.interstitial)
        
        BrowserManager.defaults.items = [.navgationItem]
        self.refreshWebView()
        self.alert("Clean successfully.")
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: [WKWebsiteDataTypeCookies]) {
           _ = $0.map {
                WKWebsiteDataStore.default().removeData(ofTypes: $0.dataTypes, for: [$0]) {
                    debugPrint("clean cookies")
                }
            }
        }
        
        FirebaseManager.logEvent(name: .cleanSuccess)
        FirebaseManager.logEvent(name: .cleanAlert)
        FirebaseManager.logEvent(name: .navigaShow)
    }
    
    @IBAction func goTabAcction(_ sender: Any) {
        let vc = TabVC()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    @IBAction func goSettingAction(_ sender: Any) {
        let settingView = SettingView.loadFromNib()
        settingView.present()
        settingView.newHandle = {
            BrowserManager.defaults.items.forEach {
                $0.isSelect = false
            }
            BrowserManager.defaults.items.insert(.navgationItem, at: 0)
            self.refreshWebView()
            FirebaseManager.logEvent(name: .tabNew, params: ["bro": "setting"])
            FirebaseManager.logEvent(name: .navigaShow)
        }
        settingView.shareHandle = {
            if let url = self.item.webView.url  {
                let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                self.present(vc, animated: true)
            } else {
                let vc = UIActivityViewController(activityItems: ["https://itunes.apple.com/cn/app/id1639973863"], applicationActivities: nil)
                self.present(vc, animated: true)
            }
            FirebaseManager.logEvent(name: .shareClick)
        }
        
        settingView.copyHandle = {
            let item = BrowserManager.defaults.item
            if let url = item.webView.url {
                UIPasteboard.general.setValue(url.absoluteString, forPasteboardType: kUTTypePlainText as String)
                self.alert("Copy successfully.")
            } else {
                UIPasteboard.general.setValue("", forPasteboardType: kUTTypePlainText as String)
                self.alert("Copy successfully.")
            }
            FirebaseManager.logEvent(name: .copyClick)
        }
        
        settingView.rateHandle = {
            let url = URL(string: "https://itunes.apple.com/cn/app/id1639973863")
            if let url = url {
                UIApplication.shared.open(url)
            }
        }
        
        settingView.termsHandle = {
            TermsView.loadFromNib().present()
        }
        
        settingView.privacyHandle = {
            PrivacyView.loadFromNib().present()
        }
    }
    
    
    @IBAction func facebookAction(_ sender: Any) {
        loadUrl(.facebook)
    }
    
    @IBAction func googleAction(_ sender: Any) {
        loadUrl(.google)
    }
    
    @IBAction func youtubeAction(_ sender: Any) {
        loadUrl(.youtube)
    }
    
    @IBAction func twitterAction(_ sender: Any) {
        loadUrl(.twitter)
    }
    
    @IBAction func instagramAction(_ sender: Any) {
        loadUrl(.instagram)
    }
    
    @IBAction func amazonAction(_ sender: Any) {
        loadUrl(.amazon)
    }
    
    @IBAction func gmailAction(_ sender: Any) {
        loadUrl(.gmail)
    }
    
    @IBAction func yahooAction(_ sender: Any) {
        loadUrl(.yahoo)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        item.webView.frame = CGRect(x: 0, y: -20, width: self.webView.bounds.width, height: self.webView.bounds.height + 40)
        item.webView.scrollView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: -20, right: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        willApear = true
        self.refreshWebView()
        FirebaseManager.logEvent(name: .homeShow)
        if self.item.isNavigation {
            FirebaseManager.logEvent(name: .navigaShow)
        }
        ADManager.share.load(.native)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        willApear = false
        ADManager.share.close(.native)
    }
}


extension HomeVC {
    override func setupUI() {
        super.setupUI()
        self.topView.layer.cornerRadius = 20
        self.bottomView.layer.cornerRadius = 20
        self.topView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        self.bottomView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.topView.layer.masksToBounds = true
        self.bottomView.layer.masksToBounds = true
        
    }
    
    func refreshWebView() {
        self.tabLabel.text = "\(BrowserManager.defaults.items.count)"
        self.navigationView.isHidden = !self.item.isNavigation
        self.webView.subviews.forEach {
            $0.removeFromSuperview()
            $0.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
            $0.removeObserver(self, forKeyPath: #keyPath(WKWebView.url))
        }
        self.item.webView.isUserInteractionEnabled = true
        self.webView.addSubview(self.item.webView)
        self.item.webView.navigationDelegate = self
        self.item.webView.uiDelegate = self
        self.item.webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: nil)
        self.item.webView.addObserver(self, forKeyPath: #keyPath(WKWebView.url), context: nil)
        self.searchView.text = self.item.webView.url?.absoluteString
        self.placeholderLabel.isHidden = self.searchView.text?.count != 0
        if self.loadItem != self.item {
            progressView.isHidden = true
            self.refreshSearchButton(false)
        }
    }
    
    func refreshSearchButton(_ isLoading: Bool) {
        if isLoading {
            self.searchButton.setImage(UIImage(named: "search_cancel"), for: .normal)
            self.searchButton.removeTarget(self, action: #selector(searchAction), for: .touchUpInside)
            self.searchButton.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        } else {
            self.searchButton.setImage(UIImage(named: "search_icon"), for: .normal)
            self.searchButton.removeTarget(self, action: #selector(cancelAction), for: .touchUpInside)
            self.searchButton.addTarget(self, action: #selector(searchAction), for: .touchUpInside)
        }
    }
    
    func loadUrl(_ browse: BrowseUrl){
        self.loadItem = self.item
        self.start = Date()
        self.item.loadUrl(browse.url)
        self.searchView.text = browse.url
        self.placeholderLabel.isHidden = true
        FirebaseManager.logEvent(name: .navigaClick, params: ["bro": browse.rawValue])
        searchAction()
    }
    
    @objc func searchAction() {
        self.view.endEditing(true)
        if self.searchView.text?.count == 0 {
            self.alert("Please enter your search content.")
            return
        }
        if self.item.isNavigation {
            FirebaseManager.logEvent(name: .navigaSearch, params: ["bro": self.searchView.text!])
        }
        self.loadItem = self.item
        self.start = Date()
        self.item.loadUrl(self.searchView.text!)
        self.refreshWebView()
    }

    
    @objc func cancelAction() {
        self.progressView.isHidden = true
        self.view.endEditing(true)
        self.item.webView.stopLoading()
        self.searchView.text = ""
        self.placeholderLabel.isHidden = false
        self.refreshSearchButton(false)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            if self.loadItem != self.item {
                return
            }
            self.progressView.isHidden = false
            self.refreshSearchButton(true)
            let progress: Float = Float(self.item.webView.estimatedProgress)
            UIView.animate(withDuration: 0.25) {
                self.progressView.progress = progress
            }
            if progress == 1.0 {
                // 加载完成
                self.progressView.progress = 0.0
                self.progressView.isHidden = true
                self.refreshSearchButton(false)
                let time = Date().timeIntervalSince1970 - start.timeIntervalSince1970
                FirebaseManager.logEvent(name: .webSuccess, params: ["bro": "\(ceil(time))"])
            }
        } else if keyPath == "URL" {
            self.searchView.text = self.item.webView.url?.absoluteString
            FirebaseManager.logEvent(name: .webStart)
        }
    }
}

extension HomeVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchAction()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.placeholderLabel.isHidden = true
        if textField.text?.count != 0 {
            self.refreshSearchButton(true)
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.placeholderLabel.isHidden = textField.text?.count != 0
        return true
    }
}

extension HomeVC: WKNavigationDelegate, WKUIDelegate {
    /// 跳转链接前是否允许请求url
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        self.backButton.isEnabled = webView.canGoBack
        self.nextButton.isEnabled = webView.canGoForward
        return .allow
    }
    
    /// 响应后是否跳转
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse) async -> WKNavigationResponsePolicy {
        self.backButton.isEnabled = webView.canGoBack
        self.nextButton.isEnabled = webView.canGoForward
        return .allow
    }
    
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if webView.url == nil {
            self.refreshWebView()
        }
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        /// 打开新的窗口
        self.backButton.isEnabled = webView.canGoBack
        self.nextButton.isEnabled = webView.canGoForward
        
        let frameInfo = navigationAction.targetFrame
        if frameInfo?.isMainFrame == true {
            webView.load(navigationAction.request)
        }
        webView.load(navigationAction.request)
        return nil
    }
    
}

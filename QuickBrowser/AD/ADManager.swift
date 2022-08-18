//
//  ADManager.swift
//  QuickBrowser
//
//  Created by yangjian on 2022/8/16.
//

import Foundation
import Firebase

class ADManager: NSObject {
    
    static let share = ADManager()
    override init() {
        super.init()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.ads.forEach {
                $0.loadedArray = $0.loadedArray.filter({ model in
                    return model.loadedDate?.isExpired == false
                })
            }
        }
    }
    
    // 本地记录 配置
    var adConfig: ADConfig? {
        set{
            UserDefaults.standard.setObject(newValue, forKey: .adConfig)
        }
        get {
            UserDefaults.standard.getObject(ADConfig.self, forKey: .adConfig)
        }
    }
    
    // 本地记录 限制次数
    var limit: ADLimit? {
        set{
            UserDefaults.standard.setObject(newValue, forKey: .adLimited)
        }
        get {
            UserDefaults.standard.getObject(ADLimit.self, forKey: .adLimited)
        }
    }
    
    // 本地记录 拉黑时间
    var isUserCanShowAdmobDate: Date? {
        set{
            UserDefaults.standard.setObject(newValue, forKey: .adUnAvaliableDate)
        }
        get {
            UserDefaults.standard.getObject(Date.self, forKey: .adUnAvaliableDate)
        }
    }
    
    /// 是否拉黑
    var isUserCanShowAD: Bool {
        if isUserCanShowAdmobDate == nil {
            return true
        }
        return Date().timeIntervalSince1970 >= (isUserCanShowAdmobDate ?? Date()).timeIntervalSince1970
    }
    
    /// 是否超限
    var isADLimited: Bool {
        if limit?.date.isToday == true {
            if (limit?.showTimes ?? 0) >= (adConfig?.showTimes ?? 0) || (limit?.clickTimes ?? 0) >= (adConfig?.clickTimes ?? 0) {
                return true
            }
        }
        return false
    }
    
    /// 是否需要插屏显示间隔
    var isNeedInterstitialShow = false
    
    /// 广告位加载模型
    let ads:[ADLoadModel] = ADPosition.allCases.map { p in
        ADLoadModel(position: p)
    }.filter { m in
        m.position != .all
    }
    
    func isLoaded(_ position: ADPosition) -> Bool {
        return self.ads.filter {
            $0.position == position
        }.first?.isLoaded == true
    }
    
    /// 请求远程配置
    func requestRemoteConfig() {
        // 获取本地配置
        if adConfig == nil {
            let path = Bundle.main.path(forResource: "admob", ofType: "json")
            let url = URL(fileURLWithPath: path!)
            do {
                let data = try Data(contentsOf: url)
                adConfig = try JSONDecoder().decode(ADConfig.self, from: data)
                QLog("[Config] Read local ad config success.")
            } catch let error {
                QLog("[Config] Read local ad config fail.\(error.localizedDescription)")
            }
        }
        
        /// 远程配置
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        remoteConfig.configSettings = settings
        remoteConfig.fetch { [weak remoteConfig] (status, error) -> Void in
            if status == .success {
                QLog("[Config] Config fetcher! ✅")
                remoteConfig?.activate(completion: { _, _ in
                    let keys = remoteConfig?.allKeys(from: .remote)
                    QLog("[Config] config params = \(keys ?? [])")
                    if let remoteAd = remoteConfig?.configValue(forKey: "adConfig").stringValue {
                        // base64 的remote 需要解码
                        let data = Data(base64Encoded: remoteAd) ?? Data()
                        if let remoteADConfig = try? JSONDecoder().decode(ADConfig.self, from: data) {
                            // 需要在主线程
                            DispatchQueue.main.async {
                                self.adConfig = remoteADConfig
                            }
                        } else {
                            QLog("[Config] Config config 'ad_config' is nil or config not json.")
                        }
                    }
                })
            } else {
                QLog("[Config] config not fetcher, error = \(error?.localizedDescription ?? "")")
            }
        }
        
        /// 广告配置是否是当天的
        if limit == nil || limit?.date.isToday != true {
            limit = ADLimit(showTimes: 0, clickTimes: 0, date: Date())
        }
    }
    
    /// 限制
    func add(_ status: ADLimit.Status) {
        if isADLimited {
            QLog("[AD] 用戶超限制。")
            clean(.all)
            close(.all)
            return
        }
        if status == .show {
            let showTime = limit?.showTimes ?? 0
            limit?.showTimes = showTime + 1
            QLog("[AD] [LIMIT] showTime: \(showTime+1) total: \(adConfig?.showTimes ?? 0)")
        } else  if status == .click {
            let clickTime = limit?.clickTimes ?? 0
            limit?.clickTimes = clickTime + 1
            QLog("[AD] [LIMIT] clickTime: \(clickTime+1) total: \(adConfig?.clickTimes ?? 0)")
        }
    }
    
    /// 加载
    func load(_ position: ADPosition) {
        let ads = ads.filter{
            $0.position == position
        }
        if let ad = ads.first {
            ad.beginAddWaterFall { isSuccess in
                if isSuccess {
                    switch position {
                    case .native:
                        self.show(position) { ad in
                            NotificationCenter.default.post(name: .nativeUpdate, object: ad)
                        }
                    default:
                        break
                    }
                }
            }
        }
    }
    
    /// 展示
    func show(_ position: ADPosition, completion: @escaping (ADBaseModel?)->Void) {
        // 超限需要清空广告
        if isADLimited {
            clean(.all)
        }
        // 拉黑需要清空广告
        if !isUserCanShowAD {
            clean(.all)
            close(.all)
        }
        let loadAD = ads.filter {
            $0.position == position
        }.first
        switch position {
        case .interstitial:
            /// 有廣告
            if let ad = loadAD?.loadedArray.first as? InterstitialADModel,
               isUserCanShowAD, !scenceEnterbackground, !isADLimited {
                ad.impressionHandler = { [weak self, loadAD] in
                    if self?.isNeedInterstitialShow == true {
                        loadAD?.impressionDate = Date()
                    }
                    self?.add(.show)
                    self?.display(position)
                    self?.load(position)
                }
                ad.clickHandler = { [weak self] in
                    self?.add(.click)
                }
                ad.closeHandler = { [weak self] in
                    self?.close(position)
                    completion(nil)
                }
//                ad.clickTwiceHandler = { _ in
//                    self?.clean(.all)
                    /// 48小时
//                    let date = Date(timeIntervalSinceNow: 48 * 60 * 60)
//                    self?.isUserCanShowAdmobDate = date
//                }
                if !scenceEnterbackground {
                    if isNeedInterstitialShow {
                        if loadAD?.isNeedShow == true {
                            ad.present()
                        } else {
                            completion(nil)
                        }
                    } else {
                        ad.present()
                    }
                }
            } else {
                completion(nil)
            }
            
        case .native:
            if let ad = loadAD?.loadedArray.first as? NativeADModel, !scenceEnterbackground, !isADLimited {
                /// 预加载回来数据 当时已经有显示数据了
                if loadAD?.isDisplay == true {
                    return
                }
                ad.nativeAd?.unregisterAdView()
                ad.nativeAd?.delegate = ad
                ad.impressionHandler = {
                    loadAD?.impressionDate = Date()
                    self.add(.show)
                    self.display(position)
                    self.load(position)
                }
                ad.clickHandler = {
                    self.add(.click)
                }
                // 10秒间隔
                if loadAD?.isNeedShow == true {
                    completion(ad)
                }
            } else {
                /// 预加载回来数据 当时已经有显示数据了 并且没超过限制
                if loadAD?.isDisplay == true, !isADLimited {
                    return
                }
                completion(nil)
            }
        default:
            break
        }
    }
    
    /// 清除缓存 针对loadedArray数组
    func clean(_ position: ADPosition) {
        switch position {
        case .all:
            ads.filter{
                $0.position.isNativeAD
            }.forEach {
                $0.clean()
            }
        default:
            let loadAD = ads.filter{
                $0.position == position
            }.first
            loadAD?.clean()
        }
    }
    
    /// 关闭正在显示的广告（原生，插屏）针对displayArray
    func close(_ position: ADPosition) {
        switch position {
        case .all:
            ads.forEach {
                $0.closeDisplay()
            }
        default:
            ads.filter{
                $0.position == position
            }.first?.closeDisplay()
        }
        if position == .native || position == .all {
            NotificationCenter.default.post(name: .nativeUpdate, object: nil)
        }
    }
    
    /// 展示
    func display(_ position: ADPosition) {
        switch position {
        case .all:
            break
        default:
            ads.filter {
                $0.position == position
            }.first?.display()
        }
    }
    
    func dismiss() {
        ads.forEach {
            if let ad = $0.loadedArray.first as? InterstitialADModel {
                ad.dismiss()
            }
            if let ad = $0.displayArray.first as? InterstitialADModel {
                ad.dismiss()
            }
        }
    }
}


extension Notification.Name {
    static let nativeUpdate = Notification.Name(rawValue: "homeNativeUpdate")
}

extension String {
    static let adConfig = "adConfig"
    static let adLimited = "adLimited"
    static let adUnAvaliableDate = "adUnAvaliableDate"
}

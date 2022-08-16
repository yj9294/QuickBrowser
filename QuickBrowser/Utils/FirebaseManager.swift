//
//  FirebaseManager.swift
//  QuickBrowser
//
//  Created by yangjian on 2022/8/15.
//

import Foundation

class FirebaseManager: NSObject {
    static let shared = FirebaseManager()
    static func logEvent(name: FirebaseEvent, params: [String: Any]? = nil) {
        
        if name.first {
            if UserDefaults.standard.bool(forKey: name.rawValue) == true {
                return
            } else {
                UserDefaults.standard.set(true, forKey: name.rawValue)
            }
        }
        
        #if DEBUG
        #else
        Analytics.logEvent(name.rawValue, parameters: params)
        #endif
        
        debugPrint("[ANA] [Event] \(name.rawValue) \(params ?? [:])")
    }
    
    static func logProperty(name: FirebaseProperty, value: String? = nil) {
        
        var value = value
        
        if name.first {
            if UserDefaults.standard.string(forKey: name.rawValue) != nil {
                value = UserDefaults.standard.string(forKey: name.rawValue)!
            } else {
                UserDefaults.standard.set(Locale.current.regionCode ?? "us", forKey: name.rawValue)
            }
        }
#if DEBUG
#else
        Analytics.setUserProperty(value, forName: name.rawValue)
#endif
        debugPrint("[ANA] [Property] \(name.rawValue) \(value ?? "")")
    }
}

enum FirebaseProperty: String {
    /// 設備
    case local = "city"
    
    var first: Bool {
        switch self {
        case .local:
            return true
        }
    }
}

enum FirebaseEvent: String {
    
    var first: Bool {
        switch self {
        case .open:
            return true
        default:
            return false
        }
    }
    
    /// 首次打開
    case open = "lunch"
    /// 冷啟動
    case openCold = "clunch"
    /// 熱起動
    case openHot = "hlunch"
    
    /// 主頁展示
    case homeShow = "onepage"
    
    /// 展示导航页面
    case navigaShow = "gu_sh"
    
    /// 导航点击
    /// bro（点击的网站）：facebook / google / youtube / twitter / instagram / amazon / gmail / yahoo
    case navigaClick = "gu_se"
    
    /// 在导航页上方输入栏中输入内容，并点击键盘上的 search
    /// bro（用户输入的内容）：具体的内容直接打印出来
    case navigaSearch = "gue_ma"
    
    /// clean click
    case cleanClick = "cl1"
    
    /// 清理动画展示完成
    case cleanSuccess = "cl2"
    
    /// 展示清理成功的 toast 提示
    /// bro（点击清理按钮～展示 toast 的时间）：秒，时间向上取整，不足 1 计 1
    case cleanAlert = "cl3"
    
    /// 展示 tab 管理页
    case tabShow = "tab_sh"
    
    /// 点击开启新 tab 按钮时，立马打点
    /// - 包括：tab 管理页点击底部加号、设置弹窗点击加号
    /// bro（点击开启新 tab 按钮的位置）：tab（tab 管理页）/ setting（设置弹窗）
    case tabNew = "tab_n"
    
    
    /// share click
    case shareClick = "setg_share"
    
    /// copy click
    case copyClick = "setg_copy"
    
    case webStart = "web_start"
    
    /// bro（开始请求～加载成功的时间）：秒，时间向上取整，不足 1 计 1
    case webSuccess = "web_su"
}

//
//  BrowserManager.swift
//  QuickBrowser
//
//  Created by yangjian on 2022/8/12.
//

import Foundation
import UIKit
import WebKit

class BrowserManager: NSObject {
    static let defaults = BrowserManager()
    var items: [BrowserItem] = [.navgationItem]
    var item: BrowserItem {
        items.filter {
            $0.isSelect == true
        }.first ?? .navgationItem
    }
    
    func removeItem(_ item: BrowserItem) {
        if item.isSelect {
            self.items = self.items.filter {
                $0 != item
            }
            self.items.first?.isSelect = true
        } else {
            self.items = self.items.filter {
                $0 != item
            }
        }
    }
}

enum BrowseUrl: String {
    case facebook, google, youtube, twitter, instagram, amazon, gmail, yahoo
    var url: String {
        switch self {
        case .facebook:
            return "https://www.facebook.com"
        case .google:
            return "https://www.google.com"
        case .youtube:
            return "https://www.youtube.com"
        case .twitter:
            return "https://www.twitter.com"
        case .instagram:
            return "https://www.instagram.com"
        case .amazon:
            return "https://www.amazon.com"
        case .gmail:
            return "https://www.gmail.com"
        case .yahoo:
            return "https://www.yahoo.com"
        }
    }
}


class BrowserItem: NSObject {
    init(webView: WKWebView, isSelect: Bool) {
        self.webView = webView
        self.isSelect = isSelect
    }
    var webView: WKWebView
    var isNavigation: Bool {
        webView.url == nil
    }
    var isSelect: Bool
    
    func loadUrl(_ url: String) {
        if url.isUrl, let Url = URL(string: url) {
            let request = URLRequest(url: Url)
            webView.load(request)
        } else {
            let urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let reqString = "https://www.google.com/search?q=" + urlString
            self.loadUrl(reqString)
        }
    }
    
    static var navgationItem: BrowserItem {
        return BrowserItem(webView: WKWebView(), isSelect: true)
    }
}

//
//  AppOptions.swift
//  QuickBrowser
//
//  Created by yangjian on 2022/8/12.
//

import Foundation

var isRelease = false

var scenceDelegate: SceneDelegate? = nil

var scenceEnterbackground: Bool = false

var rootVC: RootVC {
    scenceDelegate?.rootVC ?? RootVC()
}

func QLog(_ log: @autoclosure () -> String) {
    if !isRelease {
        NSLog("\(log())")
    } else {
        debugPrint(log())
    }
}

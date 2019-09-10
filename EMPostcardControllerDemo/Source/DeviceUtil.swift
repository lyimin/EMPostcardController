//
//  DeviceUtil.swift
//  EMPostcardControllerDemo
//
//  Created by EamonLiang on 2019/9/4.
//  Copyright © 2019 EamonLiang. All rights reserved.
//

import UIKit



class DeviceUtil: NSObject {
    
    /// 屏幕大小
    class var screenSize: CGSize {
        get {
            return UIScreen.main.bounds.size
        }
    }
  
    /// 判断是否是刘海屏
    class var isNotchScreen: Bool {
        get {
            if #available(iOS 11.0, *) {
                if (UI_USER_INTERFACE_IDIOM() == .phone) {
                    let window = UIApplication.shared.windows.first
                    let safeAreaBottom: CGFloat = window?.safeAreaInsets.bottom ?? 0
                    return safeAreaBottom > 0
                }
            }
            return false
        }
    }
    
    /// 安全区域顶部高度
    class var safeAreaBottomHeight: CGFloat {
        get {
            if isNotchScreen {
                return 44
            }
            return 20
        }
    }
    
    /// 安全区域底部高度
    class var safeAreaTopHeight: CGFloat {
        get {
            if isNotchScreen {
                return 34
            }
            return 0
        }
    }
}

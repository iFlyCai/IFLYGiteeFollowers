//
//  UIApplication+Extensions.swift
//  IFLYCommonKit
//
//  Created by iFlyCai on 2025/2/14.
//

import Foundation
// UIApplication 扩展，用于获取当前活动的 keyWindow
extension UIApplication {
    public var currentWindow: UIWindow? {
        return self.connectedScenes
            .filter { $0.activationState == .foregroundActive } // 筛选前台激活状态的场景
            .compactMap { $0 as? UIWindowScene }                // 转换为 UIWindowScene
            .first?.windows                                    // 获取窗口数组
            .first { $0.isKeyWindow }                          // 获取 keyWindow
    }
}
import UIKit
extension UIView {
    /// 获取当前UIView所在的UIViewController
    public var viewController: UIViewController? {
        var nextResponder = self.next
        while nextResponder != nil {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            nextResponder = nextResponder?.next
        }
        return nil
    }
}
extension UIView {
    /// 获取当前UIView所在的UIViewController的NavigationController
    public var navigationController: UINavigationController? {
        var nextResponder = self.next
        while nextResponder != nil {
            if let viewController = nextResponder as? UIViewController {
                return viewController.navigationController
            }
            nextResponder = nextResponder?.next
        }
        return nil
    }
}

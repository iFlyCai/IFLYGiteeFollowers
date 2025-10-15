//
//  UIApplication+Extensions.swift
//  IFLYCommonKit
//
//  Created by iFlyCai on 2025/2/14.
//

import UIKit

extension UIViewController {
    /// 获取当前最顶层的 UIViewController
    public static func topViewController() -> UIViewController? {
        guard let keyWindow = UIApplication.shared.currentWindow else {
            return nil
        }
        return topViewController(window: keyWindow)
    }
    
    /// 从指定的 UIWindow 获取最顶层的 UIViewController
    public static func topViewController(window: UIWindow) -> UIViewController? {
        return topViewControllerFromViewController(viewController: window.rootViewController)
    }
    
    /// 递归获取当前视图层级中的最顶层 UIViewController
    public static func topViewControllerFromViewController(viewController: UIViewController?) -> UIViewController? {
        if let presentedViewController = viewController?.presentedViewController {
            return topViewControllerFromViewController(viewController: presentedViewController)
        }
        if let navigationController = viewController as? UINavigationController {
            return topViewControllerFromViewController(viewController: navigationController.visibleViewController)
        }
        if let tabBarController = viewController as? UITabBarController,
           let selectedViewController = tabBarController.selectedViewController {
            return topViewControllerFromViewController(viewController: selectedViewController)
        }
        return viewController
    }
}

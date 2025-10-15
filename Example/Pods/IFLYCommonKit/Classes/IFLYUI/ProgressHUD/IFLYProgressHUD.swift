//
//  IFLYProgressHUD.swift
//  MBProgressHUD
//
//  Created by iFlyCai on 2025/2/12.
//

import UIKit

// 自定义 IFLYProgressHUD 类
public class IFLYProgressHUD: NSObject {
    
    // MARK: - 实例方法
    public func show(view: UIView? = nil, message: String? = nil, allowInteraction: Bool = false, animated: Bool = true) {
        Self.show(view: view, message: message, allowInteraction: allowInteraction, animated: animated)
    }
    
    public func dismiss(view: UIView? = nil, animated: Bool = true) {
        Self.dismiss(view: view, animated: animated)
    }
    
    // MARK: - 类方法
    @discardableResult
    public class func show(view: UIView? = nil, message: String? = nil, allowInteraction: Bool = false, animated: Bool = true) -> MBProgressHUD? {
        guard let displayView = view ?? UIApplication.shared.currentWindow else { return nil }
        
        let hud = MBProgressHUD.showAdded(to: displayView, animated: animated)
        hud.isUserInteractionEnabled = !allowInteraction // 设置是否允许交互
        if let message = message {
            hud.label.text = message
        }
        return hud
    }
    
    public class func dismiss(view: UIView? = nil, animated: Bool = true) {
        guard let displayView = view ?? UIApplication.shared.currentWindow else { return }
        MBProgressHUD.hide(for: displayView, animated: animated)
    }
    
    public class func showSuccess(view: UIView? = nil, message: String, allowInteraction: Bool = false, animated: Bool = true) {
        showCustomHUD(view: view, icon: "success_icon", message: message, allowInteraction: allowInteraction, animated: animated)
    }
    
    public class func showError(view: UIView? = nil, message: String, allowInteraction: Bool = false, animated: Bool = true) {
        showCustomHUD(view: view, icon: "error_icon", message: message, allowInteraction: allowInteraction, animated: animated)
    }
    
    private class func showCustomHUD(view: UIView?, icon: String, message: String, allowInteraction: Bool, animated: Bool) {
        guard let displayView = view ?? UIApplication.shared.currentWindow else { return }
        
        let hud = MBProgressHUD.showAdded(to: displayView, animated: animated)
        hud.mode = .customView
        hud.customView = UIImageView(image: UIImage(named: icon))
        hud.isUserInteractionEnabled = !allowInteraction // 设置是否允许交互
        hud.label.text = message
        hud.hide(animated: animated, afterDelay: 1.5)
    }
}
// UIView 扩展
public extension UIView {
    func showProgressHUD(message: String? = nil, allowInteraction: Bool = false, animated: Bool = true) {
        IFLYProgressHUD.show(view: self, message: message, allowInteraction: allowInteraction, animated: animated)
    }
    
    func dismissProgressHUD(animated: Bool = true) {
        IFLYProgressHUD.dismiss(view: self, animated: animated)
    }
    
    func showSuccessHUD(message: String, allowInteraction: Bool = false, animated: Bool = true) {
        IFLYProgressHUD.showSuccess(view: self, message: message, allowInteraction: allowInteraction, animated: animated)
    }
    
    func showErrorHUD(message: String, allowInteraction: Bool = false, animated: Bool = true) {
        IFLYProgressHUD.showError(view: self, message: message, allowInteraction: allowInteraction, animated: animated)
    }
}


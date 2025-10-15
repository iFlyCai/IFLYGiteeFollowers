//
//  IFLYToast.swift
//  IFLYCommonKit
//
//  Created by iFlyCai on 2025/1/22.
//

import UIKit
import Foundation
import Toast


public class IFLYToast: NSObject {
    public enum IFLYToastPosition {
        case top
        case center
        case bottom
        
        var toastPosition: String {
            switch self {
            case .top:
                return CSToastPositionTop
            case .center:
                return CSToastPositionCenter
            case .bottom:
                return CSToastPositionBottom
            }
        }
    }
    // MARK: - 实例方法
    /// 显示消息（默认显示在窗口中央）
    public func showMessage(message: String? = nil, duration: TimeInterval = 3.0) {
        guard let window = UIApplication.shared.currentWindow else { return }
        window.makeToast(message, duration: duration, position: CSToastPositionCenter)
    }

    // MARK: - 类方法
    /// 在窗口中显示消息
    public class func showMessage(_ message: String, duration: TimeInterval = 3.0) {
        guard let window = UIApplication.shared.currentWindow else { return }
        window.makeToast(message, duration: duration, position: CSToastPositionCenter)
    }

    /// 在指定视图中显示消息
    public class func showMessage(_ message: String, duration: TimeInterval = 3.0, in sourceView: UIView?, position: IFLYToastPosition = .center) {
        guard let sourceView = sourceView else { return }
        sourceView.makeToast(message, duration: duration, position: position.toastPosition)
    }

    /// 在指定视图中显示消息（默认时长）
    public class func showMessage(_ message: String, in sourceView: UIView?) {
        showMessage(message, duration: 3.0, in: sourceView, position: .center)
    }
    
}

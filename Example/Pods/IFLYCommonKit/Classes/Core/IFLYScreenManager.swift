//  IFLYScreenManager.swift
//  IFLYCommonKit
//
//  Created by iFlyCai on 2025/2/14.
//  屏幕信息管理类，提供屏幕尺寸、分辨率、安全区域等信息获取方法
//

import UIKit

/// 屏幕信息管理类
/// 提供获取屏幕尺寸、分辨率、安全区域以及设备类型判断等功能
open class IFLYScreenManager: NSObject {
    
    // MARK: - 屏幕基本信息
    
    /// 获取屏幕宽度
    /// - Returns: 屏幕宽度（pt）
    public static func screenWidth() -> Double {
        return Double(UIScreen.main.bounds.width)
    }
    
    /// 获取屏幕高度
    /// - Returns: 屏幕高度（pt）
    public static func screenHeight() -> Double {
        return Double(UIScreen.main.bounds.height)
    }
    
    /// 获取内容区域宽度（不包括安全区域）
    public static func contentWidth() -> Double {
        // 确保在主线程访问UIApplication
        if Thread.isMainThread {
            if let mainWindowScene = UIApplication.shared.connectedScenes
                .filter({ $0.activationState == .foregroundActive })
                .first as? UIWindowScene,
               let window = mainWindowScene.windows.first(where: { $0.isKeyWindow }) {
                let safeAreaInsets = window.safeAreaInsets
                let width = UIScreen.main.bounds.width - safeAreaInsets.left - safeAreaInsets.right
                return Double(width)
            }
        } else {
            // 如果在后台线程，切换到主线程执行
            var result: Double = 0
            let semaphore = DispatchSemaphore(value: 0)
            DispatchQueue.main.async {
                if let mainWindowScene = UIApplication.shared.connectedScenes
                    .filter({ $0.activationState == .foregroundActive })
                    .first as? UIWindowScene,
                   let window = mainWindowScene.windows.first(where: { $0.isKeyWindow }) {
                    let safeAreaInsets = window.safeAreaInsets
                    let width = UIScreen.main.bounds.width - safeAreaInsets.left - safeAreaInsets.right
                    result = Double(width)
                }
                semaphore.signal()
            }
            semaphore.wait()
            return result
        }
        return 0
    }

    /// 获取内容区域高度（不包括安全区域）
    public static func contentHeight() -> Double {
        // 确保在主线程访问UIApplication
        if Thread.isMainThread {
            if let mainWindowScene = UIApplication.shared.connectedScenes
                .filter({ $0.activationState == .foregroundActive })
                .first as? UIWindowScene,
               let window = mainWindowScene.windows.first(where: { $0.isKeyWindow }) {
                let safeAreaInsets = window.safeAreaInsets
                let height = UIScreen.main.bounds.height - safeAreaInsets.top - safeAreaInsets.bottom
                return Double(height)
            }
        } else {
            // 如果在后台线程，切换到主线程执行
            var result: Double = 0
            let semaphore = DispatchSemaphore(value: 0)
            DispatchQueue.main.async {
                if let mainWindowScene = UIApplication.shared.connectedScenes
                    .filter({ $0.activationState == .foregroundActive })
                    .first as? UIWindowScene,
                   let window = mainWindowScene.windows.first(where: { $0.isKeyWindow }) {
                    let safeAreaInsets = window.safeAreaInsets
                    let height = UIScreen.main.bounds.height - safeAreaInsets.top - safeAreaInsets.bottom
                    result = Double(height)
                }
                semaphore.signal()
            }
            semaphore.wait()
            return result
        }
        return 0
    }
    
    /// 获取屏幕对角线尺寸
    /// - Returns: 屏幕对角线长度（pt）
    public static func screenSize() -> Double {
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        return sqrt(pow(width, 2) + pow(height, 2))
    }
    
    /// 获取屏幕物理分辨率
    /// - Returns: 格式为"宽度x高度"的分辨率字符串
    public static func screenResolution() -> String {
        let scale = UIScreen.main.scale
        let width = UIScreen.main.bounds.width * scale
        let height = UIScreen.main.bounds.height * scale
        return "\(Int(width))x\(Int(height))"
    }
    
    // MARK: - 安全区域信息
    
    /// 获取安全区域顶部距离
    /// - Returns: 安全区域顶部距离（pt）
    public static func safeAreaTopInset() -> CGFloat {
        if let mainWindowScene = UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .first as? UIWindowScene,
           let window = mainWindowScene.windows.first(where: { $0.isKeyWindow }) {
            return window.safeAreaInsets.top
        }
        return 0
    }
    
    /// 获取安全区域底部距离
    /// - Returns: 安全区域底部距离（pt）
    public static func safeAreaBottomInset() -> CGFloat {
        if let mainWindowScene = UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .first as? UIWindowScene,
           let window = mainWindowScene.windows.first(where: { $0.isKeyWindow }) {
            return window.safeAreaInsets.bottom
        }
        return 0
    }
    
    /// 获取安全区域左侧距离
    /// - Returns: 安全区域左侧距离（pt）
    public static func safeAreaLeftInset() -> CGFloat {
        if let mainWindowScene = UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .first as? UIWindowScene,
           let window = mainWindowScene.windows.first(where: { $0.isKeyWindow }) {
            return window.safeAreaInsets.left
        }
        return 0
    }
    
    /// 获取安全区域右侧距离
    /// - Returns: 安全区域右侧距离（pt）
    public static func safeAreaRightInset() -> CGFloat {
        if let mainWindowScene = UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .first as? UIWindowScene,
           let window = mainWindowScene.windows.first(where: { $0.isKeyWindow }) {
            return window.safeAreaInsets.right
        }
        return 0
    }
    
    // MARK: - 系统栏高度
    
    /// 获取状态栏高度
    /// - Returns: 状态栏高度（pt）
    public static func statusBarHeight() -> CGFloat {
        if let mainWindowScene = UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .first as? UIWindowScene {
            return mainWindowScene.statusBarManager?.statusBarFrame.height ?? 0
        }
        return 0
    }
    
    /// 获取导航栏推荐高度
    /// - Returns: 导航栏推荐高度（pt），包含状态栏
    public static func navigationBarHeight() -> CGFloat {
        return statusBarHeight() + 44
    }
    
    /// 获取标签栏推荐高度
    /// - Returns: 标签栏推荐高度（pt），包含安全区域底部间距
    public static func tabBarHeight() -> CGFloat {
        return safeAreaBottomInset() + 49
    }
    
    /// 获取屏幕缩放因子
    /// - Returns: 屏幕缩放因子
    public static func screenScale() -> CGFloat {
        return UIScreen.main.scale
    }
    
    // MARK: - 设备类型判断
    
    /// 判断是否为iPhone设备
    /// - Returns: 是否为iPhone
    public static func isIPhone() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    /// 判断是否为iPad设备
    /// - Returns: 是否为iPad
    public static func isIPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    /// 判断是否为全面屏设备
    /// - Returns: 是否为全面屏设备
    public static func isFullScreen() -> Bool {
        // 全面屏设备的特征：底部安全区域大于0，且设备不是iPad
        return safeAreaBottomInset() > 0 && !isIPad()
    }
    
    /// 判断是否为刘海屏设备
    /// - Returns: 是否为刘海屏设备
    public static func isNotchScreen() -> Bool {
        // 刘海屏设备的特征：顶部安全区域大于20pt
        return safeAreaTopInset() > 20
    }
    
    // MARK: - 自适应计算
    
    /// 根据设计稿宽度计算自适应尺寸
    /// - Parameter designWidth: 设计稿中的宽度（pt）
    /// - Returns: 自适应后的宽度（pt）
    public static func adaptWidth(_ designWidth: CGFloat) -> CGFloat {
        // 假设设计稿基于iPhone 11 (375pt宽度)
        let baseWidth: CGFloat = 375.0
        return (designWidth / baseWidth) * UIScreen.main.bounds.width
    }
    
    /// 根据设计稿高度计算自适应尺寸
    /// - Parameter designHeight: 设计稿中的高度（pt）
    /// - Returns: 自适应后的高度（pt）
    public static func adaptHeight(_ designHeight: CGFloat) -> CGFloat {
        // 假设设计稿基于iPhone 11 (812pt高度，包含安全区域)
        let baseHeight: CGFloat = 812.0
        return (designHeight / baseHeight) * UIScreen.main.bounds.height
    }
    
    /// 根据屏幕宽度计算字体大小
    /// - Parameter baseSize: 基础字体大小
    /// - Returns: 自适应后的字体大小
    public static func adaptFontSize(_ baseSize: CGFloat) -> CGFloat {
        // 基于屏幕宽度比例调整字体大小
        let baseWidth: CGFloat = 375.0
        let ratio = UIScreen.main.bounds.width / baseWidth
        let fontSize = baseSize * ratio
        
        // 限制字体大小范围，避免过大或过小
        let minSize = baseSize * 0.8
        let maxSize = baseSize * 1.2
        return max(minSize, min(maxSize, fontSize))
    }
    
    // MARK: - 屏幕方向
    
    /// 获取当前屏幕方向
    /// - Returns: 当前屏幕方向
    public static func currentOrientation() -> UIInterfaceOrientation {
        if let mainWindowScene = UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .first as? UIWindowScene {
            return mainWindowScene.interfaceOrientation
        }
        return .unknown
    }
    
    /// 判断是否为横屏
    /// - Returns: 是否为横屏
    public static func isLandscape() -> Bool {
        return UIDevice.current.orientation.isLandscape
    }
    
    /// 判断是否为竖屏
    /// - Returns: 是否为竖屏
    public static func isPortrait() -> Bool {
        return UIDevice.current.orientation.isPortrait
    }
}

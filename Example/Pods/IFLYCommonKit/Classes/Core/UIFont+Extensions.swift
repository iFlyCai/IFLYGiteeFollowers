//
//  UIApplication+Extensions.swift
//  IFLYCommonKit
//
//  Created by iFlyCai on 2025/2/14.
//

import UIKit
import CoreText

// MARK: - PingFang 字体扩展
public extension UIFont {
    
    private static func iFlyCaiFontWithName(_ name: String, size: CGFloat) -> UIFont {
        return UIFont(name: name, size: size) ?? .systemFont(ofSize: size)
    }

    static func pingfangLight(withSize size: CGFloat) -> UIFont {
        return iFlyCaiFontWithName("PingFangSC-Light", size: size)
    }

    static func pingfangRegular(withSize size: CGFloat) -> UIFont {
        return iFlyCaiFontWithName("PingFangSC-Regular", size: size)
    }

    static func pingfangMedium(withSize size: CGFloat) -> UIFont {
        return iFlyCaiFontWithName("PingFangSC-Medium", size: size)
    }

    static func pingfangSemibold(withSize size: CGFloat) -> UIFont {
        return iFlyCaiFontWithName("PingFangSC-Semibold", size: size)
    }
}

// MARK: - Bundle Extension
extension Bundle {
    /// 原始资源 Bundle（根据当前类查找资源包）
    static var iflyFontCommonKitBundle: Bundle? {
        guard let bundleURL = Bundle(for: IFLYFontBundleFinder.self).url(forResource: "IFLYCommonKitResources", withExtension: "bundle") else {
            print("⚠️ 未找到资源包 IFLYCommonKitResources.bundle，请检查路径配置。")
            return nil
        }
        guard let bundle = Bundle(url: bundleURL) else {
            print("⚠️ 无法加载资源包 IFLYCommonKitResources.bundle，请检查路径配置。")
            return nil
        }
        return bundle
    }
    /// 统一资源访问入口，供所有组件使用（推荐）
    static var iflyFontBundle: Bundle? {
        return Bundle.iflyFontCommonKitBundle
    }
}

private class IFLYFontBundleFinder {}

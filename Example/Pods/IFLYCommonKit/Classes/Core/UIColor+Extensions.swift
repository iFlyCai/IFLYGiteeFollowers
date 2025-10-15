//
//  UIApplication+Extensions.swift
//  IFLYCommonKit
//
//  Created by iFlyCai on 2025/2/14.
//

import Foundation

extension UIColor {
    
    /// 通过 Hex 字符串创建 UIColor（支持 "#RRGGBB"、"RRGGBB"、"#AARRGGBB"、"AARRGGBB" 格式）
    public convenience init?(hex: String) {
        // 去除空格和换行符，并转为大写
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        // 处理 # 前缀
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }
        
        // 支持 6 位（RRGGBB）和 8 位（AARRGGBB）
        guard hexString.count == 6 || hexString.count == 8 else {
            return nil // 无效格式
        }
        
        // 将字符串转为整数
        guard let rgba = Int(hexString, radix: 16) else {
            return nil
        }
        
        let a, r, g, b: CGFloat
        if hexString.count == 8 { // AARRGGBB
            a = CGFloat((rgba >> 24) & 0xFF) / 255.0
            r = CGFloat((rgba >> 16) & 0xFF) / 255.0
            g = CGFloat((rgba >> 8) & 0xFF) / 255.0
            b = CGFloat(rgba & 0xFF) / 255.0
        } else { // RRGGBB，默认为不透明
            a = 1.0
            r = CGFloat((rgba >> 16) & 0xFF) / 255.0
            g = CGFloat((rgba >> 8) & 0xFF) / 255.0
            b = CGFloat(rgba & 0xFF) / 255.0
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    /// 将 UIColor 转换为 Hex 字符串（格式：#AARRGGBB，始终包含透明度）
    public func toHexString() -> String? {
        guard let components = cgColor.components, components.count >= 4 else {
            return nil // 无法获取颜色分量
        }
        
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        let a = Int(components[3] * 255)
        
        return String(format: "#%02X%02X%02X%02X", a, r, g, b)
    }
    /// 通过 16 进制数值创建颜色
    /// - Parameters:
    ///   - hex: 16 进制颜色值，例如 0x3498db
    ///   - alpha: 透明度，范围 0.0 - 1.0
    /// - Returns: UIColor 对象
    public static func color(hex: UInt, alpha: CGFloat = 1.0) -> UIColor {
        let r = CGFloat((hex >> 16) & 0xFF) / 255.0
        let g = CGFloat((hex >> 8) & 0xFF) / 255.0
        let b = CGFloat(hex & 0xFF) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: alpha)
    }
    public static func label(withName:String)->UIColor{
        if let color = UIColor(named: withName) {
            return color
        }else{
            return .label
        }
    }
    public static func link(withName:String)->UIColor{
        if let color = UIColor(named: withName) {
            return color
        }else{
            return .link
        }
    }
    public static func back(withName:String)->UIColor{
        if let color = UIColor(named: withName) {
            return color
        }else{
            return .systemBackground
        }
    }
    public static func iconColor(withName:String)->UIColor{
        if let color = UIColor(named: withName) {
            return color
        }else{
            return .label
        }
    }
}

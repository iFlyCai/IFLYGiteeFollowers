//
//  UIApplication+Extensions.swift
//  IFLYCommonKit
//
//  Created by iFlyCai on 2025/2/14.
//

import UIKit

public class IFLYDevice: NSObject {
    
    /// 获取当前设备的系统名称和版本号（如 iOS17.0）
    /// - Returns: 系统名称+版本号字符串
    public static func getDeviceSystemVersion() -> String {
        let systemName = UIDevice.current.systemName
        let systemVersion = UIDevice.current.systemVersion
        return "\(systemName) \(systemVersion)"
    }
    
    /// 获取当前设备的型号名称（如 iPhone 15 Pro）
    /// - Returns: 设备型号字符串
    public static func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
#if DEBUG
        debugPrint("identifier:\(identifier)")
#endif
        return deviceMap[identifier] ?? identifier
    }

    // 设备型号映射表（部分机型省略）
    private static let deviceMap: [String: String] = [
        // iPhone
        "iPhone8,1": "iPhone 6s",
        "iPhone8,2": "iPhone 6s Plus",
        "iPhone9,1": "iPhone 7",
        "iPhone9,2": "iPhone 7 Plus",
        "iPhone10,1": "iPhone 8",
        "iPhone10,2": "iPhone 8 Plus",
        "iPhone10,3": "iPhone X",
        "iPhone10,6": "iPhone X",
        "iPhone11,2": "iPhone XS",
        "iPhone11,4": "iPhone XS Max",
        "iPhone11,6": "iPhone XS Max",
        "iPhone11,8": "iPhone XR",
        "iPhone12,1": "iPhone 11",
        "iPhone12,3": "iPhone 11 Pro",
        "iPhone12,5": "iPhone 11 Pro Max",
        "iPhone13,1": "iPhone 12 mini",
        "iPhone13,2": "iPhone 12",
        "iPhone13,3": "iPhone 12 Pro",
        "iPhone13,4": "iPhone 12 Pro Max",
        "iPhone14,4": "iPhone 13 mini",
        "iPhone14,5": "iPhone 13",
        "iPhone14,2": "iPhone 13 Pro",
        "iPhone14,3": "iPhone 13 Pro Max",
        "iPhone14,7": "iPhone 14",
        "iPhone14,8": "iPhone 14 Plus",
        "iPhone15,2": "iPhone 14 Pro",
        "iPhone15,3": "iPhone 14 Pro Max",
        "iPhone15,4": "iPhone 15",
        "iPhone15,5": "iPhone 15 Plus",
        "iPhone16,1": "iPhone 15 Pro",
        "iPhone16,2": "iPhone 15 Pro Max",
        // iPhone 16 系列
        "iPhone16,3": "iPhone 16",
        "iPhone16,4": "iPhone 16 Plus",
        "iPhone16,5": "iPhone 16 Pro",
        "iPhone16,6": "iPhone 16 Pro Max",
        // iPhone 17 系列
        "iPhone17,1": "iPhone 17",
        "iPhone17,2": "iPhone 17 Plus",
        "iPhone17,3": "iPhone 17 Pro",
        "iPhone17,4": "iPhone 17 Pro Max",

        // iPad
        "iPad6,11": "iPad 5",
        "iPad6,12": "iPad 5",
        "iPad7,5": "iPad 6",
        "iPad7,6": "iPad 6",
        "iPad7,11": "iPad 7",
        "iPad7,12": "iPad 7",
        "iPad11,6": "iPad 8",
        "iPad11,7": "iPad 8",
        "iPad12,1": "iPad 9",
        "iPad12,2": "iPad 9",
        "iPad13,18": "iPad 10",
        "iPad13,19": "iPad 10",

        // iPad Pro
        "iPad8,1": "iPad Pro 11 (2018)",
        "iPad8,2": "iPad Pro 11 (2018)",
        "iPad8,3": "iPad Pro 11 (2018)",
        "iPad8,4": "iPad Pro 11 (2018)",
        "iPad8,9": "iPad Pro 11 (2020)",
        "iPad8,10": "iPad Pro 11 (2020)",
        "iPad13,4": "iPad Pro 11 (2021)",
        "iPad13,5": "iPad Pro 11 (2021)",
        "iPad13,6": "iPad Pro 11 (2021)",
        "iPad13,7": "iPad Pro 11 (2021)",
        "iPad14,3": "iPad Pro 11 (2022)",
        "iPad14,4": "iPad Pro 11 (2022)",
        "iPad8,5": "iPad Pro 12.9 (2018)",
        "iPad8,6": "iPad Pro 12.9 (2018)",
        "iPad8,7": "iPad Pro 12.9 (2018)",
        "iPad8,8": "iPad Pro 12.9 (2018)",
        "iPad8,11": "iPad Pro 12.9 (2020)",
        "iPad8,12": "iPad Pro 12.9 (2020)",
        "iPad13,8": "iPad Pro 12.9 (2021)",
        "iPad13,9": "iPad Pro 12.9 (2021)",
        "iPad13,10": "iPad Pro 12.9 (2021)",
        "iPad13,11": "iPad Pro 12.9 (2021)",
        "iPad14,5": "iPad Pro 12.9 (2022)",
        "iPad14,6": "iPad Pro 12.9 (2022)",

        // iPad Air
        "iPad13,16": "iPad Air 5",
        "iPad13,17": "iPad Air 5",
        "iPad14,8": "iPad Air 6",
        "iPad14,9": "iPad Air 6",

        // iPad mini
        "iPad14,1": "iPad mini 6",
        "iPad14,2": "iPad mini 6",

        // 模拟器
        "i386": "Simulator(i386)",
        "x86_64": "Simulator(x86_64)",
        "arm64": "Simulator(arm64)",

        // Apple Watch
        "Watch1,1": "Apple Watch 1st Gen",
        "Watch1,2": "Apple Watch 1st Gen",
        "Watch2,6": "Apple Watch Series 1",
        "Watch2,7": "Apple Watch Series 1",
        "Watch2,3": "Apple Watch Series 2",
        "Watch2,4": "Apple Watch Series 2",
        "Watch3,1": "Apple Watch Series 3",
        "Watch3,2": "Apple Watch Series 3",
        "Watch3,3": "Apple Watch Series 3",
        "Watch3,4": "Apple Watch Series 3",
        "Watch4,1": "Apple Watch Series 4",
        "Watch4,2": "Apple Watch Series 4",
        "Watch4,3": "Apple Watch Series 4",
        "Watch4,4": "Apple Watch Series 4",
        "Watch5,1": "Apple Watch Series 5",
        "Watch5,2": "Apple Watch Series 5",
        "Watch5,3": "Apple Watch Series 5",
        "Watch5,4": "Apple Watch Series 5",
        "Watch6,1": "Apple Watch Series 6",
        "Watch6,2": "Apple Watch Series 6",
        "Watch6,3": "Apple Watch Series 6",
        "Watch6,4": "Apple Watch Series 6",
        "Watch5,9": "Apple Watch SE (1st Gen)",
        "Watch5,10": "Apple Watch SE (1st Gen)",
        "Watch5,11": "Apple Watch SE (1st Gen)",
        "Watch5,12": "Apple Watch SE (1st Gen)",
        "Watch7,1": "Apple Watch Series 7",
        "Watch7,2": "Apple Watch Series 7",
        "Watch7,3": "Apple Watch Series 7",
        "Watch7,4": "Apple Watch Series 7",
        "Watch6,6": "Apple Watch Series 8",
        "Watch6,7": "Apple Watch Series 8",
        "Watch6,8": "Apple Watch Series 8",
        "Watch6,9": "Apple Watch Series 8",
        "Watch6,10": "Apple Watch SE (2nd Gen)",
        "Watch6,11": "Apple Watch SE (2nd Gen)",
        "Watch6,12": "Apple Watch SE (2nd Gen)",
        "Watch6,13": "Apple Watch SE (2nd Gen)",
        "Watch6,14": "Apple Watch Ultra",
        "Watch6,15": "Apple Watch Ultra",
        "Watch6,16": "Apple Watch Ultra",
        "Watch6,17": "Apple Watch Ultra",
        "Watch6,18": "Apple Watch Ultra 2",

        // Mac
        "MacBookAir10,1": "MacBook Air (M1, 2020)",
        "MacBookPro17,1": "MacBook Pro (M1, 2020)",
        "MacBookPro18,1": "MacBook Pro 16-inch (2021, M1 Pro)",
        "MacBookPro18,2": "MacBook Pro 16-inch (2021, M1 Max)",
        "MacBookPro18,3": "MacBook Pro 14-inch (2021, M1 Pro)",
        "MacBookPro18,4": "MacBook Pro 14-inch (2021, M1 Max)",
        "MacBookPro19,1": "MacBook Pro 16-inch (2023, M2 Pro)",
        "MacBookPro19,2": "MacBook Pro 16-inch (2023, M2 Max)",
        "Mac14,2": "Mac Studio (M1 Max)",
        "Mac14,3": "Mac Studio (M1 Ultra)",
        "Mac14,7": "Mac mini (M2, 2023)",
        "iMac21,1": "iMac (24-inch, M1, 2021)",
        "iMac21,2": "iMac (24-inch, M1, 2021)",
        "Mac15,3": "MacBook Air 15-inch (M2, 2023)",
        "Mac15,2": "MacBook Air 13-inch (M2, 2022)",
        "Mac15,12": "MacBook Pro 14-inch (M3, 2023)",
        "Mac15,13": "MacBook Pro 16-inch (M3 Max, 2023)",
        "Mac15,14": "MacBook Pro 16-inch (M3 Pro, 2023)"
    ]
    
    /// 判断当前设备是否为 iPad
    /// - Returns: true 表示为 iPad，false 表示不是
    public static func isIpad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    /// 判断当前设备是否为 iPhone
    /// - Returns: true 表示为 iPhone，false 表示不是
    public static func isIphone() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    /// 获取当前 App 的显示名称
    /// - Returns: App 名称字符串
    public static func getAppName() -> String {
        let infoDict = Bundle.main.infoDictionary
        return infoDict?["CFBundleDisplayName"] as? String
            ?? infoDict?["CFBundleName"] as? String
            ?? "Unknown"
    }
    /// 获取当前 App 的版本号
    /// - Returns: 版本号字符串
    public static func getAppVersion() -> String {
        let infoDict = Bundle.main.infoDictionary
        return infoDict?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
}

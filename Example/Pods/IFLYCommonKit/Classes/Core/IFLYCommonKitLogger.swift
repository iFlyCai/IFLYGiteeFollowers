//
//  IFLYCommonKitLogger.swift
//  IFLYCommonKit
//
//  Created by iFlyCai on 2025/7/1.
//

import Foundation

/// IFLYCommonKit 日志管理类
public class IFLYCommonKitLogger: NSObject {
    
    /// 单例实例
    public static let shared = IFLYCommonKitLogger()
    
    /// 是否在控制台打印 IFLYCommonKit 相关日志
    /// 默认为 true，可在 App 启动时设置为 false 来关闭日志输出
    public var enableConsoleLogging: Bool = true
    
    /// 是否打印依赖库版本信息
    /// 默认为 true，可在 App 启动时设置为 false 来关闭版本信息输出
    public var enableVersionLogging: Bool = true
    
    /// 是否打印 Podfile.lock 信息
    /// 默认为 true，可在 App 启动时设置为 false 来关闭 Podfile.lock 输出
    public var enablePodfileLogging: Bool = true
    
    private override init() {
        super.init()
    }
    
    /// 打印 IFLYCommonKit 版本信息
    public func logVersion() {
        guard enableConsoleLogging && enableVersionLogging else { return }
        print("[IFLYCommonKit] Version: \(IFLYCommonKitVersion.current)")
    }
    
    /// 打印依赖库版本信息
    public func logDependencyVersions() {
        guard enableConsoleLogging && enableVersionLogging else { return }
    }
    
    /// 打印 Podfile.lock 信息
    public func logPodfileVersions() {
        guard enableConsoleLogging && enablePodfileLogging else { return }
        guard let path = Bundle.main.path(forResource: "Podfile.lock", ofType: nil) else {
            print("[IFLYCommonKit] Podfile.lock not found in bundle")
            return
        }
        do {
            let content = try String(contentsOfFile: path)
            let lines = content.components(separatedBy: .newlines)
            print("[IFLYCommonKit] Podfile.lock 依赖库版本信息:")
            for line in lines {
                if line.trimmingCharacters(in: .whitespaces).hasPrefix("- ") {
                    print(line.trimmingCharacters(in: .whitespaces))
                }
            }
        } catch {
            print("[IFLYCommonKit] Failed to read Podfile.lock: \(error)")
        }
    }
    
    /// 打印所有日志信息
    public func logAllInfo() {
        logVersion()
        logDependencyVersions()
        logPodfileVersions()
    }
    
    /// 通用日志打印方法
    /// - Parameter message: 日志消息
    public func log(_ message: String) {
        guard enableConsoleLogging else { return }
        print("[IFLYCommonKit] \(message)")
    }
    
    /// 错误日志打印方法
    /// - Parameter message: 错误消息
    public func logError(_ message: String) {
        guard enableConsoleLogging else { return }
        print("[IFLYCommonKit] ❌ \(message)")
    }
    
    /// 成功日志打印方法
    /// - Parameter message: 成功消息
    public func logSuccess(_ message: String) {
        guard enableConsoleLogging else { return }
        print("[IFLYCommonKit] ✅ \(message)")
    }
    
    /// 警告日志打印方法
    /// - Parameter message: 警告消息
    public func logWarning(_ message: String) {
        guard enableConsoleLogging else { return }
        print("[IFLYCommonKit] ⚠️ \(message)")
    }
} 

//
//  UIColor+IFLYUtilities.swift
//  FBSnapshotTestCase
//
//  Created by iFlyCai on 2025/8/29.
//

import Foundation

extension String {
    /// 将 ISO 8601 格式的时间字符串转换为中国本地化时间显示
    /// - Returns: 格式化后的时间字符串，格式为 "yyyy年MM月dd日 HH:mm" 或相对时间（如"3天前"、"30秒前"）
    public func chinaTimes() -> String? {
        // 创建日期格式化器
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        
        // 尝试解析日期
        guard let date = isoFormatter.date(from: self) else {
            // 如果标准格式解析失败，尝试其他常见格式
            return tryOtherFormats() ?? self
        }
        
        // 计算与当前时间的时间差
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: date, to: now)
        
        // 如果是今天
        if calendar.isDateInToday(date) {
            // 计算秒数差
            if let seconds = components.second, seconds < 60 {
                return "\(seconds)秒前"
            }
            // 计算分钟差
            else if let minutes = components.minute, minutes < 60 {
                return "\(minutes)分钟前"
            }
            // 其他情况显示时间
            else {
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "zh_CN")
                formatter.dateFormat = "HH:mm"
                return formatter.string(from: date)
            }
        }
        // 如果是昨天，显示"昨天"
        else if calendar.isDateInYesterday(date) {
            return "昨天"
        }
        // 如果是7天内，显示相对时间
        else if let days = components.day, days < 7 {
            return "\(days)天前"
        }
        // 其他情况显示完整日期
        else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "zh_CN")
            formatter.dateFormat = "yyyy年MM月dd日"
            return formatter.string(from: date)
        }
    }
    
    private func tryOtherFormats() -> String? {
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ssZ",        // 2025-08-26T11:30:35+0800
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",    // 2025-08-26T11:30:35.123+0800
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",  // 2025-08-26T11:30:35.123Z
            "yyyy-MM-dd'T'HH:mm:ss'Z'",      // 2025-08-26T11:30:35Z
            "yyyy-MM-dd HH:mm:ss",           // 2025-08-26 11:30:35
            "yyyy/MM/dd HH:mm:ss"            // 2025/08/26 11:30:35
        ]
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: self) {
                return formatDateForChina(date)
            }
        }
        
        return nil
    }
    
    private func formatDateForChina(_ date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: date, to: now)
        
        // 如果是今天
        if calendar.isDateInToday(date) {
            // 计算秒数差
            if let seconds = components.second, seconds < 60 {
                return "\(seconds)秒前"
            }
            // 计算分钟差
            else if let minutes = components.minute, minutes < 60 {
                return "\(minutes)分钟前"
            }
            // 其他情况显示时间
            else {
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "zh_CN")
                formatter.dateFormat = "HH:mm"
                return formatter.string(from: date)
            }
        }
        // 如果是昨天，显示"昨天"
        else if calendar.isDateInYesterday(date) {
            return "昨天"
        }
        // 如果是7天内，显示相对时间
        else if let days = components.day, days < 7 {
            return "\(days)天前"
        }
        // 其他情况显示完整日期
        else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "zh_CN")
            formatter.dateFormat = "yyyy年MM月dd日"
            return formatter.string(from: date)
        }
    }
}

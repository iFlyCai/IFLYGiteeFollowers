//
//  UIColor+IFLYUtilities.swift
//  FBSnapshotTestCase
//
//  Created by iFlyCai on 2025/8/29.
//

import Foundation
import UIKit

extension Date {
    /// 返回中国本地化时间显示
    /// - Returns: 格式化后的时间字符串，格式为 "yyyy年MM月dd日" 或相对时间（如"3天前"、"30秒前"）
    public func chinaTimes() -> String {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: self, to: now)
        
        // 如果是今天
        if calendar.isDateInToday(self) {
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
                return formatter.string(from: self)
            }
        }
        // 如果是昨天，显示"昨天"
        else if calendar.isDateInYesterday(self) {
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
            return formatter.string(from: self)
        }
    }
}

//
//  DateCoding.swift
//  IFLYNetworkManager
//
//  Created by iFlyCai on 2025/9/2.
//

import Foundation

// MARK: - JSONDecoder 扩展
extension JSONDecoder {
    /// 支持 ISO8601 和带毫秒的 ISO8601 时间格式
    static var iso8601withFractionalSeconds: JSONDecoder {
        let decoder = JSONDecoder()
        
        decoder.dateDecodingStrategy = .custom { decoder -> Date in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            
            // 带毫秒
            let formatterWithMS = ISO8601DateFormatter()
            formatterWithMS.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            // 不带毫秒
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime]
            
            if let date = formatterWithMS.date(from: dateStr) {
                return date
            } else if let date = formatter.date(from: dateStr) {
                return date
            } else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "无法解析日期: \(dateStr)"
                )
            }
        }
        
        return decoder
    }
}

// MARK: - JSONEncoder 扩展
extension JSONEncoder {
    /// 输出 ISO8601（带毫秒）的时间格式
    static var iso8601withFractionalSeconds: JSONEncoder {
        let encoder = JSONEncoder()
        
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            let dateStr = formatter.string(from: date)
            try container.encode(dateStr)
        }
        
        return encoder
    }
}

//
//  UIApplication+Extensions.swift
//  IFLYCommonKit
//
//  Created by iFlyCai on 2025/2/14.
//

import Foundation

extension Date {
    public init(year: Int, month: Int, day: Int) {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        self = Calendar.current.date(from: components) ?? Date()
    }
    
    public var day: Int {
        Calendar.current.component(.day, from: self)
    }
    
    public var month: Int {
        Calendar.current.component(.month, from: self)
    }
    
    public var year: Int {
        Calendar.current.component(.year, from: self)
    }
    
    public var daysInMonth: Int {
        Calendar.current.range(of: .day, in: .month, for: self)?.count ?? 0
    }
}

public extension Date {
    
    func toString(format: String = "YYYY-MM-dd hh:mm:ss",timeZone: TimeZone = .current) -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = format
        dateFormat.timeZone = timeZone
        return dateFormat.string(from: self)
    }
    
}

public extension String {
    
    func toDate(format: String = "YYYY-MM-dd hh:mm:ss",timeZone: TimeZone = .current) -> Date? {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = format
        dateFormat.timeZone = timeZone
        return dateFormat.date(from: self)
    }
}

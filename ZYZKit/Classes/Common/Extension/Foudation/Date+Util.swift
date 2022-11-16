//
//  Date+Util.swift
//  cleaner
//
//  Created by zy on 2020/9/4.
//  Copyright © 2020 gramm. All rights reserved.
//

import Foundation

public extension Date {
    var dayString: String {
        get {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            let dateStr = df.string(from: self)
            return dateStr
        }
    }
    
    var minString: String {
        get {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd HH:mm"
            let dateStr = df.string(from: self)
            return dateStr
        }
    }
    
    var secondsString: String {
        get {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateStr = df.string(from: self)
            return dateStr
        }
    }
    
    
    /// 当前时间是不是比date早
    /// - Parameter date: date description
    /// - Returns: description
    func isEarlier(than date: Date) -> Bool {
        if self.timeIntervalSince(date) < 0 {
            return true
        }
        return false
    }
    
    
    /// 比当前时间早
    var isEarlierNow: Bool {
        return self.isEarlier(than: Date())
    }
    
    /// 判断两个日期是不是同一天
    /// - Parameter anthor: anthor description
    /// - Returns: description
    func isSameDay(with anthor: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: anthor)
    }
    
    
    ///
    /// - Parameters:
    ///   - date: Date类型
    ///   - dateFormat: 格式化样式默认“"yyyy-MM-dd HH:mm:ss"”
    /// - Returns: 日期字符串
    /*
     let df = DateFormatter()
     df.dateFormat = "yyyy-MM-dd HH:mm:ss"
     let dateStr = df.string(from: self)
     return dateStr
     
     */
    static func dateConvertString(date:Date, dateFormat:String="yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.string(from: date)
        
    }
    
    /// 日期字符串转化为Date类型
    ///
    /// - Parameters:
    ///   - string: 日期字符串
    ///   - dateFormat: 格式化样式，默认为“yyyy-MM-dd HH:mm:ss”
    /// - Returns: Date类型
    static func stringConvertDate(string:String, dateFormat:String="yyyy-MM-dd HH:mm:ss") -> Date {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: string)
        return date!
    }
    
    //时间戳转成字符串
    static func timeIntervalChangeToTimeStr(timeInterval:Double, _ dateFormat:String? = "yyyy-MM-dd HH:mm:ss") -> String {
        let date:Date = Date.init(timeIntervalSince1970: timeInterval)
        let formatter = DateFormatter.init()
        formatter.dateFormat = dateFormat
        return formatter.string(from: date)
    }
}

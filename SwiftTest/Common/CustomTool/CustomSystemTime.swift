//
//  CustomSystemTime.swift
//  SwiftTest
//
//  Created by user on 2025/4/14.
//
// 获取系统时间
/* 模拟时区过程 (Xcode 运行真机如 mac 设备)
 1.Xcode 中 Edit Scheme, 修改 Options 中 Default Location
 2.运行 Xcode ,不终止程序,电脑找到“日期与时间, 关闭再开启“自动设定时区”选项,这时电脑时区会自动变成 “Default Location”
 3.重新运行程序, 电脑时区就会一直是手动设置的时区
 4.若需要修改时区,重复以上操作
 5.若恢复默认设置,关闭程序,修改 Options 中 Default Location 为 None,运行 Xcode ,不终止程序,关闭再开启“自动设定时区”选项,令电脑时区变成“中国标准时间”(若未恢复默认值,断网重复操作)
 */

import Foundation

/// 表示系统时间的值类型，封装日期时间相关数据
public struct CustomSystemTime {
    // MARK: - 时间属性
    public let is24HourFormat: Bool
    public let hour: Int
    public let minute: Int
    public let second: Int
    public let millisecond: Int
    public let year: Int
    public let month: Int
    public let day: Int
    public let weekday: Weekday // 1=周一, 2=周二,..., 7=周日
    public let timezoneOffset: Int // 时区偏移(小时)
    
    // MARK: - 初始化方法
    public init(
        is24HourFormat: Bool,
        hour: Int,
        minute: Int,
        second: Int,
        millisecond: Int,
        year: Int,
        month: Int,
        day: Int,
        weekday: Weekday,
        timezoneOffset: Int
    ) {
        self.is24HourFormat = is24HourFormat
        self.hour = hour
        self.minute = minute
        self.second = second
        self.millisecond = millisecond
        self.year = year
        self.month = month
        self.day = day
        self.weekday = weekday
        self.timezoneOffset = timezoneOffset
    }
    
    // MARK: - 派生属性
    public var description: String {
        return """
        时间格式: \(is24HourFormat ? "24小时制" : "12小时制")
        时间: \(year)-\(month)-\(day) \(hour):\(minute):\(second).\(millisecond)
        星期: \(weekday)
        时区偏移: GMT\(timezoneOffset >= 0 ? "+" : "")\(timezoneOffset)
        """
    }
    
    public var formattedDateTime: String {
        String(format: "%04d-%02d-%02d %02d:%02d:%02d.%03d",
               year, month, day, hour, minute, second, millisecond)
    }
    
    // MARK: - 数据转换
    public func toIntArray() -> [Int] {
        return [
            is24HourFormat ? 1 : 0,  // 时间格式标志 (1=24小时制, 0=12小时制)
            hour,                     // 小时
            minute,                   // 分钟
            second,                   // 秒
            millisecond,              // 毫秒
            year,                     // 年
            month,                    // 月
            day,                      // 日
            weekday.rawValue,         // 星期 (1=周一,...,7=周日)
            timezoneOffset            // 与 GMT 时区偏移多少 (小时)
        ]
    }
    
}

// MARK: - 嵌套类型
extension CustomSystemTime {
    /// 星期枚举（类型安全）
    public enum Weekday: Int, CaseIterable {
        case monday = 1, tuesday, wednesday, thursday, friday, saturday, sunday
        
        public var localizedString: String {
            switch self {
            case .monday: return "周一"
            case .tuesday: return "周二"
            case .wednesday: return "周三"
            case .thursday: return "周四"
            case .friday: return "周五"
            case .saturday: return "周六"
            case .sunday: return "周日"
            }
        }
    }
    
    public enum TimeInput {
        case now(String)
        case dateSring(String, TimeZone)
    }
}
// MARK: - 嵌套工具类方法
extension CustomSystemTime {

    /// 统一入口（根据输入类型自动选择方法）
    static func create(from input: TimeInput) -> CustomSystemTime? {
        switch input {
        case .now(let tzIden):
            return getSystemTime(forTimeZone: tzIden)
        case .dateSring(let str, let tz):
            return from(dateString: str, timeZone: tz)
        }
    }
    
    ///- Returns:
    /// 根据 urlString, 获取服务器上的网络时间(24小时制),  并根据自身要求转为指定时区时间
    /// 返回 completion : selectedTime: 选定时区的本地时间, systemTime: 系统本地时间, serverTime: 服务器时间, convertedTime: 服务器时间转换成所选时区
    ///  增加 static 关键字,表明该方法属于工具类方法,不依赖结构体的任何实例属性（如 hour、year 等）
    static func getNetWorkTime(
        urlString: String,
        isFollowSystem: Bool = true,
        timeZoneIden: String = "Asia/Shanghai",
        completion: @escaping ((selectedTime: String, systemTime: String, serverTime: String, convertedTime: String)) -> Void
    ) {
        // 1. 先获取当前系统时间
        let systemFormatter = DateFormatter()
        systemFormatter.timeZone = TimeZone.current
        systemFormatter.dateStyle = .medium
        systemFormatter.timeStyle = .medium
        let systemTime = systemFormatter.string(from: Date())
        
        // 2. 创建网络请求
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  let dateHeader = httpResponse.allHeaderFields["Date"] as? String else {
                print("Failed to get Date header")
                return
            }
            
            // 3. 解析服务器时间
            let serverFormatter = DateFormatter()
            serverFormatter.locale = Locale(identifier: "en_US_POSIX")
            serverFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
            
            guard let serverDate = serverFormatter.date(from: dateHeader) else {
                print("Failed to parse server date")
                return
            }
            
            // 4. 转换到所选时区
            let selectedTimeZone = isFollowSystem ? TimeZone.current : TimeZone(identifier: timeZoneIden) ?? TimeZone.current
            
            let selectedFormatter = DateFormatter()
            selectedFormatter.timeZone = selectedTimeZone
            selectedFormatter.dateStyle = .medium
            selectedFormatter.timeStyle = .medium
            let selectedTime = selectedFormatter.string(from: Date())
            
            // 5. 转换服务器时间到所选时区
            let convertedFormatter = DateFormatter()
            convertedFormatter.timeZone = selectedTimeZone
            convertedFormatter.dateStyle = .medium
            convertedFormatter.timeStyle = .medium
            let convertedTime = convertedFormatter.string(from: serverDate)
            
            // 6. 返回所有时间信息
            DispatchQueue.main.async {
                completion((
                    selectedTime: selectedTime,
                    systemTime: systemTime,
                    serverTime: dateHeader,
                    convertedTime: convertedTime
                ))
            }
        }
        task.resume()
    }
    
    ///- Returns:
    /// 从日期字符串解析, 处理时间数据
    /// 适配 DateFormatter 的 .medium 样式, 可自由指定目标时区（默认当前时区）
    /// 返回: CustomSystemTime
    private static func from(dateString: String, timeZone: TimeZone = .current) -> CustomSystemTime? {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        
        guard let date = formatter.date(from: dateString) else { return nil }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second, .nanosecond, .weekday],
            from: date
        )
        
        guard let year = components.year,
              let month = components.month,
              let day = components.day,
              let hour = components.hour,
              let minute = components.minute,
              let second = components.second,
              let weekday = components.weekday else {
            return nil
        }
        
        // 转换星期格式（系统返回1=周日，需转为1=周一）
        let adjustedWeekday = (weekday + 5) % 7 + 1
        
        return CustomSystemTime(
            is24HourFormat: Locale.current.uses24HourTimeFormat,
            hour: hour,
            minute: minute,
            second: second,
            millisecond: (components.nanosecond ?? 0) / 1_000_000,
            year: year,
            month: month,
            day: day,
            weekday: Weekday(rawValue: adjustedWeekday) ?? .monday,
            timezoneOffset: timeZone.secondsFromGMT() / 3600
        )
    }
    
    ///- Returns:
    /// 直接获取当前系统时间 (Date()), 处理时间数据
    /// 根据本地系统的日历设置格式,始终实时获取系统当前时间
    /// 返回: CustomSystemTime
    private static func getSystemTime(forTimeZone identifier: String = "Asia/Shanghai") -> CustomSystemTime? {
        // 配置DateFormatter
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: identifier) ?? .current
        formatter.locale = Locale.current
        
        //  获取当前日期（已应用指定时区）
        let now = Date()
        
        // 使用 Calendar 分解日期组件
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond, .weekday, .timeZone], from: now)
        
        // 安全解包必要组件
        guard let year = components.year,
              let month = components.month,
              let day = components.day,
              let hour = components.hour,
              let minute = components.minute,
              let second = components.second,
              let nanosecond = components.nanosecond,
              let weekday = components.weekday else {
            return nil
        }
        
        // 计算衍生值
        let millisecond = nanosecond / 1_000_000
        let adjustedWeekday = (weekday + 5) % 7 + 1  // 转换星期格式（1=周一...7=周日）
        let timezoneOffset = formatter.timeZone!.secondsFromGMT() / 3600 //时区偏移(小时)

        
        return CustomSystemTime(
            is24HourFormat: Locale.current.uses24HourTimeFormat,
            hour: hour,
            minute: minute,
            second: second,
            millisecond: millisecond,
            year: year,
            month: month,
            day: day,
            weekday: CustomSystemTime.Weekday(rawValue: adjustedWeekday) ?? .monday,
            timezoneOffset: timezoneOffset
        )
    }

}

// MARK: - Locale 扩展
extension Locale {
    //系统时间是否使用24小时制
    var uses24HourTimeFormat: Bool {
        DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: self)?.contains("a") == false
    }
}

//MARK: - Date 扩展
extension Date {
    //毫秒
    var milliTime: Int {
        let time = self.timeIntervalSince1970
        return Int(CLongLong(round(time*1000)))
    }
    //秒
    var secondTime: Int {
        let time = self.timeIntervalSince1970
        return Int(time)
    }
}

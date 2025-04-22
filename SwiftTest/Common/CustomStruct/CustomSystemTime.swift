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

struct CustomSystemTime {
    let is24HourFormat: Bool
    let hour: Int
    let minute: Int
    let second: Int
    let millisecond: Int
    let year: Int
    let month: Int
    let day: Int
    let weekday: Int // 1=周一, 2=周二,..., 7=周日
    let timezoneOffset: Int // 时区偏移(小时)
    
    var description: String {
        return """
        时间格式: \(is24HourFormat ? "24小时制" : "12小时制")
        时间: \(year)-\(month)-\(day) \(hour):\(minute):\(second).\(millisecond)
        星期: \(weekday)
        时区偏移: GMT\(timezoneOffset >= 0 ? "+" : "")\(timezoneOffset)
        """
    }
    
    func toIntArray() -> [Int] {
        return [
            is24HourFormat ? 1 : 0,  // 时间格式标志 (1=24小时制, 0=12小时制)
            hour,                     // 小时
            minute,                   // 分钟
            second,                   // 秒
            millisecond,              // 毫秒
            year,                     // 年
            month,                    // 月
            day,                      // 日
            weekday,                  // 星期 (1=周一,...,7=周日)
            timezoneOffset            // 与 GMT 时区偏移多少 (小时)
        ]
    }
}

enum TimeFormat {
    case hoursMinutesSeconds    // HH:mm:ss
    case hoursMinutes          // HH:mm
}

///- Returns:
/// 根据本地系统的日历设置格式,获取本地系统时间
/// 返回: CustomSystemTime
func getSystemTimeForCalendar() -> CustomSystemTime? {
    let calendar = Calendar.current
    let now = Date()
    
    // 获取日期组件
    let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond, .weekday, .timeZone], from: now)
    
    // 安全解包必要组件
    guard let year = components.year,
          let month = components.month,
          let day = components.day,
          let hour = components.hour,
          let minute = components.minute,
          let second = components.second,
          let nanosecond = components.nanosecond,
          let weekday = components.weekday,
          let timeZone = components.timeZone else {
        return nil
    }
    
    // 计算毫秒
    let millisecond = nanosecond / 1_000_000
    
    // 调整星期表示 (1=周日 -> 1=周一, 7=周日)
    let adjustedWeekday = weekday == 1 ? 7 : weekday - 1
    
    // 计算时区偏移(小时)
    let timezoneOffset = timeZone.secondsFromGMT() / 3600
    
    return CustomSystemTime(
        is24HourFormat: Locale.current.uses24HourTimeFormat,
        hour: hour,
        minute: minute,
        second: second,
        millisecond: millisecond,
        year: year,
        month: month,
        day: day,
        weekday: adjustedWeekday,
        timezoneOffset: timezoneOffset
    )
}

/// - Returns:
///  根据时区 string ,获取指定时区时间
///  返回: 字符串
func getSystemTime(forTimeZone identifier: String = "Asia/Shanghai") -> String{
    let formatter:DateFormatter = DateFormatter()
    formatter.timeZone = TimeZone(identifier: identifier)
    formatter.dateFormat = Locale.current.uses24HourTimeFormat ? "yy-MM-dd a E z HH:mm:ss.SSS" : "yy-MM-dd a E z hh:mm:ss.SSS"// 设置日期格式，以字符串表示的日期形式的格式

    return formatter.string(from: Date())
}

///- Returns:
/// 根据 urlString, 获取服务器上的网络时间(24小时制),  并根据自身要求转为指定时区时间
/// 返回 completion : selectedTime: 选定时区的本地时间, systemTime: 系统本地时间, serverTime: 服务器时间, convertedTime: 服务器时间转换成所选时区
func getNetWorkTime(
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

/// 时间戳转为时间字符串
/// - Parameter timeData: 总数据,
/// - Parameter TimeFormat: 时间转换类型
/// - Returns: 时间字符串
func getTimeStringForInt(timeData: Int, format: TimeFormat = .hoursMinutesSeconds) -> String {
    switch format {
    case .hoursMinutesSeconds:
        let hours = timeData / 3600
        let minutes = (timeData % 3600) / 60
        let remainingSeconds = (timeData % 3600) % 60
        return String(format: "%.2d:%.2d:%.2d", hours, minutes, remainingSeconds)
    case .hoursMinutes:
        return String(format: "%.2d:%.2d", (timeData / 60), (timeData % 60))
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

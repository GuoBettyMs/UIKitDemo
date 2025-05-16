//
//  TimeFormatter.swift
//  SwiftTest
//
//  Created by user on 2025/5/16.
//

/// 时间格式化工具
public enum TimeFormatter {
    /// 时间显示格式
    public enum Style {
        case hoursMinutesSeconds    // HH:mm:ss
        case hoursMinutes          // HH:mm
    }
    
    /// 将秒数转换为格式化的时间字符串
    /// - Parameters:
    ///   - totalSeconds: 总秒数
    ///   - style: 显示格式
    /// - Returns: 格式化后的字符串
    public static func string(
        from totalSeconds: Int,
        style: Style = .hoursMinutesSeconds
    ) -> String {
        switch style {
        case .hoursMinutesSeconds:
            let hours = totalSeconds / 3600
            let minutes = (totalSeconds % 3600) / 60
            let seconds = totalSeconds % 60
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            
        case .hoursMinutes:
            return String(format: "%02d:%02d", totalSeconds / 60, totalSeconds % 60)
        }
    }
}

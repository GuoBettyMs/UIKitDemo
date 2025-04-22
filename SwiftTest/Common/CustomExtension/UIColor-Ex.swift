//
//  UIColor-Ex.swift
//  SwiftTest
//
//  Created by user on 2025/4/21.
//

import UIKit

extension UIColor {
    // MARK: - 从 Int 十六进制值创建颜色
    /// 从 Int 十六进制值创建 UIColor
    /// - Parameter hexValue: 格式如 `0xFF0000`（红色）
    /// - Returns: 对应的 UIColor
    static func fromHex(_ hexValue: Int) -> UIColor {
        UIColor(
            red: CGFloat((hexValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hexValue & 0xFF00) >> 8) / 255.0,
            blue: CGFloat(hexValue & 0xFF) / 255.0,
            alpha: 1.0
        )
    }

    // MARK: - 从十六进制字符串创建颜色
    /// 从十六进制字符串创建 UIColor（支持 `#RRGGBB` 或 `RRGGBB` 格式）
    /// - Parameter hexString: 如 `"#FF0000"` 或 `"FF0000"`
    /// - Returns: 对应的 UIColor，解析失败时返回 `.gray`
    static func fromHex(_ hexString: String) -> UIColor {
        var formattedString = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if formattedString.hasPrefix("#") {
            formattedString.removeFirst()
        }

        guard formattedString.count == 6 else {
            return .gray
        }

        var rgbValue: UInt64 = 0
        Scanner(string: formattedString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }

    // MARK: - 随机颜色
    /// 生成随机颜色
    /// - Returns: 随机的 UIColor
    static func random() -> UIColor {
        UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1.0
        )
    }
    
    //MARK: - Usage Example
    static func example(){
        // 从 Int 十六进制值创建颜色
        let redColor = UIColor.fromHex(0xFF0000)

        // 从十六进制字符串创建颜色
        let greenColor = UIColor.fromHex("#00FF00")
        let blueColor = UIColor.fromHex("0000FF")

        // 生成随机颜色
        let randomColor = UIColor.random()
        
        print(redColor, greenColor, blueColor, randomColor)
    }
}

//
//  String-Ex.swift
//  SwiftTest
//
//  Created by user on 2025/4/22.
//

import Foundation

extension String {
    // MARK: - 下标访问优化
    
    /// 安全获取指定位置的字符
    /// "Hello"[1] -> "e"
    subscript(safe position: Int) -> String? {
        guard position >= 0, position < count else { return nil }
        let index = self.index(startIndex, offsetBy: position)
        return String(self[index])
    }
    
    /// 安全获取子字符串范围
    /// "Hello"[1..<3] -> "el"
    subscript(safe bounds: Range<Int>) -> String? {
        //lowerBound: 范围的下限; upperBound: 范围的上限
        guard bounds.lowerBound >= 0,
              bounds.upperBound <= count,
              bounds.lowerBound <= bounds.upperBound else {
            return nil
        }
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
    
    /// 安全获取从指定位置开始的子字符串
    /// "Hello"[2,  2] -> "ll"
    subscript(_ start: Int, _ length: Int) -> String? {
        guard start >= 0, length >= 0, start + length <= count else {
            return nil
        }
        let startIndex = index(self.startIndex, offsetBy: start)
        let endIndex = index(startIndex, offsetBy: length)
        return String(self[startIndex..<endIndex])
    }
    
    // MARK: - 子字符串截取
    
    /// 截取从头到指定位置
    func prefix(upTo position: Int) -> String? {
        self[safe: 0..<position]
    }
    
    /// 截取从指定位置到末尾
    func suffix(from position: Int) -> String? {
        self[safe: position..<count]
    }
    
    // MARK: - 数字提取
    
    /// 提取字符串中的所有数字
    /// "A1B23" -> ["1", "23"]
    var numbers: [String] {
        let pattern = "[0-9]+"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let matches = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
        return matches.compactMap { match in
            Range(match.range, in: self).map { String(self[$0]) }
        }
    }
    
    // MARK: - 兼容旧API
    
    /// 旧版下标访问（不建议使用）
    @available(*, deprecated, message: "Use `subscript(safe:)` instead", renamed: "subscript(safe:)")
    subscript(i: Int) -> String {
        self[safe: i] ?? ""
    }

    
    // MARK: - Usage Example
    
    static func example(){
        let str = "Hello123"

        // 安全访问
        print(str[safe: 1] ?? "") // "e"
        print(str[safe: 1..<3] ?? "")// "el"
        print(str[2, 2] ?? "")// "ll"
        
        // 子字符串
        print(str.prefix(upTo: 3) ?? "")// "Hel"
        print(str.suffix(from: 5) ?? "") // "23"
        
        // 数字提取
        print(str.numbers)           // ["123"]

        // 错误处理示例
        print("Hi"[safe: 99] ?? "error")        // nil（不会崩溃）
    }
}

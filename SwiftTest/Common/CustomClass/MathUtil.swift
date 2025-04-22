//
//  MathUtil.swift
//  SwiftTest
//
//  Created by user on 2025/4/21.
//

import Foundation

class MathUtil {
    
    // MARK: - Number Formatting
        
    static func format(double: Double, decimalPlaces accuracy: Int, locale: Locale = .current) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = locale
        formatter.minimumFractionDigits = accuracy
        formatter.maximumFractionDigits = accuracy
        formatter.minimumIntegerDigits = 1
        
        guard let formatted = formatter.string(from: NSNumber(value: double)) else {
            return String(format: "%.\(accuracy)f", double)
        }
        return formatted
    }
    
    // MARK: - Number Filtering
    
    static func filteredInt(from string: String) -> Int {
        let filtered = string.filter { $0.isNumber }
        return Int(filtered) ?? 0
    }
    
    static func filteredDouble(from string: String) -> Double {
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
        let filtered = string.unicodeScalars.filter { allowedCharacters.contains($0) }
        return Double(String(filtered)) ?? 0
    }
    
    // MARK: - Data Conversion

    /// 自动组合字节
    /// load(as: UInt32.self):
    /// 直接从 Data 的字节缓冲区加载一个 UInt32，按照当前平台的字节序（如果 CPU 是小端序，就按小端序加载；如果是大端序，就按大端序加载）
    /// .littleEndian：
    /// 如果当前平台是大端序（如某些 PowerPC、网络字节序），它会交换字节顺序，确保返回的值是小端序格式。如果当前平台已经是小端序（如 x86、ARM），它不会做任何改变
    /// - Parameter data: 如果数据是小端序存储的，并且运行在 小端序 CPU（如 Intel/ARM），load(as:) 会正确读取，.littleEndian 不会改变结果。如果数据是大端序存储的，但函数期望小端序，则 .littleEndian 会交换字节顺序（但可能逻辑错误）
    /// - Returns: 小端序格式的数据
    static func littleEndianUInt32(from data: Data) -> UInt32 {
        guard data.count >= MemoryLayout<UInt32>.size else { return 0 }
        return data.withUnsafeBytes { $0.load(as: UInt32.self).littleEndian }
    }
    

    static func bigEndianUInt32(from data: Data) -> UInt32 {
        guard data.count >= MemoryLayout<UInt32>.size else { return 0 }
        return data.withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
    }
    
    // MARK: - Alternative implementations with explicit byte manipulation

    /// 手动组合字节
    /// bytes[0] 是最低有效字节; bytes[3] 是最高有效字节
    /// - Parameter data: 数据必须是小端序存储的，否则结果错误
    /// - Returns: 小端序格式的数据
    static func littleEndianUInt32Manual(from data: Data) -> UInt32 {
        guard data.count >= 4 else { return 0 }
        let bytes = [UInt8](data)
        return UInt32(bytes[0]) |
               (UInt32(bytes[1]) << 8)  |
               (UInt32(bytes[2]) << 16) |
               (UInt32(bytes[3]) << 24)
    }
    
    static func bigEndianUInt32Manual(from data: Data) -> UInt32 {
        guard data.count >= 4 else { return 0 }
        let bytes = [UInt8](data)
        return (UInt32(bytes[0]) << 24) |
               (UInt32(bytes[1]) << 16) |
               (UInt32(bytes[2]) << 8)  |
               UInt32(bytes[3])
    }
    
    
    // MARK: - 泛型交换函数
    /// 交换两个同类型变量的值
    /// - Parameters:
    ///   - a: 第一个变量（inout）
    ///   - b: 第二个变量（inout）
    static func swap<T>(_ a: inout T, _ b: inout T) {
        (a, b) = (b, a)  // 使用元组交换更简洁
    }

    // MARK: - 数值求和
    /// 计算任意数量整数的和
    /// - Parameter numbers: 可变数量的整数参数
    /// - Returns: 所有输入整数的总和
    static func sum(_ numbers: Int...) -> Int {
        numbers.reduce(0, +)  // 使用高阶函数更简洁
    }

    // MARK: - 字符串拼接
    /// 拼接任意数量的字符串
    /// - Parameter strings: 可变数量的字符串参数
    /// - Returns: 拼接后的字符串
    static func concatenate(_ strings: String...) -> String {
        strings.joined()
    }
    
    //MARK: - Usage Example
    static func example(){
        //MathUtil
        // Formatting
        let formatted = MathUtil.format(double: 1234.5678, decimalPlaces: 2)
        print("Formatting: \(formatted)\n")
        
        // Filtering
        let intValue = MathUtil.filteredInt(from: "abc123def")
        let doubleValue = MathUtil.filteredDouble(from: "12.34abc")
        print("Filtering: intValue(\(intValue)), doubleValue(\(doubleValue))\n")
        
        // Data conversion
        let data = Data([0x12, 0x34, 0x56, 0x78])
        let littleEndian = MathUtil.littleEndianUInt32(from: data)
        let bigEndian = MathUtil.bigEndianUInt32(from: data)
        print("Data conversion: littleEndian(\(littleEndian)), bigEndian(\(bigEndian))\n")
        
        //manipulation
        let littleEndianManual = MathUtil.littleEndianUInt32Manual(from: data)
        let bigEndianManual = MathUtil.bigEndianUInt32Manual(from: data)
        print("manipulation: littleEndianManual(\(littleEndianManual)), bigEndianManual(\(bigEndianManual))\n")
        
        //Data 
        var x = 5, y = 10
        swap(&x, &y)
        print("交换后：x=\(x), y=\(y)")  // 交换后：x=10, y=5

        let total = sum(1, 2, 3, 4, 5)
        print("总和：\(total)")  // 总和：15

        let result = concatenate("Hello", " ", "World", "!")
        print(result)  // Hello World!
        
    }
}


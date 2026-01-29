//
//  ModelEx_forWorkpage.swift
//  SwiftTest
//
//  Created by user on 2026/1/27.
//

import Foundation

extension CustomPickViewM{
    
    //MARK:  设定电压电流
    func setvoltageDouble(){
        data_v = voltageConvertToDouble(from: dataVArr_new)
    }
    
    func setcurrentDouble(){
        data_i = currentConvertToDouble(from: dataIArr_new)
    }
    
    func setvoltageIntArr(text: String){
        dataVArr_new = voltageStringToIntArray(text)
    }
    
    func setcurrentIntArr(text: String){
        dataIArr_new = currentStringToIntArray(text)
    }
    
    //将电压值（如 200 表示 2.00V）格式化为 固定两位整数 + 两位小数 的形式
    func formatVoltage(_ rawValue: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 2  // 整数部分至少2位，不足补0
        formatter.minimumFractionDigits = 2 // 小数部分至少2位
        formatter.maximumFractionDigits = 2 // 小数部分最多2位
        
        return (formatter.string(from: NSNumber(value: rawValue)) ?? "00.00") //+ "V"
    }
    
    func voltageStringToIntArray(_ str: String) -> [Int] {
        // 1. 分离整数和小数部分
        let components = str.components(separatedBy: ".")
        
        let integerPart = components.first ?? "0"
        let decimalPart = components.count > 1 ? components[1] : ""
        
        // 2. 补全位数
        let paddedInteger = String(format: "%02d", Int(integerPart) ?? 0)
        let paddedDecimal = decimalPart.padding(toLength: 2, withPad: "0", startingAt: 0) // 固定2位小数
        
        // 3. 转换为数字数组
        let integerDigits = paddedInteger.map { Int(String($0)) ?? 0 }
        let decimalDigits = paddedDecimal.map { Int(String($0)) ?? 0 }
        
        // 4. 合并结果 [整数, 小数点(0), 小数...]
        return integerDigits + [0] + decimalDigits
    }
    
    ///电流字符串转为 Int 数组
    func currentStringToIntArray(_ str: String) -> [Int] {
        // 1. 分离整数和小数部分
        let components = str.components(separatedBy: ".")
        let integerPart = components.first ?? "0"
        let decimalPart = components.count > 1 ? components[1] : ""
        
        // 2. 补全位数
        let paddedInteger = String(format: "%01d", Int(integerPart) ?? 0) // 固定1位整数
        let paddedDecimal = decimalPart.padding(toLength: 3, withPad: "0", startingAt: 0) // 固定3位小数
        
        // 3. 转换为数字数组
        let integerDigit = Int(String(paddedInteger.first ?? "0")) ?? 0
        let decimalDigits = paddedDecimal.map { Int(String($0)) ?? 0 }
        
        // 4. 合并结果 [整数, 小数点(0), 小数...]
        return [integerDigit, 0] + decimalDigits
    }

    ///电压 Int 数组转换为 Double 类型
    func voltageConvertToDouble(from array: [Int]) -> Double {
        guard array.count >= 5 else {
            return 0.0 // 或者根据需求处理数组长度不足的情况
        }
        
        let integerPart = array[0...1].map { String($0) }.joined()
        let decimalPart = array[2...4].map { String($0) }.joined()
        let integerValue = Double(integerPart) ?? 0.0
        let decimalValue = Double(decimalPart) ?? 0.0
        
        return integerValue + decimalValue / 100.0
    }
    
//    func getVoltageFromArray(_ values: [Int]) -> Double {
//        let integerPart = Double(values[0] * 10 + values[1])
//        let decimalPart = Double(values[3]) * 0.1 + Double(values[4]) * 0.01
//        return integerPart + decimalPart
//    }
    
    ///电流 Int 数组转换为 Double 类型
    func currentConvertToDouble(from array: [Int]) -> Double {
        guard array.count >= 5 else {
            return 0.0 // 或者根据需求处理数组长度不足的情况
        }
        
        let integerPart = array[0]
        let decimalPart = array[1...4].map { String($0) }.joined()
        let decimalValue = Double(decimalPart) ?? 0.0
        
        return Double(integerPart) + decimalValue / 1000.0
    }
}

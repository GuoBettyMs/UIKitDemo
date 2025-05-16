//
//  CustomUsbData.swift
//  SwiftTest
//
//  Created by user on 2025/5/15.
//
// 自定义端口数据字符串

import Foundation

enum UsbData {
    case vol(decimals: Int = 1)
    case cur(decimals: Int = 1)
    case pow(decimals: Int = 1)
    case volCur(volDecimals: Int = 1, curDecimals: Int = 1)
    case volPow(volDecimals: Int = 1, powDecimals: Int = 1)
    case curPow(curDecimals: Int = 1, powDecimals: Int = 1)
    case volCurPow(volDecimals: Int = 1, curDecimals: Int = 1, powDecimals: Int = 1)
}
let chargingProtocol = [" ", NSLocalizedString("QuickCharge", comment: "QuickCharge"), "QC", "QC", "PD", "PD", "PD", NSLocalizedString("QuickCharge", comment: "QuickCharge")]

struct CustomUsbData{

    private init() {} // 防止外部实例化
    
    static func setUsbDataStr(_ v: Int32, _ c: Int32, _ p: Int32, _ dataType: UsbData, _ manualPowerCalculation: Bool = false) -> [String]{
        let vol = Double(v) / 1000.0
        let cur = abs(Double(c) / 1000.0)
        let pow = manualPowerCalculation ? abs(Double(v * c) / 1000000.0) : abs(Double(p) / 1000.0)

        switch dataType {
        case .vol(let decimals):
            let volStr = vol.formatted(decimalPlaces: decimals)
            return [volStr]
            
        case .cur(let decimals):
            let curStr = cur.formatted(decimalPlaces: decimals)
            return [curStr]
            
        case .pow(let decimals):
            let powStr = pow.formatted(decimalPlaces: decimals)
            return [powStr]
            
        case .volCur(let volDecimals, let curDecimals):
            let volStr = vol.formatted(decimalPlaces: volDecimals)
            let curStr = cur.formatted(decimalPlaces: curDecimals)
            return [volStr, curStr]
            
        case .volPow(let volDecimals, let powDecimals):
            let volStr = vol.formatted(decimalPlaces: volDecimals)
            let powStr = pow.formatted(decimalPlaces: powDecimals)
            return [volStr, powStr]
            
        case .curPow(let curDecimals, let powDecimals):
            let curStr = cur.formatted(decimalPlaces: curDecimals)
            let powStr = pow.formatted(decimalPlaces: powDecimals)
            return [curStr, powStr]
            
        case .volCurPow(let volDecimals, let curDecimals, let powDecimals):
            let volStr = vol.formatted(decimalPlaces: volDecimals)
            let curStr = cur.formatted(decimalPlaces: curDecimals)
            let powStr = pow.formatted(decimalPlaces: powDecimals)
            return [volStr, curStr, powStr]
        }
    }

    // Custom join function that takes an array of separators
    static func customJoin(_ parts: [String], separators: [String], defaultSeparator: String = " ") -> String {

        guard !parts.isEmpty else { return "" }
        guard parts.count > 1 else { return parts[0] }
        
        var result = ""
        let effectiveSeparators: [String]
        
        if separators.isEmpty {
            effectiveSeparators = Array(repeating: defaultSeparator, count: parts.count)
        } else {
            effectiveSeparators = separators + Array(repeating: defaultSeparator,
                                                   count: max(0, parts.count - separators.count))
        }
        
        for (index, part) in parts.enumerated() {
            result += part
            if index < parts.count - 1 || index < effectiveSeparators.count {
                result += effectiveSeparators[index]
            }
        }
        
        return result
    }
    
    static func setAccessibilityUsbdataL(
        _ dataStrArr: [String],
        proIndex: Int = 0,
        _ dataType: UsbData,
        shouldLocalize: Bool = true  // 新增参数控制是否使用本地化
    ) -> String {
        // 本地化字符串的获取方式
        func localized(_ key: String, comment: String = "") -> String {
            if shouldLocalize {
                return NSLocalizedString(key, comment: comment)
            } else {
                // 确保项目中有 zh-Hans.lproj/Localizable.strings 文件,强制读取中文本地化资源
                guard let path = Bundle.main.path(forResource: "zh-Hans", ofType: "lproj"),
                      let bundle = Bundle(path: path) else {
                    return key
                }
                return bundle.localizedString(forKey: key, value: key, table: nil)
            }
        }

        let protocolSuffix = localized("protocol", comment: "协议")
        let proStr = proIndex > 0 ? " \(chargingProtocol[proIndex])\(protocolSuffix) " : " "
        
        let dataPrefix = localized("thedatais", comment: "数据为")
        var accessibilityL = dataPrefix + proStr
        
        let voltageSuffix = localized("V", comment: "伏")
        let currentSuffix = localized("A", comment: "安")
        let powerSuffix = localized("W", comment: "瓦")
        
        switch dataType{
        case .vol(_):
            accessibilityL += CustomUsbData.customJoin(dataStrArr, separators: ["\(voltageSuffix) "])
            
        case .cur(_):
            accessibilityL += CustomUsbData.customJoin(dataStrArr, separators: ["\(currentSuffix) "])
            
        case .pow(_):
            accessibilityL += CustomUsbData.customJoin(dataStrArr, separators: ["\(powerSuffix) "])
            
        case .volCur(_, _):
            accessibilityL += CustomUsbData.customJoin(dataStrArr, separators: ["\(voltageSuffix) ", "\(currentSuffix) "])
            
        case .volPow(_, _):
            accessibilityL += CustomUsbData.customJoin(dataStrArr, separators: ["\(voltageSuffix) ", "\(powerSuffix) "])
            
        case .curPow(_, _):
            accessibilityL += CustomUsbData.customJoin(dataStrArr, separators: ["\(currentSuffix) ", "\(powerSuffix) "])
            
        case .volCurPow(_, _, _):
            accessibilityL += CustomUsbData.customJoin(dataStrArr, separators: ["\(voltageSuffix) ", "\(currentSuffix) ", "\(powerSuffix) "])
        }
       return accessibilityL
    }
    
    // 统一本地化工具方法
    private static func localized(_ key: String,
                                defaultValue: String,
                                shouldLocalize: Bool) -> String {
        guard shouldLocalize else { return defaultValue }
        return NSLocalizedString(key, value: defaultValue, comment: "") // 当找不到翻译时使用默认值 defaultValue
    }

    // 电池容量描述（Int版本）
    static func setAccessibilityBatterycapacityL(_ per: Int,
                                                 shouldLocalize: Bool = true) -> String {
        if !shouldLocalize {
            return "当前电量是百分之\(per)"
        } else {
            let powerStr = localized("CurrentPower",
                                   defaultValue: "The current power is",
                                     shouldLocalize: shouldLocalize)
            let percentStr = localized("Percent",
                                     defaultValue: "%",
                                       shouldLocalize: shouldLocalize)
            return "\(powerStr) \(per) \(percentStr)"
        }
    }

    // 端口描述（String版本）
    static func setAccessibilityPortL(_ c: String,
                                      shouldLocalize: Bool = true) -> String {
        if !shouldLocalize  {
            return "\(c)口"
        } else {
            let portStr = localized("Port",
                                 defaultValue: "port",
                                    shouldLocalize: shouldLocalize)
            return "\(portStr) \(c) "
        }
    }
  
    
    static func example(){
        let v = 9100
        let c = -1500
        let p = Double(v * c) / 1000.0
        let p1 = Double(v * c) / 1000000.0
        print("V: \(p),\(p1.formatted(decimalPlaces: 2)), \((abs(p)+500)/1000)")//-13650.0,-13.65, 14.15
        print("V: \(abs(p1).formatted(decimalPlaces: 1))") //13.7
        print("手动计算功率: \(setUsbDataStr(Int32(v), Int32(c), 0, .volCurPow(), true))") // ["9.1", "1.5", "13.7"]
        print("自动计算功率: \(setUsbDataStr(Int32(v), Int32(c), 0, .volCurPow()))")//["9.1", "1.5", "0.0"]
        
        print("------------------")
        let parts = setUsbDataStr(Int32(v), Int32(c), 0, .volCurPow())
        let dataStr0 = customJoin(parts, separators: [])
        let dataStr1 = customJoin(parts, separators: ["V "])
        let dataStr2 = customJoin(parts, separators: ["V / ", "A / "])
        let dataStr3 = customJoin(parts, separators: ["V ", "A ", "W "])
        print("dataStr0: \(dataStr0)")//dataStr0: 9.1 1.5 0.0
        print("dataStr1: \(dataStr1)") //dataStr1: 9.1V 1.5 0.0
        print("dataStr2: \(dataStr2)") //dataStr2: 9.1V / 1.5A / 0.0
        print("dataStr3: \(dataStr3)") //dataStr3: 9.1V 1.5A 0.0W
        
        print("------------------")
        let parts1 = setUsbDataStr(Int32(v), Int32(c), 0, .volPow())
        let label = customJoin(parts1, separators: ["V ", "W "])
        let label1 = customJoin(parts1, separators: ["V / ", "W "])
        print("label: \(label)") //label: 9.1V 0.0W
        print("label1: \(label1)") //label1: 9.1V / 0.0W
        
        let per = setAccessibilityBatterycapacityL(50)
        let per1 = setAccessibilityBatterycapacityL(50, shouldLocalize: false)
        print("per: \(per)") //per: The current power is 50 percent
        print("per1: \(per1)") //per1: 当前电量是百分之50
        
        let c1 = setAccessibilityPortL("c1")
        let c2 = setAccessibilityPortL("c1", shouldLocalize: false)
        let accessibilityL1 = c2+setAccessibilityUsbdataL(parts1, proIndex: 0, .volPow(), shouldLocalize: false)
        let accessibilityL2 = c1+setAccessibilityUsbdataL(parts1, proIndex: 2, .volPow())

        print("accessibilityL1: \(accessibilityL1)") //accessibilityL1: c1口数据为 9.1伏 0.0瓦
        print("accessibilityL2: \(accessibilityL2)") //accessibilityL2: port c1 the data is QCprotocol 9.1V 0.0W
    }
}


//
//  VCEx_forNumberKeyboard.swift
//  SwiftTest
//
//  Created by user on 2026/1/16.
//

import UIKit

// MARK: - 文本框设置模式处理扩展
extension CustomPickViewVC: NumberKeyboardDelegate, UITextFieldDelegate{
    
    // MARK:  UITextFieldDelegate
    
    //文本框输入过程,自动对文本进行检查
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let config = currentConfig
         let currentText = textField.text ?? ""
         let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
         
         // 如果是删除操作，允许
         if string.isEmpty {
             return true
         }
         
         // 1. 检查输入合法性
         if !isValidNumberInput(newText, config: config) {
             return false
         }
         
         // 2. 检查是否超过最大值
         if !isWithinMaxLimit(newText, config: config) {
             return false
         }
         
         // 3. 检查特殊边界条件
         if !isValidForBoundary(newText, config: config) {
             return false
         }

         return true
    }
    
//    func textFieldDidChangeSelection(_ textField: UITextField) {
//        // 文本变化时更新键盘状态
//        updateKeyboardState(for: textField.text ?? "")
//    }
    
    // MARK: 动态配置
    private var currentConfig: NumberInputConfig {
        // 根据当前模式返回不同的配置
        if container.pickV.maxValue >= 10.0 {
            return NumberInputConfig(maxValue: 30.50)
        } else if container.pickV.maxValue >= 1.0 {
            return NumberInputConfig(maxValue: 5.100)
        } else {
            return NumberInputConfig(maxValue: 0.99)
        }
    }
    
    // MARK: NumberKeyboardDelegate
    
    func backspacePressed() {
        Log.debug("退格键按下")
        handleBackspace()
    }
    
    func clearPressed() {
        Log.debug("清空键按下")
        handleClear()
    }
    
    func confirmPressed() {
//        Log.debug("确认键按下")
        handleConfirm()
    }
    
    func numberKeyPressed(_ number: Int) {
        Log.debug(" \(model.isOutputVolSet ? "电压" : "电流") 数字键按下: \(number)")
        handleNumberInput(number)
    }
    
    func decimalPointPressed() {
        Log.debug("小数点按下")
        handleDecimalPoint()
    }
    
    func iconButtonPressed() {
        Log.debug("隐藏按钮按下")
        
        model.setBtnClickedI = -1
        container.recoverSetBtnMaskedCorners(isVolSetting: model.isOutputVolSet)
        
        model.isOutputSetOpen = false
        container.showTimeandEnergyV1(isShow: true)

        
    }


    /// 文本框设置模式下,获取文本内容
    private func getCurrentTextField() -> UITextField? {
        for subview in container.textfieldBgV.subviews {
            if let textField = subview as? UITextField {
                return textField
            }
        }
        return nil
    }
    
    private func handleNumberInput(_ number: Int) {
        guard let textField = getCurrentTextField() else { return }
        let config = currentConfig
        let currentText = textField.text ?? ""
        let defaultText = getDefaultText(config: config)
        
        // 如果是默认值，清空
        let normalizedText = (currentText == defaultText) ? "" : currentText
            
        let newText = constructNewText(currentText: normalizedText, newDigit: number, config: config)
            
        if isValidNumberInput(newText, config: config) &&
           isWithinMaxLimit(newText, config: config) &&
           isValidForBoundary(newText, config: config) {
            
            container.setTextfieldAttributedText(text: (newText.isEmpty) ? defaultText : newText)
        }
        
        updateKeyboardState(for: textField.text ?? "")
    }
    
    private func handleDecimalPoint() {
            guard let textField = getCurrentTextField() else { return }
            let config = currentConfig
            let currentText = textField.text ?? ""
            let defaultText = getDefaultText(config: config)
            
            let normalizedText = (currentText == defaultText) ? "" : currentText
            
            if normalizedText.contains(".") {
                return
            }
            
            if let currentValue = Double(normalizedText), currentValue >= config.maxValue {
                return
            }
            
            let newText: String
            if normalizedText.isEmpty {
                newText = "0."
            } else {
                newText = normalizedText + "."
            }
            
            if isValidNumberInput(newText, config: config) &&
               isWithinMaxLimit(newText, config: config) &&
               isValidForBoundary(newText, config: config) {
                
                container.setTextfieldAttributedText(text: newText)
            }
            
            updateKeyboardState(for: textField.text ?? "")
        }
    
    private func handleBackspace() {
        guard let textField = getCurrentTextField() else { return }
         let config = currentConfig
         let defaultText = getDefaultText(config: config)
         let currentText = textField.text ?? ""
         
         if currentText.isEmpty || currentText == defaultText {
             Log.debug("currentText \(currentText) 为空 或者 == \(defaultText)")
             return
         }
         
         let newText = String(currentText.dropLast())
         container.setTextfieldAttributedText(text: newText.isEmpty ? defaultText : newText)
         
         updateKeyboardState(for: textField.text ?? "")
    }
    
    private func handleClear() {
        guard let textField = getCurrentTextField() else { return }
        let config = currentConfig
        
        container.setTextfieldAttributedText(text: getDefaultText(config: config))
        updateKeyboardState(for: textField.text ?? "")
    }
    
    private func handleConfirm() {
        guard let textField = getCurrentTextField() else { return }
        let text = textField.text ?? ""
        
        //一键确认发送命令
        if model.isOutputVolSet {
            model.setvoltageIntArr(text: text) //文本转数组
            model.dataVArr_origin = model.dataVArr_new
            model.setvoltageDouble() //数组转 double
            
            container.setBtns[0].setValueText("\(model.data_v.formattedWithLeadingZero())")
            
            Log.debug("确认键按下: \(text) = \(model.dataVArr_new) = \(model.data_v)")
            
            let data = round(model.data_v * 100)
            Log.debug("执行发送命令,电压一键设定数值: \(model.data_v)V = \(data) * 10mV, \(Int(data))")
            //sendRemoteControldata(at: 1, Int(data))
        }else{
            model.setcurrentIntArr(text: text) //文本转数组
            model.dataIArr_origin = model.dataIArr_new
            model.setcurrentDouble() //数组转 double
            
            container.setBtns[1].setValueText("\(model.data_i.formatted(decimalPlaces: 3))")
            
            Log.debug("确认键按下: \(text) = \(model.dataIArr_new) = \(model.data_i)")
            
            let data = round(model.data_i * 1000)
            Log.debug("执行发送命令,电流一键设定数值: \(model.data_i)A = \(data)mA, \(Int(data))")
            //sendRemoteControldata(at: 2, Int(data))
            
        }
        
        
    }
    
    // MARK: - 辅助函数

    private func predictMinValueAfterDecimal(_ textWithDot: String) -> Double {
        // 预测添加小数点后的最小值
        // 如 "30." → 30.0, "3." → 3.0
        guard textWithDot.hasSuffix(".") else {
            // 如果不是以小数点结尾，直接转换
            return Double(textWithDot) ?? currentConfig.getMaxDecimalValue() + 1
        }
        
        // 移除末尾的点，转换为整数
        let integerPart = String(textWithDot.dropLast())
        if let intValue = Int(integerPart) {
            return Double(intValue) // 如 30.0
        }
        
        return currentConfig.getMaxDecimalValue() + 1
    }
        
    private func formatNumberText(_ text: String) -> String {
        if let number = Double(text) {
            // 根据需求格式化，这里保留两位小数
            return String(format: "%.2f", number)
        }
        return text
    }

    
    // 检查输入是否为合法数字
    private func isValidNumberInput(_ text: String, config: NumberInputConfig) -> Bool {
        // 允许删除
           if text.isEmpty { return true }
           
           // 检查是否是数字或小数点
           let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
           let characterSet = CharacterSet(charactersIn: text)
           if !allowedCharacters.isSuperset(of: characterSet) {
               return false
           }
           
           // 检查小数点数量（最多一个）
           if text.components(separatedBy: ".").count > 2 {
               return false
           }
           
           // 动态检查小数位数
           if let dotRange = text.range(of: ".") {
               let decimalPart = text[dotRange.upperBound...]
               
               if decimalPart.count > config.decimalDigits {
                   return false
               }
           }
           
           // 检查整数位数
           let integerPart: String
           if let dotRange = text.range(of: ".") {
               integerPart = String(text[..<dotRange.lowerBound])
           } else {
               integerPart = text
           }
           
           if integerPart.count > config.integerDigits {
               return false
           }
           
           return true
    }
    
    private func isWithinMaxLimit(_ text: String, config: NumberInputConfig) -> Bool {
            // 空文本或初始值始终允许
            if text.isEmpty || text == getDefaultText(config: config) {
                Log.debug("空文本或初始值始终允许")
                return true
            }
            
            // 转换为数值检查
            if let value = Double(text) {
//                Log.debug("value \(value) 是否 <= \(config.maxValue)")
                return value <= config.maxValue
            }
            
            // 对于不完整的输入，进行预测性检查
            return predictWillExceedLimit(text, config: config)
        }
    
    private func predictWillExceedLimit(_ text: String, config: NumberInputConfig) -> Bool {
           if text.contains(".") {
               let parts = text.split(separator: ".")
               let integerPart = String(parts[0])
               let decimalPart = parts.count > 1 ? String(parts[1]) : ""
               
               // 检查整数部分
               if integerPart.count > config.integerDigits {
                   Log.debug("整数部分 \(integerPart) count > \(config.integerDigits)")
                   return false
               }
               
               // 检查小数部分长度
               if decimalPart.count > config.decimalDigits {
                   Log.debug("小数部分 \(decimalPart) count > \(config.decimalDigits)")
                   return false
               }
               
               // 预测添加一位小数后的值
               if text.hasSuffix(".") {
                   let predictedText = text + "0"
                   if let predictedValue = Double(predictedText) {
                       Log.debug("预测值 \(predictedValue) <= \(config.maxValue)")
                       return predictedValue <= config.maxValue
                   }
               }
               
               return true
           } else {
               // 纯整数部分
               if text.count > config.integerDigits {
                   return false
               }
               
               // 预测添加小数点和小数后的值
               let predictedText = text + ".0"
               if let predictedValue = Double(predictedText) {
                   return predictedValue <= config.maxValue
               }
               
               return true
           }
       }
    private func isValidForBoundary(_ text: String, config: NumberInputConfig) -> Bool {
         // 边界值特殊处理（如30.50, 5.100）
         if !config.isBoundaryValue {
             return true
         }
         
         let maxInteger = config.getMaxIntegerValue()
         let maxDecimal = config.getMaxDecimalValue()
         
         if text.contains(".") {
             let parts = text.split(separator: ".")
             let integerPart = parts.count > 0 ? Int(parts[0]) ?? 0 : 0
             let decimalPart = parts.count > 1 ? String(parts[1]) : ""
             
             // 整数部分已达到最大值
             if integerPart == maxInteger {
                 // 检查小数部分是否超过限制
                 if decimalPart.isEmpty {
                     return true // 如 "30." 允许
                 }
                 
                 // 将小数部分转换为数值
                 let decimalValue = Double("0.\(decimalPart)") ?? 0.0
                 return decimalValue <= maxDecimal
             }
         } else {
             // 纯整数
             if let intValue = Int(text) {
                 return intValue <= maxInteger
             }
         }
         
         return true
     }
    // MARK: - 辅助方法
        
        private func getDefaultText(config: NumberInputConfig) -> String {
//            // 根据配置返回默认文本
//            if config.decimalDigits == 2 {
//                return "00.00"
//            } else if config.decimalDigits == 3 {
//                return "0.000"
//            } else {
//                return "00.00"
//            }
            return ""
        }
        
//        func textFieldDidChangeSelection(_ textField: UITextField) {
//            Log.debug(" 文本变化时更新键盘状态 ")
//            // 文本变化时更新键盘状态
//            updateKeyboardState(for: textField.text ?? "")
//        }
    
    
    func updateKeyboardState(for text: String) {
        
        let config = currentConfig
        
//        Log.debug("=== 更新键盘状态开始 ===")
//        Log.debug("当前配置: maxValue=\(config.maxValue), 整数位=\(config.integerDigits), 小数位=\(config.decimalDigits)")
       
        // 处理初始值
        var normalizedText = text
        let defaultText = getDefaultText(config: config)
        if text == defaultText || text.isEmpty {
            normalizedText = ""
        }
//        Log.debug("输入文本: '\(text)', 默认文本: '\(defaultText)', 标准化文本: '\(normalizedText)'")
        
        // 首先处理特殊场景
        let specialCaseHandled = handleSpecialScenariosIfNeeded(normalizedText, config: config)
        if specialCaseHandled {
            Log.debug("特殊场景已处理")
//            Log.debug("=== 更新键盘状态结束 ===\n")
            return
        }
        
        // 控制小数点按钮
        updateDecimalPointState(for: normalizedText, config: config)
        
        // 控制数字键0-9
        updateNumberKeysState(for: normalizedText, config: config)
        
//        Log.debug("=== 更新键盘状态结束 ===\n")
    }
    
    private func handleSpecialScenariosIfNeeded(_ text: String, config: NumberInputConfig) -> Bool {
        let maxInteger = config.getMaxIntegerValue()
        
        // 根据不同的maxValue生成特殊场景
        var specialCases: [String] = []
        
        if config.maxValue >= 10.0 {
            // 30.50模式
            specialCases = ["\(maxInteger)", "\(maxInteger).", "\(maxInteger).5", ""]
        } else if config.maxValue >= 1.0 {
            // 5.100模式
            specialCases = ["\(maxInteger)", "\(maxInteger).", "\(maxInteger).1", ""]
        } else {
            // 0.99模式
            specialCases = ["0", "0.", "0.99"]
        }
        
        
        if specialCases.contains(text) {
            handleSpecialScenarios(text, config: config)
            return true
        }
        return false
    }
    
    private func handleSpecialScenarios(_ text: String, config: NumberInputConfig) {
        
        let maxInteger = config.getMaxIntegerValue()
        let maxDecimal = config.getMaxDecimalValue()
        
        let numberKeyboardV = container.numberKeyboardV
        
        Log.debug("text:\(text) ,  其中 maxInteger: \(maxInteger), maxDecimal: \(maxDecimal)")

        if text == ""{
            Log.debug("场景0: 未输入")
            if config.maxValue >= 10.0 {
                // 小数点应该启用
                container.numberKeyboardV.enableDecimalPoint()
                for number in 0...9 {
                    numberKeyboardV.enableNumberKey(number)
                }
            }else if config.maxValue >= 1.0 {
                //0-5
                for number in 6...9{
                    numberKeyboardV.disableNumberKey(number)
                }
            }else {
                for number in 0...9 {
                    numberKeyboardV.enableNumberKey(number)
                }
            }
        }
        
        // 场景1: 文本为 "30" 或 “5”
        if text == "\(maxInteger)"  {
            Log.debug("场景1: 文本为最大值整数部分")
            // 小数点应该启用（可以变成"30."）
            numberKeyboardV.enableDecimalPoint()
            // 所有数字键禁用（30+任何数字 > 30.5）
            for number in 0...9 {
                numberKeyboardV.disableNumberKey(number)
            }
            return
        }

        // 场景2: 文本为 "30."
        if text == "\(maxInteger)." {
            Log.debug("场景2: 文本为最大值整数部分 + 小数点")
            // 小数点应该禁用（已经有小数点了）
            numberKeyboardV.disableDecimalPoint()

            
            // 根据小数位最大值启用相应数字键
            if config.maxValue >= 10.0 {
                // 30.50: 数字键0-5启用
                for number in 0...5 {
                    numberKeyboardV.enableNumberKey(number)
                }
                for number in 6...9 {
                    numberKeyboardV.disableNumberKey(number)
                }
            } else if config.maxValue >= 1.0 {
                // 5.100: 数字键0-1启用
                for number in 0...1 {
                    numberKeyboardV.enableNumberKey(number)
                }
                for number in 2...9 {
                    numberKeyboardV.disableNumberKey(number)
                }
            } else {
                // 0.99: 所有数字键启用
                for number in 0...9 {
                    numberKeyboardV.enableNumberKey(number)
                }
            }
            
            return
        }

        // 将文本转换为数字
        if let textValue = Double(text) {
            // 场景1: 文本已达到最大值（完全匹配，包含小数位）
            if text == String(format: "%.\(config.decimalDigits)f", config.maxValue) {
                Log.debug("场景3: 文本已达到最大值（精确格式匹配）")
                disableAllKeys()
                return
            }
            
            // 场景2: 文本值在数值上等于最大值（忽略格式化差异）
            if textValue == config.maxValue {
                Log.debug("场景4: 文本值在数值上等于最大值")
                disableAllKeys()
                return
            }
            
            // 场景3: 处理用户输入可能省略尾随零的情况
            // 例如：maxValue=30.50，用户输入30.5
            // 或者：maxValue=5.100，用户输入5.1
            
            //  使用NumberFormatter进行比较
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = config.decimalDigits
            
            if let formattedMax = formatter.string(from: NSNumber(value: config.maxValue)),
               let formattedText = formatter.string(from: NSNumber(value: textValue)),
               formattedMax == formattedText {
                Log.debug("场景5: 文本在数值上等于最大值（忽略尾随零）")
                disableAllKeys()
                return
            }
        }
        
        // 场景6: 文本为 "0"
        if text == "0"  {
            Log.debug("场景6: 文本为0")
            // 小数点应该启用（可以变成"0."）
            numberKeyboardV.enableDecimalPoint()
            // 所有数字键禁用
            for number in 0...9 {
                numberKeyboardV.disableNumberKey(number)
            }
            return
        }
        
    }
    
    func disableAllKeys() {
        container.numberKeyboardV.disableDecimalPoint()
        for number in 0...9 {
            container.numberKeyboardV.disableNumberKey(number)
        }
    }
    
    private func updateDecimalPointState(for text: String, config: NumberInputConfig) {
        if text.contains(".") {
            // 已经有小数点，禁用小数点按钮
            container.numberKeyboardV.disableDecimalPoint()
            return
        }
        
        // 检查添加小数点后是否可能形成有效值
        let textWithDot = text.isEmpty ? "0." : text + "."
        
        // 预测添加小数点后的最小可能值（如"30." → "30.0"）
        let minPossibleValue = predictMinValueAfterDecimal(textWithDot)
        
        if minPossibleValue <= config.maxValue {
            container.numberKeyboardV.enableDecimalPoint()
        } else {
            container.numberKeyboardV.disableDecimalPoint()
        }

    }
    
    private func updateNumberKeysState(for text: String, config: NumberInputConfig) {
        // 检查每个数字键
        for number in 0...9 {
            let nextText = constructNewText(currentText: text, newDigit: number, config: config)
                    
//          Log.debug("检查数字 \(number): 当前文本='\(text)', 预测文本='\(nextText)'")
            
            if canAddDigitToText(nextText, digit: number, config: config) {
                container.numberKeyboardV.enableNumberKey(number)
//                        Log.debug("✅ 启用数字键 \(number)")
            } else {
                container.numberKeyboardV.disableNumberKey(number)
//                        Log.debug("❌ 禁用数字键 \(number)")
            }
        }
    }
    
    private func constructNewText(currentText: String, newDigit: Int, config: NumberInputConfig) -> String {
        let text = currentText

        let defaultText = getDefaultText(config: config)
        // 处理初始值
        if text == defaultText || text.isEmpty {
            return "\(newDigit)"
        }
        
        // 如果当前是"0"，用新数字替换
        if text == "0" {
            return "\(newDigit)"
        }
        
        // 如果当前是"0."，直接追加
        if text == "0." {
            return text + "\(newDigit)"
        }
        
        // 检查是否已经达到最大长度
        let maxLength = config.integerDigits + (config.decimalDigits > 0 ? config.decimalDigits + 1 : 0)
        if text.replacingOccurrences(of: ".", with: "").count >= maxLength {
            return text  // 已达到最大长度，不再追加
        }
        
        // 否则追加数字
        return text + "\(newDigit)"
    }
    
    private func canAddDigitToText(_ text: String, digit: Int, config: NumberInputConfig) -> Bool {

        // 空文本时，检查这个数字本身是否有效
        if text.isEmpty {
            // ✅ 检查单个数字是否超过最大值
            let singleDigitValue = Double(digit)
            return singleDigitValue <= config.maxValue
        }
        
//        // 如果文本以"0"开头且不是"0."，可能有问题
//        if text == "0" && digit == 0 {
//            return false // "00" 通常不允许
//        }
        
        if text.contains(".") {
            return canAddDigitAfterDecimal(text, digit: digit, config: config)
        } else {
            return canAddDigitBeforeDecimal(text, digit: digit, config: config)
        }
    }
        
    private func canAddDigitBeforeDecimal(_ text: String, digit: Int, config: NumberInputConfig) -> Bool {

        // 检查新整数是否超过允许的整数位数
        if text.count > config.integerDigits {
            Log.debug("❌ 预测 '\(text)' 整数部分会超过 \(config.integerDigits) 位 ")
            return false
        }
        
        // 转换为数字检查
        if let intValue = Int(text) {
            // 预测添加小数点后的最小值（如"30" → "30.0"）
            let minPossibleValue = Double(intValue)
//                    Log.debug("预测添加小数点后的最小值 \(minPossibleValue)")
            return minPossibleValue <= config.maxValue
//
//                    if minPossibleValue > config.maxValue {
//                        Log.debug("❌ 预测最小值 \(minPossibleValue) 超过最大值 \(config.maxValue)")
//                        return false
//                    }
//
//                    // ✅ 特殊检查：对于30.5，输入"3"后，"30"是允许的，但"30" + 任何数字 > "30.5"
//                    if intValue == config.getMaxIntegerValue() && digit > 0 {
//                        Log.debug("❌ 已达到整数部分最大值 \(intValue)，不能再加数字 \(digit)")
//                        return false
//                    }
//
//                    Log.debug("✅ 允许数字 \(digit)，新文本 '\(text)'，整数值 \(intValue)")
//                    return true
        }
        
        Log.debug("❌ 无法转换为整数: '\(text)'")
        return false
    }
        
    private func canAddDigitAfterDecimal(_ text: String, digit: Int, config: NumberInputConfig) -> Bool {

        // 分割整数和小数部分
        let parts = text.split(separator: ".")
        guard parts.count >= 1 else { return false }
        
        _ = String(parts[0])
        let decimalPart = parts.count > 1 ? String(parts[1]) : ""
        
//            Log.debug("整数部分: \(integerPart), 小数部分: \(decimalPart)")
        
//            decimalPart += "\(digit)"// 添加新数字到小数部分
        
        // 检查小数部分长度
        if decimalPart.count > config.decimalDigits {
//                Log.debug(" 小数部分个数超出 \(config.decimalDigits )")
            return false
        }
        
//            let fullText = "\(integerPart).\(decimalPart)"// 构建完整数字
        
        // 转换为数值检查
        if let value = Double(text) {
            return value <= config.maxValue
        }
        
        return false
    }
    
}

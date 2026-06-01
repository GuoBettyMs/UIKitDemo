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
        
        // 1. 快速路径：删除操作永远允许，不做任何计算
        if string.isEmpty {
            return true
        }
        
        // 2. 预计算新文本 (只计算一次)
        // 使用 NSString 的替换方法比 Swift String 的切片更高效
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        // 3. 漏斗式校验：
        // 顺序很重要：先做低成本的正则/长度检查，最后做高成本的数值转换
        
        // 第一层：基础格式校验 (检查非法字符、多个小数点)
        guard isValidFormat(newText, config: config) else {
            return false
        }
            
        // 第二层：长度限制校验 (检查整数/小数位数是否超标)
        guard isValidLength(newText, config: config) else {
            return false
        }
            
        // 第三层：数值边界校验 (检查是否超过 maxValue)
        guard isValidValue(newText, config: config) else {
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
    
    //更新数字键盘使能
    func updateKeyboardState(for text: String) {

        let config = currentConfig
        
        // 1. 标准化文本（去除默认占位符）
        let defaultText = getDefaultText(config: config)
        let normalizedText = (text == defaultText || text.isEmpty) ? "" : text
        
        // 2. 动态计算并更新键盘状态
        updateDecimalPointState(for: normalizedText, config: config)// 控制小数点按钮
        updateNumberKeysState(for: normalizedText, config: config)// 控制数字键0-9
        
    }
    
    //MARK: - 辅助函数

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
        
        // 获取基础文本（处理默认值）
        let currentText = textField.text ?? ""
        let defaultText = getDefaultText(config: config)
        let normalizedText = (currentText == defaultText) ? "" : currentText
        
        // 构造新文本
        let newText = constructNewText(currentText: normalizedText, newDigit: number, config: config)
        
        // 漏斗式校验：基础格式 -> 长度限制 -> 数值边界
        if isValidFormat(newText, config: config) &&
           isValidLength(newText, config: config) &&
           isValidValue(newText, config: config) {
            
            container.setTextfieldAttributedText(text: newText.isEmpty ? defaultText : newText)
        }
        
        updateKeyboardState(for: textField.text ?? "")

    }
    
    private func handleDecimalPoint() {
        guard let textField = getCurrentTextField() else { return }
        let config = currentConfig
       
        // 获取基础文本（处理默认值）
        let currentText = textField.text ?? ""
        let defaultText = getDefaultText(config: config)
        let normalizedText = (currentText == defaultText) ? "" : currentText //输入“.”, 识别失败,文本重置为空
        
        if normalizedText.contains(".") {
            return
        }
        
        if let currentValue = Double(normalizedText), currentValue >= config.maxValue {
            return
        }
        
        let newText: String
        if normalizedText.isEmpty { //若文本为空,重置为“0.”
            newText = "0."
        } else {
            newText = normalizedText + "."
        }
        
        // 漏斗式校验：基础格式 -> 长度限制 -> 数值边界
        if isValidFormat(newText, config: config) &&
           isValidLength(newText, config: config) &&
           isValidValue(newText, config: config) {
            
            container.setTextfieldAttributedText(text: newText.isEmpty ? defaultText : newText)
        }
    
        updateKeyboardState(for: textField.text ?? "")
    }
    
    private func handleBackspace() {
        guard let textField = getCurrentTextField() else { return }
         let config = currentConfig
         let defaultText = getDefaultText(config: config)
         let currentText = textField.text ?? ""
         
         if currentText.isEmpty || currentText == defaultText {
             Log.debug("currentText为空,无需退格")
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

    // MARK: 基础格式校验
    private func isValidFormat(_ text: String, config: NumberInputConfig) -> Bool {
        if text.isEmpty { return true }
        
        // 只能包含数字和小数点
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
        if !allowedCharacters.isSuperset(of: CharacterSet(charactersIn: text)) {
            return false
        }
        
        // 只能有一个小数点
        if text.components(separatedBy: ".").count > 2 {
            return false
        }
        
        return true
    }
    // MARK: 长度限制校验
    private func isValidLength(_ text: String, config: NumberInputConfig) -> Bool {
        if text.isEmpty { return true }
        
        let parts = text.split(separator: ".", maxSplits: 1)
        let integerPart = String(parts[0])
        let decimalPart = parts.count > 1 ? String(parts[1]) : ""
        
        // 检查整数位数
        if integerPart.count > config.integerDigits {
            return false
        }
        
        // 检查小数位数
        if decimalPart.count > config.decimalDigits {
            return false
        }
        
        return true
    }
    
    // MARK: 数值边界校验
    private func isValidValue(_ text: String, config: NumberInputConfig) -> Bool {
        if text.isEmpty { return true }
        
        // 情况 A: 完整的数字(如 "30.5", "20"),Double 转换成功
        // 注意：Double("30.") 返回 30，Double("30.0") 返回 30.0
        // 对于 "30." 这种中间状态，我们通常认为它是合法的，等待用户继续输入
        if let value = Double(text) {
            return value <= config.maxValue
        }
        
        // (可选)防呆 isValidFormat、 isValidLength 未正常拦截,如不完整的输入 (如 "30.a"), Double 转换失败
        // 此时需要预测它是否可能超标,预测逻辑：如果整数部分已经超过最大值，直接拒绝
        if text.hasSuffix(".") {
            let integerPart = String(text.dropLast())
            if let intValue = Int(integerPart) {
                // 如果整数部分已经大于最大值的整数部分，拒绝 (例如 max=30.5, input=31.)
                if intValue > config.getMaxIntegerValue() {
                    return false
                }
                // 如果整数部分相等 (例如 max=30.5, input=30.)，允许继续输入
                return true
            }
        }
        
        return true
    }

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
    
    //小数点状态更新
    private func updateDecimalPointState(for text: String, config: NumberInputConfig) {
        if text.contains(".") {
            // 已经有小数点，禁用小数点按钮
            container.numberKeyboardV.disableDecimalPoint()
            return
        }
        
        // 检查添加小数点后是否可能形成有效值
        // "30" -> "30." -> Double("30.") = 30.0
        // "" -> "0." -> Double("0.") = 0.0
        let textWithDot = text.isEmpty ? "0." : text + "."
        
        if let predictedValue = Double(textWithDot) {
            // 如果预测值小于最大值，允许输入小数点
            // 例如：max=30.5, current=30 -> 30.0 <= 30.5 (允许)
            // 例如：max=30.5, current=31 -> 31.0 > 30.5 (禁用)
            if predictedValue <= config.maxValue {
                container.numberKeyboardV.enableDecimalPoint()
            } else {
                container.numberKeyboardV.disableDecimalPoint()
            }
        } else {
            // 极端情况，默认禁用
            container.numberKeyboardV.disableDecimalPoint()
        }

    }
    
    //数字键状态更新
    private func updateNumberKeysState(for text: String, config: NumberInputConfig) {

        for number in 0...9 {
            // 1. 构造尝试输入后的文本
            let nextText = constructNewText(currentText: text, newDigit: number, config: config)
            
            // 2. 核心逻辑：直接复用之前的“漏斗式校验”
            // 如果这个新文本是合法的，就启用该按键；否则禁用
            if isValidFormat(nextText, config: config) &&
               isValidLength(nextText, config: config) &&
               isValidValue(nextText, config: config) {
                container.numberKeyboardV.enableNumberKey(number)
            } else {
                container.numberKeyboardV.disableNumberKey(number)
            }
        }
    }
    
    //新文本构造逻辑
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
        
        
        // 否则追加数字
        return text + "\(newDigit)"
    }

}

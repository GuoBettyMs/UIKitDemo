//
//  VCEx_forWheelNumberPicker.swift
//  SwiftTest
//
//  Created by user on 2026/1/16.
//


import UIKit

// MARK: - 选择器设置模式处理扩展
extension CustomPickViewVC: WheelNumberPickerDelegate{
    
    func wheelNumberPicker(_ picker: WheelNumberPicker, didSelectValue value: Double) {
        
        Log.debug("picker.tag: \(picker.tag) ,最终数值: \(value)")
        
        if model.isOutputVolSet {
            if model.volRealtimeStatus {
                let data = round(model.data_v * 100)
                Log.debug("执行发送命令,电压设定数值: \(model.data_v)V = \(data) * 10mV, \(Int(data))")
                //sendRemoteControldata(at: 1, Int(data))
                
                container.setBtns[0].setValueText("\(model.data_v.formattedWithLeadingZero())")
                
            }
        }else{
            if model.curRealtimeStatus{
                let data = round(model.data_i * 1000)
                Log.debug("执行发送命令,电流设定数值: \(model.data_i)A = \(data)mA, \(Int(data))")
                //sendRemoteControldata(at: 2, Int(data))
                container.setBtns[1].setValueText("\(model.data_i.formatted(decimalPlaces: 3))")
            }
        }

    }
    
    func wheelSingleNumberPicker(_ picker: WheelNumberPicker,
                               didSelectPickerIndex pickerI: Int,
                               didSelectValue value: Int,
                               isRealTime: Bool) {
        
        if picker.tag == 0 { //电压
            // pickerI: 0,1,2,3 -> numI: 0,1,3,4
            let numI = pickerI > 1 ? pickerI+1 : pickerI
            
            guard numI < model.dataVArr_new.count else { return }
            
            if model.dataVArr_new[numI] != value {
                Log.debug("picker.tag: \(picker.tag) ,PickerIndex: \(pickerI), didSelectValue: \(value), model.dataVArr_new: \(model.dataVArr_new)[\(numI)]")
                
                // 检查是否允许数值更改
                if volshouldAllowValueChange(at: numI, oldValue: model.dataVArr_new[numI], newValue: value) {
                    volhandleNumberChangeWithValidation(at: numI, newValue: value)
                } else {
                    restoreVoltagePickerValue1(at: numI, for: picker)
                }
            }
        }else if  picker.tag == 1 { //电流
            // pickerI: 0,1,2,3 -> numI: 0,2,3,4
            let numI = pickerI > 0 ? pickerI+1 : pickerI
            guard numI < model.dataIArr_new.count else { return }

            if model.dataIArr_new[numI] != value {
                Log.debug("picker.tag: \(picker.tag) ,PickerIndex: \(pickerI), didSelectValue: \(value), model.dataIArr_new: \(model.dataIArr_new)[\(numI)] ")
                
                 // 检查是否允许数值更改
                if curshouldAllowValueChange(at: numI, oldValue: model.dataIArr_new[numI], newValue: value) {
                    curhandleNumberChangeWithValidation(at: numI, newValue: value)
                } else {
                    restoreVoltagePickerValue1(at: numI, for: picker)
                }
            }
        }

    }
    
    //MARK: -
    //恢复到原来的选中行
    private func restoreVoltagePickerValue1(at index: Int, for pickerView: WheelNumberPicker) {
        
        if pickerView.tag == 0 {
            let oldValue = model.dataVArr_new[index]
            //index: 0,1,3,4 -> pickerViewI: 0,1,2,3
            let pickerViewI = index > 2 ? index-1 : index
            let scrollRow = container.pickV.calculateScrollRow(from: oldValue, forPickerTag: pickerViewI)
            
            pickerView.pickerViews[pickerViewI].selectRow(scrollRow , inComponent: 0, animated: true)
            
            Log.debug("\(pickerViewI) 电压恢复到原来的选中行: \(scrollRow)")
        }else if  pickerView.tag == 1 {
            
            let oldValue = model.dataIArr_new[index]
            //index: 0,2,3,4 -> pickerViewI: 0,1,2,3
            let pickerViewI = index > 1 ? index-1 : index
            let scrollRow = container.pickV.calculateScrollRow(from: oldValue, forPickerTag: pickerViewI)
            
            pickerView.pickerViews[pickerViewI].selectRow(scrollRow , inComponent: 0, animated: true)
            
            Log.debug("\(pickerViewI) 电流恢复到原来的选中行: \(scrollRow)")
        }
    }
    
    // 操作类型枚举
    private enum OperationType {
        case carry      // 进位操作 (3→0 或 9→0)
        case borrow     // 借位操作 (0→3 或 0→9)
        case increment  // 普通递增
        case decrement  // 普通递减
        case noChange   // 无变化
    }
    
  
    //更新数据模型、更新 setpickBGVs 里的 ui 值
    private func updateLabelAndModel(isVol: Bool,at index: Int, value: Int) {
        
        if isVol {
            guard index < model.dataVArr_new.count else { return }
          
            // 更新数据模型
            model.dataVArr_new[index] = value
            
            
            //保存电压最终设置值
            model.setvoltageDouble()
//            if model.volRealtimeStatus {
//                container.setBtns[0].setValueText("\(model.data_v.formattedWithLeadingZero())")
//            }
            
            
        }else{
            guard index < model.dataIArr_new.count else { return }
          
            // 更新数据模型
            model.dataIArr_new[index] = value
            
            
            //保存最终设置值
            model.setcurrentDouble()
//            if model.curRealtimeStatus {
//                container.setBtns[1].setValueText("\(model.data_i.formatted(decimalPlaces: 3))")
//            }
        }
    }
    
    // 处理临时数组中的进位（用于最大值检查）
    private func handleCarryInTempArray(_ tempValues: inout [Int], at index: Int) {
        // 简化的进位处理逻辑，用于预测
        if tempValues[index] == 10 { // 如果某位变成10
            tempValues[index] = 0
            if index > 0 {
                tempValues[index-1] += 1
            }
        }
    }
    // 更新所有picker的选中行
    private func updateVolAllPickerRows(isVol: Bool) {
        
        for i in 0..<5 {
            if isVol {
                if i != 2 { // 跳过小数点
                    //datai: 0,1,3,4 -> pickerViewI:0,1,2,3
                    let pickerViewI = i > 2 ? i-1 : i
                    let scrollRow = container.pickV.calculateScrollRow(from: model.dataVArr_new[i], forPickerTag: pickerViewI)
                    container.pickV.pickerViews[pickerViewI].selectRow(scrollRow , inComponent: 0, animated: true)
                }
            }else{
                if i != 1 { // 跳过小数点
                    //datai: 0,2,3,4 -> pickerViewI:0,1,2,3
                    let pickerViewI = i > 0 ? i-1 : i
                    let scrollRow = container.pickV.calculateScrollRow(from: model.dataIArr_new[i], forPickerTag: pickerViewI)
                    container.pickV.pickerViews[pickerViewI].selectRow(scrollRow , inComponent: 0, animated: true)
                }
            }
            
        }
    }
    
    //进位过程,设置新的滚动位置
    func adjustNewScrollPosition_Carry(isvol: Bool ,actualValue: Int, carryIndex: Int){
        
        Log.debug("索引 \(carryIndex) 即将进位加1")
    
        // 确保 pickerView 存在且有效
        if carryIndex < container.pickV.pickerViews.count {
            
            let pickerViewI: Int
            if isvol{
                //carryIndex: 0,1,3 -> picvkI: 0,1,2
                pickerViewI = carryIndex < 2 ? carryIndex : carryIndex-1
            }else{
                //carryIndex: 0,2,3 -> picvkI: 0,1,2
                pickerViewI = carryIndex > 1 ? carryIndex-1 : carryIndex
            }
            let pickerView = container.pickV.pickerViews[pickerViewI]
            let scrollRow = container.pickV.calculateScrollRow(from: actualValue, forPickerTag: pickerViewI)
                    
//           // 检查当前选中的行
//            let currentSelectedRow = pickerView.selectedRow(inComponent: 0)
//            Log.debug("pickerView[\(carryIndex)] 当前选中行: \(currentSelectedRow), 即将滚动到: \(scrollRow)")
            
            // 设置新的滚动位置
            pickerView.selectRow(scrollRow, inComponent: 0, animated: true)
            
            // 手动触发代理方法
            container.pickV.pickerView(pickerView, didSelectRow: scrollRow, inComponent: 0)
        }

        Log.debug("进位完成")
    }
    //借位过程,设置滚轮新的滚动位置
    func adjustNewScrollPosition_Borrow(isVol: Bool, actualValue: Int, borrowIndex: Int){
        
        Log.debug("索引 \(borrowIndex) 即将退位减1")
        
        // 确保 pickerView 存在且有效
        if borrowIndex < container.pickV.pickerViews.count {

            var picvkI: Int
            if isVol {
                //borrowIndex: 0,1,3 -> picvkI: 0,1,2
                picvkI = borrowIndex > 2 ? borrowIndex-1 : borrowIndex
                
            }else{
                //borrowIndex: 0,2,3 -> 0,1,2
                picvkI = borrowIndex > 0 ? borrowIndex-1 : borrowIndex
            }

            let pickerView = container.pickV.pickerViews[picvkI]
            let scrollRow = container.pickV.calculateScrollRow(from: actualValue, forPickerTag: picvkI)
            
//            // 检查当前选中的行
//            let currentSelectedRow = pickerView.selectedRow(inComponent: 0)
//            Log.debug("pickerView[\(picvkI)] 当前选中行: \(currentSelectedRow), 即将滚动到: \(scrollRow), actualValue:\(actualValue)")
            
            // 设置新的滚动位置
            pickerView.selectRow(scrollRow, inComponent: 0, animated: true)

        }
    }
    
    
    //MARK:  设置电压
    
    // 判断电压操作类型
    private func getVolOperationType(at index: Int, oldValue: Int, newValue: Int) -> OperationType {

        // 进位操作判断
        if (index == 0 && oldValue == 3 && newValue == 0) ||
           (index > 0 && oldValue == 9 && newValue == 0) {
            return .carry
        }
        
        // 借位操作判断
        if (index == 0 && oldValue == 0 && newValue == 3) ||
           (index > 0 && oldValue == 0 && newValue == 9) {
            return .borrow
        }
        
        // 普通递增/递减操作判断
        if newValue > oldValue {
            return .increment
        } else if newValue < oldValue {
            return .decrement
        }
        
        return .noChange
    }
    
    
    // 处理普通操作
    private func handleVolNormalOperation(at index: Int, oldValue: Int, newValue: Int, operationType: OperationType) -> Bool {
        
        let isIncreasing = operationType == .increment
//        let isDecreasing = operationType == .decrement
        
        // ========== 递增过程中,最大值检查规则 ==========
        if isIncreasing && willExceedMaxVoltage(at: index, newValue: newValue) {
            print("禁止：\(index) 递增过程中,数值超过最大值 30.5V, 恢复原来值: \(oldValue)")
//            adjustVolToMaxVoltage()
            
            model.dataVArr_new[index] = oldValue
            restoreVoltagePickerValue1(at: index, for: container.pickV)
            
            return false
        }
        
        // ========== 特殊规则检查 ==========
        if !checkSpecialRules(at: index, newValue: newValue, isIncreasing: isIncreasing) {
            return false
        }
        
        return true
    }
    
    
    // 检查特殊规则
    private func checkSpecialRules(at index: Int, newValue: Int, isIncreasing: Bool) -> Bool {
        // 特殊规则1：整数部分为 3 时，个位禁止递增
        if model.dataVArr_new[0] == 3 && index == 1 {
            if newValue > 0 && isIncreasing {
                print("禁止：整数部分为 3 时，个位只能递减")
                return false
            }
        }
        
        // 特殊规则2：当整数部分为 30 时，小数点后第一位禁止递增
        if model.dataVArr_new[0] == 3 && model.dataVArr_new[1] == 0 && index == 3 {
            if newValue > 5 && isIncreasing {
                print("禁止：整数部分为 30 时，小数点后第一位只能递减")
                return false
            }
        }
        
        // 特殊规则3：当整数部分为 30.5 时，最后一位禁止递增
        if model.dataVArr_new[0] == 3 && model.dataVArr_new[1] == 0 && model.dataVArr_new[3] == 5 && index == 4 {
            if newValue > 0 && isIncreasing {
                print("禁止：数值为 30.5 时，最后一位小数只能递减")
                return false
            }
        }
        
        return true
    }
    
    //允许数值更改的情况
    private func volshouldAllowValueChange(at index: Int, oldValue: Int, newValue: Int) -> Bool {
        
        // 判断操作类型
        let operationType = getVolOperationType(at: index, oldValue: oldValue, newValue: newValue)
        
        switch operationType {
        case .carry:
            // ========== 进位操作处理 ==========
            return handleVolCarryOperation(at: index, oldValue: oldValue, newValue: newValue)
            
        case .borrow:
            // ========== 借位操作处理 ==========
            return handleVolBorrowOperation(at: index, oldValue: oldValue, newValue: newValue)
            
        case .decrement, .increment:
            // ========== 普通递增/递减操作处理 ==========
            return handleVolNormalOperation(at: index, oldValue: oldValue, newValue: newValue, operationType: operationType)
            
        case .noChange:
            return false // 无变化，不允许操作
        }
        
    }
    
    //数值有效情况下,处理数值更改
    private func volhandleNumberChangeWithValidation(at currentIndex: Int, newValue: Int) {
     
        guard currentIndex < model.dataVArr_new.count else { return }
        let oldValue = model.dataVArr_new[currentIndex]
        
        // 判断操作类型
        let operationType = getVolOperationType(at: currentIndex, oldValue: oldValue, newValue: newValue)
        
        switch operationType {
        case .carry:
            Log.debug("\(currentIndex) 电压处理进位")
            handleVolCarry(at: currentIndex, from: newValue)
            
        case .borrow:
            Log.debug("\(currentIndex) 电压处理退位")
            let borrowSuccess = handleVolBorrow(at: currentIndex, from: newValue)
            if borrowSuccess {
                updateLabelAndModel(isVol: true, at: currentIndex, value: newValue)
                Log.debug("借位成功，更新当前位[\(currentIndex)]为\(newValue), \(model.data_v) = \(model.dataVArr_new)")
            }
            // 重置清零标志
            model.hasClearedTrailingDigits = false
            
        case .increment, .decrement:
            Log.debug("\(currentIndex) 普通更新，\(oldValue)->\(newValue)")
            updateLabelAndModel(isVol: true, at: currentIndex, value: newValue)
            // 重置清零标志
            model.hasClearedTrailingDigits = false
            
        case .noChange:
            break // 无变化，不处理
        }
        
    }
    
    //MARK: 处理进位
    
    // 返回值表示是否允许下一步的进位操作
    private func handleVolCarryOperation(at index: Int, oldValue: Int, newValue: Int) -> Bool {
        Log.debug("进位操作: 位置[\(index)] \(oldValue)→\(newValue)")
            
        // 检查进位后是否超过最大值
        if willExceedMaxVoltageAfterCarry(at: index, newValue: newValue) {
            Log.debug("进位后将超过最大值 30.5，调整到最大值")
            adjustVolToMaxVoltage()
            return false
        }
        
        // 允许进位操作，实际处理在 volhandleNumberChangeWithValidation 中
        return true
    }
    
    // 检查进位后是否会超过最大值
    private func willExceedMaxVoltageAfterCarry(at index: Int, newValue: Int) -> Bool {
        
        // 创建临时数组模拟进位后的状态
        var tempValues = model.dataVArr_new
        tempValues[index] = newValue // 当前位变为0
        
        var carryIndex = index - 1
        
        // 模拟进位过程
        while carryIndex >= 0 {
            if carryIndex == 2 {
                carryIndex -= 1
                continue
            }
            
            guard carryIndex < tempValues.count else { break }
            
            if tempValues[carryIndex] < 9 {
                tempValues[carryIndex] += 1
                break
            } else {
                tempValues[carryIndex] = 0
                carryIndex -= 1
            }
        }
            
            // 计算进位后的电压值
        let voltage = model.voltageConvertToDouble(from: tempValues)
        Log.debug("进位后预测电压: \(voltage)V")
        
        return voltage > 30.5

    }
    
    // 检查普通递增时,是否会超过最大电压 30.5
    private func willExceedMaxVoltage(at index: Int, newValue: Int) -> Bool {
        // 创建临时数组来模拟更新后的状态
        var tempValues = model.dataVArr_new
        tempValues[index] = newValue
        
        // 处理可能的进位
        handleCarryInTempArray(&tempValues, at: index)
        
        // 计算电压值
        let voltage =  model.voltageConvertToDouble(from: tempValues)
        Log.debug("递增时 预测电压: \(voltage)V")
        return voltage > 30.5
    }


    // 调整到最大电压值 30.5
    private func adjustVolToMaxVoltage() {
        updateLabelAndModel(isVol: true, at: 0, value: 3)  // 十位: 3
        updateLabelAndModel(isVol: true, at: 1, value: 0)  // 个位: 0
        updateLabelAndModel(isVol: true, at: 3, value: 5)  // 十分位: 5
        updateLabelAndModel(isVol: true, at: 4, value: 0)  // 百分位: 0
        
        // 更新所有对应的picker选中行
        updateVolAllPickerRows(isVol: true)
    }

    
    //处理进位
    private func handleVolCarry(at currentIndex: Int, from newValue: Int) {
        
        Log.debug("进位处理 at index: \(currentIndex), newValue: \(newValue)")
            
        // 先更新当前位为0（因为是从9变为0）
        model.dataVArr_new[currentIndex] = 0
        updateLabelAndModel(isVol: true, at: currentIndex, value: 0)
        
        var carryIndex = currentIndex - 1
        
        // 向前进位直到不需要进位为止
        while carryIndex >= 0 {
            if carryIndex == 2 {
                // 跳过小数点位置
                carryIndex -= 1
                continue
            }
            
            guard carryIndex < model.dataVArr_new.count else { break }
            
            if model.dataVArr_new[carryIndex] < 9 {
                // 当前位可以加1，进位完成
                model.dataVArr_new[carryIndex] += 1
                updateLabelAndModel(isVol: true, at: carryIndex, value: model.dataVArr_new[carryIndex])
                
                adjustNewScrollPosition_Carry(isvol: true, actualValue: model.dataVArr_new[carryIndex], carryIndex: carryIndex)
                
                // 检查是否达到最大值 30.5
                if model.dataVArr_new[0] == 3 && model.dataVArr_new[1] == 0 && model.dataVArr_new[3] == 5 {
                    Log.debug("电压进位后, 总值达到最大值 30.5, 后续位数清零")
                    
                    updateLabelAndModel(isVol: true, at: 4, value: 0)
                    
                    let scrollRow = container.pickV.calculateScrollRow(from: 0, forPickerTag: 3)
                    container.pickV.pickerViews[3].selectRow(scrollRow , inComponent: 0, animated: true)
                }
                break
            } else {
                Log.debug("\(carryIndex) 当前是9，置为0，继续向前进位")
                // 当前位是9，置为0，继续向前进位
                model.dataVArr_new[carryIndex] = 0
                updateLabelAndModel(isVol: true, at: carryIndex, value: 0)
                
                adjustNewScrollPosition_Carry(isvol: true, actualValue: model.dataVArr_new[carryIndex], carryIndex: carryIndex)
                
                carryIndex -= 1
            }
        }
            
        // 如果进位到最高位且最高位也是9→0，需要特殊处理
        if carryIndex < 0 {
            Log.debug("最高位进位，恢复原来值")
//            // 调整到最大值
//            adjustVolToMaxVoltage()
            
            model.dataVArr_new[0] = 3
            restoreVoltagePickerValue1(at: 0, for: container.pickV)
            
        }

    }
    
    //MARK: 处理借位
    
    // 返回值表示是否允许下一步的借位操作
    private func handleVolBorrowOperation(at index: Int, oldValue: Int, newValue: Int) -> Bool {
        Log.debug("借位操作: 位置[\(index)] \(oldValue)→\(newValue)")
            
        if isAtMinVoltage() {
            let pickerViewI = index > 2 ? index-1 : index
            let scrollRow = container.pickV.calculateScrollRow(from: oldValue, forPickerTag: pickerViewI)
            container.pickV.pickerViews[pickerViewI].selectRow(scrollRow , inComponent: 0, animated: true)
            
            Log.debug("已达到电压最小值，\(index) 停止借位")
            return false
        }
        
        // 检查是否需要清零后面位数
        if shouldClearTrailingDigits(at: index, oldValue: oldValue, newValue: newValue) {
            if model.hasClearedTrailingDigits {
                Log.debug("禁止：已经清零过后面位数，无法继续借位")
                return false
            } else {
                Log.debug("第一次借位，清零后面位数")
                clearTrailingDigits(from: index)
                model.hasClearedTrailingDigits = true
                return false
            }
        }
        
        // 不需要清零，允许借位操作
        Log.debug("允许借位操作")
        return true
        
    }
    
    // 检查是否应该清零后面的位数
    private func shouldClearTrailingDigits(at index: Int, oldValue: Int, newValue: Int) -> Bool {
        // 只有借位操作才考虑清零
        let isBorrowOperation = (index == 0 && newValue == 3 && oldValue == 0) ||
                               (index > 0 && newValue == 9 && oldValue == 0)
        
        guard isBorrowOperation else { return false }
        
        switch index {
        case 0: // 十位借位：检查个位或小数位是否有非零值
            return model.dataVArr_new[1] != 0 || model.dataVArr_new[3] != 0 || model.dataVArr_new[4] != 0
            
        case 1: // 个位借位：检查小数位是否有非零值
            return model.dataVArr_new[0] == 0 && (model.dataVArr_new[3] != 0 || model.dataVArr_new[4] != 0)
            
        case 3: // 十分位借位：检查百分位是否有非零值
            return model.dataVArr_new[0] == 0 && model.dataVArr_new[1] == 0 && model.dataVArr_new[4] != 0
            
        default:
            return false
        }
        
    }

    // 清零从指定位置开始的所有后面位数
    private func clearTrailingDigits(from index: Int) {
        switch index {
        case 0: // 清零个位和小数位
            if model.dataVArr_new[1] != 0 {
                updateLabelAndModel(isVol: true, at: 1, value: 0)
            }
            if model.dataVArr_new[3] != 0 {
                updateLabelAndModel(isVol: true, at: 3, value: 0)
            }
            if model.dataVArr_new[4] != 0 {
                updateLabelAndModel(isVol: true, at: 4, value: 0)
            }
            
        case 1: // 清零小数位
            if model.dataVArr_new[3] != 0 {
                updateLabelAndModel(isVol: true, at: 3, value: 0)
            }
            if model.dataVArr_new[4] != 0 {
                updateLabelAndModel(isVol: true, at: 4, value: 0)
            }
            
        case 3: // 清零百分位
            if model.dataVArr_new[4] != 0 {
                updateLabelAndModel(isVol: true, at: 4, value: 0)
            }
            
        default:
            break
        }
        
        // 更新picker显示
        updateVolAllPickerRows(isVol: true)
    }

    
    //处理借位, 返回值表示借位是否成功
    private func handleVolBorrow(at currentIndex: Int, from newValue: Int) -> Bool {
        
        Log.debug(" ==== 操作位 \(currentIndex) ====  ")
        
        var borrowIndex = currentIndex - 1
        var borrowSuccessful = false
        
        while borrowIndex >= 0 {
            // 跳过小数点位置
            if borrowIndex == 2 {
                borrowIndex -= 1
                continue
            }
            
            guard borrowIndex < model.dataVArr_new.count else { break }
            
            Log.debug("待借位 \(borrowIndex) 的旧值, \( model.dataVArr_new[borrowIndex])  ")
            
            if model.dataVArr_new[borrowIndex] > 0 {
                // 当前位可以减1，借位完成
                model.dataVArr_new[borrowIndex] -= 1
                updateLabelAndModel(isVol: true, at: borrowIndex, value: model.dataVArr_new[borrowIndex])
                
                adjustNewScrollPosition_Borrow(isVol: true, actualValue: model.dataVArr_new[borrowIndex], borrowIndex: borrowIndex)
                
                borrowSuccessful = true
                Log.debug("当前位[\(borrowIndex)]减1, 借位完成")
                break
            } else {
                // 当前位为0，先置为9,继续借位
                model.dataVArr_new[borrowIndex] = 9
                updateLabelAndModel(isVol: true, at: borrowIndex, value: 9)
                Log.debug("位置[\(borrowIndex)]置为9，继续借位")
                
                adjustNewScrollPosition_Borrow(isVol: true, actualValue: model.dataVArr_new[borrowIndex], borrowIndex: borrowIndex)
                
                borrowIndex -= 1
            }
        }
        
        return borrowSuccessful
      
    }
    
    // 检查是否达到最小电压值 0.00
    private func isAtMinVoltage() -> Bool {
        return model.dataVArr_new[0] == 0 &&
               model.dataVArr_new[1] == 0 &&
               model.dataVArr_new[3] == 0 &&
               model.dataVArr_new[4] == 0
    }
 
    
    //MARK: - 设置电流
    
    // 判断电流操作类型
    private func getCurOperationType(at index: Int, oldValue: Int, newValue: Int) -> OperationType {
        // 进位操作判断
        if (index == 0 && oldValue == 5 && newValue == 0) ||
           (index > 0 && oldValue == 9 && newValue == 0) {
            return .carry
        }
        
        // 借位操作判断
        if (index == 0 && oldValue == 0 && newValue == 5) ||
           (index > 0 && oldValue == 0 && newValue == 9) {
            return .borrow
        }
        
        // 普通递增/递减操作判断
        if newValue > oldValue {
            return .increment
        } else if newValue < oldValue {
            return .decrement
        }
        
        return .noChange
    }
    
    // 处理普通操作
    private func handleCurNormalOperation(at index: Int, oldValue: Int, newValue: Int, operationType: OperationType) -> Bool {
        
        let isIncreasing = operationType == .increment
        
        // ========== 递增过程中,最大值检查规则 ==========
        if isIncreasing && willExceedMaxCurrent(at: index, newValue: newValue) {
            print("禁止：\(index) 递增过程中,数值超过最大值 5.1A, 恢复原来值: \(oldValue)")
//            adjustVolToMaxCurrent()
            
            model.dataIArr_new[index] = oldValue
            restoreVoltagePickerValue1(at: index, for: container.pickV)
            
            return false
        }
        
        // ========== 特殊规则检查 ==========
        if !checkCurSpecialRules(at: index, newValue: newValue, isIncreasing: isIncreasing) {
            return false
        }
        
        return true
    }
    
    // 检查特殊规则
    private func checkCurSpecialRules(at index: Int, newValue: Int, isIncreasing: Bool) -> Bool {
 
        // 特殊规则1：当整数部分为5时，小数点后第一位禁止递增: 1->2->3...,只能0->1
        if model.dataIArr_new[0] == 5 && index == 2 {
            if newValue > 1 && isIncreasing{
                print("禁止：整数部分为5时，小数点后第一位只能递减 ")
                return false
            }
        }
        
        // 特殊规则2：当整数部分为5时，小数点后第二位禁止递增: 1->2->3...,只能0->1
        if model.dataIArr_new[0] == 5 && model.dataIArr_new[2] == 1 && index == 3 {
            if newValue > 0 && isIncreasing{
                print("禁止：数值为 5.1 时，小数点后第二位只能递减")
                return false
            }
        }
        
        // 特殊规则3：当整数部分为5时，小数点最后一位禁止递增: 1->2->3...,只能0->1
        if model.dataIArr_new[0] == 5 && model.dataIArr_new[2] == 1 && model.dataIArr_new[3] == 0 && index == 4 {
            if newValue > 0 && isIncreasing{
                print("禁止：数值为 5.1 时，小数点最后一位只能递减")
                return false
            }
        }
  
        return true //符合递增条件
    }
    
    //允许数值更改的情况
    private func curshouldAllowValueChange(at index: Int, oldValue: Int, newValue: Int) -> Bool {

        // 判断操作类型
        let operationType = getCurOperationType(at: index, oldValue: oldValue, newValue: newValue)
        
        switch operationType {
        case .carry:
            // ========== 进位操作处理 ==========
            return handleCurCarryOperation(at: index, oldValue: oldValue, newValue: newValue)
            
        case .borrow:
            // ========== 借位操作处理 ==========
            return handleCurBorrowOperation(at: index, oldValue: oldValue, newValue: newValue)
            
        case .decrement, .increment:
            // ========== 普通递增/递减操作处理 ==========
            return handleCurNormalOperation(at: index, oldValue: oldValue, newValue: newValue, operationType: operationType)
            
        case .noChange:
            return false // 无变化，不允许操作
        }
        
    }
    
    //数值有效情况下,处理数值更改
    private func curhandleNumberChangeWithValidation(at currentIndex: Int, newValue: Int) {
     
        guard currentIndex < model.dataIArr_new.count else { return }
        let oldValue = model.dataIArr_new[currentIndex]
        
        // 判断操作类型
        let operationType = getCurOperationType(at: currentIndex, oldValue: oldValue, newValue: newValue)
        
        switch operationType {
        case .carry:
            Log.debug("\(currentIndex) 电流处理进位")
            handleCurCarry(at: currentIndex, from: newValue)
            
        case .borrow:
            Log.debug("\(currentIndex) 电流处理退位")
            let borrowSuccess = handleCurBorrow(at: currentIndex, from: newValue)
            if borrowSuccess {
                updateLabelAndModel(isVol: false, at: currentIndex, value: newValue)
                Log.debug("借位成功，更新当前位[\(currentIndex)]为\(newValue)")
            }
            // 重置清零标志
            model.hasClearedCurTrailingDigits = false
            
        case .increment, .decrement:
            Log.debug("\(currentIndex) 普通更新，\(oldValue)->\(newValue)")
            updateLabelAndModel(isVol: false, at: currentIndex, value: newValue)
            // 重置清零标志
            model.hasClearedCurTrailingDigits = false
            
        case .noChange:
            break // 无变化，不处理
        }
        
    }
    
    //MARK: 处理进位
    
    // 返回值表示是否允许下一步的进位操作
    private func handleCurCarryOperation(at index: Int, oldValue: Int, newValue: Int) -> Bool {
        Log.debug("进位操作: 位置[\(index)] \(oldValue)→\(newValue)")
            
        // 检查进位后是否超过最大值
        if willExceedMaxCurrentAfterCarry(at: index, newValue: newValue) {
            Log.debug("进位后将超过最大值 5.1，调整到最大值")
            adjustVolToMaxCurrent()
            return false
        }
        
        // 允许进位操作，实际处理在 curhandleNumberChangeWithValidation 中
        return true
    }
    
    // 检查进位后是否会超过最大值
    private func willExceedMaxCurrentAfterCarry(at index: Int, newValue: Int) -> Bool {
        
        // 创建临时数组模拟进位后的状态
        var tempValues = model.dataIArr_new
        tempValues[index] = newValue // 当前位变为0
        
        var carryIndex = index - 1
        
        // 模拟进位过程
        while carryIndex >= 0 {
            if carryIndex == 1 {
                carryIndex -= 1
                continue
            }
            
            guard carryIndex < tempValues.count else { break }
            
            if tempValues[carryIndex] < 9 {
                tempValues[carryIndex] += 1
                break
            } else {
                tempValues[carryIndex] = 0
                carryIndex -= 1
            }
        }
            
            // 计算进位后的电压值
        let current = model.currentConvertToDouble(from: tempValues)
        Log.debug("\(index) 进位后预测电流: \(current)A")
        
        return current > 5.1

    }
    
    // 检查普通递增时,是否会超过最大值
    private func willExceedMaxCurrent(at index: Int, newValue: Int) -> Bool {
        // 创建临时数组来模拟更新后的状态
        var tempValues = model.dataIArr_new
        tempValues[index] = newValue
        
        // 处理可能的进位
        handleCarryInTempArray(&tempValues, at: index)
        
        // 计算电流值
        let current =  model.currentConvertToDouble(from: tempValues)
        Log.debug("\(index) 递增时 预测电流: \(current)A")
        return current > 5.1
    }
    
    // 调整到最大值
    private func adjustVolToMaxCurrent() {
        updateLabelAndModel(isVol: false, at: 0, value: 5)  // 个位: 5
        updateLabelAndModel(isVol: false, at: 2, value: 1)  // 十分位: 1
        updateLabelAndModel(isVol: false, at: 3, value: 0)  // 百分位: 0
        updateLabelAndModel(isVol: false, at: 4, value: 0)  // 千分位: 0
        
        // 更新所有对应的picker选中行
        updateVolAllPickerRows(isVol: false)
    }

    
    //处理进位
    private func handleCurCarry(at currentIndex: Int, from newValue: Int) {
        
        Log.debug("进位处理 at index: \(currentIndex), newValue: \(newValue)")
            
        // 先更新当前位为0（因为是从9变为0）
        model.dataIArr_new[currentIndex] = 0
        updateLabelAndModel(isVol: false, at: currentIndex, value: 0)
        
        var carryIndex = currentIndex - 1
        
        // 向前进位直到不需要进位为止
        while carryIndex >= 0 {
            if carryIndex == 1 {
                // 跳过小数点位置
                carryIndex -= 1
                continue
            }
            
            guard carryIndex < model.dataIArr_new.count else { break }
            
            if model.dataIArr_new[carryIndex] < 9 {
                // 当前位可以加1，进位完成
                model.dataIArr_new[carryIndex] += 1
                updateLabelAndModel(isVol: false, at: carryIndex, value: model.dataIArr_new[carryIndex])
                
                adjustNewScrollPosition_Carry(isvol: false, actualValue: model.dataIArr_new[carryIndex], carryIndex: carryIndex)

                // 检查是否达到最大值
                if model.dataIArr_new[0] == 5 && model.dataIArr_new[2] == 1 {
                    Log.debug("电流进位后, 总值达到最大值 5.1, 后续位数清零")
                    updateLabelAndModel(isVol: false, at: 3, value: 0)  // 百分位: 0
                    updateLabelAndModel(isVol: false, at: 4, value: 0)  // 千分位: 0
                    
                    let scrollRow2 = container.pickV.calculateScrollRow(from: 0, forPickerTag: 2)
                    container.pickV.pickerViews[2].selectRow(scrollRow2 , inComponent: 0, animated: true)
                    
                    let scrollRow3 = container.pickV.calculateScrollRow(from: 0, forPickerTag: 3)
                    container.pickV.pickerViews[3].selectRow(scrollRow3 , inComponent: 0, animated: true)
                }
                break
            } else {
                // 当前位是9，置为0，继续向前进位
                model.dataIArr_new[carryIndex] = 0
                updateLabelAndModel(isVol: false, at: carryIndex, value: 0)
                
                adjustNewScrollPosition_Carry(isvol: false, actualValue: model.dataIArr_new[carryIndex], carryIndex: carryIndex)
                
                carryIndex -= 1
            }
        }
            
        // 如果进位到最高位且最高位也是9→0，需要特殊处理
        if carryIndex < 0 {
            Log.debug("最高位进位，恢复原来值")
//            // 调整到最大值
//            adjustVolToMaxCurrent()
            
            model.dataIArr_new[0] = 5
            restoreVoltagePickerValue1(at: 0, for: container.pickV)
        }
        
    }
    
    //MARK: 处理借位
    
    // 返回值表示是否允许下一步的借位操作
    private func handleCurBorrowOperation(at index: Int, oldValue: Int, newValue: Int) -> Bool {
        Log.debug("借位操作: 位置[\(index)] \(oldValue)→\(newValue)")
            
        if isAtMinCurrent() {
            Log.debug("已达到最小值，\(index) 停止借位")
            return false
        }
        
        // 检查是否需要清零后面位数
        if shouldClearCurTrailingDigits(at: index, oldValue: oldValue, newValue: newValue) {
            if model.hasClearedCurTrailingDigits {
                Log.debug("禁止：已经清零过后面位数，无法继续借位")
                return false
            } else {
                Log.debug("第一次借位，清零后面位数")
                clearCurTrailingDigits(from: index)
                model.hasClearedCurTrailingDigits = true
                return false
            }
        }
        
        // 不需要清零，允许借位操作
        Log.debug("允许借位操作")
        return true
    }
    
    // 检查是否应该清零后面的位数
    private func shouldClearCurTrailingDigits(at index: Int, oldValue: Int, newValue: Int) -> Bool {
        // 只有借位操作才考虑清零
        let isBorrowOperation = (index == 0 && newValue == 5 && oldValue == 0) ||
                               (index > 0 && newValue == 9 && oldValue == 0)
        
        guard isBorrowOperation else { return false }
        
        switch index {
        case 0: // 个位借位：检查小数位是否有非零值
            return model.dataIArr_new[2] != 0 || model.dataIArr_new[3] != 0 || model.dataIArr_new[4] != 0
            
        case 2: // 十分位借位：检查百分位是否有非零值
            return  model.dataIArr_new[0] == 0 && (model.dataIArr_new[3] != 0 || model.dataIArr_new[4] != 0)
            
        case 3: // 百分位借位：检查千分位是否有非零值
            return model.dataIArr_new[0] == 0 && model.dataIArr_new[2] == 0 && model.dataIArr_new[4] != 0
            
        default:
            return false
        }
        
    }
    
    // 清零从指定位置开始的所有后面位数
    private func clearCurTrailingDigits(from index: Int) {
        switch index {
        case 0: // 清零小数位
            if model.dataIArr_new[2] != 0 {
                updateLabelAndModel(isVol: false, at: 2, value: 0)
            }
            if model.dataIArr_new[3] != 0 {
                updateLabelAndModel(isVol: false, at: 3, value: 0)
            }
            if model.dataIArr_new[4] != 0 {
                updateLabelAndModel(isVol: false, at: 4, value: 0)
            }
            
        case 2:
            if model.dataIArr_new[3] != 0 {
                updateLabelAndModel(isVol: false, at: 3, value: 0)
            }
            if model.dataIArr_new[4] != 0 {
                updateLabelAndModel(isVol: false, at: 4, value: 0)
            }
            
        case 3:
            if model.dataIArr_new[4] != 0 {
                updateLabelAndModel(isVol: false, at: 4, value: 0)
            }
            
        default:
            break
        }
        
        // 更新picker显示
        updateVolAllPickerRows(isVol: false)
    }

    //处理借位, 返回值表示借位是否成功
    private func handleCurBorrow(at currentIndex: Int, from newValue: Int) -> Bool {
    
        var borrowIndex = currentIndex - 1
        var borrowSuccessful = false
        
        while borrowIndex >= 0 {
            // 跳过小数点位置
            if borrowIndex == 1 {
                borrowIndex -= 1
                continue
            }
            
            guard borrowIndex < model.dataIArr_new.count else { break }
            
            if model.dataIArr_new[borrowIndex] > 0 {
                // 当前位可以减1，借位完成
                model.dataIArr_new[borrowIndex] -= 1
                updateLabelAndModel(isVol: false, at: borrowIndex, value: model.dataIArr_new[borrowIndex])
                
                adjustNewScrollPosition_Borrow(isVol: false, actualValue: model.dataIArr_new[borrowIndex], borrowIndex: borrowIndex)
                
              
                borrowSuccessful = true
                Log.debug("成功借位，位置[\(borrowIndex)]减1")
                break
            } else {
                model.dataIArr_new[borrowIndex] = 9
                updateLabelAndModel(isVol: false, at: borrowIndex, value: 9)
                Log.debug("位置[\(borrowIndex)]置为9，继续借位")
                
                adjustNewScrollPosition_Borrow(isVol: false, actualValue: model.dataIArr_new[borrowIndex], borrowIndex: borrowIndex)
                
                borrowIndex -= 1
            }
        }
        
        return borrowSuccessful
        
    }
    
    // 检查是否达到最小值 0.00
    private func isAtMinCurrent() -> Bool {
        return model.dataIArr_new[0] == 0 &&
               model.dataIArr_new[2] == 0 &&
               model.dataIArr_new[3] == 0 &&
               model.dataIArr_new[4] == 0
    }
}

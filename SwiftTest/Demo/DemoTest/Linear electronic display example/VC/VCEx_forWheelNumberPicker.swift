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
        
        Log.debug("picker.tag: \(picker.tag) ,uipickview 上计算得到的数值: \(value)")
        
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
        

        let digitCount = String(Int(container.pickV.maxValue)).count // 30 → 2, 5 → 1
        
        // 电压: pickerI: 0,1,2,3 -> numI: 0,1,3,4 ; 电流: pickerI: 0,1,2,3 -> numI: 0,2,3,4
        let numI = pickerI > (digitCount-1) ? pickerI+1 : pickerI
        let modelValue = picker.tag == 0 ? model.dataVArr_new[numI] : model.dataIArr_new[numI]
        
        if modelValue != value {
            if shouldAllowValueChange(at: numI, oldValue: modelValue, newValue: value){
                handleNumberChangeWithValidation(at: numI, newValue: value)
            }
        }
        
    }

    
    //MARK: - 操作处理判断
    //允许数值更改的情况
    private func shouldAllowValueChange(at index: Int, oldValue: Int, newValue: Int) -> Bool {

        // 判断操作类型
        let operationType = getOperationType(at: index, oldValue: oldValue, newValue: newValue)
        
        switch operationType {
        case .carry:
            // ========== 进位操作处理 ==========
            return handleCarryOperation(at: index, oldValue: oldValue, newValue: newValue)
            
        case .borrow:
            // ========== 借位操作处理 ==========
            return handleBorrowOperation(at: index, oldValue: oldValue, newValue: newValue)
            
        case .decrement, .increment:
            // ========== 普通递增/递减操作处理 ==========
            return handleNormalOperation(at: index, oldValue: oldValue, newValue: newValue, operationType: operationType)
            
        case .noChange:
            return false // 无变化，不允许操作
        }
        
    }
    
    // 判断操作类型
    private func getOperationType(at index: Int, oldValue: Int, newValue: Int) -> OperationType {
        
        let highestDigit = MathUtil.highestDigit(of: container.pickV.maxValue)
        
        // 进位操作判断
        if (index == 0 && oldValue == highestDigit && newValue == 0) ||
           (index > 0 && oldValue == 9 && newValue == 0) {
            return .carry
        }
        
        // 借位操作判断
        if (index == 0 && oldValue == 0 && newValue == highestDigit) ||
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
    
    //MARK: 进位操作判断
    // 返回值表示是否允许下一步的进位操作
    private func handleCarryOperation(at index: Int, oldValue: Int, newValue: Int) -> Bool {
//        Log.debug("进位操作: 位置[\(index)] \(oldValue)→\(newValue)")

         //检查进位后是否超过最大值: 如29.6->30.6,超过最大值30.5
        if willExceedMaxAfterCarry(at: index, newValue: newValue) {
            Log.debug("进位后将超过最大值，调整到最大值")
            adjustToMaxValue()
            return false
        }
       
        // 允许进位操作，实际处理在 handleNumberChangeWithValidation 中
        return true
    }
    
    // 检查进位后是否会超过最大值
    private func willExceedMaxAfterCarry(at index: Int, newValue: Int) -> Bool {
        // 创建临时数组模拟进位后的状态
        var tempValues = model.isOutputVolSet ? model.dataVArr_new : model.dataIArr_new
        tempValues[index] = newValue // 当前位变为0
        
        let digitCount = String(Int(container.pickV.maxValue)).count
        var carryIndex = index - 1
        
        // 模拟进位过程
        while carryIndex >= 0 {
            if carryIndex == digitCount {
                carryIndex -= 1
                continue
            }
            
            guard carryIndex < tempValues.count else { break }
            
            if tempValues[carryIndex] < 9 {
                tempValues[carryIndex] += 1
                break
            } else {
                //连续进位
                tempValues[carryIndex] = 0
                carryIndex -= 1
            }
        }
        
        // 计算进位后的值
        let newValue = model.isOutputVolSet ? model.voltageConvertToDouble(from: tempValues) : model.currentConvertToDouble(from: tempValues)
        
        //使用进位前的数据去跟最大值比较
        model.pickVTempValues = model.isOutputVolSet ? model.dataVArr_new : model.dataIArr_new
//        Log.debug("进位后的值: \(newValue), model.pickVTempValues= \(model.pickVTempValues)")
        
        return newValue > container.pickV.maxValue
        
    }
    
    //调整为最大值
    private func adjustToMaxValue() {
        let maxValue = container.pickV.maxValue
        let digitCount = String(Int(maxValue)).count
        let maxValueStr = String(maxValue)
        let dataArr = model.isOutputVolSet ? model.voltageStringToIntArray(maxValueStr) : model.currentStringToIntArray(maxValueStr)

        for i in 0..<dataArr.count {
            if i != digitCount && model.pickVTempValues[i] != dataArr[i] {
                Log.debug("更新 \(i): \(model.pickVTempValues[i]) -> \(dataArr[i])")
                updateLabelAndModel(isVol: model.isOutputVolSet, at: i, value: dataArr[i])
                
//                //i != 2, datai: 0,1,3,4 -> pickerViewI:0,1,2,3
//                //i != 1, datai: 0,2,3,4 -> pickerViewI:0,1,2,3
//                let pickerViewI = i > (digitCount-1) ? i-1 : i
//                let scrollRow = container.pickV.calculateScrollRow(from: dataArr[i], forPickerTag: pickerViewI)
//                container.pickV.pickerViews[pickerViewI].selectRow(scrollRow , inComponent: 0, animated: true)
                updatePickerviewSelectrow(at: i, value: dataArr[i])
            }
        }
    }
    
    
    //MARK: 退位操作判断
    // 定义位数索引
    struct DigitIndices {
        let integerIndices: [Int]   // 整数位索引（从高位到低位）
        let decimalIndices: [Int]   // 小数位索引（从高位到低位）
        let placeholderIndex: Int   // 小数点占位索引（若存在）
    }
    // 获取当前模式下的索引配置
    private var currentIndices: DigitIndices {
        let decimalIndices = String(Int(container.pickV.maxValue)).count
        let totalCount = model.isOutputVolSet ? model.dataVArr_new.count : model.dataIArr_new.count
        return DigitIndices(
            integerIndices: Array(0..<decimalIndices),
            decimalIndices: Array(decimalIndices..<totalCount),
            placeholderIndex: decimalIndices
        )
    }
    //获取所有有效位
    private var effectiveDigits: [Int] {
        let idx = currentIndices
        return idx.integerIndices + idx.decimalIndices
    }
    
    private func updatePickerviewSelectrow(at index: Int, value: Int){
        let digitCount = String(Int(container.pickV.maxValue)).count
        //i != 2, datai: 0,1,3,4 -> pickerViewI:0,1,2,3
        //i != 1, datai: 0,2,3,4 -> pickerViewI:0,1,2,3
        let pickerViewI = index > (digitCount-1) ? index-1 : index
        let scrollRow = container.pickV.calculateScrollRow(from: value, forPickerTag: pickerViewI)
        container.pickV.pickerViews[pickerViewI].selectRow(scrollRow , inComponent: 0, animated: true)
        
    }
    private func handleBorrowOperation(at index: Int, oldValue: Int, newValue: Int) -> Bool {
//        Log.debug("借位操作: 位置[\(index)] \(oldValue)→\(newValue)")
            
        if isAtMinValue() {
//            let digitCount = String(Int(container.pickV.maxValue)).count
//            //i != 2, datai: 0,1,3,4 -> pickerViewI:0,1,2,3
//            //i != 1, datai: 0,2,3,4 -> pickerViewI:0,1,2,3
//            let pickerViewI = index > (digitCount-1) ? index-1 : index
//            let scrollRow = container.pickV.calculateScrollRow(from: oldValue, forPickerTag: pickerViewI)
//            container.pickV.pickerViews[pickerViewI].selectRow(scrollRow , inComponent: 0, animated: true)
            updatePickerviewSelectrow(at: index, value: oldValue)
            Log.debug("已达到最小值，\(index) 停止借位, 恢复原位")
            

            
            return false
        }
        
        // 检查是否需要清零后面位数
        if hasNonZeroTrailingDigits(at: index){
            let clearSign = model.isOutputVolSet ? model.hasClearedTrailingDigits : model.hasClearedCurTrailingDigits
            if !clearSign {
                Log.debug("前置位为零且后置位不为零，清零后面位数")
                clearTrailingDigits(from: index)
                
                if model.isOutputVolSet{
                    model.hasClearedTrailingDigits = true
                }else{
                    model.hasClearedCurTrailingDigits = true
                }
                return false
            }
        }
        
        // 不需要清零，允许借位操作
        return true
        
    }
    
    //判断是否为最小值
    private func isAtMinValue() -> Bool{
        let modelData = model.isOutputVolSet ? model.dataVArr_new : model.dataIArr_new
        let decimalPlace = String(Int(container.pickV.maxValue)).count

        // 跳过小数点占位符（索引 decimalPlace）
        let otherValues = modelData.enumerated().filter { $0.offset != decimalPlace }.map { $0.element }
       
        //检查剩下位是否都为 0
        return otherValues.allSatisfy { $0 == 0 }
        
    }

    //判断 index 后续位是否有非零值
    private func hasNonZeroTrailingDigits(at index: Int) -> Bool {
        let modelData = model.isOutputVolSet ? model.dataVArr_new : model.dataIArr_new
        guard let pos = effectiveDigits.firstIndex(of: index) else { return false }
        let trailing = effectiveDigits.suffix(from: pos + 1)
        return trailing.contains { modelData[$0] != 0 }
    }

    // 清零从指定位置开始的所有后面位数
    private func clearTrailingDigits(from index: Int) {
        let isVol = model.isOutputVolSet
        let modelData = isVol ? model.dataVArr_new : model.dataIArr_new
        guard let pos = effectiveDigits.firstIndex(of: index) else { return }
        let trailing = effectiveDigits.suffix(from: pos + 1)
        var needUpdate = false
        for idx in trailing {
            if modelData[idx] != 0 {
                Log.debug("清空 \(idx): \(modelData[idx]) -> 0 ")
                updateLabelAndModel(isVol: isVol, at: idx, value: 0)
//                needUpdate = true
                
                updatePickerviewSelectrow(at: idx, value: 0)
            }
        }
//        if needUpdate {
//            updateVolAllPickerRows(isVol: isVol)
//        }
    }
  
    //MARK: 普通递增/递减判断
    // 处理普通操作
    private func handleNormalOperation(at index: Int, oldValue: Int, newValue: Int, operationType: OperationType) -> Bool {
        
        let isIncreasing = operationType == .increment
//        Log.debug("\(isIncreasing ? "递增" : "递减")操作: 位置[\(index)] \(oldValue)→\(newValue)")
        
        // ========== 递增过程中,最大值检查规则 ==========
        // 如30.6->31.6,超过最大值30.5
        if isIncreasing && willExceedMaxValue(at: index, newValue: newValue) {
            Log.debug("\(index) 递增后将超过最大值，调整到最大值")
            adjustToMaxValue()
            
//            Log.debug("禁止：\(index) 递增过程中,数值超过最大值, 恢复原来值: \(oldValue)")
//            CustomAlert.showToast(title: "数值超过最大值\(container.pickV.maxValue)", vc: self)
//            
//            if model.isOutputVolSet {
//                model.dataVArr_new[index] = oldValue
//            }else{
//                model.dataIArr_new[index] = oldValue
//            }
//            restoreVoltagePickerValue1(at: index, for: container.pickV)
            
            return false
        }
        
        return true

    }
    
    // 检查普通递增时,是否会超过最大值
    private func willExceedMaxValue(at index: Int, newValue: Int) -> Bool {
        // 创建临时数组来模拟更新后的状态
        var tempValues = model.isOutputVolSet ? model.dataVArr_new : model.dataIArr_new
        tempValues[index] = newValue
        
        // 计算递增后的值
        let newValue = model.isOutputVolSet ? model.voltageConvertToDouble(from: tempValues) : model.currentConvertToDouble(from: tempValues)
        
        model.pickVTempValues = tempValues
//        Log.debug("递增后的值= \(newValue), model.pickVTempValues = \(model.pickVTempValues)")
        return newValue > container.pickV.maxValue
        
    }

    
    //MARK: - 处理数值更改
    //数值有效情况下,处理数值更改
    private func handleNumberChangeWithValidation(at currentIndex: Int, newValue: Int) {
     
        let modelData = model.isOutputVolSet ? model.dataVArr_new : model.dataIArr_new
        guard currentIndex < modelData.count else { return }
        let oldValue = modelData[currentIndex]
        
        // 判断操作类型
        let operationType = getOperationType(at: currentIndex, oldValue: oldValue, newValue: newValue)
        
        switch operationType {
        case .carry:
            handleCarry(at: currentIndex, from: newValue)
            
        case .borrow:
            let borrowSuccess = handleBorrow(at: currentIndex, from: newValue)
            if borrowSuccess {
                updateLabelAndModel(isVol: model.isOutputVolSet, at: currentIndex, value: newValue)
                Log.debug("借位成功，更新当前位[\(currentIndex)]为\(newValue)")
            }
            
            // 重置清零标志
            if model.isOutputVolSet{
                model.hasClearedTrailingDigits = false
            }else{
                model.hasClearedCurTrailingDigits = false
            }
            
        case .increment, .decrement:
            Log.debug("索引[\(currentIndex)] 处理普通更新: \(oldValue)->\(newValue)")
            updateLabelAndModel(isVol: model.isOutputVolSet, at: currentIndex, value: newValue)
            // 重置清零标志
            if model.isOutputVolSet{
                model.hasClearedTrailingDigits = false
            }else{
                model.hasClearedCurTrailingDigits = false
            }
            
        case .noChange:
            break // 无变化，不处理
        }
        
    }
    //处理进位
    private func handleCarry(at currentIndex: Int, from newValue: Int) {
        Log.debug("进位处理 at index: \(currentIndex), newValue: \(newValue)")
            
        if model.isOutputVolSet {
            // 先更新当前位为0（因为是从9变为0）
            model.dataVArr_new[currentIndex] = 0
        }else{
            model.dataIArr_new[currentIndex] = 0
        }
        updateLabelAndModel(isVol: model.isOutputVolSet, at: currentIndex, value: 0)
        
        
        let digitCount = String(Int(container.pickV.maxValue)).count
        var carryIndex = currentIndex - 1
        let temparory = model.isOutputVolSet ? model.dataVArr_new : model.dataIArr_new
        
        
        // 向前进位直到不需要进位为止
        while carryIndex >= 0 {
            if carryIndex == digitCount {
                // 跳过小数点位置
                carryIndex -= 1
                continue
            }
            
            guard carryIndex < temparory.count else { break }
            
            if temparory[carryIndex] < 9 {
                //普通递增
                // 当前位可以加1，进位完成
                if model.isOutputVolSet {
                    model.dataVArr_new[carryIndex] += 1
                    updateLabelAndModel(isVol: true, at: carryIndex, value: model.dataVArr_new[carryIndex])
                    
                    adjustNewScrollPosition_Carry(isvol: true, actualValue: model.dataVArr_new[carryIndex], carryIndex: carryIndex)
                }else{
                    model.dataIArr_new[carryIndex] += 1
                    updateLabelAndModel(isVol: false, at: carryIndex, value: model.dataIArr_new[carryIndex])
                    
                    adjustNewScrollPosition_Carry(isvol: false, actualValue: model.dataIArr_new[carryIndex], carryIndex: carryIndex)
                }
                break
            } else {
                Log.debug("\(carryIndex) 当前是9，置为0，继续向前进位")
                if model.isOutputVolSet {
                    // 当前位是9，置为0，继续向前进位
                    model.dataVArr_new[carryIndex] = 0
                }else{
                    // 当前位是9，置为0，继续向前进位
                    model.dataIArr_new[carryIndex] = 0
                }
                updateLabelAndModel(isVol: model.isOutputVolSet, at: carryIndex, value: 0)
                adjustNewScrollPosition_Carry(isvol: model.isOutputVolSet, actualValue: 0, carryIndex: carryIndex)
                carryIndex -= 1
            }
        }
            
        // 如果进位到最高位且最高位也是9→0，需要特殊处理
        if carryIndex < 0 {
            let highestDigit = MathUtil.highestDigit(of: container.pickV.maxValue)
            Log.debug("当前操作位是最高位,不允许进位: \(highestDigit) -> 0")
            
            if model.isOutputVolSet {
                model.dataVArr_new[0] = highestDigit
            }else{
                model.dataIArr_new[0] = highestDigit
            }
            restoreVoltagePickerValue1(at: 0, for: container.pickV)
        }

    }
    
    //处理借位, 返回值表示借位是否成功
    private func handleBorrow(at currentIndex: Int, from newValue: Int) -> Bool {
        Log.debug("退位处理 at index: \(currentIndex), newValue: \(newValue)")
        
        let digitCount = String(Int(container.pickV.maxValue)).count
        let temparory = model.isOutputVolSet ? model.dataVArr_new : model.dataIArr_new
        
        var borrowIndex = currentIndex - 1
        var borrowSuccessful = false
        
        while borrowIndex >= 0 {
            // 跳过小数点位置
            if borrowIndex == digitCount {
                borrowIndex -= 1
                continue
            }
            
            guard borrowIndex < temparory.count else { break }
            
            Log.debug("待借位 \(borrowIndex) 的旧值, \( temparory[borrowIndex])  ")
            
            if temparory[borrowIndex] > 0 {
                // 当前位可以减1，借位完成
                if model.isOutputVolSet{
                    model.dataVArr_new[borrowIndex] -= 1
                    updateLabelAndModel(isVol: true, at: borrowIndex, value: model.dataVArr_new[borrowIndex])
                    
                    adjustNewScrollPosition_Borrow(isVol: true, actualValue: model.dataVArr_new[borrowIndex], borrowIndex: borrowIndex)
                    
                }else{
                    model.dataIArr_new[borrowIndex] -= 1
                    updateLabelAndModel(isVol: false, at: borrowIndex, value: model.dataIArr_new[borrowIndex])
                    
                    adjustNewScrollPosition_Borrow(isVol: false, actualValue: model.dataIArr_new[borrowIndex], borrowIndex: borrowIndex)
                }

                borrowSuccessful = true
                Log.debug("当前位[\(borrowIndex)]减1, 借位完成")
                break
            } else {
                // 当前位为0，先置为9,继续借位
                if model.isOutputVolSet {
                    model.dataVArr_new[borrowIndex] = 9
                }else{
                    model.dataIArr_new[borrowIndex] = 9
                }
               
                updateLabelAndModel(isVol: model.isOutputVolSet, at: borrowIndex, value: 9)
                Log.debug("位置[\(borrowIndex)]置为9，继续借位")
                
                adjustNewScrollPosition_Borrow(isVol: model.isOutputVolSet, actualValue: 9, borrowIndex: borrowIndex)
                borrowIndex -= 1
                
            }
        }
        
        return borrowSuccessful
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
            
//            Log.debug("\(pickerViewI) 电压恢复到原来的选中行: \(scrollRow)")
        }else if  pickerView.tag == 1 {
            
            let oldValue = model.dataIArr_new[index]
            //index: 0,2,3,4 -> pickerViewI: 0,1,2,3
            let pickerViewI = index > 1 ? index-1 : index
            let scrollRow = container.pickV.calculateScrollRow(from: oldValue, forPickerTag: pickerViewI)
            
            pickerView.pickerViews[pickerViewI].selectRow(scrollRow , inComponent: 0, animated: true)
            
//            Log.debug("\(pickerViewI) 电流恢复到原来的选中行: \(scrollRow)")
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
        }else{
            guard index < model.dataIArr_new.count else { return }
          
            // 更新数据模型
            model.dataIArr_new[index] = value
            
            //保存最终设置值
            model.setcurrentDouble()
        }
    }
    
//    // 处理临时数组中的进位（用于最大值检查）
//    private func handleCarryInTempArray(_ tempValues: inout [Int], at index: Int) {
//        // 简化的进位处理逻辑，用于预测
//        if tempValues[index] == 10 { // 如果某位变成10
//            tempValues[index] = 0
//            if index > 0 {
//                tempValues[index-1] += 1
//            }
//        }
//    }
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
    
}

//
//  ProgrammablePagelistCell.swift
//  SwiftTest
//
//  Created by user on 2026/1/19.
//
// 左滑可删除、新增的自定义 view

import UIKit
import SnapKit

extension Notification.Name {
    static let programmablePagelistCellEditStateChanged = Notification.Name("programmablePageCellEditStateChanged")
    static let presetlistCellEditStateChanged = Notification.Name("presetlistCellEditStateChanged")
    static let presetSublistcellEditStateChanged = Notification.Name("presetSublistcellEditStateChanged")
}

class ProgrammablePagelistCell: UIView{

    var strs = ["NO", "V", "A", "S"] {
        didSet{
            labels[0].attributedText = bahnschrift_formatted(strs[0], 16)
            
            for i in 0...2{
                textFields[i].attributedText = bahnschrift_formatted(strs[i+1], 16)
            }
        }
    }
    
    var dataModel: ProgramDataModel?//绑定数据模型
    var labels: [UILabel] = [] //索引


    //MARK: 监听编辑状态
    var textFields:[UITextField] = [] //内容文本框
    var currentTextField: UITextField? //当前编辑的文本
    private var originalValues: [UITextField: NSAttributedString] = [:] //保留文本框旧值
    private var backgroundTapGesture: UITapGestureRecognizer? // 添加 cell 空白区域点击手势
    
    var hasBeenEdited = false {// 标记是否被编辑过,跳转到其他页面(非预设值页面)会自动恢复默认值
        didSet {
            // 当编辑状态改变时通知外部
            if hasBeenEdited != oldValue {
                NotificationCenter.default.post(
                    name: .programmablePagelistCellEditStateChanged,
                    object: self,
                    userInfo: ["cell": self, "edited": hasBeenEdited]
                )
            }
        }
    }
    private var isEditing: Bool {
        return textFields[0].isFirstResponder || textFields[1].isFirstResponder || textFields[2].isFirstResponder // 检查当前单元格是否有文本框在编辑
    }
    private var isEditingText = false // 标记是否正在编辑
    
    
    // 静态属性，用于全局管理编辑状态
    static var isAnyCellEditing = false //编辑结束后会恢复默认值
    private static var currentEditingCell: ProgrammablePagelistCell?
    private var alert = UIAlertController() //当文本框输入值不合要求显示的提示框
    
    //MARK: 左滑相关属性
    var isSwiped = false
    var panGesture: UIPanGestureRecognizer? //滑动手势
    
    // 静态变量跟踪当前左滑的单元格, 实现父视图每次只能左滑一个 cell
    static var currentlySwipedCell: ProgrammablePagelistCell?
    private var contentLeftConstraint: Constraint? //左滑约束
    private var contentRightConstraint: Constraint?//左滑约束
    
    // 常量定义
    private let swipeDeleteBtnWidth = 60.0
    private let swipeAddBtnWidth = 60.0
    private let contentContainer = UIView()
    let swipeDeleteBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = UIColor(named: "DP_FF0004")
        if #available(iOS 13.0, *) {
            btn.setImage(UIImage(named: "DP_ProgramItemReduce")?.withTintColor(.white), for: .normal)
        } else {
            btn.setImage(UIImage(named: "DP_ProgramItemReduce"), for: .normal)
        }
        btn.isHidden = true
        btn.alpha = 0
        return btn
    }()
    let swipeAddBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = UIColor(named: "DP_0B8CE8ff")
        if #available(iOS 13.0, *) {
            btn.setImage(UIImage(named: "DP_ProgramItemSwipeAdd")?.withTintColor(.white), for: .normal)
        } else {
            btn.setImage(UIImage(named: "DP_ProgramItemSwipeAdd"), for: .normal)
        }
        btn.isHidden = true
        btn.alpha = 0
        return btn
    }()
    
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        additionalSetup3()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func additionalSetup3(){
        
        addSubview(contentContainer)
        contentContainer.isUserInteractionEnabled = true // 必须为 true 才能响应 pan
        
        contentContainer.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            contentLeftConstraint = make.left.equalToSuperview().constraint
            contentRightConstraint = make.right.equalToSuperview().constraint
        }
        
        let label = UILabel()
        contentContainer.addSubview(label)
        label.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.18) //63/351
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        label.textColor = UIColor(named: "DP_999999")
        label.font = UIFont(name: kSourceHanSansCN_Regular, size: 16)
        label.text = strs[0]
        label.textAlignment = .center
        labels.append(label)
        
        let stackV = UIStackView()
        contentContainer.addSubview(stackV)
        stackV.snp.makeConstraints { make in
            make.height.equalToSuperview()
            make.right.equalToSuperview()
            make.left.equalTo(label.snp.right)
            make.centerY.equalToSuperview()
        }
        stackV.axis = .horizontal
        stackV.distribution = .fillEqually
        stackV.spacing = 0
        
        for i in 0...2{
            let labelBg = UIView()
            stackV.addArrangedSubview(labelBg)
            
            let label = UITextField()
            labelBg.addSubview(label)
            label.textColor = UIColor(named: "DP_999999")
            label.attributedText = bahnschrift_formatted(strs[i+1])
            label.textAlignment = .center
            label.delegate = self
            label.tag = i
            label.keyboardType = i == 2 ? .numberPad : .decimalPad
            label.layer.borderWidth = 1
            label.layer.borderColor = UIColor.clear.cgColor
            label.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            label.snp.makeConstraints { make in
                make.width.equalTo(i == 2 ? 46 : 52)
                make.height.equalTo(20)
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview()
            }
            
            textFields.append(label)
            
            // 记录初始值
            originalValues[label] = label.attributedText
            
        }
        
        addSubview(swipeDeleteBtn)
        swipeDeleteBtn.snp.makeConstraints { make in
            make.width.equalTo(swipeDeleteBtnWidth)
            make.height.equalTo(40) // 明确高度
            make.centerY.equalToSuperview() // 垂直居中
            make.right.equalToSuperview()
        }
        
        addSubview(swipeAddBtn)
        swipeAddBtn.snp.makeConstraints { make in
            make.width.equalTo(swipeAddBtnWidth)
            make.height.equalTo(40)
            make.centerY.equalToSuperview()
            make.right.equalTo(swipeDeleteBtn.snp.left)
        }
        
        // Add pan gesture to contentContainer (for swipe)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.delegate = self
        contentContainer.addGestureRecognizer(panGesture)
        self.panGesture = panGesture
        

        // 初始化空白区域点击手势（但不立即添加）
        backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        backgroundTapGesture?.cancelsTouchesInView = false
        
        // 添加单元格点击手势
        let cellTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCellTap))
        cellTapGesture.cancelsTouchesInView = false
        self.addGestureRecognizer(cellTapGesture)
        
    }
    
    
    // MARK: - Private Methods
    
    // 静态方法：结束所有编辑
    static func endAllEditing() {
        // 先收起所有键盘
        currentEditingCell?.endCellEditing(true)
        
        // 延迟更新状态，确保键盘完全收起
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isAnyCellEditing = false
            currentEditingCell = nil
            

            // 发送通知，通知所有单元格结束编辑
            NotificationCenter.default.post(name: NSNotification.Name("EndAllCellEditing"), object: nil)
        }
        
    }
    
    
    // 结束当前单元格的编辑
    private func endCellEditing(_ force: Bool) {
        if textFields[0].isFirstResponder {
            textFields[0].resignFirstResponder()
        }
        if textFields[1].isFirstResponder {
            textFields[1].resignFirstResponder()
        }
        if textFields[2].isFirstResponder {
            textFields[2].resignFirstResponder()
        }
        
        swipeAddBtn.isUserInteractionEnabled = true
        swipeDeleteBtn.isUserInteractionEnabled = true
        
    }
    
    
    // MARK: - Public Methods
    
    func setIndex(_ i: Int){
        labels[0].attributedText = bahnschrift_formatted("\(i)", 16)
    }
    
    /// 设置文本框使能
    /// - Parameters:
    ///   - isEnable: 是否可编辑
    ///   - textField: 选中文本框
    func changeTextfieldUI(isEnable: Bool, _ textField: UITextField){

        textField.backgroundColor = isEnable ? UIColor(named: "DP_E5E5E5") : .clear
        textField.layer.borderColor = isEnable ? UIColor(named: "DP_999999")!.cgColor : UIColor.clear.cgColor
        
    }
    
    // MARK: - Event
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let rawText = textField.text ?? ""

        // 安全设置 attributedText
        textField.attributedText = bahnschrift_formatted(rawText)
        
        // 恢复光标位置（防止跳到末尾）
        if let selectedRange = textField.selectedTextRange {
            textField.selectedTextRange = selectedRange
        }
    }
    
    //滑动手势
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        
        guard let parentVC = self.parentViewController as? CustomPickViewVC else{ return}
            
        if parentVC.container.programmablePageV.titleTextField.isEditing {
            parentVC.container.programmablePageV.titleTextField.endEditing(true)
            Log.debug("标题行正在编辑,结束编辑")
        }
        
        if ProgrammablePagelistCell.isAnyCellEditing {
            ProgrammablePagelistCell.endAllEditing()
            Log.debug("文本框正在编辑,结束编辑")
        }
        
        let translation = gesture.translation(in: self)
        let velocity = gesture.velocity(in: self)
        
        switch gesture.state {
        case .began:
            // 如果有其他单元格左滑，先恢复它
            if let currentCell = ProgrammablePagelistCell.currentlySwipedCell,
               currentCell != self {
                currentCell.resetSwipe()
            }
            
        case .changed:
            if translation.x < 0 {
                // Left swipe
                let offsetX = max(-swipeDeleteBtnWidth*2, translation.x)
                updateContentOffset(offsetX)
                
                swipeAddBtn.isHidden = false
                swipeDeleteBtn.isHidden = false
                swipeAddBtn.alpha = min(1.0, abs(offsetX) / swipeDeleteBtnWidth*2)
                swipeDeleteBtn.alpha = min(1.0, abs(offsetX) / swipeDeleteBtnWidth)
                
                layoutIfNeeded()
            } else if translation.x > 0 && isSwiped {
                // Right swipe to reset
                resetSwipe()
            }
            
        case .ended, .cancelled:
            let shouldComplete = abs(translation.x) > swipeDeleteBtnWidth || velocity.x < -500
            if shouldComplete && translation.x < 0 {
                completeSwipe()
            } else {
                resetSwipe()
            }
            
        default:
            break
        }
    }
    
    private func updateContentOffset(_ offset: CGFloat) {
        contentLeftConstraint?.update(offset: offset)
        contentRightConstraint?.update(offset: offset)
    }
    
    private func completeSwipe() {
        isSwiped = true
        updateContentOffset(-swipeDeleteBtnWidth*2)
        UIView.animate(withDuration: 0.2) {
            self.swipeDeleteBtn.alpha = 1.0
            self.swipeAddBtn.alpha = 1.0
            self.layoutIfNeeded()
        }
        // 设置为当前左滑的单元格
        ProgrammablePagelistCell.currentlySwipedCell = self
    }
    
    func resetSwipe() {
        isSwiped = false
        updateContentOffset(0)
        UIView.animate(withDuration: 0.2) {
            self.swipeDeleteBtn.alpha = 0
            self.swipeAddBtn.alpha = 0
            self.layoutIfNeeded()
        } completion: { _ in
            self.swipeDeleteBtn.isHidden = true
            self.swipeAddBtn.isHidden = true
        }
        // 如果是当前左滑的单元格，清空引用
        if ProgrammablePagelistCell.currentlySwipedCell == self {
            ProgrammablePagelistCell.currentlySwipedCell = nil
        }
    }
    
    // 点击单元格空白区域(即非文本框位置),收起软键盘
    @objc private func handleBackgroundTap() {

        // 收起键盘
        ProgrammablePagelistCell.endAllEditing()
        Log.debug("点击单元格空白区域，收起所有键盘")
    }
    
    //单元格点击手势
    @objc private func handleCellTap(_ gesture: UITapGestureRecognizer) {
        
        let tapLocation = gesture.location(in: self)
        
        if isSwiped {
            // 只在滑出状态下检查按钮区域
            if swipeAddBtn.frame.contains(tapLocation) || swipeDeleteBtn.frame.contains(tapLocation) {
                Log.debug("排除按钮区域")
                return
            }
        }
        
        guard textFields[0].isUserInteractionEnabled || textFields[1].isUserInteractionEnabled || textFields[2].isUserInteractionEnabled else{
            Log.debug("uilabel 无法编辑，触发单元格点击回调")
            return
        }
        
        if isSwiped{
            resetSwipe()
            return
        }
        
        // 检查点击位置是否在文本框内
        let isTappingTextField = textFields[0].frame.contains(tapLocation) ||
        textFields[1].frame.contains(tapLocation) ||
        textFields[2].frame.contains(tapLocation)
        
        if isTappingTextField {
            // 点击了文本框，让文本框成为第一响应者
            if textFields[0].frame.contains(tapLocation) {
                textFields[0].becomeFirstResponder()
            } else if textFields[1].frame.contains(tapLocation) {
                textFields[1].becomeFirstResponder()
            } else if textFields[2].frame.contains(tapLocation) {
                textFields[2].becomeFirstResponder()
            }
            
            Log.debug("点击文本框区域，开始编辑")
        } else if ProgrammablePagelistCell.isAnyCellEditing {
            // 有单元格在编辑且点击了空白区域，先收起键盘
            ProgrammablePagelistCell.endAllEditing()
            
            Log.debug("有单元格正在编辑，点击空白区域收起键盘")
            
        } else {
            // 没有编辑状态，点击空白区域触发回调
//            onCellTap?()
            Log.debug("无编辑状态，触发单元格点击回调")
            
        }

    }
}

// MARK: - UIGestureRecognizerDelegate
extension ProgrammablePagelistCell: UIGestureRecognizerDelegate {

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            if let pan = gestureRecognizer as? UIPanGestureRecognizer {
                let velocity = pan.velocity(in: self)
                // Only allow horizontal pan
                return abs(velocity.x) > abs(velocity.y)
            }
            return true
        }
    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
//                         shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        // 允许与其他手势同时识别
//        return true
//    }
}
extension ProgrammablePagelistCell: UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        // 如果有其他单元格左滑，先恢复它
        if let currentCell = ProgrammablePagelistCell.currentlySwipedCell,
           currentCell != self {
            Log.debug("有其他单元格左滑，先恢复它")
            currentCell.resetSwipe()
        }
        
        // 设置全局编辑状态
        ProgrammablePagelistCell.isAnyCellEditing = true
        ProgrammablePagelistCell.currentEditingCell = self
          
        isEditingText = true
        changeTextfieldUI(isEnable: true, textField)
          
        currentTextField = textField
        textField.addKeyboardDoneToolbar(target: self, action: #selector(doneButtonAction))
        
        // 添加空白区域点击手势
        if let gesture = backgroundTapGesture {
          self.addGestureRecognizer(gesture)
        }

        if let vc = self.parentViewController as? CustomPickViewVC {
            vc.setActiveTextField(textField) //用于锁定当前文本框,自动调整文本框位置到软键盘上方
        }
    }
    
    /// - Returns:
    /// 完成按钮事件
    ///  textfiled 移除焦点,用于隐藏键盘,用户当前无法再输入
    @objc private func doneButtonAction(_ sender: UIBarButtonItem) {
        
//        Log.debug("收起软键盘, editingText: \(currentTextField?.text ?? "")")
        currentTextField?.resignFirstResponder()
        currentTextField = nil
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    
        var currentText = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "" //移除字符串开头和结尾的空白字符（空格、换行、制表符等）
        let attributedString = NSAttributedString(string: currentText)
        if currentText.isEmpty || currentText == "."{
            currentText = "0"
            textField.attributedText = bahnschrift_formatted("0")
        }
        
        let originalText = originalValues[textField]
        
        changeTextfieldUI(isEnable: false, textField)
        
        if attributedString != originalText {
            
            if !hasBeenEdited{
                hasBeenEdited = true
            }
            
            // 标准化：解析为数字再格式化（去除前导零、补零等）
            if let number = Double(currentText) {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.usesGroupingSeparator = false  // ← 禁用千位分隔符
                
                switch textField.tag {
                case 0:// 格式化文本为2位小数
                    formatter.minimumFractionDigits = 2
                    formatter.maximumFractionDigits = 2
                    textField.attributedText = bahnschrift_formatted(number.formattedWithLeadingZero())
                    
                case 1:
                    formatter.minimumFractionDigits = 3
                    formatter.maximumFractionDigits = 3
                    if let formattedStr = formatter.string(from: NSNumber(value: number)) {
                        // 使用格式化后的文本创建富文本
                        textField.attributedText = bahnschrift_formatted(formattedStr)
                    }
                    
                default:
                    formatter.minimumFractionDigits = 0
                    formatter.maximumFractionDigits = 0
                    if let formattedStr = formatter.string(from: NSNumber(value: number)) {
                        // 使用格式化后的文本创建富文本
                        textField.attributedText = bahnschrift_formatted(formattedStr)
                    }
                }
                
            } else {
                // 如果不是有效数字，保持原样
                textField.attributedText = bahnschrift_formatted(currentText)
            }
 
            // 编辑结束时再次验证设定值是否合理
            validateAndAdjustVoltages()

            
            // 移除空白区域点击手势
            if let gesture = backgroundTapGesture {
                self.removeGestureRecognizer(gesture)
            }
            
            // 延迟检查所有编辑状态
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.checkAllEditingState()
            }
            
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        // 获取当前文本
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        // 4. 处理小数点
        if string == "." {
            return !currentText.contains(".")
        }

        // 5. 检查输入合法性, 新文本是否超过最大值
        switch textField.tag {
        case 0: // voltageL - 30.5
            if !isValidNumberInput(newText) {
                return false
            }
           if let number = Double(newText), number > 30.5 {
               return false
           }
           
        case 1: // currentL - 5.1
            if !isValidNumberInput(newText, maxIntegerPlaces: 1 ,maxDecimalPlaces: 3) {
                return false
            }
           if let number = Double(newText), number > 5.1 {
               return false
           }
           
        case 2: // timeL - 9999
            if !isValidNumberInput(newText, maxIntegerPlaces: 4 , maxDecimalPlaces: 0) {
                return false
            }
           if let number = Double(newText), number > 9999 {
               return false
           }
           
        default:
           break
        }
        
        return true

    }

    
    //MARK: -

    // 最终验证并处理错误
    private func validateAndAdjustVoltages() {
        
        // 从UI读取最新值
        let time = Double(textFields[2].text ?? "0") ?? 0
        let current = Double(textFields[1].text ?? "0") ?? 0
        let voltage = Double(textFields[0].text ?? "0") ?? 0
        
        var alertMessages: [String] = []
        
        if time == 0 {
            if voltage != 0 && voltage != 1{
                textFields[0].attributedText = bahnschrift_formatted("01.00")
                alertMessages.append(NSLocalizedString("时间=0, 电压只能设为 0 或者 1", comment: "时间=0, 电压只能设为 0 或者 1"))
            }
            
            if voltage == 0 && current != 0 {
                textFields[1].attributedText = bahnschrift_formatted("0.000")
                alertMessages.append(NSLocalizedString("时间=0, 电压=0, 电流只能为0", comment: "时间=0, 电压=0, 电流只能为0"))
            }
            
            if voltage == 1 {
                //电压显示“Jump”,电流显示电流数值的高8位, 时间显示电流数值的低24位,其中若低24位为0则 时间不显示
                textFields[0].attributedText = bahnschrift_formatted("Jump")
                
                // 提取高8位（跳转行）
                let high8Bits = (Int(current) >> 24) & 0xFF
                        
                // 提取低24位（循环次数）
                let low24Bits = Int(current) & 0x00FFFFFF
                        
                // 更新电流显示（显示高8位）
                textFields[1].attributedText = bahnschrift_formatted("\(high8Bits)")
                
                // 更新时间显示（显示低24位，如果为0则不显示）
                if low24Bits == 0 {
                    textFields[2].attributedText = bahnschrift_formatted("")
                } else {
                    textFields[2].attributedText = bahnschrift_formatted("\(low24Bits)")
                }
                Log.debug("3005, 电压为1时，电流的高8位= \(high8Bits)，低24位= \(low24Bits == 0 ? "无限循环" : "\(low24Bits)")")
    //                    // 添加说明信息
    //                    alertMessages.append("电压=1时：\n电流显示跳转行(高8位)=\(high8Bits)\n时间显示循环次数(低24位)=\(low24Bits == 0 ? "无限循环" : "\(low24Bits)")")
                
            }
            
        }
        
        // 显示所有警告信息
        if !alertMessages.isEmpty {
            showAlert(message: alertMessages.joined(separator: "\n"))
        }

    }
    
    // 检查输入是否为合法数字
    private func isValidNumberInput(_ text: String, maxIntegerPlaces: Int = 2 ,maxDecimalPlaces: Int = 2) -> Bool {
        
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
 
       
        if let dotRange = text.range(of: ".") {
        // 有小数点的情况: 检查小数点前的整数部分
            let integerPart = String(text[..<dotRange.lowerBound])
            let decimalPart = String(text[dotRange.upperBound...])

            // 整数部分不能超过 maxIntegerPlaces
            if integerPart.count > maxIntegerPlaces {
                return false
            }

            // 小数部分不能超过 maxDecimalPlaces
            if decimalPart.count > maxDecimalPlaces {
                return false
            }


        } else {
            // 没有小数点的情况：检查整个字符串的长度
            if text.count > maxIntegerPlaces {
                return false
            }
        }
        
        
        return true
    }
    
    private func showAlert(message: String) {
        
        if let parentVC = self.parentViewController as? CustomPickViewVC {
            alert = UIAlertController(title: NSLocalizedString("提示", comment: "提示"), message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("确定", comment: "确定"), style: .default))
            parentVC.present(alert, animated: true)
        }
        
    }
    
    // 检查所有单元格的编辑状态
    private func checkAllEditingState() {
        var foundEditingCell = false
        
        // 通过父视图查找所有同类型单元格
        if let parentVC = self.parentViewController as? CustomPickViewVC {
            let sublist = parentVC.container.programmablePageV.programmablePageRows
            for cell in sublist {
                if cell.isEditing {
                    foundEditingCell = true
                    ProgrammablePagelistCell.currentEditingCell = cell
                    break
                }
            }
        }
           
        
        ProgrammablePagelistCell.isAnyCellEditing = foundEditingCell
        isEditingText = foundEditingCell
        
        if !foundEditingCell {
            ProgrammablePagelistCell.currentEditingCell = nil
        }
        
    }
    
    
}

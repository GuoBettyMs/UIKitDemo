//
//  PresetSublistCell.swift
//  SwiftTest
//
//  Created by user on 2026/1/23.
//


import UIKit
import SnapKit

class PresetSublistCell: UIView{
    
    //MARK:   ui 属性
    var index = UILabel()
    var voltages:[UITextField] = []
    var secondVoltages:[UITextField] = []
    var currents:[UITextField] = []
    var connects: [UILabel] = []
    var volUnits: [UILabel] = []
    var curUnits: [UILabel] = []
    let img = UIImageView()
    var isChooseen = false { //复选框是否被选中
        didSet{
            img.image = UIImage(named: isChooseen ? "DP_usbItemComfirm_presetvalues" : "DP_usbItemUncomfirm_presetvalues")
        }
    }
    var isInitialItem: Bool = false //是否初始项
    private var originalValues: [UITextField: String] = [:]  //保留文本框旧值

    // 常量定义
    private let MIN_VOLTAGE: Double = 3.3
    private let MAX_VOLTAGE: Double = 28.0
    private let CURRENT_LIMIT: Double = 5.0
    
    //MARK: 监听编辑状态
    var onCellTap: (() -> Void)? //单元格点击回调
    var currentTextField: UITextField? //当前编辑的文本
    private var backgroundTapGesture: UITapGestureRecognizer? // 添加 cell 空白区域点击手势

    
    // 标记是否被编辑过,跳转到其他页面(非预设值页面)会自动恢复默认值
    var hasBeenEdited = false {
        didSet {
            // 当编辑状态改变时通知外部
            if hasBeenEdited != oldValue {
                NotificationCenter.default.post(
                    name: .presetSublistcellEditStateChanged,
                    object: self,
                    userInfo: ["cell": self, "celledited": hasBeenEdited]
                )
            }
        }
    }
    
    private var isEditingText = false // 标记是否正在编辑
    private var isEditing: Bool { // 检查当前单元格是否有文本框在编辑
        return voltages[0].isFirstResponder || voltages[1].isFirstResponder || secondVoltages[0].isFirstResponder || secondVoltages[1].isFirstResponder || currents[0].isFirstResponder || currents[1].isFirstResponder
    }
    
    
    // 静态属性，用于全局管理编辑状态
    static var isAnyCellEditing = false
    private static var currentEditingCell: PresetSublistCell?
    

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        additionalSetup2()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        let height: CGFloat = (tag == 6 && isInitialItem) ? 60 : 40
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }
    
    func updateHeightIfNeeded() {
        invalidateIntrinsicContentSize()
    }
    
    deinit {
        // 在对象销毁时清除回调
        onCellTap = nil
        Log.debug("PresetSublistCell deinit")
    }
    
    // MARK: - Private Methods
    private func additionalSetup2(){
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(img)
        img.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
        }
        img.image = UIImage(named: "DP_UsbEditFirstRow")
        img.isUserInteractionEnabled = true

        addSubview(index)
        index.snp.makeConstraints { make in
            make.left.equalTo(img.snp.right).offset(16)
            make.centerY.equalToSuperview()
        }
        index.textColor = .black
        index.text = "1"
        
        let stackV = UIStackView()
        addSubview(stackV)
        stackV.snp.makeConstraints { make in
            make.left.equalTo(img.snp.right).offset(25)
            make.right.equalToSuperview().offset(-74)
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        stackV.axis = .horizontal
        stackV.distribution = .fillEqually
        stackV.spacing = 0
        
        //第一行,tag: 0-vol, 2-maxVol, 1-cur
        //第二行,tag: 3-vol, 5-maxVol, 4-cur
        for itemI in 0...1 {
            let item = UIView()
            stackV.addArrangedSubview(item)
            
            if itemI == 0 {
                for rowI in 0...1{
                    let vol = UITextField()
                    item.addSubview(vol)
                    vol.snp.makeConstraints { make in
                        make.width.equalTo(52)
                        make.height.equalTo(20)
                        //                make.centerX.equalToSuperview().offset(-56)
                        make.centerX.equalToSuperview()
                        if rowI == 0 {
                            make.centerY.equalToSuperview().offset(1)
                        }else{
                            make.bottom.equalToSuperview().offset(-1)
                        }
                        
                    }
                    vol.layer.cornerRadius = 5
                    vol.textColor = .black
                    vol.attributedText = bahnschrift_formatted("-")
                    vol.delegate = self
                    vol.tag = rowI == 0 ? 0 : 3
                    vol.keyboardType = .decimalPad
                    vol.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
                    
                    let maxVol = UITextField()
                    item.addSubview(maxVol)
                    maxVol.snp.makeConstraints { make in
                        make.width.equalTo(52)
                        make.height.equalTo(20)
                        make.centerX.equalToSuperview().offset(29)
                        //                make.centerX.equalToSuperview().offset(-28)
                        if rowI == 0 {
                            make.centerY.equalToSuperview().offset(1)
                        }else{
                            make.bottom.equalToSuperview().offset(-1)
                        }
                    }
                    maxVol.layer.cornerRadius = 5
                    maxVol.textColor = .black
                    maxVol.attributedText = bahnschrift_formatted("11.0")
                    maxVol.delegate = self
                    maxVol.tag = rowI == 0 ? 2 : 5
                    maxVol.keyboardType = .decimalPad
                    maxVol.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
                    
                    let connectL = UILabel()
                    item.addSubview(connectL)
                    connectL.snp.makeConstraints { make in
                        if rowI == 0 {
                            make.centerY.equalTo(vol.snp.centerY)
                        }else{
                            make.centerY.equalTo(maxVol.snp.centerY)
                        }
                        make.centerX.equalToSuperview()//.offset(-56)
                    }
                    connectL.textColor = .black
                    connectL.attributedText = bahnschrift_formatted("-", 14)
                    
                    let volUnitL = UILabel()
                    item.addSubview(volUnitL)
                    volUnitL.snp.makeConstraints { make in
                        if rowI == 0 {
                            make.bottom.equalTo(vol.snp.bottom).offset(-2)
                            make.left.equalTo(vol.snp.right)
                        }else{
                            make.bottom.equalTo(maxVol.snp.bottom).offset(-2)
                            make.left.equalTo(maxVol.snp.right)
                        }
                    }
                    volUnitL.textColor = .black
                    volUnitL.attributedText = bahnschrift_formatted("V", 14)
                    
                    if rowI == 1 {
                        vol.isHidden = true
                        maxVol.isHidden = true
                        connectL.isHidden = true
                        volUnitL.isHidden = true
                    }
                    vol.layer.borderWidth = 1
                    vol.layer.borderColor = UIColor.clear.cgColor
                    maxVol.layer.borderWidth = 1
                    maxVol.layer.borderColor = UIColor.clear.cgColor
                    
                    
                    voltages.append(vol)
                    secondVoltages.append(maxVol)
                    connects.append(connectL)
                    volUnits.append(volUnitL)
                }
            }else{
                for rowI in 0...1{
                    let cur = UITextField()
                    item.addSubview(cur)
                    cur.snp.makeConstraints { make in
                        make.width.equalTo(52)
                        make.height.equalTo(20)
    //                    make.centerX.equalToSuperview().offset(54)
                        make.centerX.equalToSuperview()
                        if rowI == 0 {
                            make.centerY.equalToSuperview().offset(1)
                        }else{
                            make.bottom.equalToSuperview().offset(-1)
                        }
                    }
                    cur.layer.cornerRadius = 5
                    cur.textColor = .black
                    cur.attributedText = bahnschrift_formatted("-")
                    cur.delegate = self
                    cur.tag = rowI == 0 ? 1 : 4
                    cur.keyboardType = .decimalPad
                    cur.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
                    
                    let curUnitL = UILabel()
                    item.addSubview(curUnitL)
                    curUnitL.snp.makeConstraints { make in
                        make.bottom.equalTo(cur.snp.bottom).offset(-1)
                        make.left.equalTo(cur.snp.right)
                    }
                    curUnitL.textColor = .black
                    curUnitL.attributedText = bahnschrift_formatted("A", 14)
                    
                    if rowI == 1 {
                        cur.isHidden = true
                        curUnitL.isHidden = true
                    }
                    
                    cur.layer.borderWidth = 1
                    cur.layer.borderColor = UIColor.clear.cgColor
                    currents.append(cur)
                    curUnits.append(curUnitL)
                }
            }
            
        }
        
        // 初始化空白区域点击手势（但不立即添加）
        backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        backgroundTapGesture?.cancelsTouchesInView = false
        
        // 添加单元格点击手势
        let cellTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCellTap))
        cellTapGesture.cancelsTouchesInView = false
        self.addGestureRecognizer(cellTapGesture)
        
        
        
        // 记录初始值
        originalValues[voltages[0]] = voltages[0].text
        originalValues[secondVoltages[0]] = secondVoltages[0].text
        originalValues[currents[0]] = currents[0].text
        originalValues[currents[1]] = currents[1].text
    }
    
    // MARK: - Public Methods

    
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

    //设置特殊行
    func setSpecialVolLabel(cur15V_10ma: Double, cur20V_10ma: Double){

        connects.enumerated().forEach({ (index,l) in
            l.isHidden = false
        })
        
        img.snp.remakeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.centerY.equalTo(connects[0].snp.centerY)
        }
        
        curUnits.enumerated().forEach({ (index,uint) in
            uint.isHidden = false
        })
        
        voltages.enumerated().forEach({ (index,vol) in
            vol.isUserInteractionEnabled = false
            vol.isHidden = false
             
            vol.attributedText = bahnschrift_formatted(index == 0 ? "9.0" : "15.0")
          
            vol.snp.remakeConstraints { make in
                make.width.equalTo(52)
                make.height.equalTo(20)
//                make.centerX.equalToSuperview().offset(-56)
                make.right.equalTo(connects[index == 0 ? 0 : 1].snp.left).offset(2)
                if index == 0 {
                    make.top.equalToSuperview().offset(6)
                }else{
                    make.bottom.equalToSuperview().offset(-6)
                }
            }
            
        })
        
        secondVoltages.enumerated().forEach({ (index,vol) in
            vol.isUserInteractionEnabled = false
            vol.isHidden = false
            
            vol.attributedText = bahnschrift_formatted(index == 0 ? "15.0" : "20.0")
            
            vol.snp.remakeConstraints { make in
                make.width.equalTo(52)
                make.height.equalTo(20)
                make.centerX.equalToSuperview().offset(29)
//                make.centerX.equalToSuperview().offset(-28)
                if index == 0 {
                    make.top.equalToSuperview().offset(6)
                }else{
                    make.bottom.equalToSuperview().offset(-6)
                }
                
            }
        })
        
        volUnits.enumerated().forEach({ (index,unit) in
            unit.isHidden = false
            
            unit.snp.remakeConstraints { make in
                make.bottom.equalTo(secondVoltages[index].snp.bottom).offset(-2)
                make.left.equalTo(secondVoltages[index].snp.right)
            }
            
        })
       
        currents.enumerated().forEach({ (index,cur) in
            cur.isUserInteractionEnabled = true
            cur.isHidden = false
            
            cur.attributedText = bahnschrift_formatted(index == 0 ? "\(cur15V_10ma.formatted(decimalPlaces: 2))": "\(cur20V_10ma.formatted(decimalPlaces: 2))")
            
            cur.snp.remakeConstraints { make in
                make.width.equalTo(52)
                make.height.equalTo(20)
                make.centerX.equalToSuperview()//.offset(54)
                if index == 0 {
                    make.top.equalToSuperview().offset(6)
                }else{
                    make.bottom.equalToSuperview().offset(-6)
                }
            }
        })

        
    }
    
    func setVolLabel(volMin: Double, volMax: Double, isLast: Bool){
 
        let minvolStr = "\(volMin.formatted(decimalPlaces: isLast ? 1 : 2))"
        let maxvolStr = "\(volMax.formatted())"
        
        if isLast{
            connects[0].isHidden = false
            secondVoltages[0].isHidden = false
            
            volUnits[0].snp.remakeConstraints { make in
                make.bottom.equalTo(secondVoltages[0].snp.bottom).offset(-2)
                make.left.equalTo(secondVoltages[0].snp.right)
            }
            
            voltages[0].snp.remakeConstraints { make in
                make.width.equalTo(52)
                make.height.equalTo(20)
                make.right.equalTo(connects[0].snp.left).offset(2)
                make.centerY.equalToSuperview().offset(1)
            }
            
            voltages[0].attributedText = bahnschrift_formatted(minvolStr)
            secondVoltages[0].attributedText = bahnschrift_formatted(maxvolStr)
        }else{
            connects[0].isHidden = true
            secondVoltages[0].isHidden = true
            voltages[0].attributedText = bahnschrift_formatted(minvolStr)
        }
    }
    
    func setCurLabel(cur: Double){
        currents[0].attributedText = bahnschrift_formatted("\(cur.formatted(decimalPlaces: 2))")
    }

    func setIndexL(_ str: Int){
        index.text = "\(str)"
    }
    
    /// 设置文本框使能
    /// - Parameters:
    ///   - isEnable: 是否可编辑
    ///   - textField: 选中文本框
    func changeTextfieldUI(isEnable: Bool, _ textField: UITextField){

        textField.backgroundColor = isEnable ? UIColor(named: "DP_E5E5E5") : .clear
        textField.layer.borderColor = isEnable ? UIColor(named: "DP_999999")!.cgColor : UIColor.clear.cgColor
        
    }
    
    
    // MARK: - Helper Methods
    
    //监听文本框值改变
    @objc func textFieldDidChange(_ textField: UITextField) {
        let rawText = textField.text ?? ""

        // 安全设置 attributedText
        textField.attributedText = bahnschrift_formatted(rawText)
        
        // 恢复光标位置（防止跳到末尾）
        if let selectedRange = textField.selectedTextRange {
            textField.selectedTextRange = selectedRange
        }
    }
    
    //单元格点击手势
    @objc private func handleCellTap(_ gesture: UITapGestureRecognizer) {
        
        let tapLocation = gesture.location(in: self)
        if img.frame.contains(tapLocation){
            if self.tag != 0 {
                isChooseen = !isChooseen
                Log.debug("isChooseen: \(isChooseen), \(self.tag)")
            }
        }else if PresetSublistCell.isAnyCellEditing {
            // 有单元格在编辑且点击了空白区域，先收起键盘
            Log.debug("有单元格正在编辑，点击空白区域收起键盘")
            PresetSublistCell.endAllEditing()
            
        }else{
            if self.tag == 5 && (voltages[0].frame.contains(tapLocation) ||
                                 secondVoltages[0].frame.contains(tapLocation)) {
                Log.debug("点击文本框区域，开始编辑")
            }else if self.tag == 6 && ( currents[0].frame.contains(tapLocation)
                                        || currents[1].frame.contains(tapLocation)){
                Log.debug("点击文本框区域，开始编辑")
            }else if currents[0].frame.contains(tapLocation) {
                Log.debug("点击文本框区域，开始编辑")
            }
        }
        
    }
    
    // 点击单元格空白区域(即非文本框位置),收起软键盘
    @objc private func handleBackgroundTap() {
        // 收起键盘
        PresetSublistCell.endAllEditing()
        Log.debug("预设值 PDO 列表点击单元格空白区域，收起所有键盘")
    }
    
    // 结束当前单元格的编辑
    private func endCellEditing(_ force: Bool) {
        if voltages[0].isFirstResponder {
            voltages[0].resignFirstResponder()
        }
        
        if secondVoltages[0].isFirstResponder {
            secondVoltages[0].resignFirstResponder()
        }
        
        if currents[0].isFirstResponder {
            currents[0].resignFirstResponder()
        }
        if currents[1].isFirstResponder {
            currents[1].resignFirstResponder()
        }
    }
    
}
extension PresetSublistCell: UITextFieldDelegate{

    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        // 设置全局编辑状态
        PresetSublistCell.isAnyCellEditing = true
        PresetSublistCell.currentEditingCell = self

        isEditingText = true
        changeTextfieldUI(isEnable: true, textField)
        
        currentTextField = textField
        textField.addKeyboardDoneToolbar(target: self, action: #selector(doneButtonAction))

        // 添加空白区域点击手势
        if let gesture = backgroundTapGesture {
          self.addGestureRecognizer(gesture)
        }

        if let vc = self.parentViewController as? CustomPickViewVC {
            vc.setPresetSublistActiveTextField(textField)
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

        var currentText = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if currentText.isEmpty || currentText == "."{
            currentText = "0"
            textField.text = "0" // 先设置普通 text，避免 attributedText 干扰
        }

        let originalText = originalValues[textField] ?? "0" // 原始值也应为 "0" 而非 "-"
        
        changeTextfieldUI(isEnable: false, textField)
        
        if currentText != originalText {
            
            if !hasBeenEdited{
                hasBeenEdited = true
            }
            
            if let number = Double(currentText) {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.usesGroupingSeparator = false  // ← 禁用千位分隔符
                
                if textField.tag == 0 && self.tag == 5 || textField.tag == 2 && self.tag == 5 {
                    formatter.minimumFractionDigits = 1
                    formatter.maximumFractionDigits = 1
                }else{
                    formatter.minimumFractionDigits = 2
                    formatter.maximumFractionDigits = 2
                }
                
                
                if let formattedStr = formatter.string(from: NSNumber(value: number)) {
                    // 使用格式化后的文本创建富文本
                    textField.attributedText = bahnschrift_formatted(formattedStr)
                }
                
            } else {
                // 如果不是有效数字，保持原样
                textField.attributedText = bahnschrift_formatted(currentText)
            }
            
            // 编辑结束时验证电压设定值是否合理
            ///不在 shouldChangeCharactersIn()验证原因: 电压值可能为2位数,难以确定用户是想输入一位数还是两位数,比如 min=3.3,若用户想输入 max=10,但是 “1”会被判定小于 min 而无法输入
            if textField.tag == 0 || textField.tag == 2 {
                switch self.tag {
                case 1...4:
                    validateAndAdjustVoltagesForRows1to4()
                case 5:
                    validateAndAdjustVoltagesForRow5(textField.tag)
                case 7:
                    validateAndAdjustVoltagesForRows1to4()
                default: break
                }
            }


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
    
    //文本框输入过程,自动对文本进行检查
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        //确保实时颜色为黑色
        textField.textColor = .black
        
        // 获取当前文本
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)

        // 4. 处理小数点
        if string == "." {
            return !currentText.contains(".")
        }
        // 特殊处理：允许完全删除（清空文本框）
        if newText.isEmpty {
            // 允许用户清空文本框
            DispatchQueue.main.async {
                textField.attributedText = bahnschrift_formatted("")
            }
            return true
        }
        
        // 如果新文本只有一个点，暂时允许（用户可能在输入小数）
        if newText == "." {
            DispatchQueue.main.async {
                textField.attributedText = bahnschrift_formatted(newText)
            }
            return true
        }
        
        //第一行 textfiledTag, tag: 0-vol, 2-maxVol, 1-cur
        //第二行 textfiledTag ,tag: 3-vol, 5-maxVol, 4-cur
        // 检查输入合法性
        switch textField.tag {
        case 0,
            2,
            3,
            5:
            let places = self.tag == 5 || self.tag == 6 ? 1 : 2
            if !isValidNumberInput(newText, maxDecimalPlaces: places) {
                return false
            }
           
        case 1,
            4:
            if !isValidNumberInput(newText, maxIntegerPlaces: 1) {
                return false
            }
            
        default: break
        }
        
        guard let vc = parentViewController as? CustomPickViewVC , vc.container.presetPageV.selectedRowI >= 0 && vc.container.presetPageV.selectedRowI < vc.model.initialPresetListDatas.count else {
            return false
        }
        
        // initialPresetListDatas 索引从 0 开始,pDODataListIndex_ForPresetvalues 索引从1开始
        let power = vc.model.initialPresetListDatas[vc.container.presetPageV.selectedRowI].pDOPower
//        Log.debug("3005, 选中行= \(vc.container.presetPageV.selectedRowI),  power= \(power)")
      
        // 根据不同的行和文本框类型进行验证
        let isValid = validateInputForCell(
                cellTag: self.tag,
                textFieldTag: textField.tag,
                newText: newText,
                power: Double(power),
                voltageMin: MIN_VOLTAGE,
                voltageMax: MAX_VOLTAGE,
                currentLimit: CURRENT_LIMIT
            )
        
        return isValid
        
    }
    
    // MARK: - 输入验证逻辑
    private func validateInputForCell(
        cellTag: Int,
        textFieldTag: Int,
        newText: String,
        power: Double,
        voltageMin: Double,
        voltageMax: Double,
        currentLimit: Double
    ) -> Bool {
        
        guard let newValue = Double(newText) else {
            return false
        }
        
        //第一行,tag: 0-vol, 2-maxVol, 1-cur
        //第二行,tag: 3-vol, 5-maxVol, 4-cur
        //电压*电流 <= 功率
        switch cellTag {
        case 0:
            return validateForRow0(textFieldTag: textFieldTag, newValue: newValue, power: power, currentLimit: currentLimit)
            
        case 1...4:
            return validateCurrentForRows1to4(textFieldTag: textFieldTag, newValue: newValue, power: power, voltageMin: voltageMin, voltageMax: voltageMax, currentLimit: currentLimit)
            
        case 5:
            return validateCurrentForRow5(textFieldTag: textFieldTag, newValue: newValue, power: power, voltageMin: voltageMin, voltageMax: voltageMax, currentLimit: currentLimit)
            
        case 6:
            return validateForRow6(textFieldTag: textFieldTag, newValue: newValue, power: power, currentLimit: currentLimit)
            
        default:
            return true
        }
        
    }
    
    // MARK:  第0行验证（电压固定5V，只验证电流）
    private func validateForRow0(
        textFieldTag: Int,
        newValue: Double,
        power: Double,
        currentLimit: Double
    ) -> Bool {
        
        if textFieldTag == 1 { // 电流
            let estimatedCurrent = power / 5.0
            let maxCurrent = min(estimatedCurrent, currentLimit)
            
            Log.debug("第0行 - 当前值: \(newValue), 估算电流: \(estimatedCurrent), 最大电流: \(maxCurrent)")
            return newValue <= maxCurrent
        }
        return true
    }

    // MARK:  第1-4行验证（单电压+电流）
    private func validateCurrentForRows1to4(
        textFieldTag: Int,
        newValue: Double,
        power: Double,
        voltageMin: Double,
        voltageMax: Double,
        currentLimit: Double
    ) -> Bool {
        
        // 获取当前电压
        let currentVoltage = Double(voltages[0].text ?? "") ?? 0
        if textFieldTag == 1 { // 电流输入
            // 获取电压的实时值
            let voltageValue: Double
            if let voltageText = voltages[0].text, !voltageText.isEmpty, voltageText != "-" {
                voltageValue = Double(voltageText) ?? 0
            } else {
                voltageValue = 0
            }
            
            // 电流必须小于等于限制值
            guard newValue <= currentLimit else {
                Log.debug("电流超出限制: \(newValue) > \(currentLimit)")
                return false
            }
            
            // 与电压的功率关系验证
            if voltageValue > 0 {
                let estimatedCurrent = power / currentVoltage
                let maxCurrent = min(estimatedCurrent, currentLimit)
                
                Log.debug("第\(self.tag)行 - 电流: \(newValue), 基于电压估算电流: \(estimatedCurrent), 最大电流: \(maxCurrent)")

                return newValue <= maxCurrent
            }
        }
        return true
    }

    private func validateAndAdjustVoltagesForRows1to4(){
        guard let firstText = voltages[0].text, !firstText.isEmpty,
              var firstVoltage = Double(firstText) else {
            return
        }
        guard let vc = parentViewController as? CustomPickViewVC , vc.container.presetPageV.selectedRowI >= 0 && vc.container.presetPageV.selectedRowI < vc.model.initialPresetListDatas.count else {
            return
        }
        
        var needsUpdate = false
        
        // 确保 voltageL >= MIN_VOLTAGE
        if firstVoltage < MIN_VOLTAGE {
            firstVoltage = MIN_VOLTAGE
            voltages[0].text = String(format: "%.2f", firstVoltage)
            needsUpdate = true
        }
        
        let currentValue: Double
        if let currentText = currents[0].text, !currentText.isEmpty, currentText != "-" {
            currentValue = Double(currentText) ?? 0
        } else {
            currentValue = 0
        }
        
        // 与电流的功率关系验证
        if currentValue > 0 {
            // initialPresetListDatas 索引从 0 开始,pDODataListIndex_ForPresetvalues 索引从1开始
            let power = vc.model.initialPresetListDatas[vc.container.presetPageV.selectedRowI].pDOPower
            let estimatedVoltage = Double(power) / currentValue
            let maxVoltage = min(estimatedVoltage, MAX_VOLTAGE)
            
            Log.debug("第\(self.tag)行 - 电压: \(firstVoltage), 基于电流(\(currentValue))估算电压: \(estimatedVoltage), 最大允许电压: \(maxVoltage)")
            
            if firstVoltage <= maxVoltage && firstVoltage >= MIN_VOLTAGE {
                voltages[0].text = String(format: "%.2f", firstVoltage)
                voltages[0].attributedText = bahnschrift_formatted(voltages[0].text ?? "")
            }else{
                voltages[0].text = String(format: "%.2f", estimatedVoltage)
                voltages[0].attributedText = bahnschrift_formatted(voltages[0].text ?? "")
//                Log.debug("第\(self.tag)行 - 电压值强制设置为 \(estimatedVoltage)")
                
                showAlert(message: NSLocalizedString("基于电流(\(currentValue))估算电压: \(estimatedVoltage.formatted(decimalPlaces: 2)), \n最大允许电压: \(maxVoltage.formatted(decimalPlaces: 2)), \n电压值强制设置为最大允许电压", comment: "基于电流(\(currentValue))估算电压: \(estimatedVoltage.formatted(decimalPlaces: 2)), \n最大允许电压: \(maxVoltage.formatted(decimalPlaces: 2)), \n电压值强制设置为最大允许电压"))
            }
            
        }else{
            // 确保 secondVoltageL <= MAX_VOLTAGE
            if firstVoltage > MAX_VOLTAGE {
                firstVoltage = MAX_VOLTAGE
                voltages[0].text = String(format: "%.2f", firstVoltage)
                needsUpdate = true
            }
        }
        
        
        
        // 如果需要更新，刷新显示
        if needsUpdate {
            voltages[0].attributedText = bahnschrift_formatted(voltages[0].text ?? "")
            showAlert(message: NSLocalizedString("电压值已自动调整为有效范围：\n最小电压 ≥ \(MIN_VOLTAGE)V\n最大电压 ≤ \(MAX_VOLTAGE)V\n且最大电压 > 最小电压", comment: "电压值已自动调整为有效范围：\n最小电压 ≥ \(MIN_VOLTAGE)V\n最大电压 ≤ \(MAX_VOLTAGE)V\n且最大电压 > 最小电压"))
        }
        
    }
    
    
    // MARK:  第5行验证（双电压范围+电流）

    private func validateCurrentForRow5(
        textFieldTag: Int,
        newValue: Double,
        power: Double,
        voltageMin: Double,
        voltageMax: Double,
        currentLimit: Double
    ) -> Bool {
        
        let maxVoltage = Double(secondVoltages[0].text ?? "") ?? 0
        if textFieldTag == 1{ // 电流
            guard newValue <= currentLimit else {
                Log.debug("电流超出限制: \(newValue) > \(currentLimit)")
                return false
            }
            
            if maxVoltage > 0 {
                let estimatedCurrent = power / maxVoltage
                let maxCurrent = min(estimatedCurrent, currentLimit)
                
                Log.debug("第5行 - 电流: \(newValue), 基于大电压估算电流: \(estimatedCurrent), 最大电流: \(maxCurrent)")
                return newValue <= maxCurrent
            }
            
            return true
        }
        return true
    }

    
    // 最终验证并处理错误
    private func validateAndAdjustVoltagesForRow5(_ textFieldTag: Int) {
        
        guard let firstText = voltages[0].text, !firstText.isEmpty,
              let secondText = secondVoltages[0].text, !secondText.isEmpty,
              var firstVoltage = Double(firstText),
              var secondVoltage = Double(secondText) else {
            return
        }
        guard let vc = parentViewController as? CustomPickViewVC , vc.container.presetPageV.selectedRowI >= 0 && vc.container.presetPageV.selectedRowI < vc.model.initialPresetListDatas.count else {
            return
        }
        
        var needsUpdate = false
        
        let currentValue: Double
        if let currentText = currents[0].text, !currentText.isEmpty, currentText != "-" {
            currentValue = Double(currentText) ?? 0
        } else {
            currentValue = 0
        }
        // 与电流的功率关系验证
        if currentValue > 0 {
            // initialPresetListDatas 索引从 0 开始,pDODataListIndex_ForPresetvalues 索引从1开始
            let power = vc.model.initialPresetListDatas[vc.container.presetPageV.selectedRowI].pDOPower
            let estimatedVoltage = Double(power) / currentValue
            let maxVoltage = min(estimatedVoltage, MAX_VOLTAGE)
            
           
            if textFieldTag == 0 {
                Log.debug("第\(self.tag)行 - 小电压: \(firstVoltage), 基于电流(\(currentValue))估算电压: \(estimatedVoltage), 最大允许电压: \(maxVoltage)")
                
                // 确保 voltageL >= MIN_VOLTAGE
                if firstVoltage < MIN_VOLTAGE {
                    firstVoltage = MIN_VOLTAGE
                    voltages[0].text = String(format: "%.1f", firstVoltage)
                    needsUpdate = true
                }
                
                // 确保 secondVoltageL > voltageL
                if secondVoltage <= firstVoltage {
                    
                    // 自动调整：将 secondVoltageL 设置为比 voltageL 稍大的值
                    secondVoltage = firstVoltage + 0.1
                    if secondVoltage > maxVoltage {
                        // 如果调整后超过最大值，则调整 voltageL
                        firstVoltage = maxVoltage - 0.1
                        voltages[0].text = String(format: "%.1f", firstVoltage)
                        secondVoltages[0].text = String(format: "%.1f", maxVoltage)
                        showAlert(message: NSLocalizedString("设置第二电压时,第二电压不大于第一电压,且第二电压超过最大允许电压,将第二电压设置为最大允许电压", comment: "设置第二电压时,第二电压不大于第一电压,且第二电压超过最大允许电压,将第二电压设置为最大允许电压"))
                    } else {
                        secondVoltages[0].text = String(format: "%.1f", secondVoltage)
                        showAlert(message: NSLocalizedString("设置第二电压时,第二电压不大于第一电压,将第二电压重新设置为比第一电压稍大的值", comment: "设置第二电压时,第二电压不大于第一电压,将第二电压重新设置为比第一电压稍大的值"))
                    }
                    
                }
            }else if textFieldTag == 2{
                Log.debug("第\(self.tag)行 - 大电压: \(secondVoltage), 基于电流(\(currentValue))估算电压: \(estimatedVoltage), 最大允许电压: \(maxVoltage)")
                
                if secondVoltage <= maxVoltage && secondVoltage >= MIN_VOLTAGE {
                    if secondVoltage <= firstVoltage {
                        // 自动调整：将 secondVoltageL 设置为比 voltageL 稍大的值
                        secondVoltage = firstVoltage + 0.1
                        if secondVoltage > maxVoltage {
                            // 如果调整后超过最大值，则调整 voltageL
                            firstVoltage = maxVoltage - 0.1
                            voltages[0].text = String(format: "%.1f", firstVoltage)
                            secondVoltages[0].text = String(format: "%.1f", maxVoltage)
                            showAlert(message: NSLocalizedString("设置第二电压时,第二电压不大于第一电压,且第二电压超过最大允许电压,将第二电压设置为最大允许电压", comment: "设置第二电压时,第二电压不大于第一电压,且第二电压超过最大允许电压,将第二电压设置为最大允许电压"))
                        } else {
                            secondVoltages[0].text = String(format: "%.1f", secondVoltage)
                            showAlert(message: NSLocalizedString("设置第二电压时,第二电压不大于第一电压,将第二电压重新设置为比第一电压稍大的值", comment: "设置第二电压时,第二电压不大于第一电压,将第二电压重新设置为比第一电压稍大的值"))
                        }

                    }else{
                        secondVoltages[0].text = String(format: "%.1f", secondVoltage)
                        secondVoltages[0].attributedText = bahnschrift_formatted(secondVoltages[0].text ?? "")
                    }
                    
                }else{
                    secondVoltages[0].text = String(format: "%.1f", estimatedVoltage)
                    secondVoltages[0].attributedText = bahnschrift_formatted(secondVoltages[0].text ?? "")
    //                Log.debug("第\(self.tag)行 - 电压值强制设置为 \(estimatedVoltage)")
                    showAlert(message: NSLocalizedString("基于电流(\(currentValue))估算电压: \(estimatedVoltage.formatted(decimalPlaces: 1)), \n最大允许电压: \(maxVoltage.formatted(decimalPlaces: 1)), \n电压值强制设置为最大允许电压", comment: "基于电流(\(currentValue))估算电压: \(estimatedVoltage.formatted(decimalPlaces: 1)), \n最大允许电压: \(maxVoltage.formatted(decimalPlaces: 1)), \n电压值强制设置为最大允许电压"))
                }
                
                // 确保 secondVoltageL <= MAX_VOLTAGE
                if secondVoltage > MAX_VOLTAGE {
                    secondVoltage = MAX_VOLTAGE
                    secondVoltages[0].text = String(format: "%.1f", secondVoltage)
                    needsUpdate = true
                }
            }
            
        }

        
        // 如果需要更新，刷新显示
        if needsUpdate {
            voltages[0].attributedText = bahnschrift_formatted(voltages[0].text ?? "")
            secondVoltages[0].attributedText = bahnschrift_formatted(secondVoltages[0].text ?? "")
            showAlert(message: NSLocalizedString("电压值已自动调整为有效范围：\n最小电压 ≥ \(MIN_VOLTAGE)V\n最大电压 ≤ \(MAX_VOLTAGE)V\n且最大电压 > 最小电压", comment: "电压值已自动调整为有效范围：\n最小电压 ≥ \(MIN_VOLTAGE)V\n最大电压 ≤ \(MAX_VOLTAGE)V\n且最大电压 > 最小电压"))
        }
 
    }

    
    // MARK: 第6行验证（固定双电压，只验证电流）
    private func validateForRow6(
        textFieldTag: Int,
        newValue: Double,
        power: Double,
        currentLimit: Double
    ) -> Bool {
        
        if textFieldTag == 1 { // 15V电流
            let estimatedCurrent = power / 15.0
            let maxCurrent = min(estimatedCurrent, currentLimit)
            
            Log.debug("第6行15V - 电流: \(newValue), 估算电流: \(estimatedCurrent), 最大电流: \(maxCurrent)")
            
            return newValue <= maxCurrent
            
        } else if textFieldTag == 4 { // 20V电流
            let estimatedCurrent = power / 20.0
            let maxCurrent = min(estimatedCurrent, currentLimit)
            
            Log.debug("第6行20V - 电流: \(newValue), 估算电流: \(estimatedCurrent), 最大电流: \(maxCurrent)")
            
            return newValue <= maxCurrent
        }
        
        return true
    }
        
    //MARK: -
    
    private func clamp(value: Double, min: Double, max: Double) -> Double {
        return Swift.max(min, Swift.min(value, max))
    }

    // 检查所有单元格的编辑状态
    private func checkAllEditingState() {
        var foundEditingCell = false
        
        // 通过父视图查找所有同类型单元格
        if let parentVC = self.parentViewController as? CustomPickViewVC,
           let row = parentVC.container.presetPageV.selectedRowV,
           let pDOsublist = parentVC.container.presetPageV.presetRowToSublistMap[row] {
            
            for cell in pDOsublist {
                if cell.isEditing {
                    foundEditingCell = true
                    PresetSublistCell.currentEditingCell = cell
                    break
                }
            }
        }
        
        PresetSublistCell.isAnyCellEditing = foundEditingCell
        isEditingText = foundEditingCell
        
        if !foundEditingCell {
            PresetSublistCell.currentEditingCell = nil
        }
        
    }
  
    private func showAlert(message: String) {
        
        if let parentVC = self.parentViewController as? CustomPickViewVC {
            let alert = UIAlertController(title: NSLocalizedString("提示", comment: "提示"), message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("确定", comment: "确定"), style: .default))
            parentVC.present(alert, animated: true)
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
 
}


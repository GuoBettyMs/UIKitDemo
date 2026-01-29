//
//  PresetListCell.swift
//  SwiftTest
//
//  Created by user on 2026/1/23.
//


import UIKit
import SnapKit
import RxSwift
import RxCocoa

class PresetListCell: UIView{
    
    let titleTextField = UITextField()
    let indexL = UILabel()
    let valueL = UILabel()

    var dataModel: ProgramFileModel?//绑定数据模型
    var valueTapHandler: (() -> Void)? //轻触手势回调闭包
    
    var hasBeenEdited = false {// 标记是否被编辑过,跳转到其他页面(非预设值页面)会自动恢复默认值
        didSet {
            // 当编辑状态改变时通知外部
            if hasBeenEdited != oldValue {
                NotificationCenter.default.post(
                    name: .presetlistCellEditStateChanged,
                    object: self,
                    userInfo: ["cell": self, "titleedit": hasBeenEdited]
                )
            }
        }
    }
    private var originalValues: [UITextField: NSAttributedString] = [:] //保留文本框旧值

    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI1()

    }
    
    override var intrinsicContentSize: CGSize {
        let height: CGFloat = 40
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        valueTapHandler = nil
        Log.debug("PresetListCell deinit")
    }
    
    private func setupUI1() {
        
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = true // Enable interaction for tap & pan
        
        // Add tap gesture for row click
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleRowTap))
        addGestureRecognizer(tapGesture)
        

        // indexL
        addSubview(indexL)
        indexL.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
        }
        indexL.textColor = .white
        indexL.attributedText = bahnschrift_formatted("1")

        // valueL
        addSubview(valueL)
        valueL.snp.makeConstraints { make in
            make.width.equalTo(50)
            make.height.equalTo(44)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-25)
        }
        valueL.textColor = UIColor(named: "DP_999999")
        valueL.attributedText = bahnschrift_formatted("--W")
        
        let valueTap = UITapGestureRecognizer(target: self, action: #selector(handleValueLTap))
        valueL.addGestureRecognizer(valueTap)
        valueL.isUserInteractionEnabled = true
        
        
        // titleTextField
        addSubview(titleTextField)
        titleTextField.snp.makeConstraints { make in
            make.height.equalTo(25)
            make.centerY.equalToSuperview()
            make.left.equalTo(indexL.snp.centerX).offset(24)
        }
        titleTextField.backgroundColor = .clear
        titleTextField.textColor = .white
        titleTextField.attributedText = bahnschrift_formatted("text", alignment: .center)
        titleTextField.returnKeyType = .done
        titleTextField.delegate = self
        titleTextField.isUserInteractionEnabled = false
        titleTextField.layer.cornerRadius = 5
        originalValues[titleTextField] = titleTextField.attributedText
        
        // titleTextField 增加左边距
       let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: titleTextField.frame.height))
       titleTextField.leftView = leftPaddingView
       titleTextField.leftViewMode = .always

    }
    
    // MARK: - Public Methods
    
    func setIndex(_ index: Int) {
        indexL.attributedText = bahnschrift_formatted("\(index)")
    }
    
    func setValue(_ power: Int){
        valueL.attributedText = bahnschrift_formatted("\(power)W", alignment: .right)
//        Log.debug("setValue: \(power) ")
    }
    
    ///根据功率值值获取行
    func getRow(from value: Int) -> Int {
        switch value{
        case 12: return 0
        case 18: return 1
        case 20: return 2
        case 30: return 3
        case 36: return 4
        case 45: return 5
        case 60: return 6
        case 65: return 7
        case 100: return 8
        case 140: return 9
        default: return 0
        }
    }
    
    // MARK: - Event
    
    @objc private func handleValueLTap() {
        valueTapHandler?()
    }
    
    @objc func handleRowTap() {
        // This will be observed externally via Rx or delegate
        // No logic here — just a signal
//        Log.debug("handleRowTap ")
    }
    
    // MARK: - Helper Methods
    
    func changeTitleTextFieldUI(isEnable: Bool){
        
        titleTextField.backgroundColor = isEnable ? .white : .clear
        titleTextField.textColor = isEnable ? .black : .white
        titleTextField.snp.remakeConstraints { make in
            if isEnable{
                make.width.equalTo(200)
            }
            make.height.equalTo(25)
            make.centerY.equalToSuperview()
            make.left.equalTo(indexL.snp.centerX).offset(24)
        }
    }
    
    func setTitle(_ text: String){
        titleTextField.attributedText = bahnschrift_formatted(text, 20, weight: .regular, alignment: .left, baseline: -1)
        
    }
    
}
// MARK: - RxSwift Support (Optional but useful)
extension Reactive where Base: PresetListCell {
    var rowTap: ControlEvent<Void> {
        let source = base.rx
            .sentMessage(#selector(PresetListCell.handleRowTap))
            .map { _ in }
        return ControlEvent(events: source)
    }
}
extension PresetListCell: UITextFieldDelegate{
    
    // UITextFieldDelegate 方法
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder() // 点击键盘上的返回键收起
        changeTitleTextFieldUI(isEnable: false)
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        // 如果有其他单元格左滑，先恢复它
        if let currentCell = ProgrammablePagelistCell.currentlySwipedCell,
           currentCell != self {
            currentCell.resetSwipe()
//            Log.debug("有其他单元格左滑，先恢复它")
        }
        
        changeTitleTextFieldUI(isEnable: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {

        //去除字符串开头和结尾的空白字符（包括空格、制表符、换行符等）
        let currentText = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "-"
        let attributedString = NSAttributedString(string: currentText)
        let originalText = originalValues[textField]
        
        // 结束编辑时的处理
        changeTitleTextFieldUI(isEnable: false)
        
        if attributedString != originalText {
            if !hasBeenEdited{
                hasBeenEdited = true
            }
            
            setTitle(currentText)
        }

    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // 1. 获取当前文本
        let currentText = textField.text ?? ""
        
        // 2. 计算替换后的完整文本
        guard let textRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: textRange, with: string)
        
        // 3. 检查是否超过 16 字节（UTF-8 编码）
        let byteCount = updatedText.utf8.count
        if byteCount > 16 {
            showToast(NSLocalizedString("长度过长,最多支持16字节", comment: "长度过长,最多支持16字节"))
            return false
        }
        
        // 4. 允许删除
        if string.isEmpty { return true }
        
        // 5. 禁止中文（可选，根据你的需求保留）
        if containsChinese(string) {
            showToast(NSLocalizedString("不支持中文输入", comment: "不支持中文输入"))
            return false
        }

        // 6. 只允许 ASCII 可打印字符（注意：这会排除中文、emoji 等）
        let allowed = CharacterSet.asciiPrintable
        let characterSet = CharacterSet(charactersIn: string)
        if !allowed.isSuperset(of: characterSet) {
            showToast(NSLocalizedString("只支持英文、数字和常用符号", comment: "只支持英文、数字和常用符号"))
            return false
        }
        
        return true
        
    }
    
    private func containsChinese(_ text: String) -> Bool {
        // 简单高效的中文检查
        for scalar in text.unicodeScalars {
            let value = scalar.value
            if (value >= 0x4E00 && value <= 0x9FFF) ||  // 基本汉字
               (value >= 0x3400 && value <= 0x4DBF) {   // 扩展A
                return true
            }
        }
        return false
    }
        
    private func showToast(_ message: String) {
        // 简单的提示
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            alert.dismiss(animated: true)
        }
        parentViewController?.present(alert, animated: true)
    }
}

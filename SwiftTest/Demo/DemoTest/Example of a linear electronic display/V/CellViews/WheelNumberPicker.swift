//
//  WheelNumberPicker.swift
//  SwiftTest
//
//  Created by user on 2026/1/15.
//
// 4滚轮数字选择器，支持多格式的自定义数值

import UIKit
import SnapKit
import AudioToolbox

protocol WheelNumberPickerDelegate: AnyObject {
    
    //传递整体值
    func wheelNumberPicker(_ picker: WheelNumberPicker, didSelectValue value: Double)
    
    //传递单独的值
//    func wheelSingleNumberPicker(_ picker: WheelNumberPicker, didSelectPickerIndex pickerI:Int, didSelectValue value: Int)
    func wheelSingleNumberPicker(_ picker: WheelNumberPicker,
                                   didSelectPickerIndex pickerI: Int,
                                   didSelectValue value: Int,
                                   isRealTime: Bool)
}

class WheelNumberPicker: UIView {
    
    private var lastActualValue: Int = -1 //pickview 上一次实际值
    
    //频率限制
    private var lastRealTimeUpdate: [Int: Date] = [:] //上一个实时回调时长
    private let updateInterval: TimeInterval = 0.05 // 50ms, pivckiew 实时回调时长

    weak var delegate: WheelNumberPickerDelegate?
    var pickerViews: [UIPickerView] = []
    
//    private var scrollDirections: [Int: ScrollDirection] = [:]
    
    // MARK: - 动态属性
    private var componentCount: Int = 4 // 默认4个滚轮
    private var leftComponentCount: Int = 2 // 左边滚轮数量
    private var rightComponentCount: Int = 2 // 右边滚轮数量
    
    private let scrollMultiplier = 2000
    
    var maxValue: Double = 30.50 {
        didSet {
            // 根据最大值重新计算布局
            updateLayoutForMaxValue()
        }
    }
    
    var currentValue: Double = 0.0 {
        didSet {
            updatePickerValues()
        }
    }
    
    var minValue: Double = 0.0
    
    let leftPickVBg = UIStackView()
    let rightPickVBg = UIStackView()
    
    private let containerView = UIView()
    let separatorLabel = UILabel()
    
    // MARK: - 初始化
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if #available(iOS 13.0, *) {
            UIPickerView.appearance().backgroundColor = .clear
            UIPickerView.appearance().tintColor = .clear // ⚠️ 可能无效
        }
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - 根据最大值更新布局
    
    private func updateLayoutForMaxValue() {
        
        // 1. 确定需要多少个组件
        var newComponentCount = 4
        var newLeftCount = 2
        var newRightCount = 2
        var newTag = 0

        if maxValue >= 10.0 {
            newTag = 0
            newComponentCount = 4
            newLeftCount = 2
            newRightCount = 2
        } else if maxValue >= 1.0 {
            newTag = 1
            newComponentCount = 4
            newLeftCount = 1
            newRightCount = 3
        } else {
            newTag = 2
            newComponentCount = 2
            newLeftCount = 1
            newRightCount = 1
        }

        self.tag = newTag
        componentCount = newComponentCount
        leftComponentCount = newLeftCount
        rightComponentCount = newRightCount

        // 2. 确保有足够多的 pickerView（懒创建）
        while pickerViews.count < newComponentCount {
            let pickerView = createPickerView()
            pickerView.tag = pickerViews.count
            pickerViews.append(pickerView)
            containerView.addSubview(pickerView) // 先加入 container，稍后分配到 stack
        }

        // 清空 stack views（仅解除 arranged 关系，不销毁 pickerView）
        leftPickVBg.arrangedSubviews.forEach { view in
            leftPickVBg.removeArrangedSubview(view)
            view.isHidden = true
        }
        rightPickVBg.arrangedSubviews.forEach { view in
            rightPickVBg.removeArrangedSubview(view)
            view.isHidden = true
        }

        // 4. 重新分配 pickerView 到左右 stack
        for i in 0..<newComponentCount {
            let pickerView = pickerViews[i]
            pickerView.isHidden = false
            if i < newLeftCount {
                leftPickVBg.addArrangedSubview(pickerView)
            } else {
                rightPickVBg.addArrangedSubview(pickerView)
            }
        }

        // 5. 隐藏多余的 pickerView
        for i in newComponentCount..<pickerViews.count {
            pickerViews[i].isHidden = true
        }

        // 6. 更新约束
        updateConstraintsForNewLayout()

        // 7. 重新计算并设置当前值（会触发 selectRow）
        updatePickerValues()
        
    }
    
    // MARK: - 更新布局约束
    
    private func updateConstraintsForNewLayout() {
        // 移除旧的约束
        separatorLabel.snp.remakeConstraints { make in
            make.width.equalTo(10)
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        leftPickVBg.snp.remakeConstraints { make in
            make.left.equalToSuperview()
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        rightPickVBg.snp.remakeConstraints { make in
            make.right.equalToSuperview()
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        // 分隔符放在左右stackView之间
        separatorLabel.snp.makeConstraints { make in
            make.left.equalTo(leftPickVBg.snp.right)
            make.right.equalTo(rightPickVBg.snp.left)
        }
        
        // 设置stackView的distribution
        leftPickVBg.distribution = .fillEqually
        rightPickVBg.distribution = .fillEqually
        
        // 设置spacing
        leftPickVBg.spacing = 5
        rightPickVBg.spacing = 5
        
        // 根据左右组件数量调整宽度
        let totalComponents = CGFloat(componentCount)
        
        if leftComponentCount > 0 && rightComponentCount > 0 {
            // 左右都有组件，分隔符居中
            leftPickVBg.snp.makeConstraints { make in
                make.width.equalToSuperview().multipliedBy(CGFloat(leftComponentCount) / totalComponents).offset(-5)
            }
        } else if leftComponentCount > 0 {
            // 只有左边有组件
            separatorLabel.isHidden = true
            leftPickVBg.snp.makeConstraints { make in
                make.right.equalToSuperview()
            }
        } else {
            // 只有右边有组件
            separatorLabel.isHidden = true
            rightPickVBg.snp.makeConstraints { make in
                make.left.equalToSuperview()
            }
        }
    }
    
    // MARK: - 设置UI
    
    private func setupUI() {
        backgroundColor = .clear
        
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.addSubview(separatorLabel)
        separatorLabel.attributedText = bahnschrift_formatted(".")
        separatorLabel.textAlignment = .center
//        separatorLabel.textColor = .white
        separatorLabel.textColor = .white.withAlphaComponent(0.8)

        containerView.addSubview(leftPickVBg)
        leftPickVBg.axis = .horizontal
        leftPickVBg.distribution = .fillEqually
        leftPickVBg.spacing = 5
        

        containerView.addSubview(rightPickVBg)
        rightPickVBg.axis = .horizontal
        rightPickVBg.distribution = .fillEqually
        rightPickVBg.spacing = 5
        
        // 初始根据maxValue设置布局
        updateLayoutForMaxValue()
    }
    
    private func createPickerView() -> UIPickerView {

        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = .clear
        
        // 添加平移手势识别器来拦截拖拽结束
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePickerPan(_:)))
        panGesture.delegate = self // 需要 conform to UIGestureRecognizerDelegate
        pickerView.addGestureRecognizer(panGesture)

        // 清除所有内部视图的背景色
        pickerView.subviews.forEach { subview in
            subview.backgroundColor = .clear
            subview.subviews.forEach { $0.backgroundColor = .clear }
        }
        
        // 延迟清除背景,以确保内部视图已加载
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.removePickerViewBackground(pickerView)
        }
        
        return pickerView
    }
    
    //UIPickerView 实时回调监控（频率限制）
    private func canSendRealTimeUpdate(for tag: Int) -> Bool {
        let now = Date()
        if let lastTime = lastRealTimeUpdate[tag] {
            if now.timeIntervalSince(lastTime) < updateInterval {
                return false
            }
        }
        lastRealTimeUpdate[tag] = now
        return true
    }

    //滚动中的震动 - 使用 UISelectionFeedbackGenerator（轻量）
    private func triggerSelectionVibration() {
        if #available(iOS 10.0, *) {
            // 滚动时每变化一格震动一次
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        } else {
            AudioServicesPlaySystemSound(1519)
        }
    }
        
    // 停止时的震动 - 使用 UIImpactFeedbackGenerator(.medium)
    private func triggerImpactVibration() {
        if #available(iOS 10.0, *) {
            // 用户松手时的确认反馈
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        } else {
            AudioServicesPlaySystemSound(1520)
        }
    }
    
    @objc private func handlePickerPan(_ gesture: UIPanGestureRecognizer) {
        guard let pickerView = gesture.view as? UIPickerView else { return }
        
        // 实时获取当前值
        let component = 0
        let currentRow = pickerView.selectedRow(inComponent: component)
        let actualRow = calculateActualRow(from: currentRow, forPickerTag: pickerView.tag)
        
//        AudioServicesPlaySystemSound(SystemSoundID(1519))
        
        switch gesture.state{
        case .changed:
            // 值变化时震动
            if actualRow != lastActualValue {
                triggerSelectionVibration()
                lastActualValue = actualRow
            }
            
            // 实时回调（频率限制）
            if canSendRealTimeUpdate(for: pickerView.tag) {
                delegate?.wheelSingleNumberPicker(self,
                                                didSelectPickerIndex: pickerView.tag,
                                                didSelectValue: actualRow,
                                                isRealTime: true)
            }
        case .ended, .cancelled:
            // 停止时确认震动
            triggerImpactVibration()
            lastActualValue = -1 // 重置
            
            // 获取当前最接近中心的 row（即用户松手时视觉上最居中的行）
            pickerView.selectRow(currentRow, inComponent: component, animated: false)
            // 通知代理,传递单独的值
            delegate?.wheelSingleNumberPicker(self,
                                                    didSelectPickerIndex: pickerView.tag,
                                                    didSelectValue: actualRow,
                                                    isRealTime: false)
    
//            // 更新其他picker的可用选项
//            if pickerView.tag == 0{
//                updateDependentPickers(after: pickerView.tag)
//            }else{
//            }
            
            // 计算当前值
            calculateCurrentValue()
        default:
            break
        }
        
    }
    
    // 递归查找并移除所有不需要的背景色
    private func removePickerViewBackground(_ pickerView: UIPickerView) {

        func recursiveClearBackground(view: UIView) {
            view.backgroundColor = .clear
            view.subviews.forEach { recursiveClearBackground(view: $0) }
        }
        
        pickerView.subviews.forEach { recursiveClearBackground(view: $0) }
        
        // 特殊处理：iOS 14+ 的 UIPickerView 结构
        if #available(iOS 14.0, *) {
            for subview in pickerView.subviews {
                // 移除UIPickerColumnView的背景
                if let columnView = subview as? UICollectionView {
                    columnView.backgroundColor = .clear
                }
                
                // 移除UITableView的背景
                if let tableView = subview as? UITableView {
                    tableView.backgroundColor = .clear
                    tableView.separatorStyle = .none
                }
            }
        }
    }
    
    // MARK: - 数据源和代理需要根据布局调整
    
    private func getPickerPosition(for tag: Int) -> (position: String, indexInPosition: Int) {
        // 根据tag返回picker的位置信息
        if tag < leftComponentCount {
            // 左边的picker
            return ("left", tag)
        } else {
            // 右边的picker
            return ("right", tag - leftComponentCount)
        }
    }
    
    // 根据maxValue和picker位置确定实际含义
    private func getPickerMeaning(for tag: Int) -> String {
        if maxValue >= 10.0 {
            // 4位数布局
            switch tag {
            case 0: return "tens"       // 十位
            case 1: return "ones"       // 个位
            case 2: return "tenths"     // 十分位
            case 3: return "hundredths" // 百分位
            default: return "unknown"
            }
        } else if maxValue >= 1.0 {
            // 4位数布局
            switch tag {
            case 0: return "ones"       // 个位
            case 1: return "tenths"     // 十分位
            case 2: return "hundredths" // 百分位
            case 3: return "thousandths"// 千分位
            default: return "unknown"
            }
        } else {
            // 2位数布局
            switch tag {
            case 0: return "tenths"     // 十分位
            case 1: return "hundredths" // 百分位
            default: return "unknown"
            }
        }
    }
    
    // MARK: - 更新值显示
    
    private func updatePickerValues() {
        let value = max(minValue, min(currentValue, maxValue))
//        Log.debug("updatePickerValues, min(\(currentValue), \(maxValue)) = \(value)")
        
        // 根据maxValue确定小数位数
        var decimalPlaces = 2 // 默认2位小数
        
        if maxValue >= 10.0 {
            decimalPlaces = 2 // 30.50模式：2位小数
        } else if maxValue >= 1.0 {
            decimalPlaces = 3 // 5.100模式：3位小数
        } else {
            decimalPlaces = 2 // 小于1.0：2位小数
        }
        
        // 将值转换为整数（根据小数位数乘以不同的倍数）
        let multiplier = Int(pow(10.0, Double(decimalPlaces)))
        let intValue = Int(value * Double(multiplier) + 0.5)
        
//        Log.debug("decimalPlaces: \(decimalPlaces), multiplier: \(multiplier), intValue: \(intValue)")
        
        // 根据不同的布局提取各位数字
        var digitValues: [Int] = []
        
        if maxValue >= 10.0 {
            // 4位数：十位、个位、十分位、百分位
            // 模式：XX.XX (2位整数 + 2位小数)
            let total = intValue // 已经乘以100
            
            // 提取百分位
            let hundredths = total % 10
            // 提取十分位
            let temp1 = total / 10
            let tenths = temp1 % 10
            // 提取个位
            let temp2 = temp1 / 10
            let ones = temp2 % 10
            // 提取十位
            let tens = temp2 / 10
            
            digitValues = [tens, ones, tenths, hundredths]
            
//            Log.debug("30.50模式: tens=\(tens), ones=\(ones), tenths=\(tenths), hundredths=\(hundredths)")
            
        } else if maxValue >= 1.0 {
            // 4位数：个位、十分位、百分位、千分位
            // 模式：X.XXX (1位整数 + 3位小数)
            let total = intValue // 已经乘以1000
            
            // 提取千分位
            let thousandths = total % 10
            // 提取百分位
            let temp1 = total / 10
            let hundredths = temp1 % 10
            // 提取十分位
            let temp2 = temp1 / 10
            let tenths = temp2 % 10
            // 提取个位
            let ones = temp2 / 10
            
            digitValues = [ones, tenths, hundredths, thousandths]
            
//            Log.debug("5.100模式: ones=\(ones), tenths=\(tenths), hundredths=\(hundredths), thousandths=\(thousandths)")
            
        } else {
            // 2位数：十分位、百分位
            // 模式：0.XX (0位整数 + 2位小数)
            let total = intValue // 已经乘以100
            
            // 提取百分位
            let hundredths = total % 10
            // 提取十分位
            let tenths = total / 10
            
            digitValues = [tenths, hundredths]
            
//            Log.debug("0.XX模式: tenths=\(tenths), hundredths=\(hundredths)")
        }
        
        // 设置各个picker的值
        DispatchQueue.main.async {
            for (index, digit) in digitValues.enumerated() {
                if index < self.pickerViews.count {
                    let pickerView = self.pickerViews[index]
                    
                    // 确保 pickerView 已布局（frame 不为零）
                    guard pickerView.window != nil && !pickerView.frame.isEmpty else {
                        // 如果还没显示，稍后再试（可选：用 CADisplayLink 或观察 window）
                        return
                    }
                    
                    let scrollRow = self.calculateScrollRow(from: digit, forPickerTag: index)
                    pickerView.selectRow(scrollRow, inComponent: 0, animated: false)
                }
            }
        }
        
//        DispatchQueue.main.async {
//            for (index, digit) in digitValues.enumerated() {
//                if index < self.pickerViews.count {
//                    let pickerView = self.pickerViews[index]
//                    let scrollRow = self.calculateScrollRow(from: digit, forPickerTag: index)
//
////                    Log.debug("设置picker[\(index)]: digit=\(digit), scrollRow=\(scrollRow)")
//
//                    pickerView.selectRow(scrollRow, inComponent: 0, animated: false)
//                    pickerView.reloadAllComponents()//不要调用 reloadAllComponents() —— 它会强制重绘所有行，是“闪”的常见原因
//                }
//            }
//        }
        
    }
    
    /// 从循环滚动的行数计算实际显示的行数值
    private func calculateActualRow(from row: Int, forPickerTag tag: Int) -> Int {
        
        let count = getMaxDigitsForPicker(at: tag).count//getNumberOfRowsForTag(tag)
        return count > 0 ? (max(0, row) % count) : 0
    }
    
    /// 从实际值计算循环滚动中的位置
    func calculateScrollRow(from actualRow: Int, forPickerTag tag: Int) -> Int {
        let count = getMaxDigitsForPicker(at: tag).count//getNumberOfRowsForTag(tag)
        guard count >= 1 else { return 0 }
        let middleSection = scrollMultiplier / 2
        return middleSection * count + actualRow
        
    }
    
//    func formattedText(_ text: String, headIndent: CGFloat = 0.0) -> NSMutableAttributedString{
//
//        return formattedText1(text, isSelected: false)
//
//    }
    
//    func formattedText1(_ text: String, isSelected: Bool = false) -> NSMutableAttributedString {
//        let descriptor = UIFontDescriptor(
//                    fontAttributes: [
//                        .name: kBahnschrift,
//                        .traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.regular]
//                    ]
//                )
//                let numFont = UIFont(descriptor: descriptor, size: 48)
//                let attributedString = NSMutableAttributedString(string: text)
//                let paragraphStyle = NSMutableParagraphStyle()
//                paragraphStyle.lineSpacing = 41.0
//                paragraphStyle.alignment = .center
////                paragraphStyle.firstLineHeadIndent = 0.0 //设置首行缩进，向右偏移
//        
//                let color: UIColor = .white
//        
//                attributedString.addAttributes([
//                    .font: numFont,
//                    .paragraphStyle: paragraphStyle,
//                    .baselineOffset: -2,
//                    .foregroundColor: color // 设置前景色
//                ], range: NSRange(location: 0, length: text.count))
//                
//                return attributedString
//
//    }

    // MARK: - 公共方法
    
    func setValue(_ value: Double, animated: Bool = false) {
        currentValue = max(minValue, min(value, maxValue))
    }
    
    func getValue() -> Double {
        return currentValue
    }
    
//    // 设置最大值并更新布局
//    func setMaxValue(_ maxValue: Double, animated: Bool = false) {
//        self.maxValue = maxValue
//        // updateLayoutForMaxValue() 已经在 didSet 中调用
//    }
}

// MARK: - UIGestureRecognizerDelegate

extension WheelNumberPicker: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true // 允许与 UIPickerView 内部手势共存
    }
}

// MARK: - UIPickerView 数据源和代理
extension WheelNumberPicker: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // 每个picker只有一个component
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let tag = pickerView.tag
        _ = getPickerMeaning(for: tag)
        let maxDigits = getMaxDigitsForPicker(at: tag)
        
        // 计算实际行数
        let rowCount = maxDigits.count
        
        return rowCount * scrollMultiplier
    }
    
    private func getMaxDigitsForPicker(at tag: Int) -> [Int] {
        
        let meaning = getPickerMeaning(for: tag)
        
        switch meaning {
        case "tens":
            // 十位：0-3（最大30.5）
            return [0, 1, 2, 3]
            
        case "ones":
            // 个位：根据十位决定
            if maxValue >= 10.0 {
//                // 4位数布局
//                let tensPicker = pickerViews.first(where: { getPickerMeaning(for: $0.tag) == "tens" })
//                let tensValue = getActualValue(for: tensPicker)
//
//                if tensValue == 3 {
//                    return [0] // 十位为3时，个位只能为0
//                }
                return Array(0...9)
            } else if maxValue >= 1.0 {
                // 4位数布局：个位直接受maxValue限制
                let maxOnes = Int(floor(maxValue))
                return Array(0...maxOnes)
            } else {
                return [0] // 2位数布局没有个位
            }
            
        case "tenths":
            // 十分位,如果整数部分是30，小数位递增只能0-5, 但是递减允许0-9;如果整数部分是5，小数位递增只能0-1, 但是递减允许0-9
            return Array(0...9)
            
        case "hundredths":
            return Array(0...9)
            
        case "thousandths":
            return Array(0...9)
            
        default:
            return [0]
        }
    }
    
    private func getActualValue(for pickerView: UIPickerView?) -> Int {
        guard let pickerView = pickerView else { return 0 }
        let scrollRow = pickerView.selectedRow(inComponent: 0)
        return calculateActualRow(from: scrollRow, forPickerTag: pickerView.tag)
    }
    
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {

        let containerView: UIView
        let label: UILabel
          
        if let reused = view, let existingLabel = reused.subviews.first as? UILabel {
              containerView = reused
              label = existingLabel
          } else {
              containerView = UIView()
              
              label = UILabel()
              label.textAlignment = .center
              label.backgroundColor = .clear
              label.translatesAutoresizingMaskIntoConstraints = false
              containerView.addSubview(label)
              NSLayoutConstraint.activate([
                  label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                  label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
              ])
          }

          let actualRow = calculateActualRow(from: row, forPickerTag: pickerView.tag)
          let selectedRow = pickerView.selectedRow(inComponent: component)
          let actualSelectedRow = calculateActualRow(from: selectedRow, forPickerTag: pickerView.tag)
          let isSelected = (actualRow == actualSelectedRow)
          
          let text = "\(actualRow)"
          let displayText = text == "1" ? "\u{200A}\(text)\u{200A}" : text
          
        label.attributedText = bahnschrift_formatted(displayText, 48)
          return containerView

    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 38
    }
    
//    //UIPickerView 内部的 component 宽度不受外部约束影响,由 UIPickerViewDelegate 的方法决定的,如果 component 宽度没设置，系统会使用默认宽度
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 48
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let tag = pickerView.tag
        let actualRow = calculateActualRow(from: row, forPickerTag: tag)
  
//        // 更新其他picker的可用选项
//        if pickerView.tag == 0{
//            updateDependentPickers(after: pickerView.tag)
//        }else{
//
//        }

        // 计算当前值
        calculateCurrentValue()
        
        // 通知代理,传递单独的值
        delegate?.wheelSingleNumberPicker(self, didSelectPickerIndex: tag, didSelectValue: actualRow, isRealTime: true)
        
    }
    
    
    private func calculateCurrentValue() {
      
        var digitValues: [Int] = []
        
        for i in 0..<pickerViews.count {
            let pickerView = pickerViews[i]
            let scrollRow = pickerView.selectedRow(inComponent: 0)
            let actualValue = calculateActualRow(from: scrollRow, forPickerTag: i)
            digitValues.append(actualValue)
        }
        
       
        if self.tag == 0 {
            // 30.50模式：tens, ones, tenths, hundredths
            let tens = digitValues.count > 0 ? digitValues[0] : 0
            let ones = digitValues.count > 1 ? digitValues[1] : 0
            let tenths = digitValues.count > 2 ? digitValues[2] : 0
            let hundredths = digitValues.count > 3 ? digitValues[3] : 0
            
            let intValue = tens * 10 + ones
            let decimalValue = Double(tenths) / 10.0 + Double(hundredths) / 100.0
            currentValue = Double(intValue) + decimalValue
            
        } else if self.tag == 1 {
            // 5.100模式：ones, tenths, hundredths, thousandths
            let ones = digitValues.count > 0 ? digitValues[0] : 0
            let tenths = digitValues.count > 1 ? digitValues[1] : 0
            let hundredths = digitValues.count > 2 ? digitValues[2] : 0
            let thousandths = digitValues.count > 3 ? digitValues[3] : 0
            
            let decimalValue = Double(tenths) / 10.0 + Double(hundredths) / 100.0 + Double(thousandths) / 1000.0
            currentValue = Double(ones) + decimalValue
            
        } else {
            // 0.XX模式：tenths, hundredths
            let tenths = digitValues.count > 0 ? digitValues[0] : 0
            let hundredths = digitValues.count > 1 ? digitValues[1] : 0
            
            currentValue = Double(tenths) / 10.0 + Double(hundredths) / 100.0
        }
        
        delegate?.wheelNumberPicker(self, didSelectValue: currentValue)
        
    }
    
//    // 更新其他picker的可用选项
//    private func updateDependentPickers(after changedTag: Int) {
//
//        // 1. 获取当前实际值
//        var tens = calculateActualRow(from: pickerViews[0].selectedRow(inComponent: 0), forPickerTag: 0)
//        var ones = calculateActualRow(from: pickerViews[1].selectedRow(inComponent: 0), forPickerTag: 1)
//        var tenths = calculateActualRow(from: pickerViews[2].selectedRow(inComponent: 0), forPickerTag: 2)
//        var hundredths = calculateActualRow(from: pickerViews[3].selectedRow(inComponent: 0), forPickerTag: 3)
//
//        // 2. 如果十位是3，个位必须为0
//        if tens == 3 && ones != 0 {
//            ones = 0
//            pickerViews[1].selectRow(calculateScrollRow(from: ones, forPickerTag: 1), inComponent: 0, animated: true)
//        }
//
//        // 3. 限制十分位
//        let maxTenths = (tens == 3 && ones == 0) ? 5 : 9
//        if tenths > maxTenths {
//            tenths = maxTenths
//            pickerViews[2].selectRow(calculateScrollRow(from: tenths, forPickerTag: 2), inComponent: 0, animated: true)
//        }
//
//        // 4. 限制百分位
//        let maxHundredths = (tens == 3 && ones == 0 && tenths == 5) ? 0 : 9
//        if hundredths > maxHundredths {
//            hundredths = maxHundredths
//            pickerViews[3].selectRow(calculateScrollRow(from: hundredths, forPickerTag: 3), inComponent: 0, animated: true)
//        }
//
//        // 5. 重载受影响的 pickers（即使没变，也可能因 count 变化需要刷新 UI）
//        if changedTag <= 1 { // 十位或个位变了
//            pickerViews[2].reloadAllComponents()
//            pickerViews[3].reloadAllComponents()
//        } else if changedTag == 2 { // 十分位变了
//            pickerViews[3].reloadAllComponents()
//        }
//
//    }
}

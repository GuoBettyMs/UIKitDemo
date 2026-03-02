//
//  ProgrammablePageV.swift
//  SwiftTest
//
//  Created by user on 2026/1/19.
//
// 标题可编辑,列表行可左滑,列表内容项可编辑,底部控制块可点击,当列表行为空时自动显示新增按钮

import UIKit
import SnapKit

//通过 delegate 回调操作 vc.initialPresetListDatas,避免视图层直接修改数据
protocol ProgrammablePageVDelegate: AnyObject {
    func programmablePageV(_ view: ProgrammablePageV, didInsertItem data: ProgramDataModel, at position: Int)
    func programmablePageV(_ view: ProgrammablePageV, didDeleteItemAt position: Int)
}

class ProgrammablePageV: BaseV{
    
    enum ScrollPosition {
        case top, middle, bottom
    }
    
    weak var programmablePageVDelegate: ProgrammablePageVDelegate?
    var programmablePageRows: [ProgrammablePagelistCell] = []
    var programControlBtns: [UIButton] = []
    private let rowStackView = UIStackView()
    private let emptyAddButton = UIButton(type: .system)
    private let btnImgs = ["DP_ProgrammablePrevious", "DP_ProgrammablePlay", "DP_ProgrammableNext"]
    
    let titleTextField = UITextField()
    private let hintL = UILabel()
    private let titleRow = ProgrammablePagelistCell()
    private var originalValues: [UITextField: NSAttributedString] = [:] //存储文本框旧值

    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        additionalSetup1()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func additionalSetup1(){

        addSubview(hintL)
        hintL.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview()
        }
        hintL.textColor = .white
        hintL.numberOfLines = 0
        hintL.lineBreakMode = .byWordWrapping
        hintL.text = "标题可编辑,列表行可左滑,列表内容项可编辑,底部控制块可点击,当列表行为空时自动显示新增按钮"
        
        addSubview(titleTextField)
        titleTextField.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.top.equalTo(hintL.snp.bottom)
            make.left.equalToSuperview().offset(16)
        }
        titleTextField.backgroundColor = .clear
        titleTextField.textColor = .white
        titleTextField.attributedText = bahnschrift_formatted("List title", 20, weight: .regular, alignment: .left, baseline: -1)
        titleTextField.returnKeyType = .done
        titleTextField.delegate = self
        titleTextField.layer.cornerRadius = 5
        originalValues[titleTextField] = titleTextField.attributedText

        
        // titleTextField 增加左边距
       let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: titleTextField.frame.height))
       titleTextField.leftView = leftPaddingView
       titleTextField.leftViewMode = .always
        
        let programControlstackV = UIStackView()
        programControlstackV.translatesAutoresizingMaskIntoConstraints = false
        addSubview(programControlstackV)
        programControlstackV.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(40)
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        programControlstackV.axis = .horizontal
        programControlstackV.distribution = .fillEqually
        programControlstackV.spacing = 5
       
        for btnI in 0...2{
            let btn = UIButton()
            programControlstackV.addArrangedSubview(btn)
            if #available(iOS 13.0, *) {
                btn.setImage(UIImage(named: btnImgs[btnI])?.withTintColor(UIColor(named: "DP_999999")!), for: .normal)
            } else {
                btn.setImage(UIImage(named: btnImgs[btnI]), for: .normal)
            }
            if btnI == 1{
                if #available(iOS 13.0, *) {
                    btn.setImage(UIImage(named: "DP_ProgrammablePlay")?.withTintColor(UIColor(named: "DP_999999")!), for: .normal)
                } else {
                    btn.setImage(UIImage(named: "DP_ProgrammablePlay"), for: .normal)
                }
            }
            btn.backgroundColor = UIColor(named: "DP_262626")
            programControlBtns.append(btn)
        }
        
        titleRow.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleRow)
        titleRow.snp.makeConstraints { make in
            make.width.equalToSuperview()//351
            make.height.equalTo(28)
            make.top.equalTo(titleTextField.snp.bottom)
            make.centerX.equalToSuperview()
        }
        titleRow.backgroundColor = UIColor(named: "DP_404040ff")
        titleRow.labels[0].textColor = .black
        titleRow.textFields[0].textColor = .black
        titleRow.textFields[1].textColor = titleRow.textFields[0].textColor
        titleRow.textFields[2].textColor = titleRow.textFields[0].textColor
        titleRow.isUserInteractionEnabled = false

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.snp.remakeConstraints { make in
            make.top.equalTo(titleRow.snp.bottom).offset(1)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(programControlstackV.snp.top).offset(-5)
        }
        scrollView.showsVerticalScrollIndicator = false

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.snp.remakeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView.snp.width) // 显式绑定宽度，防止歧义
        }

        // 添加 stackView 到 contentView
        contentView.addSubview(rowStackView)
        rowStackView.axis = .vertical
        rowStackView.spacing = 1 // 行间距 = 1
        rowStackView.distribution = .fill
        rowStackView.alignment = .fill
        rowStackView.translatesAutoresizingMaskIntoConstraints = false

        rowStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        
        contentView.addSubview(emptyAddButton)
        emptyAddButton.setTitle("＋ 添加第一行", for: .normal)
        emptyAddButton.setTitleColor(UIColor(named: "DP_999999"), for: .normal)
        emptyAddButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        emptyAddButton.backgroundColor = UIColor(named: "DP_262626")
        emptyAddButton.layer.cornerRadius = 8
        emptyAddButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        emptyAddButton.addTarget(self, action: #selector(handleEmptyAddTap), for: .touchUpInside)

        emptyAddButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            Log.debug("初始 scrollView.contentSize:, \(self.scrollView.contentSize)")
//            Log.debug("初始  scrollView.bounds: \(self.scrollView.bounds)")
//            Log.debug("初始  scrollView frame: \(self.scrollView.frame)")
//            Log.debug("初始  contentView frame: \(self.contentView.frame)")
//        }
        
    }
    
    
    // MARK: - Private Methods

    /// 新增行
    /// - Parameters:
    ///   - item: model 数据
    ///   - index: ui 索引,从 0 开始
    private func createRow(for item: ProgramDataModel, atIndex index: Int) -> ProgrammablePagelistCell {
        
        let row = ProgrammablePagelistCell()
        row.backgroundColor = UIColor(named: "DP_262626")
        
        // 👇 关键：绑定数据模型
        row.dataModel = item // ✅ 建立关联！
        
        // 格式化显示文本（复用逻辑）
        let strs = formatDisplayStrings(for: item, displayIndex: index+1)
        row.strs = strs
        
        // 绑定事件
        row.swipeDeleteBtn.addTarget(self, action: #selector(handleRowSwipeDelete(_:)), for: .touchUpInside)
        row.swipeAddBtn.addTarget(self, action: #selector(handleRowSwipeAdd(_:)), for: .touchUpInside)
        
        // 固定高度
        row.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        
        return row
    }

    private func formatDisplayStrings(for item: ProgramDataModel, displayIndex: Int) -> [String] {
        let vol = Double(item.voltageMin) / 1000
        let cur = Double(item.current) / 1000
        let time = item.time / 10
        
        if time == 0 && vol == 0 {
            return ["\(displayIndex)", "OFF", "", ""]
        } else if time == 0 && vol == 1 {
            let high8 = (Int(cur) >> 24) & 0xFF
            let low24 = Int(cur) & 0x00FFFFFF
            let curStr = "\(Double(high8).formatted(decimalPlaces: 3))"
            let timeStr = low24 == 0 ? "" : "\(low24)"
            return ["\(displayIndex)", "Jump", curStr, timeStr]
        } else {
            return [
                "\(displayIndex)",
                "\(vol.formattedWithLeadingZero())",
                "\(cur.formatted(decimalPlaces: 3))",
                "\(time)"]
        }
    }

    // MARK: 左滑添加事件
    @objc private func handleRowSwipeAdd(_ sender: UIButton) {

        // 找到点击的 row 和 rowIndex
        for (uiIndex, row) in programmablePageRows.enumerated() {
            if row.swipeAddBtn == sender {
                // 执行添加动画
                swipeAddRow(at: uiIndex)
                break
            }
        }
        
    }
    
    private func swipeAddRow(at uiIndex: Int) {
        
        guard let vc = self.parentViewController as? CustomPickViewVC else { return }
        
        let insertPos = uiIndex + 1 // 数据插入位置

        let newdataIndex = vc.model.initialProgrammablePageDatas.count //model 数据索引
        let newCelldata = ProgramDataModel(
            index: newdataIndex,
            voltageMin: 3000,
            current: 5000,
            time: newdataIndex * 10
        )
        
//        Log.debug("准备插入: 新数据 model 数据索引(从0开始)= \(newdataIndex), 新数据插入位置 uiIndex(从0开始)= \(insertPos)")
        
        // 更新数据源
        programmablePageVDelegate?.programmablePageV(self, didInsertItem: newCelldata, at: newdataIndex)
        
        // ✅ 再更新 UI
        let newRow = createRow(for: newCelldata, atIndex: insertPos)
        programmablePageRows.insert(newRow, at: insertPos)
        rowStackView.insertArrangedSubview(newRow, at: insertPos)
    
        // 动画显示
        newRow.alpha = 0
        newRow.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)

        UIView.animate(withDuration: 0.3) {
         newRow.alpha = 1
         newRow.transform = .identity
         self.layoutIfNeeded() // 触发 stackView 重排
        }

        // 滚动（稍后执行，确保 layout 完成）
        DispatchQueue.main.async {

             // 更新 ui 索引（仅当还有剩余行）
             for (i, r) in self.programmablePageRows.enumerated() {
                 r.setIndex(i + 1)
             }
             
             self.scrollToRow(insertPos)
        }

        // 重置触发行的滑动状态
        programmablePageRows[uiIndex].resetSwipe()
        
    }
    
    // MARK: 左滑删除事件
    @objc private func handleRowSwipeDelete(_ sender: UIButton) {

        // 找到点击的 row 和 rowIndex
        for (uiIndex, row) in programmablePageRows.enumerated() {
            if row.swipeDeleteBtn == sender {
                // 执行删除动画
                swipeDeleteRow(row: row, at: uiIndex)
                break
            }
        }
    }
    
    private func swipeDeleteRow(row: ProgrammablePagelistCell, at uiIndex: Int) {
        
        // 👇 直接获取数据模型！
        guard let dataToDelete = row.dataModel else {
            Log.debug("Row has no associated data model!")
            return
        }

//        Log.debug("准备删除数据: model 数据索引(从0开始)= \(dataToDelete.index), uiIndex(从0开始)= \(uiIndex)")

        // 移除 ui
        programmablePageRows.remove(at: uiIndex)
        rowStackView.removeArrangedSubview(row)
        
        // 移除数据源
        if let vc = self.parentViewController as? CustomPickViewVC,
           let dataIndex = vc.model.initialProgrammablePageDatas.firstIndex(where: {  $0.index == dataToDelete.index }) {
            
            programmablePageVDelegate?.programmablePageV(self, didDeleteItemAt: dataIndex)

        }
        

        // 动画隐藏
        UIView.animate(withDuration: 0.3, animations: {
            row.alpha = 0
            row.transform = CGAffineTransform(translationX: -row.frame.width, y: 0)
        }) { _ in
            row.removeFromSuperview()
        }
        
        // 更新 ui 索引（仅当还有剩余行）
        for (i, r) in self.programmablePageRows.enumerated() {
            r.setIndex(i + 1)
        }
        
        // 👇 更新空状态
        self.updateEmptyStateUI()
        
    }
    
    // MARK: 空状态添加按钮的点击事件
    @objc private func handleEmptyAddTap() {

        // 创建默认新行
        let newItem = ProgramDataModel(index: 0, voltageMin: 1000, current: 1000, time: 0)
        let newRow = createRow(for: newItem, atIndex: 0)
        
        programmablePageRows.append(newRow)
        rowStackView.addArrangedSubview(newRow)
        
        // 更新数据源
        programmablePageVDelegate?.programmablePageV(self, didInsertItem: newItem, at: 0)
        
        // 👇 调用统一方法
        updateEmptyStateUI()

    }
  
    //统一更新空状态 UI 的方法
    private func updateEmptyStateUI() {
        
        let isEmpty = programmablePageRows.isEmpty
        emptyAddButton.isHidden = !isEmpty
        
        // 同时处理 contentView 高度（解决 scroll view 约束歧义）
        if isEmpty {
            contentView.snp.remakeConstraints { make in
                make.edges.equalTo(scrollView)
                make.width.equalTo(scrollView.snp.width)
                // 注意：即使有 emptyAddButton，也要确保高度明确
                // 但 emptyAddButton 有 intrinsicContentSize，通常足够
                // 如果担心，可加：make.height.greaterThanOrEqualTo(100).priority(.low)
            }
        } else {
            contentView.snp.remakeConstraints { make in
                make.edges.equalTo(scrollView)
                make.width.equalTo(scrollView.snp.width)
                // 不设 height，由 rowStackView 撑开
            }
        }
    }
    
    // MARK: - Public Methods

    func createProgrammablePagelist1(with dataCellArr: [ProgramDataModel]){
        
        // 清空现有
        rowStackView.arrangedSubviews.forEach { view in
            rowStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        programmablePageRows.removeAll()

        if !dataCellArr.isEmpty {
            for (index, item) in dataCellArr.enumerated() {
                let row = createRow(for: item, atIndex: index)
                programmablePageRows.append(row)
                rowStackView.addArrangedSubview(row)
            }
        }

        // 👇 统一更新空状态
        updateEmptyStateUI()
        
    }

    
    /// 运行时的行 ui
    /// - Parameters:
    ///   - rowI: 数据工作行,从1开始;  programmablePageRows ,从0开始
    /// - Note: rowI = -1 时, 取消显示边框
    func updateRowBgColor1(_ rowI: Int){

        for (itemI, item) in programmablePageRows.enumerated(){
            item.addBorder(side: .left, color: UIColor(named: itemI == rowI ? "DP_FFA600" : "DP_262626")!, width: 2)
            item.backgroundColor = UIColor(named: itemI == rowI ? "DP_261900" : "DP_262626")
            item.labels[0].textColor = UIColor(named: itemI == rowI ? "DP_ffffffff" : "DP_999999")
            item.textFields[0].textColor = UIColor(named: itemI == rowI ? "DP_ffffffff" : "DP_999999")
            item.textFields[1].textColor = UIColor(named: itemI == rowI ? "DP_ffffffff" : "DP_999999")
            item.textFields[2].textColor = UIColor(named: itemI == rowI ? "DP_ffffffff" : "DP_999999")

        }
    }
    
    //改变控制面板的按钮图像颜色
    func changeProgramControlBtnTintcolr(isRemoteConnect: Bool, isPlay: Bool){
        
        for i in 0..<3{
            if i == 1 {
                if #available(iOS 13.0, *) {
                    programControlBtns[i].setImage(UIImage(named: isPlay ? "DP_ProgrammableStop" : "DP_ProgrammablePlay")?.withTintColor(UIColor(named: isRemoteConnect ? "DP_ffffffff" : "DP_999999")!), for: .normal)
                } else {
                    programControlBtns[i].setImage(UIImage(named: isPlay ? "DP_ProgrammableStop" : "DP_ProgrammablePlay"), for: .normal)
                }
            }else{
                if #available(iOS 13.0, *) {
                    programControlBtns[i].setImage(UIImage(named: btnImgs[i])?.withTintColor(UIColor(named: isRemoteConnect ? "DP_ffffffff" : "DP_999999")!), for: .normal)
                } else {
                    programControlBtns[i].setImage(UIImage(named: btnImgs[i]), for: .normal)
                }
            }
            
        }
    }
    

    /// 执行控制块过程中,若索引行被遮挡,实现自动滚动显示被遮挡行
    /// - Parameters:
    ///   - rowIndex: ui 数组索引, 从 0 开始
    ///    notes: scrollRectToVisible 自动处理边界、安全区域、内容偏移，比手动计算可靠得多
    func scrollToRow(_ rowIndex: Int) {
        guard rowIndex >= 0 && rowIndex < programmablePageRows.count else { return }
        scrollView.scrollRectToVisible(programmablePageRows[rowIndex].frame, animated: true)
    }
//    func scrollToRow(_ rowIndex: Int, position: ScrollPosition = .bottom) {
//
//        guard rowIndex >= 0 else { return }
//        
//        DispatchQueue.main.async {
//            self.layoutIfNeeded()
//            
//            // 获取目标行视图
//            guard rowIndex < self.programmablePageRows.count else {
//                Log.debug("⚠️ 行索引超出范围: \(rowIndex)")
//                return
//            }
//            
//            let rowView = self.programmablePageRows[rowIndex]
//            
//            // 确保行视图在视图层级中
//            guard rowView.superview != nil else {
//                Log.debug("⚠️ 行视图不在视图层级中")
//                return
//            }
//            
//            // 将行视图的frame转换到scrollView的坐标系, 间距 1
//            let rowFrameInScrollView = rowView.convert(rowView.bounds, to: self.scrollView)
//            
////            Log.debug("滚动信息:\n- ui目标行(从0开始): \(rowIndex)\n- 行frame: \(rowFrameInScrollView)\n- 当前偏移: \(self.scrollView.contentOffset.y)\n")
//            
//            // 定义边距常量
//            struct ScrollMargin {
//                static let top: CGFloat = 10
//                static let bottom: CGFloat = 10
//                static let middle: CGFloat = 0  // 中间位置通常不需要边距
//            }
//            
//            // 根据位置调整要显示的rect
//            var rectToShow = rowFrameInScrollView
//            
//            switch position {
//            case .top:
//                // 显示在顶部，添加一点边距
//                rectToShow = CGRect(
//                    x: rowFrameInScrollView.origin.x,
//                    y: rowFrameInScrollView.origin.y - ScrollMargin.top,
//                    width: rowFrameInScrollView.width,
//                    height: rowFrameInScrollView.height + ScrollMargin.top
//                )
//                
//            case .middle:
//                // 计算让行显示在中间的rect
//                let centerY = rowFrameInScrollView.midY - self.scrollView.bounds.height / 2
//                rectToShow = CGRect(
//                    x: rowFrameInScrollView.origin.x,
//                    y: centerY,
//                    width: rowFrameInScrollView.width,
//                    height: self.scrollView.bounds.height
//                )
//                
//            case .bottom:
//                // 计算让行显示在底部的rect
//                let bottomY = rowFrameInScrollView.maxY - self.scrollView.bounds.height + ScrollMargin.bottom
//                rectToShow = CGRect(
//                    x: rowFrameInScrollView.origin.x,
//                    y: bottomY,
//                    width: rowFrameInScrollView.width,
//                    height: self.scrollView.bounds.height
//                )
//            }
//            
//            // 使用系统方法滚动
//            self.scrollView.scrollRectToVisible(rectToShow, animated: true)
//            
////            // 验证滚动结果
////            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
////                let finalRowFrame = rowView.convert(rowView.bounds, to: self.scrollView)
////                let visibleTop = self.scrollView.contentOffset.y
////                let visibleBottom = visibleTop + self.scrollView.bounds.height
//                
////                Log.debug("滚动后验证:\n - 行最终位置: \(finalRowFrame) \n - 可见区域: visibleTop= \(visibleTop) \n ~ visibleBottom= \(visibleBottom) \n - 行是否可见:  \(finalRowFrame.maxY > visibleTop && finalRowFrame.minY < visibleBottom)\n ")
////            }
//        }
//    }
    
    // 检查当前工作行是否可见
    /// - Parameters:
    ///   - uiRow:  ui 数据索引, 从 0 开始
    func isWorkRowVisible(_ uiRow: Int) -> Bool {

        let rowHeight: CGFloat = 40
        let rowSpacing: CGFloat = 1
        
        // 计算行在scrollView坐标系中的位置
        let rowTop = CGFloat(uiRow+1) * (rowHeight + rowSpacing)
        let rowBottom = rowTop + rowHeight
        
        // 计算当前可见区域
        let visibleTop = scrollView.contentOffset.y
        let visibleBottom = visibleTop + scrollView.bounds.height
        
        // 判断行是否在可见区域内（至少部分可见）
        let isPartiallyVisible = (rowTop < visibleBottom) && (rowBottom > visibleTop)
//        let isFullyVisible = (rowTop >= visibleTop) && (rowBottom <= visibleBottom)
        
//        Log.debug("可见性检查: ui 行(从 0 开始)=\(uiRow) 在[\(rowTop)-\(rowBottom)]，可见区域[\(visibleTop)-\(visibleBottom)]，部分可见: \(isPartiallyVisible)，完全可见: \(isFullyVisible)")
        
        return isPartiallyVisible
    }

    
    // MARK: - Helper Methods
    
    private func changeTitleTextFieldUI(isEnable: Bool){

        titleTextField.backgroundColor = isEnable ? .white : .clear
        titleTextField.textColor = isEnable ? .black : .white
        titleTextField.snp.remakeConstraints { make in
            if isEnable{
                make.width.equalTo(200)
            }
            make.height.equalTo(44)
            make.top.equalTo(hintL.snp.bottom)
            make.left.equalToSuperview().offset(16)
        }
    }
    
    private func setTitle(_ text: String){
        titleTextField.attributedText = bahnschrift_formatted(text, 20, weight: .regular, alignment: .left, baseline: -1)
        
    }
    
}
extension ProgrammablePageV: UITextFieldDelegate{
    
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

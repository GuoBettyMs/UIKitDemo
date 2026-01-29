//
//  PresetPageV.swift
//  SwiftTest
//
//  Created by user on 2026/1/23.
//
// 列表行可长按,列表内容项可编辑,点击按钮可查看编辑记录(新增行、删除行、次列表的数据修改),当次列表行为空时自动显示新增按钮


import UIKit
import SnapKit
import RxSwift

//通过 delegate 回调操作 vc.initialPresetListDatas,避免视图层直接修改数据
protocol PresetPageViewDelegate: AnyObject {
    func presetPageView(_ view: PresetPageV, didInsertSublistItem data: ProgramDataModel, at position: Int, inRowAt rowIndex: Int)
    func presetPageView(_ view: PresetPageV, didDeleteSublistItemAt position: Int, inRowAt rowIndex: Int)
    func presetPageView(_ view: PresetPageV, didSelectPowerValue value: Int, forRowAt rowIndex: Int)
    func presetPageView(_ view: PresetPageV, didUpdateItems datas: [ProgramDataModel], forRowAt rowIndex: Int)
}

class PresetPageV: BaseV{
    
    weak var presetPageViewDelegate: PresetPageViewDelegate?
    private let hintL = UILabel()
    let upLoadBtn = UIButton()
    
    // 列表 row
    private let programTabV = UIView()
    var selectedRowI: Int = -1 //选定的 row 索引
    var presetPageRows: [PresetListCell] = []
    private let rowStackView = UIStackView()
    private let emptyAddButton = UIButton(type: .system)
    var presetRowToSublistMap: [PresetListCell: [PresetSublistCell]] = [:]
    var selectedRowV: PresetListCell? //选定的 row view

    var ispickVCreate = false
    var backgroundView = UIView()
    var pickV = UIPickerView()
    let pickbgV = UIView()
    var pickVDataSource: [Int] = [12, 18, 20, 30, 36, 45, 60, 65, 100, 140] //PDO 列表的行功率值
    
    
    // - 次列表 row
    let sublistScrollView = UIScrollView()
    let sublistContentView = UIView()
    
    var presetSubRows: [PresetSublistCell] = []
    private let subRowStackView = UIStackView()
    private let subEmptyAddBtn = UIButton() //次列表下方的添加按钮
    private let sublistV_Maxcount = 8
    private let sublistV_LowLevelPower = 140

    
    //长按菜单
    private var isLongPressVCreate = false
    var menuBackgroundView = UIView()
    let menuArrowV = UIImageView(image: UIImage(named: "DP_Arrow"))
    let menuV = UIStackView()
    private var focusCell: PresetSublistCell? //长按时选定的row
    
    
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
        hintL.text = "列表行可长按,列表内容项可编辑,点击按钮可查看编辑记录(新增行、删除行、次列表的数据修改),当列表行为空时自动显示新增按钮"
        
        addSubview(upLoadBtn)
        upLoadBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.height.equalTo(60)
            make.bottom.equalToSuperview()
        }
        upLoadBtn.setTitleColor(UIColor(named: "DP_00FF2B"), for: .normal)
        upLoadBtn.setAttributedTitle(bahnschrift_formatted(NSLocalizedString("UploadtotheDevice", comment: "Upload to the Device")), for: .normal)
        upLoadBtn.backgroundColor = UIColor(named: "DP_072713ff")
        upLoadBtn.layer.borderColor = UIColor(named: "DP_00FF2B")!.cgColor
        upLoadBtn.layer.borderWidth = 1
        upLoadBtn.layer.cornerRadius = 10
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.snp.remakeConstraints { make in
            make.top.equalTo(hintL.snp.bottom).offset(10)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(upLoadBtn.snp.top).offset(-5)
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
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        contentView.addSubview(emptyAddButton)
        emptyAddButton.setTitle("＋ 添加新行", for: .normal)
        emptyAddButton.setTitleColor(UIColor(named: "DP_999999"), for: .normal)
        emptyAddButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        emptyAddButton.backgroundColor = UIColor(named: "DP_262626")
        emptyAddButton.layer.cornerRadius = 8
        emptyAddButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        emptyAddButton.addTarget(self, action: #selector(handleEmptyAddTap), for: .touchUpInside)

        emptyAddButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(rowStackView.snp.bottom)
            make.bottom.equalToSuperview()
        }
      
        addSubview(sublistScrollView)
        sublistScrollView.translatesAutoresizingMaskIntoConstraints = false
        sublistScrollView.snp.remakeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(hintL.snp.bottom).offset(50)//scrollView 顶部间距10+固定 row 高度40
            make.bottom.equalTo(upLoadBtn.snp.top).offset(-5-40) //cellAddBtn 高度40
        }
        sublistScrollView.showsVerticalScrollIndicator = false
        sublistScrollView.backgroundColor = .white
        sublistScrollView.isHidden = true
        
        sublistScrollView.addSubview(sublistContentView)
        sublistContentView.snp.makeConstraints{ make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview()          // 对齐父视图 sublistScrollView
            make.width.equalTo(sublistScrollView)       // 宽度等于父 scrollView
        }
        sublistContentView.layer.cornerRadius = 10
        
        // 添加 stackView 到 contentView
        sublistContentView.addSubview(subRowStackView)
        subRowStackView.axis = .vertical
        subRowStackView.spacing = 1 // 行间距 = 1
        subRowStackView.distribution = .fill
        subRowStackView.alignment = .fill
        subRowStackView.translatesAutoresizingMaskIntoConstraints = false

        subRowStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        sublistContentView.addSubview(subEmptyAddBtn)
        subEmptyAddBtn.translatesAutoresizingMaskIntoConstraints = false

        subEmptyAddBtn.backgroundColor = UIColor(named: "DP_262626")
        subEmptyAddBtn.setImage(UIImage(named: "DP_ProgramItemAdd"), for: .normal)
        subEmptyAddBtn.layer.cornerRadius = 10
        subEmptyAddBtn.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        subEmptyAddBtn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        subEmptyAddBtn.addTarget(self, action: #selector(handleSubEmptyAddTap), for: .touchUpInside)
        subEmptyAddBtn.isHidden = true
        subEmptyAddBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Private Methods

    
    // MARK: 主列表
    /// 新增行
    /// - Parameters:
    ///   - item: model 数据
    ///   - index: ui 索引,从 0 开始
    private func createRow(for item: ProgramFileModel, atIndex index: Int) -> PresetListCell {
        
        let row = PresetListCell()
        row.backgroundColor = UIColor(named: "DP_262626")
        
        // 👇 关键：绑定数据模型
        row.dataModel = item // ✅ 建立关联！
        row.setTitle(item.title)
        row.setValue(item.pDOPower)
        
        pickV.selectRow(row.getRow(from: item.pDOPower), inComponent: 0, animated: false)
        
        // 绑定事件
        rowClickEvent(row)
        
        // 固定高度, 由 PresetSublistCell 里的 intrinsicContentSize 决定
        
        return row
    }

    
    // 隐藏所有行（除了选中的行）
    private func hideOtherRows(except selectedRow: PresetListCell) {

        upLoadBtn.isHidden = true
        contentView.layer.maskedCorners = []
        
        selectedRow.titleTextField.isUserInteractionEnabled = true
        presetPageRows.forEach { row in
            let isHidden = row != selectedRow
            row.isHidden = isHidden
               
        }
        
        sublistScrollView.isHidden = false

    }
    

    
    // MARK: 次列表
    private func showInitialSublist(with dataCellArr: [ProgramDataModel], below row: PresetListCell){
        
//        Log.debug("Sublist count= \(dataCellArr.count)")
        
        guard !dataCellArr.isEmpty else {
            Log.debug("dataCellArr count is 0")
            return
        }
        
        // 为这个行创建独立的数据单元格数组
        var dataCellsForThisRow: [PresetSublistCell] = []
        
        // 根据 dataModel 的数量创建单元格
        for (itemI, item) in dataCellArr.enumerated() {
            let cell = createPresetSubListRow(for: item, atIndex: itemI)
            configureSublistCell(cell, with: item, atIndex: itemI)
            cell.isInitialItem = true
            dataCellsForThisRow.append(cell)
            presetSubRows.append(cell) //绑定 row 对应的全部 cell ui
        }
        
        // 建立正确的映射关系
        presetRowToSublistMap[row] = dataCellsForThisRow

    }
    
    private func configureSublistCell(_ cell: PresetSublistCell, with data: ProgramDataModel, atIndex index: Int) {
        
        if index == 0 {
            // 第一行特殊样式
            cell.img.image = UIImage(named: "DP_UsbEditFirstRow")
            cell.img.isUserInteractionEnabled = false
            cell.connects[0].isHidden = true
            cell.secondVoltages[0].isHidden = true
            cell.voltages[0].isUserInteractionEnabled = false
            cell.currents[0].isUserInteractionEnabled = true
            cell.setCurLabel(cur: (data.current * 10) / 1000)
            cell.voltages[0].attributedText = bahnschrift_formatted("5.00")
        } else if index == 5 {
            cell.setCurLabel(cur: (data.current * 50) / 1000)
            cell.setVolLabel(volMin: (data.voltageMin * 100) / 1000, volMax: (data.voltageMax * 100) / 1000, isLast: true)
        } else if index == 6 {
            cell.setSpecialVolLabel(cur15V_10ma: (data.current * 10) / 1000, cur20V_10ma: (data.max_current20V_10ma * 10) / 1000)
        } else {
            cell.setCurLabel(cur: (data.current * 10) / 1000)
            cell.setVolLabel(volMin: (data.voltageMin * 50) / 1000, volMax: 0, isLast: false)
        }
    }
    
    private func createPresetSubListRow(for item: ProgramDataModel, atIndex index: Int) -> PresetSublistCell{
        
        let cell = PresetSublistCell()
        cell.addBorder(side: .bottom, color: UIColor.red, width: 2)
        cell.isHidden = true
        cell.tag = index //赋值索引
        cell.isChooseen = item.isSelected
        
        cell.setIndexL(index + 1)

        // 添加长按手势
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        longPressGesture.minimumPressDuration = 0.5 // 设置长按时间为0.5秒
        cell.addGestureRecognizer(longPressGesture)

        // 固定高度, 由 PresetSublistCell 里的 intrinsicContentSize 决定
        
        return cell
    }
    
    private func createProgrammableListBtns(_ selectedrow: PresetSublistCell){
        
        menuBackgroundView.backgroundColor = .clear//UIColor.white.withAlphaComponent(0.5)
        addSubview(menuBackgroundView)
        menuBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview() // ← 覆盖整个父容器
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideProgrammableListEvent))
        menuBackgroundView.addGestureRecognizer(tapGesture)

        // 获取 cell 在 menuBackgroundView 中的位置
        guard let cellFrameInSuperview = selectedrow.superview?.convert(selectedrow.frame, to: menuBackgroundView) else {
            Log.debug("无法获取cell在menuBackgroundView中的位置")
            return
        }
        
        menuBackgroundView.addSubview(menuV)
        menuV.snp.makeConstraints { make in
            make.width.equalTo(170)
            make.height.equalTo(44)
            // 使用绝对位置
            make.left.equalTo(cellFrameInSuperview.midX - 85) // 居中：midX - width/2
            make.top.equalTo(cellFrameInSuperview.maxY)
        }
        menuV.backgroundColor = UIColor(named: "DP_0B8CE8ff") //UIColor(named: "DP_000000ff")
        menuV.layer.cornerRadius = 5
        menuV.isUserInteractionEnabled = true // 确保 menuV 能够接收触摸事件
        
        menuBackgroundView.addSubview(menuArrowV)
        menuArrowV.snp.makeConstraints { make in
            make.bottom.equalTo(menuV.snp.top)
            make.centerX.equalTo(menuV.snp.centerX)
        }
        
        for i in 0...1{
            let item = UIButton()
            menuV.addSubview(item)
            item.snp.makeConstraints { make in
                make.width.equalToSuperview().multipliedBy(i == 0 ? 0.59 : 0.41) // i == 0 ? 100/170 : 70/170
                make.height.equalToSuperview()
                make.centerY.equalToSuperview()
                if i == 0 {
                    make.left.equalToSuperview()
                }else{
                    make.right.equalToSuperview()
                }
            }
//            item.backgroundColor = .random()//UIColor(named: "DP_d9d9d9ff")
//            item.layer.cornerRadius = 10
            // 确保按钮能够接收触摸事件
            item.isUserInteractionEnabled = true
            
            let label = UILabel()
            item.addSubview(label)
            label.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
            label.textColor = .white
            label.font = UIFont(name: kISDTYahei, size: 10)
            label.text = i == 0 ? NSLocalizedString("Add a row below", comment: "Add a row below") : NSLocalizedString("Delete row", comment: "Delete row")
            label.isUserInteractionEnabled = false //不参与事件响应，这样点击会穿透到 item
            
            if i == 0 {
                let lineV = UIView()
                item.addSubview(lineV)
                lineV.snp.makeConstraints { make in
                    make.width.equalTo(1)
                    make.height.equalToSuperview()
                    make.centerY.equalToSuperview()
                    make.right.equalToSuperview()
                }
                lineV.backgroundColor = UIColor(named: "DP_333333")
            }
            
            item.tag = i
            //在 viewcontroll 设置点击事件,初始化时 menuV 未加载无法设 menuVBtns 事件
            item.addTarget(self, action: #selector(menuItemTapped(_:)), for: .touchUpInside)
            
        }
    }
    //isShow: true 显示
    private func showProgrammableList(isShow: Bool, _ selectedrow: PresetSublistCell?){
        
        menuBackgroundView.isHidden = !isShow
        menuArrowV.isHidden = !isShow
        menuV.isHidden = !isShow
        
        // 获取 cell 在 menuBackgroundView 中的位置
        guard let cell = selectedrow, let cellFrameInSuperview = cell.superview?.convert(cell.frame, to: menuBackgroundView) else {
            Log.debug("无法获取cell在menuBackgroundView中的位置")
            return
        }
        
        menuV.snp.remakeConstraints { make in
            make.width.equalTo(170)
            make.height.equalTo(44)
            // 使用绝对位置
            make.left.equalTo(cellFrameInSuperview.midX - 85) // 居中：midX - width/2
            make.top.equalTo(cellFrameInSuperview.maxY)
        }
        
    }

    // 长按触发的具体操作
    private func handleLongPressActionForSublist(_ cell: PresetSublistCell) {

        focusCell = cell
        if !isLongPressVCreate {
            createProgrammableListBtns(cell)
            isLongPressVCreate = true

        } else {
            showProgrammableList(isShow: true, cell)
        }
    }
    
    
    //MARK: - Event
    
    //MARK: 长按手势
    // 长按手势处理方法
    @objc private func handleLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        // 确保只在手势开始时触发一次，避免重复触发
        if gesture.state == .began {

            // 震动反馈
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            // 从 gesture 获取它附加的 view（就是你的 cell）
            guard let cell = gesture.view as? PresetSublistCell else {
                Log.debug("长按的手势未附加到正确的 cell")
                return
            }
            
            // 执行长按操作
            handleLongPressActionForSublist(cell)
        }
    }
    

    
    //添加菜单项点击事件处理
    @objc private func menuItemTapped(_ sender: UIButton) {
//        Log.debug("sender tag = \(sender.tag)")

        guard let cell = focusCell else {return}
        
        switch sender.tag{
        case 0: //新增事件
            addSublistNewrow(cell.tag+1)
            
        case 1: //删除事件
            deleteSublistSeletedrow(cell)

        default: break
        }
        
    }

    
    @objc private func hideProgrammableListEvent() {
//        Log.debug("hideProgrammableListEvent")
        focusCell = nil
        showProgrammableList(isShow: false, focusCell)
    }
    
    
    //MARK: 点击事件

    private func rowClickEvent(_ row: PresetListCell){
        
        guard let vc = self.parentViewController as? CustomPickViewVC else { return }
        
        row.rx.rowTap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                   
                // 获取这个行对应的数据单元格
                if let index = presetPageRows.firstIndex(where: { $0 === row }) {

                    setCurrentClickedRowI(index)
                    setCurrentClickedRowV(row)
                    hideOtherRows(except: row)// 隐藏其他行
                    
                    // 清空旧内容
                    subRowStackView.arrangedSubviews.forEach {
                        self.subRowStackView.removeArrangedSubview( $0)
                        $0.removeFromSuperview()
                    }

                    
                    if let dataCells = presetRowToSublistMap[row] { // 获取这个行对应的次列表
                        // 添加新内容，并显示
                        dataCells.forEach { cell in
                            cell.isHidden = false // 👈 关键！
                            cell.alpha = 1
                            self.subRowStackView.addArrangedSubview(cell)
                        }
                    }else{
                        Log.debug("这个行对应的次列表为空")
                        subEmptyAddBtn.isHidden = false
                    }
                    // 显示子列表区域
                    sublistScrollView.isHidden = false
                    
                    
                    vc.currentPage = CustomPickviewPageIndex.programEditpage_presetvalue
                            
                    row.titleTextField.isUserInteractionEnabled = true
                    row.valueL.textColor = UIColor(named: "DP_FFA600")
                    row.valueL.isUserInteractionEnabled = true

                    // 直接设置回调，无需重复添加手势
                    row.valueTapHandler = { [weak self] in
                        if row.titleTextField.isEditing{
                            row.titleTextField.endEditing(true)
                            Log.debug("标题行正在编辑,禁用 PDO 列表的 power 设置事件")
                        }else{
                            
                            if PresetSublistCell.isAnyCellEditing {
                                PresetSublistCell.endAllEditing()
                                Log.debug("文本框正在编辑,禁用 PDO 列表的 power 设置事件")
                                return
                            }
                            
                            self?.showPickV() //显示选择器
                        }
                    }
                }
            }).disposed(by: vc.disposedBag)
            
    }
    
    //MARK: 选择器
    @objc private func showPickV(){

        guard let vc = self.parentViewController as? CustomPickViewVC,
                selectedRowI >= 0 && selectedRowI < vc.model.initialPresetListDatas.count,
              selectedRowI >= 0 && selectedRowI < presetPageRows.count
        else {
            Log.debug(" selectedRowI=\(selectedRowI) 报错 ")
            return }
        

        if !ispickVCreate {
            backgroundView = createBackgroundView()
            setupPickerViewHierarchy(in: backgroundView)
            
            ispickVCreate = true
//            Log.debug("pickV Create")
        } else {
            
            backgroundView.isHidden = false
            pickbgV.isHidden = false
            
//            Log.debug("pickV show")
        }
        
        let value = vc.model.initialPresetListDatas[selectedRowI].pDOPower
        let row = presetPageRows[selectedRowI].getRow(from: value)
//        Log.debug("set Initial PickerV row ForPDOlist, [\(row)]: \(value)")
        pickV.selectRow(row, inComponent: 0, animated: false)
 
    }

    private func createBackgroundView() -> UIView {

        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hidePickV))
        backgroundView.addGestureRecognizer(tapGesture)
        
        return backgroundView
    }
    
    private func setupPickerViewHierarchy(in backgroundView: UIView) {
        // 配置 pickbgV
        pickbgV.backgroundColor = UIColor(named: "DP_e9e9e9ff")
        pickbgV.layer.cornerRadius = 10
        pickbgV.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        backgroundView.addSubview(pickbgV)
        pickbgV.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(214)
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        // 配置 pickV
        pickV.backgroundColor = UIColor(named: "DP_e9e9e9ff")
        pickV.delegate = self
        pickV.dataSource = self
        
        pickbgV.addSubview(pickV)
        pickV.snp.makeConstraints { make in
            make.width.equalTo(300)
            make.height.equalToSuperview()
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }

    @objc private func hidePickV() {
        
        let selectedRow = pickV.selectedRow(inComponent: 0)
        guard selectedRow >= 0 && selectedRow < pickVDataSource.count else {
            Log.debug("pickVDataSource selectedRow= \(selectedRow) 报错 ")
            return }
        
        guard let vc = self.parentViewController as? CustomPickViewVC,
                selectedRowI >= 0 && selectedRowI < vc.model.initialPresetListDatas.count else {
            Log.debug(" selectedRowI=\(selectedRowI) 报错 ")
            return }

//        Log.debug(" selectedRowI=\(selectedRowI), \(pickVDataSource[selectedRow])  ")
        
        // 更新数据源
        presetPageViewDelegate?.presetPageView(self, didSelectPowerValue: pickVDataSource[selectedRow], forRowAt: selectedRowI)

        backgroundView.isHidden = true
    }
    
    
    // 列表新增按钮事件
    @objc private func handleEmptyAddTap() {
        
        guard let vc = self.parentViewController as? CustomPickViewVC else { return }
        
        let currentDataCount = vc.model.initialPresetListDatas.count
        
        //添加新数据
        let newCellData = ProgramFileModel(index: currentDataCount, title: "New Test\(currentDataCount+1)", pDOPower: 12, dataModel: [])
        
        // 创建默认新行
        let newRow = createRow(for: newCellData, atIndex: currentDataCount)
        newRow.setIndex(newCellData.index+1)
        
        presetPageRows.append(newRow)
        rowStackView.addArrangedSubview(newRow)

        // 更新数据源
        vc.model.initialPresetListDatas.append(newCellData)
        vc.model.presetlistDisplayOrder.append(newCellData.index)
        
//        Log.debug("新增的数据行索引: \(newCellData.index), initialListDatas 总数: \(vc.model.initialPresetListDatas.count), rowViews 总数: \(presetPageRows.count)")

        //添加编辑记录
        let operation = RowOperation.rowAdd(index: newCellData.index)
        vc.model.pendingOperations.append(operation)
        vc.model.presetWriteCommandIArr.append(newCellData.index)
        
    }
  
    
    //次列表新增按钮事件
    @objc private func handleSubEmptyAddTap() {
        
        addSublistNewrow(0)
        subEmptyAddBtn.isHidden = true
        
    }
    
    //MARK: - Helper Methods
    //次列表删除行
    private func deleteSublistSeletedrow(_ seletedCell: PresetSublistCell){
        
        guard let vc = self.parentViewController as? CustomPickViewVC,
                let row = selectedRowV,
                selectedRowI >= 0 && selectedRowI < vc.model.initialPresetListDatas.count
        else {
            Log.debug(" selectedRowI=\(selectedRowI) 报错 ")
            return }
        
        
        if row.titleTextField.isEditing{
            row.titleTextField.endEditing(true)
            Log.debug("标题行正在编辑,禁用可编程次列表事件")
        }
        
        if var dataCells = presetRowToSublistMap[row], let index = dataCells.firstIndex(where: { $0 === seletedCell }){
            
            // 获取要删除的cell
            let removedCell = dataCells[index]
            
            // 2. 动画完成后从所有相关数组中移除
            dataCells.remove(at: index)
            presetSubRows.removeAll(where: { $0 === removedCell })
            presetRowToSublistMap[row] = dataCells
            
            // 执行删除动画
            UIView.animate(withDuration: 0.3, animations: {
                removedCell.alpha = 0
                removedCell.transform = CGAffineTransform(scaleX: 0.8, y: 0.01) // 收缩效果
            }) { _ in
                
                // 从UI中移除
                removedCell.removeFromSuperview()
                
                //更新数据源
                self.presetPageViewDelegate?.presetPageView(self, didDeleteSublistItemAt: index, inRowAt: self.selectedRowI)
                
                //刷新所有 cell 的 tag
                self.refreshSublistCellIndices(for: row)
                self.hideProgrammableListEvent()
                
                // 发送通知,存储编辑记号
                NotificationCenter.default.post(
                    name: .presetSublistcellEditStateChanged,
                    object: self,
                    userInfo: ["action": "celldelete", "index": index]
                )
            }
        }
    }
    
    //次列表新增行
    private func addSublistNewrow(_ insertPosition: Int){

        guard let vc = self.parentViewController as? CustomPickViewVC,
                let row = selectedRowV,
                selectedRowI >= 0 && selectedRowI < vc.model.initialPresetListDatas.count
        else {
            Log.debug(" selectedRowI=\(selectedRowI) 报错 ")
            return }
        
        if row.titleTextField.isEditing{
            row.titleTextField.endEditing(true)
            Log.debug("标题行正在编辑,禁用可编程次列表事件")
        }
        
        let currentDataCount = vc.model.initialPresetListDatas[selectedRowI].dataModel.count
        let safeInsertPosition = min(insertPosition, currentDataCount) // 安全检查：确保插入位置不越界
        
        // 添加新数据
        let newCelldata = ProgramDataModel(index: currentDataCount, voltageMin: 300, current: 500) //15v / 5a
            
        // 创建新行 ui
        let newCell = createPresetSubListRow(for: newCelldata, atIndex: insertPosition)
        newCell.isInitialItem = false
        newCell.invalidateIntrinsicContentSize() //修改 isInitialItem 后，需要通知 Auto Layout 重新计算尺寸
        newCell.setCurLabel(cur: (newCelldata.current*10)/1000)
        newCell.setVolLabel(volMin: (newCelldata.voltageMin * 50)/1000, volMax: 0, isLast: false)
        
        
        // 👇 关键：确保可见（即使透明）
        newCell.isHidden = false
        newCell.alpha = 0 // 初始透明
        newCell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8) // 初始缩小
        
        // 立即插入到数据结构和视图树（关键！）
        self.presetSubRows.insert(newCell, at: safeInsertPosition)
        self.subRowStackView.insertArrangedSubview(newCell, at: safeInsertPosition)
        
        if var cellsForRow = self.presetRowToSublistMap[row] {
            cellsForRow.insert(newCell, at: safeInsertPosition)
            self.presetRowToSublistMap[row] = cellsForRow
        } else {
            self.presetRowToSublistMap[row] = [newCell]
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            // 淡入 + 放大到正常大小
            newCell.alpha = 1
            newCell.transform = .identity
        }) { _ in
            
//                Log.debug("\(self.selectedRowI) 点击的cell.tag: \(cell.tag), 插入位置: \(insertPosition)(\(safeInsertPosition)), 新cell tag: \(newCell.tag), 数组count: \(self.presetSubRows.count)")
            
            // 更新数据源
            self.presetPageViewDelegate?.presetPageView(self, didInsertSublistItem: newCelldata, at: safeInsertPosition, inRowAt: self.selectedRowI)

            //刷新所有 cell 的 tag
            self.refreshSublistCellIndices(for: row)
            
            //隐藏长按菜单栏
            self.hideProgrammableListEvent()
            self.sublistNewcellScrollToVisible(newCell)
            
            // 发送通知,存储编辑记号
            NotificationCenter.default.post(
                name: .presetSublistcellEditStateChanged,
                object: self,
                userInfo: ["action": "celladd", "index": safeInsertPosition]
            )

        }
        
    }

    
    //刷新所有 cell 的 tag
    private func refreshSublistCellIndices(for row: PresetListCell) {
        if let cells = presetRowToSublistMap[row] {
            for (i, cell) in cells.enumerated() {
                cell.tag = i
                cell.setIndexL(i + 1)
            }
        }
    }
    
    // 若索引行被遮挡,实现自动滚动显示被遮挡行,
    private func sublistNewcellScrollToVisible(_ newCell: PresetSublistCell){
        //scrollRectToVisible 自动处理边界、安全区域、内容偏移, 如果 sublistScrollView 尚未完成 layout（比如刚展开子列表），newCell.frame 可能仍是 .zero，导致滚动无效或异常,在 scrollRectToVisible 前强制更新 frame
        DispatchQueue.main.async {
            self.sublistScrollView.layoutIfNeeded() // 强制更新 frame
            self.sublistScrollView.scrollRectToVisible(newCell.frame, animated: true)
        }
        
    }
    
    // MARK: - Public Methods
    
    func setCurrentClickedRowI(_ i: Int){
        selectedRowI = i
    }
    
    func setCurrentClickedRowV(_ i: PresetListCell?){
        selectedRowV = i
    }
    
    func getCurrentClickedRowV() -> PresetListCell? {
        return selectedRowV
    }
    
    
    // 恢复所有行显示
    func restoreAllRows(with selectedRow: PresetListCell?) {
        // 1. 切回主列表
        sublistScrollView.isHidden = true
        upLoadBtn.isHidden = false

        // 2. 清空子列表
        subRowStackView.arrangedSubviews.forEach {
            subRowStackView.removeArrangedSubview( $0)
             $0.removeFromSuperview()
        }
        
        presetPageRows.forEach { row in
            row.isHidden = false
        }
        
        // 3. 重置父行样式
        if let row = selectedRow {
            // 把 row 移回主列表（如果被移走了）
            if row.superview != rowStackView {
                row.removeFromSuperview()
                rowStackView.addArrangedSubview(row)
            }
            
            row.changeTitleTextFieldUI(isEnable: false)
            row.valueL.textColor = UIColor(named: "DP_999999")
            row.valueL.isUserInteractionEnabled = false
        }

    }
    
    
    func showPresetlist(with dataCellArr: [ProgramFileModel]){
        
        // 清空现有
        rowStackView.arrangedSubviews.forEach { view in
            rowStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        presetPageRows.removeAll()

//        Log.debug("list count= \(dataCellArr.count)")
        
        if !dataCellArr.isEmpty {
            for (index, item) in dataCellArr.enumerated() {
                let row = createRow(for: item, atIndex: index)
                presetPageRows.append(row)
                rowStackView.addArrangedSubview(row)
                
                showInitialSublist(with: item.dataModel, below: row) //加载初始的次列表内容
            }
        }

    }
    
    
}
extension PresetPageV: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickVDataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        36
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        300
    }

    
    // 滚动时实时更新 valueL
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        guard selectedRowI >= 0 && selectedRowI < presetPageRows.count else { return }
        
        presetPageRows[selectedRowI].setValue(pickVDataSource[row])

        if let selectedRow = selectedRowV, let dataCells = presetRowToSublistMap[selectedRow] {

            addOrDeleteLastcell(row, dataCells) //新增或者删除 lastcell
        }
        
        //经过新增或者删除 lastcell, presetRowToSublistMap[selectedPDORow].count  可能发生改变
        if let selectedRow = selectedRowV, let dataCells = presetRowToSublistMap[selectedRow] {
            
            updateVolandCurForpickValue(row, dataCells)
        }
        
    }
    
    //根据 pickview value 更新所有 cell 的电压电流
    private func updateVolandCurForpickValue(_ row: Int, _ dataCells: [PresetSublistCell]){
        
        if let vc = self.parentViewController as? CustomPickViewVC,
           selectedRowI >= 0 && selectedRowI < vc.model.initialPresetListDatas.count,
           vc.model.initialPresetListDatas.count == dataCells.count{
            
            Log.debug("updateVolandCurForpickValue,  \(pickVDataSource[row]),  dataModel.count: \(vc.model.initialPresetListDatas[selectedRowI].dataModel.count), dataCells.count= \(dataCells.count)")
            
            var newDatamodel = [ProgramDataModel]()
            var currentArr: [Double] = []
            var max_current20V_10ma: [Double] = []
            
            switch pickVDataSource[row] {
            case 12:
                currentArr = [2.4, 1.33, 1, 0.8, 0.6, 0.55, 0.8, 0]
                max_current20V_10ma = [0, 0, 0, 0, 0, 0, 0.6, 0]
                
            case 18:
                currentArr = [3, 2, 1.5, 1.2, 0.9, 0.85, 1.2, 0]
                max_current20V_10ma = [0, 0, 0, 0, 0, 0, 0.9, 0]
                
            case 20:
                currentArr = [3, 2.22, 1.66, 1.33, 1, 0.95, 1.33, 0]
                max_current20V_10ma = [0, 0, 0, 0, 0, 0, 1, 0]
                
            case 30:
                currentArr = [3, 3, 2.5, 2, 1.5, 1.4, 2, 0]
                max_current20V_10ma = [0, 0, 0, 0, 0, 0, 1.5, 0]
                
            case 36:
                currentArr = [3, 3, 3, 2.4, 1.8, 1.7, 2.4, 0]
                max_current20V_10ma = [0, 0, 0, 0, 0, 0, 1.8, 0]
                
            case 45:
                currentArr = [3, 3, 3, 3, 2.25, 2.1, 3, 0]
                max_current20V_10ma = [0, 0, 0, 0, 0, 0, 2.25, 0]
                
            case 60:
                currentArr = [3, 3, 3, 3, 3, 2.85, 3, 0]
                max_current20V_10ma = [0, 0, 0, 0, 0, 0, 3, 0]
                
            case 65:
                currentArr = [3, 3, 3, 3, 3.25, 3, 3, 0]
                max_current20V_10ma = [0, 0, 0, 0, 0, 0, 3, 0]
                
            case 100:
                currentArr = [3, 3, 3, 3, 5, 4.75, 3, 0]
                max_current20V_10ma = [0, 0, 0, 0, 0, 0, 5, 0]
                
            case 140:
                currentArr = [3, 3, 3, 3, 5, 5, 3, 5]
                max_current20V_10ma = [0, 0, 0, 0, 0, 0, 5, 0]
                
            default:
                break
            }
            
            let volMinArr: [Double] = [5, 9, 12, 15, 20, 3.3, 9, 28]
            let volMaxArr: [Double] = [0, 0, 0, 0, 0, 21, 15, 0]
            
            for i in 0..<dataCells.count {
                if i == 5 {
                    dataCells[i].setCurLabel(cur: currentArr[i])
                    dataCells[i].setVolLabel(volMin: volMinArr[i], volMax: volMaxArr[i], isLast: true)
                    
                    let newCelldata = ProgramDataModel(index: i, voltageMin: volMinArr[i]*10 ,voltageMax: volMaxArr[i]*10, current: currentArr[i]*20, isSelected: vc.model.initialPresetListDatas[selectedRowI].dataModel[i].isSelected)
                    newDatamodel.append(newCelldata)
                    
                }else if i == 6 {
                    
                    dataCells[i].setSpecialVolLabel(cur15V_10ma: currentArr[i], cur20V_10ma: max_current20V_10ma[i])
                    
                    let newCelldata = ProgramDataModel(index: i, current: currentArr[i]*10, max_current20V_10ma: max_current20V_10ma[i]*10 , isSelected: vc.model.initialPresetListDatas[selectedRowI].dataModel[i].isSelected)
                    newDatamodel.append(newCelldata)

                }else{
                    dataCells[i].setCurLabel(cur: currentArr[i])
                    dataCells[i].setVolLabel(volMin: volMinArr[i], volMax: volMaxArr[i], isLast: false)
                    
                    let newCelldata = ProgramDataModel(index: i, voltageMin: volMinArr[i]*20 ,voltageMax: volMaxArr[i], current: currentArr[i]*100, isSelected: vc.model.initialPresetListDatas[selectedRowI].dataModel[i].isSelected)
                    newDatamodel.append(newCelldata)
                    
                }
                
            }
            // 更新数据源
            presetPageViewDelegate?.presetPageView(self, didUpdateItems: newDatamodel, forRowAt: selectedRowI)
            
        }
    }
    
    //根据 pickview 值新增或者删除最后一行 cell
    private func addOrDeleteLastcell(_ didSelectRow: Int, _ dataCells: [PresetSublistCell]){
        
        if pickVDataSource[didSelectRow] >= sublistV_LowLevelPower && dataCells.count < sublistV_Maxcount{
            
            Log.debug("功率值(\(pickVDataSource[didSelectRow]))大于等于 \(sublistV_LowLevelPower), 并且当前子列表数量(\(dataCells.count)) 小于 \(sublistV_Maxcount), 新增第8行")
            
            addSublistNewrow(7)
            
        }else if pickVDataSource[didSelectRow] < sublistV_LowLevelPower && dataCells.count >= sublistV_Maxcount {
            
            Log.debug("功率值(\(pickVDataSource[didSelectRow]))小于 \(sublistV_LowLevelPower), 并且当前子列表数量(\(dataCells.count)) 大于等于 \(sublistV_Maxcount), 删除第8行")
            
            guard let row = selectedRowV, let dataCells = self.presetRowToSublistMap[row] else {return}
            
            deleteSublistSeletedrow(dataCells[7])
            
        }
        
       
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {

        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.attributedText = bahnschrift_formatted("\(pickVDataSource[row])W", 24)
        return label
    }
    
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return "\(pickVDataSource[row])W"
//    }
}

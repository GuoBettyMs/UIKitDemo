//
//  ChargePageV.swift
//  SwiftTest
//
//  Created by user on 2026/1/19.
//
// UITableView 显示部分表格行,点击按钮,自动展开剩下的表格行
// 支持多电池类型; 支持一对一数据存储,不同电池类型对应不同的电压、串数、电流数据

import UIKit
import SnapKit

class ChargePageV: UIView{
    
    // MARK: UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    //输出开关
    let outputBtn = UIButton()
    private var isOutputOpen = false // 是否开启输出模式

    //base list
    let baselistV = UITableView()
    var isDiscon = false {//断联标识
        didSet{
            baselistV.reloadData()
            setOutput1(isEnble: false)
        }
    }
    var isFullChargeIndicator = false { //充满标志
        didSet{
            for i in 0..<6{
                let indexPath = IndexPath(row: i, section: 0)
                baselistV.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
    private var baseListDisplayIndexes: [Int] {
        return isOutputOpen ? [0, 1, 2, 3, 4, 5] : [1, 2]
    }
    private var itemUintArr:[String] = ["--mAh", "2S", "V", "Wh", "", "W"]

    //charge setting
    private let chargeSetting = UITableView()
    private var displayItems: [String] {// 计算属性：根据状态返回显示的数据
        return isExpanded ? Array(multilingualText[7..<multilingualText.count]) : Array(multilingualText[7...12])
    }
    private var isExpanded = false // 是否展开状态
    private var selectedTableviewIndexPath: IndexPath? // 保存 UITableView 当前选中的行
    private var settingImgArr:[String] = ["DP_Chemistry", "DP_Condition", "DP_Cells", "DP_Current", "DP_LastData"]
   

    private let multilingualText = [NSLocalizedString("OutputOff", comment: "OUTPUT"),
                                    "--A",
                                    NSLocalizedString("BatteryType", comment: "Battery Type"),
                                    NSLocalizedString("Voltage", comment: "Voltage"),
                                    NSLocalizedString("Energy", comment: "Energy"),
                                    NSLocalizedString("Time", comment: "Time"),
                                    NSLocalizedString("Power", comment: "Power"),
                                    
                                    NSLocalizedString("ChargeSetting", comment: "Charge Setting"),
                                    NSLocalizedString("Chemistry", comment: "Chemistry"),
                                    NSLocalizedString("Condition", comment: "Condition"),
                                    NSLocalizedString("Cells", comment: "Cells"),
                                    NSLocalizedString("Power200-Current", comment: "Current"),
                                    NSLocalizedString("LastData", comment: "Last Data"),
                                    NSLocalizedString("BatteryType", comment: "Battery Type"),
                                    NSLocalizedString("Capacity", comment: "Capacity"),
                                    NSLocalizedString("Energy", comment: "Energy"),
                                    NSLocalizedString("Time", comment: "Time")]
    
    
    private var ispickVCreate = false
    private var backgroundView = UIView()
    private var pickV = UIPickerView()
    private let pickbgV = UIView()
    
    // MARK: Data
    private var baselistItemValueArr:[Int] = [0, 0, 0, 0, 0, 0, 0, 0]//电流(mA)、容量(mAh)、类型、串数、电压(10mV)、能量(mWh)、时间、功率(10mW)
    private var oldBatteryType = "LiPo"
    private var currentBatteryType: String = "LiPo" // 当前选中的电池类型（用于读写当前配置）
    private var settinginitalValueArr:[Int] = [1, 4200, 2, 1000, 0, 0, 0, 0, 0] //0-类型,1-电压,2-串数,3-电流,4-上一次类型,5-上一次串数,6-上一次容量,7-上一次能量,8-上一次时间
    

    
    private var starRowIndex: Int? //带星标的电压行索引
    private var starVolvalue: [Int] = [4350, 4200, 4100, 3650, 2400, 8] //带星标的电压值
    
    private var voltageOptionsCache: [String: [String]] = [:] //pickview 电压选项缓存
    private var isReloadingPicker = false // pickview 列表加载标识
    private var pickVdatas: [[String]] = [[], [], [], []] //pickview 列表选项,0-类型,1-电压,2-串数,3-电流
    
    private let batteryTypeOptions = ["LiHv", "LiPo", "Lilon", "LiFe", "Pb", "NiMH/Cd"]
    //不同电池类型对应的电压、串数、电流数据
    private var batteryTypeSettings: [String: [Int]] = [
        "LiHv": [4350, 1, 100],   // [电压(mV), 串数, 电流(mA)]
        "LiPo": [4200, 1, 100],
        "Lilon": [4100, 1, 100],
        "LiFe": [3650, 1, 100],
        "Pb": [2400, 1, 100],
        "NiMH/Cd": [8, 1, 100]    // NiMH/Cd 电压单位是 mV (8mV)
    ]
    

    // 电池类型对应的电压范围和步进
    private let voltageConfigs: [String: (min: Double, max: Double, step: Double)] = [
        "LiHv": (4.25, 4.45, 0.02),  // 4.25-4.45V，步进0.02V
        "LiPo": (4.15, 4.25, 0.01),  // 4.15-4.25V，步进0.01V
        "Lilon": (4.05, 4.15, 0.01), // 4.05-4.15V，步进0.01V
        "LiFe": (3.60, 3.70, 0.01),  // 3.60-3.70V，步进0.01V
        "Pb": (2.35, 2.45, 0.01),    // 2.35-2.45V，步进0.01V
        "NiMH/Cd": (0.003, 0.013, 0.001) // 3-13mV，步进 1 mV
    ]

    // 电流选项：0.1-5.0A，步进0.1A
    private var currentOptions: [String] {
        var options: [String] = []
        for i in 1...50 { // 0.1 * 10 = 1, 5.0 * 10 = 50
            let current = Double(i) / 10.0
            options.append(String(format: "%.1fA", current))
        }
        return options
    }

    // 串数选项：1-6S
    private var cellCountOptions: [String] {
        var options: [String] = []
        for i in 1...6 {
            options.append("\(i)S")
        }
        return options
    }
    
    // NiMH/Cd 串数选项
    private var nimhCellOptions: [String] {
        return [NSLocalizedString("C4-Auto", comment: "自动")]
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)

        additionalSetup1()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    // MARK: - Private Methods
    private func additionalSetup1(){
        
        // Configure scroll view
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // Configure content view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.snp.remakeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView.snp.width) // 显式绑定宽度，防止歧义
        }
        

        // --- Baselist Table ---
        baselistV.layer.cornerRadius = 10
        baselistV.clipsToBounds = true
        baselistV.tag = 0
        baselistV.dataSource = self
        baselistV.delegate = self
        baselistV.register(ChargePageCell.self, forCellReuseIdentifier: "chargePagecell")
        baselistV.backgroundColor = .clear
        baselistV.separatorStyle = .none
        baselistV.isScrollEnabled = false
        baselistV.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(baselistV)
        baselistV.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview().inset(0) // 全宽
            make.height.equalTo(calculateTableViewHeight1(tableviewTag: 0))
        }

        // --- Charge Setting Table ---
        chargeSetting.layer.cornerRadius = 10
        chargeSetting.clipsToBounds = true
        chargeSetting.tag = 1
        chargeSetting.dataSource = self
        chargeSetting.delegate = self
        chargeSetting.register(ChargeSettingCell.self, forCellReuseIdentifier: "chargeSettingcell")
        chargeSetting.backgroundColor = .clear
        chargeSetting.separatorStyle = .none
        chargeSetting.isScrollEnabled = false
        chargeSetting.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(chargeSetting)
        chargeSetting.snp.makeConstraints { make in
            make.top.equalTo(baselistV.snp.bottom).offset(15)
            make.left.right.equalToSuperview().inset(0)
            make.height.equalTo(calculateTableViewHeight1(tableviewTag: 1))
        }

        // --- Output Button ---
        outputBtn.translatesAutoresizingMaskIntoConstraints = false
        outputBtn.backgroundColor = UIColor(named: "DP_072713ff")
        outputBtn.layer.borderColor = UIColor(named: "DP_00FF2B")!.cgColor//UIColor(named: "DP_262626")!.cgColor
        outputBtn.layer.borderWidth = 1
        outputBtn.layer.cornerRadius = 10
        
        contentView.addSubview(outputBtn)
        outputBtn.snp.makeConstraints { make in
            make.top.equalTo(chargeSetting.snp.bottom).offset(15)
            make.left.right.equalToSuperview()
            make.height.equalTo(60)
            make.bottom.equalToSuperview()
        }
        
        let containerBg = UIView()
        outputBtn.addSubview(containerBg)
        containerBg.snp.makeConstraints { make in
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        let outputImgV = UIImageView(image: UIImage(named: "DP_switch")?.withRenderingMode(.alwaysTemplate))
        containerBg.addSubview(outputImgV)
        outputImgV.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        outputImgV.tintColor = UIColor(named: "DP_00FF2B")

        let outputTitleL = UILabel()
        containerBg.addSubview(outputTitleL)
        outputTitleL.snp.makeConstraints { make in
            make.left.equalTo(outputImgV.snp.right).offset(6)
            make.right.equalToSuperview()
            make.centerY.equalToSuperview().offset(-1)
        }
        outputTitleL.textColor = UIColor(named: "DP_00FF2B")
        outputTitleL.font = UIFont(name: kSourceHanSansCN_Regular, size: 16)
        outputTitleL.text = multilingualText[0]
        
        //让 containerBg 及其子视图不参与事件响应，这样点击会穿透到 outputBtn
        containerBg.isUserInteractionEnabled = false
        outputImgV.isUserInteractionEnabled = false
        outputTitleL.isUserInteractionEnabled = false
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            print("=== DP3005ChargePageV 布局信息 ===")
//            print("scrollView.contentSize:", self.scrollView.contentSize)
//            print("scrollView.bounds:", self.scrollView.bounds)
//            print("scrollView frame:", self.scrollView.frame)
//            print("contentView frame:", self.contentView.frame)
//        }
    
    }
    //MARK: - pickview
    
    //显示 pickview 列表
    private func showPickV(){

        if !ispickVCreate {
            backgroundView = createBackgroundView()
            setupPickerViewHierarchy(in: backgroundView)
            ispickVCreate = true
//            Log.debug("pickV Create")
        }

        // 先隐藏，等数据加载完再显示
        backgroundView.isHidden = true
        pickbgV.isHidden = true

        // 延迟到下一 runloop（确保 layout）
        DispatchQueue.main.async {
            // 先 reload 数据
            self.reloadPickerViewData()

            // 数据准备好后，再显示 UI（避免空白闪现）
            DispatchQueue.main.async {
                self.backgroundView.isHidden = false
                self.pickbgV.isHidden = false
            }
        }
        
    }

    
    private func createBackgroundView() -> UIView {

        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        self.addSubview(backgroundView)
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
        
        guard let selectedIndexPath = selectedTableviewIndexPath else { return }
        
        // 取消选中状态
        chargeSetting.deselectRow(at: selectedIndexPath, animated: true)
        
        // 清空保存的 indexPath
        self.selectedTableviewIndexPath = nil
        backgroundView.isHidden = true
        
        let newdata = settinginitalValueArr[selectedIndexPath.row-1]
        let remoteSettingI = selectedIndexPath.row
        
        updateChargeSettingValue(at: remoteSettingI-1, newValue: newdata)
        
        if remoteSettingI == 1 {
            //更新电池类型时,发送的数据中,要更改为该电池类型下对应的电压、串数、电流
            updateOthertypeVolUI(newdata)
            updateOthertypeCellsUI()
            updateOthertypeCurrentUI()
        }

    }

    
    private func reloadPickerViewData() {
        
        // 防止在 pickerView delegate 中触发重新加载
        guard !isReloadingPicker else { return }
        isReloadingPicker = true
        defer { isReloadingPicker = false }
        
        guard let selectedIndexPath = selectedTableviewIndexPath,
              selectedIndexPath.row > 0 && selectedIndexPath.row < 5 else {
            Log.debug("无效的选择行: \(selectedTableviewIndexPath?.row ?? -1)")
            return
        }
        
        // 临时禁用委托，避免触发 didSelectRow 和 viewForRow
        pickV.delegate = nil
        
        // 先准备所有数据
        var componentToReload = 0
        let batteryTypeIndex = typeStrTurntotypeI(currentBatteryType)
        guard let currentSettings = batteryTypeSettings[currentBatteryType] else { return }// 获取当前类型的配置

        switch selectedIndexPath.row {
        case 1: // 电池类型
            pickVdatas[0] = batteryTypeOptions
            componentToReload = 0
            
            if batteryTypeIndex < batteryTypeOptions.count {
                DispatchQueue.main.async {
                    self.pickV.selectRow(batteryTypeIndex, inComponent: 0, animated: false)
                }
            }
            
        case 2: // 电压
            let batteryTypeIndex = typeStrTurntotypeI(currentBatteryType)//settingItemValueArr[0]
            let batteryType = currentBatteryType//batteryTypeOptions[batteryTypeIndex]
            let voltageOptions = getVoltageOptions(for: batteryType)
            pickVdatas[1] = voltageOptions
            componentToReload = 1
            
            let currentVoltage = currentSettings[0]
            
            if batteryTypeIndex == 5 {
                let clampedVoltage = max(3, min(13, currentVoltage))
                let targetIndex = clampedVoltage - 3
                
                // 预计算星标行
                let targetVoltage = starVolvalue[batteryTypeIndex]
                starRowIndex = nil
                for (index, str) in voltageOptions.enumerated() {
                    let value = Int((str as NSString).doubleValue)
                    if value == targetVoltage {
                        starRowIndex = index
                        break
                    }
                }
                
                if targetIndex >= 0 && targetIndex < voltageOptions.count {
                    DispatchQueue.main.async {
                        self.pickV.selectRow(targetIndex, inComponent: 0, animated: false)
                    }
                }
            } else {
                let currentVoltageDisplay = String(format: "%.2fV", Double(currentVoltage) / 1000.0)
                
                let targetVoltage = starVolvalue[batteryTypeIndex]
                starRowIndex = nil
                for (index, str) in voltageOptions.enumerated() {
                    if displayValueToVoltage(str) == targetVoltage {
                        starRowIndex = index
                        break
                    }
                }

                if let voltageIndex = voltageOptions.firstIndex(of: currentVoltageDisplay) {
                    DispatchQueue.main.async {
                        self.pickV.selectRow(voltageIndex, inComponent: 0, animated: false)
                    }
                }
            }
            
        case 3: // 串数
           let cellOptions = getCellOptions(for: batteryTypeIndex)
           pickVdatas[2] = cellOptions
           componentToReload = 2
                   
           let currentCells = currentSettings[1]-1
            
           let selectedCellCountIndex = max(0, min(currentCells, cellOptions.count-1))
           DispatchQueue.main.async {
               self.pickV.selectRow(selectedCellCountIndex, inComponent: 0, animated: false)
           }
            
            
        case 4: // 电流
            pickVdatas[3] = currentOptions
            componentToReload = 3
            
            let current = currentSettings[2]//settingItemValueArr[3]
            let currentDisplay = String(format: "%.1fA", Double(current) / 1000.0)
            
            if let currentIndex = currentOptions.firstIndex(of: currentDisplay) {
                DispatchQueue.main.async {
                    self.pickV.selectRow(currentIndex, inComponent: 0, animated: false)
                }
            } else {
                DispatchQueue.main.async {
                    self.pickV.selectRow(0, inComponent: 0, animated: false)
                }
            }
            
        default:
            break
        }
        
        // 确保数据已设置后再重新启用委托并刷新
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 重新启用委托
            self.pickV.delegate = self
            
            // 刷新对应的 component
            if componentToReload < self.pickV.numberOfComponents {
                self.pickV.reloadComponent(componentToReload)
            }
        }
        
    }

    
    // MARK: - Public Methods
    
    func expandBselist(isEnble: Bool){
        
        toggleBaselist1(isEnble)
        chargeSetting.isHidden = isEnble
        
        if !isEnble{
            let indexPath = IndexPath(row: 0, section: 0)
            baselistV.reloadRows(at: [indexPath], with: .automatic)
        }
        
    }
    
    ///设置输出开关
    ///isEnble: 是否开启输出, isRemoteOpen: 是否开启远程
    func setOutput1(isEnble: Bool){

        outputBtn.isSelected = isEnble
        outputBtn.layer.borderColor = UIColor(named: "DP_00FF2B")!.cgColor
        outputBtn.backgroundColor = UIColor(named: isEnble ? "DP_00FF2B" : "DP_072713ff")
        
        let containerBg = outputBtn.subviews[0]
        if let imgV = containerBg.subviews[0] as? UIImageView{
            imgV.tintColor = isEnble ? .black : UIColor(named: "DP_00FF2B")
        }
        
        if let label = containerBg.subviews[1] as? UILabel{
            label.textColor = isEnble ? .black : UIColor(named: "DP_00FF2B")
            label.text = isEnble ? NSLocalizedString("OutputOn", comment: "输出开启") : NSLocalizedString("OutputOff", comment: "OUTPUT")
        }
    }
    
    
    // dataI:  0-电流(mA)、1-容量(mAh)、2-类型、3-串数、4-电压(10mV)、5-能量(mWh)、6-时间、7-功率(10mW)
    func updateBaselistValue(at dataI: Int, newValue: Int) {
        
        guard dataI < baselistItemValueArr.count else {
            Log.debug("数据索引大于 baselistItemValueArr 总数")
            return
        }

        baselistItemValueArr[dataI] = newValue

        var actualRow = 0
        switch dataI{
            case 0...1:
                actualRow = 0
            case 2...3:
                actualRow = 1
            case 4...7:
                actualRow = dataI-2
                
            default: break
        }
        // 查找 dataI 在当前显示列表中的位置
        if let displayRowIndex = baseListDisplayIndexes.firstIndex(of: actualRow) {
            let indexPath = IndexPath(row: displayRowIndex, section: 0)

            if let cell = baselistV.cellForRow(at: indexPath) as? ChargePageCell {
              Log.debug("单元格可见，重新配置，dataI=  \(dataI), displayRow=   \(displayRowIndex)")
              listTitleConfiguration1(for: cell, at: indexPath)
            } else {
              Log.debug("单元格不可见或已回收，reload row=   \(displayRowIndex)")
              DispatchQueue.main.async {
                  self.baselistV.reloadRows(at: [indexPath], with: .none)
              }
            }
        } else {
            // dataI 不在当前显示列表中（例如 isOutputOpen=false 时 dataI=0 不显示）
            Log.debug("dataI=   \(dataI) 当前不显示，无需刷新 UI")
            return
        }
    }

    /// 更新充电设置特定行的值
    /// - Parameters:
    ///   - dataI: model 数据索引
    ///   - newValue: 新值
    /// - Note:
    ///  dataI: 0-3 -> tableviewRowI: 1-4
    ///  dataI: 4-5 -> tableviewRowI: 6 ;
    ///  dataI: 6-8 -> tableviewRowI: 7-9
    ///  0-电池类型(0:LiHv 1:LiPo 2:Lilon 3:LiFe 4:Pb 5:NiMH/Cd), 1-满充电压(mV), 2-串数(1~6), 3-电流(mA), 4-上一次充电电池类型, 5-上一次充电电池串数, 6-上一次充电容量(mAH), 7-上一次充电能量(mWh), 8-上一次充电时间(s)
    func updateChargeSettingValue(at dataI: Int, newValue: Int) {
        
        guard dataI < 9 else { return }
        
        settinginitalValueArr[dataI] = newValue
        
        if dataI < 4 {//保存不同电池类型的电压、串数、电流
            if dataI == 0 {
                currentBatteryType = batteryTypeOptions[newValue]
            }else{
                batteryTypeSettings[currentBatteryType]?[dataI-1] = newValue
            }
        }
        
//        Log.debug("update Charge Setting Value, dataI= \(dataI), newValue= \(newValue)")
        // 刷新特定的单元格
        let actualRow = dataI == 4 || dataI == 5 ? 6 : dataI+1
        let indexPath = IndexPath(row: actualRow, section: 0)
        if let cell = chargeSetting.cellForRow(at: indexPath) as? ChargeSettingCell {
            updateCellDisplay1(cell, at: indexPath)
        }
        
    }
    
    // 批量更新所有值
    func updateAllChargeSettingValues(newValues: [Int]) {
        guard newValues.count == settinginitalValueArr.count else { return }
        
        for dataI in 0..<newValues.count{
            updateChargeSettingValue(at: dataI, newValue: newValues[dataI])
        }
    }
    
}

//MARK: - UITableViewDataSource
extension ChargePageV: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if tableView.tag == 0 {
            return baseListDisplayIndexes.count
        }else if tableView.tag == 1 {
            return displayItems.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if tableView.tag == 1 {
            //设置部分
            let cell = tableView.dequeueReusableCell(withIdentifier: "chargeSettingcell", for: indexPath) as! ChargeSettingCell
            listItemConfiguration1(for: cell, at: indexPath)
            return cell
            
        }else if tableView.tag == 0 {
            //充电部分
            let cell = tableView.dequeueReusableCell(withIdentifier: "chargePagecell", for: indexPath) as! ChargePageCell
            listTitleConfiguration1(for: cell, at: indexPath)
            return cell
            
        }else {
            let cell = UITableViewCell()
            return cell
        }
        
    }
    
    private func listTitleConfiguration1(for cell: ChargePageCell,at indexPath: IndexPath){
       
        let actualCellIndex = baseListDisplayIndexes[indexPath.row]
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == baseListDisplayIndexes.count - 1
        let isSpecial = isOutputOpen && indexPath.row == 0
        
        // 配置 cell 样式
        cell.isUserInteractionEnabled = false
        cell.backgroundColor = .clear
        cell.titleL.text = Array(multilingualText[1...6])[actualCellIndex] //itemTitleArr[actualIndex]
        cell.uintL.attributedText = bahnschrift_formatted(actualCellIndex == 0 ? "" : itemUintArr[actualCellIndex])
        
        cell.configurePosition1(isFirst: isFirst, isLast: isLast)
        if isDiscon {
            cell.configureDiscon(isSpecial: isSpecial, isOutputOpen: isOutputOpen)
        }else{
            cell.configureColor1(isSpecial: isSpecial, isOutputOpen: isOutputOpen, isFullChargeIndicator: isFullChargeIndicator)
        }
        
//        // 配置cell数据
//        //actualCellIndex: 0-电流(mA)+容量(mAh)、1-类型+串数、2-电压(10mV)、3-能量(mWh)、4-时间、5-功率(10mW)
//        //baselistItemValueArr dayaI: 0-电流(mA)、1-容量(mAh)、2-类型、3-串数、4-电压(10mV)、5-能量(mWh)、6-时间、7-功率(10mW)
        switch actualCellIndex{
        case 0:
            cell.titleL.attributedText = bahnschrift_formatted("\((Double(baselistItemValueArr[0])/1000).formatted())", 48, baseline: -2)+bahnschrift_formatted("A", 24, weight: .bold, baseline: -1)
            cell.valueL.attributedText = bahnschrift_formatted("\(baselistItemValueArr[1])", 48)+bahnschrift_formatted("mAh", 24, weight: .bold)
            
        case 1:
            cell.valueL.attributedText = bahnschrift_formatted(batteryTypeOptions[baselistItemValueArr[2]])
            let str = NSLocalizedString("C4-Auto", comment: "自动")
            cell.uintL.attributedText = bahnschrift_formatted(baselistItemValueArr[2] == 5 ? str : "\(baselistItemValueArr[3])S")
            
        case 2:
            let str = "\((Double(baselistItemValueArr[4]*10)/1000).formatted(decimalPlaces: 2))"
            cell.valueL.attributedText = bahnschrift_formatted(str)
            
            
        case 3:
            let str = "\((Double(baselistItemValueArr[5])/1000).formatted(decimalPlaces: 2))"
            cell.valueL.attributedText = bahnschrift_formatted(str)
            
        case 4:
            let str = TimeFormatter.string(from: baselistItemValueArr[6], style: .hoursMinutesSeconds)
            cell.valueL.attributedText = bahnschrift_formatted(str)
            
        case 5:
            let str = "\((Double(baselistItemValueArr[7]*10)/1000).formatted(decimalPlaces: 2))"
            cell.valueL.attributedText = bahnschrift_formatted(str)
            
        default: break
        }
        
    }
    
    private func listItemConfiguration1(for cell: ChargeSettingCell,at indexPath: IndexPath){
        
        if indexPath.row == 0 {
//            Log.debug("Configuration 第0行: \(indexPath.row)")
            // 第0行：标题行
            cell.isUserInteractionEnabled = false
            cell.backgroundColor = UIColor(named: "DP_404040ff")
            cell.titleImagV.isHidden = true
            cell.directionImgV.isHidden = true
            cell.valueL.isHidden = true
            cell.titleL.font = UIFont(name: kSourceHanSansCN_Regular, size: 16)
            cell.titleL.text = multilingualText[7]//settingItemTitleArr[0]
            cell.titleL.snp.remakeConstraints { make in
                make.left.equalToSuperview().offset(15)
                make.centerY.equalToSuperview().offset(-2)
            }
            
        } else if indexPath.row >= 1 && indexPath.row <= 5 {
//            Log.debug("Configuration 第1-5行: \(indexPath.row)")
            // 第1-5行：可交互的设置行
            cell.isUserInteractionEnabled = true
            cell.backgroundColor = UIColor(named: "DP_262626")
            cell.titleL.textColor = UIColor(named: "DP_999999")
            cell.titleL.font = UIFont(name: kSourceHanSansCN_Regular, size: 20)
            cell.valueL.font = UIFont(name: kSourceHanSansCN_Regular, size: 20)
            
            // 设置标题和图标
            if indexPath.row < Array(multilingualText[7..<multilingualText.count]).count {
                cell.titleL.text = Array(multilingualText[7..<multilingualText.count])[indexPath.row]//settingItemTitleArr[indexPath.row]
            }
            if (indexPath.row - 1) < settingImgArr.count {
                cell.titleImagV.image = UIImage(named: settingImgArr[indexPath.row - 1])?.withRenderingMode(.alwaysTemplate)
                cell.titleImagV.tintColor = UIColor(named: "DP_999999")
            }
            
            // 第5行特殊处理（展开/折叠按钮）
            if indexPath.row == 5 {
                cell.directionImgV.isHidden = false
                cell.valueL.isHidden = true
                let indicatorName = isExpanded ? "DP_LastDataUp" : "DP_LastDataDown"
                cell.directionImgV.image = UIImage(named: indicatorName)?.withRenderingMode(.alwaysTemplate)
                cell.directionImgV.tintColor = UIColor(named: "DP_ffffffff")
            } else {
                // 第1-4行：显示数值, tableviewRowI: 1-4 -> dataI: 0-3
                cell.directionImgV.isHidden = true
                cell.valueL.isHidden = false
                if (indexPath.row - 1) < settinginitalValueArr.count {
//                    cell.valueL.text = settingDataTurntoLabeltext(indexPath.row, newValue: settingItemValueArr[indexPath.row - 1])
                    updateCellDisplay1(cell, at: indexPath)
                }
            }
                
        } else {
//            Log.debug("Configuration 第6-9行: \(indexPath.row)")
            // 第6-9行：展开后的额外信息行（不可交互）
            cell.isUserInteractionEnabled = false
            cell.backgroundColor = UIColor(named: "DP_ffffffff")
            cell.titleL.textColor = UIColor(named: "DP_999999")
            cell.titleL.snp.remakeConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalTo(15)
            }
            
            cell.titleImagV.isHidden = true
            cell.directionImgV.isHidden = true
            cell.valueL.isHidden = false
            
            if indexPath.row < Array(multilingualText[7..<multilingualText.count]).count {
                let str = Array(multilingualText[7..<multilingualText.count])[indexPath.row]//settingItemTitleArr[indexPath.row]
//                cell.titleL.attributedText = formattedString(str, weight: .light)
                cell.titleL.text = str
            }
            if indexPath.row - 2 < settinginitalValueArr.count {
                updateCellDisplay1(cell, at: indexPath)
            }
        }
    
    }
    
}
//MARK: - UITableViewDelegate
extension ChargePageV: UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 0{
            guard !baseListDisplayIndexes.isEmpty else { return 0 }
                
            let actualIndex = baseListDisplayIndexes[indexPath.row]
            var height: CGFloat = (actualIndex == 0) ? 80 : 50
            
            // 如果不是最后一行，加上 1pt 间距
            if indexPath.row < baseListDisplayIndexes.count - 1 {
                height += 1 //让行高本身包含间距,tableView 外部容器高度=内部 contentSize
            }
            
            return height
        }
        return 41
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        Log.debug("tableView didSelectRowAt row : \(indexPath.row)")
        
        if tableView.tag == 1 {
            // 保存选中的 indexPath
            selectedTableviewIndexPath = indexPath
            
            switch indexPath.row {
            case 1...4:
                showPickV() //显示选择器
                
            case 5:
                toggleExpansion1()
                
            default: tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    
    //展开充电 view
    private func toggleBaselist1(_ bool: Bool){
        
//        Log.debug("isOutputOpen: \(bool), isFullChargeIndicator: \(isFullChargeIndicator), isDiscon:\(isDiscon)")
        
        isOutputOpen = bool
        
        UIView.animate(withDuration: 0.3) {
            self.baselistV.snp.updateConstraints { make in
                make.height.equalTo(self.calculateTableViewHeight1(tableviewTag: 0))
            }
            self.layoutIfNeeded()
        }
        
        baselistV.reloadData()

        outputBtn.snp.remakeConstraints { make in
            if isOutputOpen{
                make.top.equalTo(baselistV.snp.bottom).offset(15)
            }else{
                make.top.equalTo(chargeSetting.snp.bottom).offset(15)
            }
            make.left.right.equalToSuperview()
            make.height.equalTo(60)
            make.bottom.equalToSuperview()
        }
        
    }
    
    //展开充电设置里的 last data view
    private func toggleExpansion1() {
        
        guard let selectedIndexPath = selectedTableviewIndexPath else { return }
        
        isExpanded.toggle()
        if !isExpanded {
            chargeSetting.deselectRow(at: selectedIndexPath, animated: true)// 取消选中状态
        }
        
        if let cell = chargeSetting.cellForRow(at: selectedIndexPath) as? ChargeSettingCell {
            let indicatorName = isExpanded ? "DP_LastDataUp" : "DP_LastDataDown"
            cell.directionImgV.image = UIImage(named: indicatorName)?.withRenderingMode(.alwaysTemplate)
            cell.directionImgV.tintColor = UIColor(named: "DP_ffffffff")
        }
        
        // 使用 performBatchUpdates 进行动画
        chargeSetting.performBatchUpdates({
            if self.isExpanded {
                // 展开：插入第6-9行
                let indexPathsToInsert = [
                    IndexPath(row: 6, section: 0),
                    IndexPath(row: 7, section: 0),
                    IndexPath(row: 8, section: 0),
                    IndexPath(row: 9, section: 0)
                ]
                self.chargeSetting.insertRows(at: indexPathsToInsert, with: .fade)
            } else {
                // 折叠：删除第6-9行
                let indexPathsToDelete = [
                    IndexPath(row: 6, section: 0),
                    IndexPath(row: 7, section: 0),
                    IndexPath(row: 8, section: 0),
                    IndexPath(row: 9, section: 0)
                ]
                self.chargeSetting.deleteRows(at: indexPathsToDelete, with: .fade)
            }
        }) { _ in
            // 动画完成后更新表格高度
            UIView.animate(withDuration: 0.2) {
                self.chargeSetting.snp.updateConstraints { make in
                    make.height.equalTo(self.calculateTableViewHeight1(tableviewTag: 1))
                }
                self.layoutIfNeeded()
            }
        }
        
//        Log.debug("表格状态: \(isExpanded ? "展开" : "折叠")")

    }

    private func calculateTableViewHeight1(tableviewTag: Int) -> CGFloat {

        if tableviewTag == 0  {
            //法一:
            let totalHeight = baseListDisplayIndexes.reduce(0) { result, index in
                return result + (index == 0 ? 80 : 50) + (index == baseListDisplayIndexes.last ? 0 : 2)
            }
//            Log.debug("CGFloat(totalHeight): \(CGFloat(totalHeight))")
            //法二:
//            guard !baseListDisplayIndexes.isEmpty else { return 0 }
//
//            let rowHeights = baseListDisplayIndexes.map { index in
//                return index == 0 ? 80.0 : 50.0
//            }
//
//            let totalRowHeight = rowHeights.reduce(0, +)
//
//            // 行间距数量 = 行数 - 1
//            let spacingCount = CGFloat(baseListDisplayIndexes.count - 1)
//            let totalSpacing = spacingCount * 2.0
            
//            Log.debug("CGFloat(totalHeight): \(CGFloat(totalHeight)), \(totalRowHeight + totalSpacing)")
            
            return CGFloat(totalHeight)
        }else{
            let rowHeight: CGFloat = 41
            let numberOfRows = displayItems.count
            
//            Log.debug("calculate TableView Height numberOfRows: \(numberOfRows)")
            
            return rowHeight * CGFloat(numberOfRows)
        }
    }
    
}

//MARK: - UIPickerViewDelegate + UIPickerViewDataSource
extension ChargePageV: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        guard let selectedIndexPath = selectedTableviewIndexPath else { return 0 }
        switch selectedIndexPath.row {
            case 1: return batteryTypeOptions.count
            case 2:
                let batteryTypeIndex = typeStrTurntotypeI(currentBatteryType)//settingItemValueArr[0]
                let batteryType = batteryTypeOptions[batteryTypeIndex]
                return getVoltageOptions(for: batteryType).count
            case 3:
                let batteryTypeIndex = typeStrTurntotypeI(currentBatteryType)//settingItemValueArr[0]
                return batteryTypeIndex == 5 ? nimhCellOptions.count : cellCountOptions.count
            case 4: return currentOptions.count
            default: return 0
            }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        36
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        300
    }

    /// 更新 电池类型电压范围
    /// - Parameters:
    ///   - typeI: 电池类型索引
    func updateOthertypeVolUI(_ typeI: Int){

        if let currentSettings = batteryTypeSettings[currentBatteryType] {
            let cellIndexPath = IndexPath(row: 2, section: 0)
            guard let cell = chargeSetting.cellForRow(at: cellIndexPath) as? ChargeSettingCell else {
                return
            }
            
            let typeIndex = settinginitalValueArr[0]//settingItemValueArr[0]
            let voltageValue = currentSettings[0]//settingItemValueArr[1]
            
            if typeIndex == 5 {
                let str = String(format: "-Δ%.fmV", Double(voltageValue))
                cell.valueL.attributedText = bahnschrift_formatted(str)
            }else{
                let str = String(format: "%.2fV", Double(voltageValue) / 1000.0)
                cell.valueL.attributedText = bahnschrift_formatted(str)
            }
            Log.debug("updateOthertypeVolUI 电压单元格已更新: \(voltageValue)，电池类型: \(currentBatteryType)")
            
        }
        
    }
    
    func updateOthertypeCellsUI(){
        
        if let currentSettings = batteryTypeSettings[currentBatteryType] {
            let cellIndexPath = IndexPath(row: 3, section: 0)
            guard let cell = chargeSetting.cellForRow(at: cellIndexPath) as? ChargeSettingCell else {
                return
            }
            let typeIndex = settinginitalValueArr[0]//settingItemValueArr[0]
            if typeIndex == 5 {
                let str = NSLocalizedString("C4-Auto", comment: "自动")//GetCurrentLanguage() == "cn" ? "自动" : "Auto"
                cell.valueL.attributedText = bahnschrift_formatted(str)
            }else{
                let cellCountIndex = currentSettings[1]  // 如果为 nil，使用 1 作为默认值
                let str = "\(cellCountIndex)S"
                cell.valueL.attributedText = bahnschrift_formatted(str)
            }
            Log.debug("串数单元格已更新: \(cell.valueL.text ?? "")，电池类型: \(currentBatteryType)")
            
        }
        
    }
    
    func updateOthertypeCurrentUI(){
        
        if batteryTypeSettings[currentBatteryType] != nil {
            let cellIndexPath = IndexPath(row: 4, section: 0)
            guard let cell = chargeSetting.cellForRow(at: cellIndexPath) as? ChargeSettingCell else {
                return
            }
            
            let currentValue = batteryTypeSettings[currentBatteryType]?[2] ?? 1000//settingItemValueArr[3]
            let str = String(format: "%.1fA", Double(currentValue) / 1000.0)
            cell.valueL.attributedText = bahnschrift_formatted(str)
            
            Log.debug("电流单元格已更新: \(cell.valueL.text ?? "")，电池类型: \(currentBatteryType)")
            
        }
        
    }

    // 滚动时实时更新 valueL
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
 
        guard !isReloadingPicker else { return } // 防止递归
            
        guard let selectedIndexPath = selectedTableviewIndexPath else { return }
        
        switch selectedIndexPath.row {
        case 1:
            oldBatteryType = currentBatteryType
            currentBatteryType = batteryTypeOptions[row]
            settinginitalValueArr[0] = row
            
            
        case 2: // 电压
            let batteryTypeIndex = typeStrTurntotypeI(currentBatteryType)//settingItemValueArr[0]
            let batteryType = batteryTypeOptions[batteryTypeIndex]
            let voltageOptions = getVoltageOptions(for: batteryType)
            
            if row < voltageOptions.count {
                let voltageString = voltageOptions[row]
                
                if batteryTypeIndex != 5 {
                    let voltageValue = displayValueToVoltage(voltageString)
                    settinginitalValueArr[1] = voltageValue
                    batteryTypeSettings[currentBatteryType]?[0] = voltageValue
                }else{
//                    let voltageValue = displayValueToVoltage_NiMhCd(voltageString)
                    let voltageValue = Int((voltageString as NSString).doubleValue)
                    settinginitalValueArr[1] = voltageValue
                    batteryTypeSettings[currentBatteryType]?[0] = voltageValue
                }
//                Log.debug("batteryType: \(batteryType), voltageString, \(voltageString), settingItemValueArr[1]= \(settinginitalValueArr[1])")
            }
            
        case 3: // 串数
            let batteryTypeIndex = typeStrTurntotypeI(currentBatteryType)//settingItemValueArr[0]
            let cellOptions = getCellOptions(for: batteryTypeIndex)//generateCellsOptions(for: batteryType)
            
            if row < cellOptions.count {
                let cellString = cellOptions[row]
                let cellValue = displayValueToCellIndex(cellString)
                settinginitalValueArr[2] = row+1
                batteryTypeSettings[currentBatteryType]?[1] = row+1
                Log.debug("串数范围: \(cellOptions), cellValue= \(cellValue), settingItemValueArr[2]= \(row+1)")
               
            }
            
        case 4: // 电流
            if row < currentOptions.count {
                let currentString = currentOptions[row]
                let currentValue = displayValueToCurrentIndex(currentString)
                settinginitalValueArr[3] = currentValue
                batteryTypeSettings[currentBatteryType]?[2] = currentValue
                
                Log.debug(" currentString, \(currentString), settingItemValueArr[3] : \(currentValue)")
            }
            
        default:
            break
        }
        
    }
    
    //设置选择器选项 view
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
       
        // 重用或创建自定义视图
        let customView: CustomviewWithIcons
        if let reusedView = view as? CustomviewWithIcons {
            customView = reusedView
        } else {
            customView = CustomviewWithIcons()
            customView.frame = CGRect(x: 0, y: 0, width: pickerView.frame.width, height: 40)
        }
        
        // 安全检查
        guard let selectedIndexPath = selectedTableviewIndexPath else {
            customView.configure(imageName: nil, title: "", showImage: false)
            return customView
        }
        
        let dataIndex = selectedIndexPath.row - 1 //0-类型,1-电压,2-串数,3-电流
        
        // 检查索引是否在有效范围内
        guard dataIndex >= 0 && dataIndex < pickVdatas.count else {
            Log.debug("dataIndex 超出范围: dataIndex=\(dataIndex), pickVdatas.count=\(pickVdatas.count)")
            customView.configure(imageName: nil, title: "", showImage: false)
            return customView
        }
        
        let currentDataArray = pickVdatas[dataIndex]
        
        // 检查行索引是否在有效范围内
        guard row >= 0 && row < currentDataArray.count else {
            Log.debug("row 超出范围: row=\(row), currentDataArray.count=\(currentDataArray.count)")
            customView.configure(imageName: nil, title: "", showImage: false)
            return customView
        }
        
        
        // 配置视图
        let shouldShowImage = (dataIndex == 1) && (row == starRowIndex) //该行是否显示星标图像
        let imageName = shouldShowImage ? "DP_Star" : nil
        let titleText = currentDataArray[row]
        
        // 配置视图
        customView.configure(imageName: imageName, title: titleText, showImage: shouldShowImage)
        
   
        return customView
        
    }
    
    //MARK: -

    // 更新表格 value 显示
    //tableviewRowI(indexPath.row): 1-4 -> settingItemValueArr dataI: 0-3
    //tableviewRowI: 6   -> settingItemValueArr dataI: 4-5
    //tableviewRowI: 7-9 -> settingItemValueArr dataI: 6-8
    private func updateCellDisplay1(_ cell: ChargeSettingCell, at indexPath: IndexPath) {

        switch indexPath.row {
            case 1: // 电池类型
                let typeIndex = settinginitalValueArr[0]//settingItemValueArr[0]
                let str = batteryTypeOptions[typeIndex]
                cell.valueL.attributedText = bahnschrift_formatted(str)
                
            case 2: // 电压
                let typeIndex = settinginitalValueArr[0]//settingItemValueArr[0]
                let voltageValue = batteryTypeSettings[currentBatteryType]?[0]//settingItemValueArr[1]
                
                if typeIndex == 5 {
                    let str = String(format: "-Δ%.fmV", Double(voltageValue ?? starVolvalue[5]))
                    cell.valueL.attributedText = bahnschrift_formatted(str)
                }else{
                    let str = String(format: "%.2fV", Double(voltageValue ?? starVolvalue[typeIndex]) / 1000.0)
                    cell.valueL.attributedText = bahnschrift_formatted(str)
                }

            case 3: // 串数
                let typeIndex = settinginitalValueArr[0]//settingItemValueArr[0]
                if typeIndex == 5 {
                    let str = NSLocalizedString("C4-Auto", comment: "自动")//GetCurrentLanguage() == "cn" ? "自动" : "Auto"
                    cell.valueL.attributedText = bahnschrift_formatted(str)
                }else{
                    let cellCountIndex = batteryTypeSettings[currentBatteryType]?[1] ?? 1//settingItemValueArr[2]
                    let str = "\(cellCountIndex)S"
                    cell.valueL.attributedText = bahnschrift_formatted(str)
    //                Log.debug("updateCellDisplay1, settingItemValueArr[2]= \(String(describing: cellCountIndex))")
                }
           
            case 4: // 电流
                let currentValue = batteryTypeSettings[currentBatteryType]?[2] ?? 1000//settingItemValueArr[3]
                    let str = String(format: "%.1fA", Double(currentValue) / 1000.0)
                    cell.valueL.attributedText = bahnschrift_formatted(str)

            case 6: //上一次电池类型与电池串数
                let str = batteryTypeOptions[settinginitalValueArr[4]] + " \(settinginitalValueArr[5])S"
                cell.valueL.attributedText = bahnschrift_formatted(str)
            
            case 7:
                let str = "\(Double(settinginitalValueArr[6]).formatted(decimalPlaces: 2)) mAh"
                cell.valueL.attributedText = bahnschrift_formatted(str)
            
            case 8:
                let str = "\((Double(settinginitalValueArr[7])/1000).formatted(decimalPlaces: 2)) Wh"
                cell.valueL.attributedText = bahnschrift_formatted(str)
            
            case 9:
                let str = TimeFormatter.string(from: settinginitalValueArr[8], style: .hoursMinutesSeconds)
                cell.valueL.attributedText = bahnschrift_formatted(str)
            
        default:
            break
        }
    }
    
    //MARK: 电池类型
    //电池类型字符串转为电池类型 model 索引
    private func typeStrTurntotypeI(_ currentBatteryType: String) -> Int{
        switch currentBatteryType{ //["LiHv", "LiPo", "Lilon", "LiFe", "Pb", "NiMH/Cd"]
        case "LiHv": return 0
        case "LiPo": return 1
        case "Lilon": return 2
        case "LiFe": return 3
        case "Pb": return 4
        case "NiMH/Cd": return 5
        default: return 0
        }
    }
    
    //MARK: 电压
    // 当前电压值不在范围内，自动显示为新类型的默认电压值（第一行）
    private func updateVoltageCellDisplay(isSpecial:Bool = false) {
        let voltageIndexPath = IndexPath(row: 2, section: 0)
        if let cell = chargeSetting.cellForRow(at: voltageIndexPath) as? ChargeSettingCell {
//            let voltageValue = settingItemValueArr[1]
            let voltageValue = batteryTypeSettings[currentBatteryType]?[0]
            cell.valueL.text = isSpecial ? String(format: "-Δ%.fmV", Double(voltageValue ?? 8)) : String(format: "%.2fV", Double(voltageValue ?? 100) / 1000.0)
            Log.debug("updateVoltageCellDisplay isSpecial , 电压单元格已更新: \(cell.valueL.text ?? "")")
        }
    }
    
    // 根据电池类型生成电压选项
    private func generateVoltageOptions(for batteryType: String) -> [String] {
        guard let config = voltageConfigs[batteryType] else {
            return generateDefaultVoltageOptions()
        }
        
        var options: [String] = []
        
        // 使用整数计算避免浮点数精度问题
        let minValue = Int(config.min * 100) // 4.15 -> 415
        let maxValue = Int(config.max * 100) // 4.25 -> 425
        let stepValue = Int(config.step * 100) // 0.01 -> 1
        
        var current = minValue
        
        while current <= maxValue {
            let voltage = Double(current) / 100.0
            options.append(String(format: "%.2fV", voltage))
            current += stepValue
        }
        
//        Log.debug("生成电压选项 - 类型: \(batteryType), 范围: \(config.min)-\(config.max), 步进: \(config.step), 选项数量: \(options.count)")
        
        return options
        
    }
    
    // 默认电压选项（备用）
    private func generateDefaultVoltageOptions() -> [String] {
        var options: [String] = []
        for i in 415...425 { // 4.15V - 4.25V
            let voltage = Double(i) / 100.0
            options.append(String(format: "%.2fV", voltage))
        }
        return options
    }


    // 获取特定电池类型的电压选项
    private func getVoltageOptions(for batteryType: String) -> [String] {
        
//        Log.debug("获取电压选项 - 电池类型: '\(batteryType)'")
//            Log.debug("缓存键: \(voltageOptionsCache.keys)")
        
        // 检查缓存
           if let cached = voltageOptionsCache[batteryType] {
//               Log.debug("从缓存获取: \(cached.count) 个选项")
               return cached
           }
        
//        Log.debug("未找到缓存，生成新选项")
           
           var options: [String] = []
        
           switch batteryType {
           case "LiHv":
               for voltage in stride(from: 4.25, through: 4.45, by: 0.02) {
                   options.append(String(format: "%.2fV", voltage))
               }
               
           case "Lilon":
               for voltage in stride(from: 4.05, through: 4.15, by: 0.01) {
                   options.append(String(format: "%.2fV", voltage))
               }
           case "LiFe":
               for voltage in stride(from: 3.60, through: 3.70, by: 0.01) {
                   options.append(String(format: "%.2fV", voltage))
               }
           case "LiPo":
               for voltage in stride(from: 4.15, through: 4.25, by: 0.01) {
                   options.append(String(format: "%.2fV", voltage))
               }
           case "NiMH/Cd":
               for i in 3...13 {
                   options.append(String(format: "%.fmV", Double(i)))
               }
//               for i in 3...13 {
//                   options.append(String(format: "-Δ%.fmV", Double(i)))
//               }
           case "Pb":
               for voltage in stride(from: 2.35, through: 2.45, by: 0.01) {
                   options.append(String(format: "%.2fV", voltage))
               }
           default:
               options = ["4.20V"] // 默认值
           }
           
           // 存入缓存
           voltageOptionsCache[batteryType] = options
//        Log.debug("已存入缓存 - 键: '\(batteryType)'")
        
           return options
    }

    
    // 电压值转换辅助方法
    private func voltageToDisplayValue(_ voltage: Int) -> String {
        return String(format: "%.2fV", Double(voltage) / 1000.0)
    }

    private func displayValueToVoltage(_ displayValue: String) -> Int {
        let valueString = displayValue.replacingOccurrences(of: "V", with: "")
        return Int((valueString as NSString).doubleValue * 1000)
    }
    
    private func displayValueToVoltage_NiMhCd(_ displayValue: String) -> Int {
        // 1. 移除 "-Δ" 前缀
        let withoutPrefix = displayValue.replacingOccurrences(of: "-Δ", with: "")
        // 2. 移除 "mV" 后缀
        let valueString = withoutPrefix.replacingOccurrences(of: "mV", with: "")
        let voltageValue = Int((valueString as NSString).doubleValue)
        return voltageValue
    }
    

    //MARK: 电流
    // 电流值转换辅助方法
    private func displayValueToCurrentIndex(_ displayValue: String) -> Int {
        let valueString = displayValue.replacingOccurrences(of: "A", with: "")
        return Int((valueString as NSString).doubleValue * 1000)
    }
    
    //MARK: 串数
    
    // 便捷方法：根据电池类型获取串数选项
    private func getCellOptions(for batteryTypeIndex: Int) -> [String] {
        return batteryTypeIndex == 5 ? nimhCellOptions : cellCountOptions
    }
    
    private func displayValueToCellIndex(_ displayValue: String) -> Int {
        
        if displayValue == NSLocalizedString("C4-Auto", comment: "自动") {
            return 1
        }else{
            let valueString = displayValue.replacingOccurrences(of: "%.fS", with: "")
            return Int((valueString as NSString).doubleValue )
        }
        
    }
}


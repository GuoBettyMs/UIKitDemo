//
//  SettingPageV.swift
//  SwiftTest
//
//  Created by user on 2026/1/28.
//
//缩短或完全移除 section 0 和 section 1 之间的间距; 设置每个 section 的圆角,最后一个 cell 底部圆角;当类型改变时，可重新配置 UI

import UIKit
import SnapKit

//通过 delegate 回调操作 vc.initialPresetListDatas,避免视图层直接修改数据
protocol SettingPageViewDelegate: AnyObject {
    func settingPageView(_ view: SettingPageV, didUpdateValue value: Int, at dataIndex: Int)
}

class SettingPageV: BaseV{
    
    var settingType: SettingType {
        didSet {
            // 当类型改变时，重新配置 UI
            Log.debug("updateUI type= \(settingType)")
            tab.reloadSections([0], with: .none)//使用 .none 动画避免闪烁
        }
    }
    weak var settingPageViewDelegate: SettingPageViewDelegate?
    let menuBtn = UIButton()
    private var tab = UITableView()
    private var verStr = "-"
    
    //section 0 的初始值
    private var initialValueStrs = ["90%",
                                    NSLocalizedString("MAG20-High", comment: "高"),
                                    NSLocalizedString("ZIP-Off", comment: "关闭"),
                                    "30min", "Horizontal", "0.5V/0.1s",
                                    NSLocalizedString("ZIP-Off", comment: "关闭"),
                                    "50ms"]
    private let titleHintStrs = [[NSLocalizedString("MP305_ChargeHint", comment: "Cap maximum charge level to extend battery lifespan"),"","","", "","",""],["","",""]]
    private let titleImgVs = [["DP_chargeLimit", "DP_Volume","DP_AutoScreenOff",
                      "DP_AutoShutdown",  "DP_RampStep", "DP_UsbLineDrop", "DP_OCPDelay"],
                      ["DP_SystemSelfTest", "DP_FactoryReset", "DP_SystemVersion"]]
    private let titleStrs = [[NSLocalizedString("ChargeLimit", comment: "Charge Limit"),
                              NSLocalizedString("Volume", comment: "Volume"),
                              NSLocalizedString("AutoScreenOff", comment: "Auto Screen-Off"),
                              NSLocalizedString("AutoShutdown", comment: "Auto Shutdown"),
                              NSLocalizedString("RampStep", comment: "Ramp Step"),
                              NSLocalizedString("USBLineDrop", comment: "USB Line Drop"),
                              NSLocalizedString("OCPDelay", comment: "OCP Delay")],
                             [NSLocalizedString("SystemSelfTest", comment: "System Self-Test"),
                              NSLocalizedString("FactoryReset", comment: "Factory Reset"),
                              NSLocalizedString("SystemVersion", comment: "System Version")]]
    private let multilingualText = [NSLocalizedString("Off", comment: "关闭"),
                                    NSLocalizedString("Low", comment: "低"),
                                    NSLocalizedString("Middle", comment: "中"),
                                    NSLocalizedString("High", comment: "高"),
                                    NSLocalizedString("Portraitmode", comment: "竖屏"),
                                    NSLocalizedString("Landscapemode", comment: "横屏"),
                                    NSLocalizedString("GeneralSettings", comment: "通用设置"),
                                    NSLocalizedString("SystemSettings", comment: "System Settings")]
    
    // MARK: - Initialization
    
    // 在初始化时传入类型
    init(frame: CGRect, type: SettingType) {
        self.settingType = type  // ← 先初始化属性
        super.init(frame: frame)  // ← 再调用 super.init
        additionalSetup1()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func additionalSetup1(){
        
        let btnBg = UIView()
        addSubview(btnBg)
        btnBg.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(90)
        }
        btnBg.backgroundColor = .black
        btnBg.layer.cornerRadius = 35
        btnBg.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        
        btnBg.addSubview(menuBtn)
        menuBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(12)
            make.height.equalTo(50)
        }
        menuBtn.backgroundColor = UIColor(named: "DP_181818ff")
        menuBtn.setImage(UIImage(named: "DP_menu"), for: .normal)
        menuBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6) // 图片右边距
        menuBtn.setTitle("tableview 可点击", for: .normal)
        menuBtn.setTitleColor(UIColor(named: "DP_ffffffff")!, for: .normal)
        menuBtn.titleLabel?.font = UIFont(name: kSourceHanSansCN_Regular, size: 16)!
        menuBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0) //标签左边距
        menuBtn.layer.cornerRadius = 25
        
        
        tab = UITableView(frame: .zero, style: .grouped)
        addSubview(tab)
        tab.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalTo(btnBg.snp.top)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        tab.dataSource = self
        tab.delegate = self
        tab.tag = 0
        tab.register(SettingsCell.self, forCellReuseIdentifier: "settingscell")
        tab.backgroundColor = .clear
        tab.separatorStyle = .none
        tab.showsVerticalScrollIndicator = false
        tab.showsHorizontalScrollIndicator = false
        
        if #available(iOS 15.0, *) {
            tab.sectionHeaderTopPadding = 0  // Removes top spacing in grouped tables
        }else{
            // Fallback for earlier versions
            tab.contentInset = UIEdgeInsets(top: -1, left: 0, bottom: 0, right: 0) //修复 UITableView 顶部多余的间距。
            tab.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))//设置最小高度的透明 header（覆盖系统间距）,leastNormalMagnitude 是系统能识别的最小正数（约 0.0000000000000000000000001），比 0 更安全（某些 iOS 版本会忽略 0）
        }
        
    }
    
    //MARK: - Public Methods
    ///设置 value 页面返回设置主页
    func backHome(){
        
        if let vc = self.parentViewController as? CustomPickViewVC {
            vc.currentPage = CustomPickviewPageIndex.settingHomepage
        }
        
        menuBtn.isUserInteractionEnabled = true
        changeMenuBtnUI(imgStr: "DP_menu")
        
        tab.tag = 0
        tab.reloadData()
    }
    
    /// 根据系统设置值更新 row 的 value 值,以及 value 列表的选中行
    /// - Parameters:
    ///   - data: model 数据设置值
    ///   - row: model 数据索引, 0-电量限制,1-声音,2-自动关闭屏幕​​​​,3-自动关机,5-斜坡步骤, 6-过流保护延迟, 9- USB线损补偿
    func updateRow(_ data: Int, at row: Int){

        switch row{
        case 0...3:
            guard row < initialValueStrs.count else {
                Log.debug("《系统设置值索引(\(row))》超出 ui 的 value 列表(\(initialValueStrs.count))")
                return }
            initialValueStrs[row] = valueString(parentI: row, data: data)
            tab.reloadRows(at: [IndexPath(item: row , section: 0)], with: .none)
        case 5: //斜坡步骤
            guard row < initialValueStrs.count else {
                Log.debug("《系统设置值索引(\(row))》超出 ui 的 value 列表(\(initialValueStrs.count))")
                return }
            initialValueStrs[row] = valueString(parentI: row, data: data)
            tab.reloadRows(at: [IndexPath(item: 4 , section: 0)], with: .none)
        case 6: //过流保护延迟
            initialValueStrs[7] = valueString(parentI: 6, data: data)
            tab.reloadRows(at: [IndexPath(item: 6 , section: 0)], with: .none)
        case 9: //USB线损补偿
            initialValueStrs[6] = valueString(parentI: 9, data: data)
            tab.reloadRows(at: [IndexPath(item: 5 , section: 0)], with: .none)
        default: break
        }
        
    }
    
    
    //MARK: - Helper Methods
    
    private func changeMenuBtnUI(imgStr: String, titleStr: String = ""){
        if #available(iOS 13.0, *) {
            menuBtn.setImage(UIImage(named: imgStr)?.withTintColor(UIColor(named: "DP_ffffffff")!), for: .normal)
        } else {
            menuBtn.setImage(UIImage(named: imgStr), for: .normal)
        }
        menuBtn.setTitle(titleStr, for: .normal)
    }
    
    /// 选项值字符串
    /// - Parameters:
    ///   - parentI:model 数据索引, 0-电量限制,1-声音,2-自动关闭屏幕​​​​,3-自动关机,4-屏幕方向,5-斜坡步骤, 6-过流保护延迟, 9- USB线损补偿
    /// - Returns: 系统设置首页列表的 value
    func valueString(parentI: Int, data: Int) -> String{
        switch parentI{
        case 0: //data: 80, 85, 90, 95, 100(“100%”)
            let valueTabRowI = dataTurnValueTableVRowIndex(parentI: parentI, data: data)
            return setGeneralItemArr(parentI: parentI)[valueTabRowI]
        case 1: //data: 0(“关闭”),1(“低”),2(“中”),3(“高”)
            return setGeneralItemArr(parentI: parentI)[data]
        case 2: //data: 0(“关闭”),30(“30s”)
            let valueTabRowI = data != 0 ? 1 : 0
            return setGeneralItemArr(parentI: parentI)[valueTabRowI]
        case 3: //data: 0(“关闭”),5, 10, 15, 20, 30
            let valueTabRowI = dataTurnValueTableVRowIndex(parentI: parentI, data: data)
            return setGeneralItemArr(parentI: parentI)[valueTabRowI]
        case 4: //data: 0(“竖”),1(“横”)
            return setGeneralItemArr(parentI: parentI)[data]
        case 5: //data: 100 - 1000 ("1v/0.1s")
            let valueTabRowI = dataTurnValueTableVRowIndex(parentI: parentI, data: data)
            return setGeneralItemArr(parentI: parentI)[valueTabRowI]
        case 6: //data: 50, 100, 200, 300, 500, 1000("1000ms")
            let valueTabRowI = dataTurnValueTableVRowIndex(parentI: parentI, data: data)
            return setGeneralItemArr(parentI: parentI)[valueTabRowI]
        case 9: //data: 0-off, 100 - 1000 (”1V/@5A“)
            let valueTabRowI = dataTurnValueTableVRowIndex(parentI: parentI, data: data)
            return setGeneralItemArr(parentI: parentI)[valueTabRowI]
        default:
            return "-"
        }
        
    }
    
    
    /// model 数据 转为 tabeview row 索引
    /// - Parameters:
    ///   - parentI: model 数据索引, 0-电量限制,1-声音,2-自动关闭屏幕​​​​,3-自动关机,4-屏幕方向,5-斜坡步骤, 6-过流保护延迟, 9- USB线损补偿
    ///   - data: model 数据
    /// - Returns: tabeview 选中 row 索引
    private func dataTurnValueTableVRowIndex(parentI: Int, data: Int) -> Int{
        //model 值到 tableview 行索引的映射
        let valueToRowMappings: [Int: [Int: Int]] = [
            0: [80: 0, 85: 1, 90: 2, 95: 3, 100: 4],      // 电量限制
            3: [0: 0, 5: 1, 10: 2, 15: 3, 20: 4, 30: 5],  // 自动关机
            5: [100: 0, 200: 1, 300: 2, 400: 3, 500: 4,   // 斜坡步骤
                600: 5, 700: 6, 800: 7, 900: 8, 1000: 9],
            6: [50: 0, 100: 1, 200: 2, 300: 3, 500: 4, 1000: 5], // 过流保护延迟
            9: [0: 0, 100: 1, 200: 2, 300: 3, 400: 4, 500: 5,    // USB线损补偿
                600: 6, 700: 7, 800: 8, 900: 9, 1000: 10]
        ]
        
        // 获取对应父索引的映射表
        guard let mapping = valueToRowMappings[parentI] else {
            return data // 默认返回原值
        }
        
        // 返回映射值或默认值
        return mapping[data] ?? defaultRowIndex(for: parentI, data: data)
    }
    // 获取默认行索引
    private func defaultRowIndex(for parentI: Int, data: Int) -> Int {
        switch parentI {
        case 0: return 2   // 电量限制默认90%
        case 3: return 5   // 自动关机默认30分钟
        case 5: return 0   // 斜坡步骤默认100
        case 6: return 0   // 过流保护延迟默认50ms
        case 9: return 0   // USB线损补偿默认0
        default: return data
        }
    }
    
    
    /// 得到 tabiew 详情页显示的内容数组
    /// - Parameters:
    ///   - parentI:model 数据索引, 0-电量限制,1-声音,2-自动关闭屏幕​​​​,3-自动关机,4-屏幕方向,5-斜坡步骤, 6-过流保护延迟, 9- USB线损补偿
    /// - Returns: 内容字符串数组
    private func setGeneralItemArr(parentI: Int) -> [String]{
        switch parentI{
        case 0: //电量限制
            return ["80%","85%","90%","95%","100%"]
        case 1: //声音
            return Array(multilingualText[0...3])
        case 2: //自动关闭屏幕
            return [multilingualText[0],"30s"]
        case 3: //自动关机
            return [multilingualText[0],"5min","10min","15min","20min","30min"]
        case 4: //屏幕方向
            return Array(multilingualText[4...5])
        case 5: //斜坡步骤
            return ["0.1V/0.1S","0.2V/0.1S","0.3V/0.1S","0.4V/0.1S","0.5V/0.1S","0.6V/0.1S","0.7V/0.1S","0.8V/0.1S","0.9V/0.1S","1V/0.1S"]
        case 6:  //过流保护延迟
            return ["50ms","100ms","200ms","300ms","500ms","1000ms"]
        case 9: //USB线损补偿
            return [multilingualText[0], "0.1V@5A","0.2V@5A","0.3V@5A","0.4V@5A","0.5V@5A","0.6V@5A","0.7V@5A","0.8V@5A","0.9V@5A","1V@5A"]

        default:
            return []
        }
    }
}

extension SettingPageV: UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView.tag == 0 && indexPath.section == 0 && indexPath.row == 0{
            //设置主页, row 0 高度为 0
            return settingType == .noBattery ? 0 : 41
        }
        return 41 //内容高度 40 +分割线间距 1

    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if tableView.tag == 0 {
            // 返回 header 的总高度（内容高度 + 底部间距）
            let contentHeight: CGFloat = 40 // header 内容高度
            let bottomSpacing: CGFloat = 1 // 底部间距
            return contentHeight + bottomSpacing
        }
        return 40
    }
    //MARK: 设置每个 section 的圆角,最后一个 cell 底部圆角
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // 设置每个 section 的圆角
        let cornerRadius: CGFloat = 12
        var corners: UIRectCorner = []
        
        // 设置 section 的最后一个 cell 底部圆角
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            corners.insert(.bottomLeft)
            corners.insert(.bottomRight)
        }
        
        // 如果只有一个 cell，四个角都设置圆角
        if tableView.numberOfRows(inSection: indexPath.section) == 1 {
            corners = [.topLeft, .topRight, .bottomLeft, .bottomRight]
        }
        
        if !corners.isEmpty {
            let maskPath = UIBezierPath(
                roundedRect: cell.bounds,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
            )
            
            let maskLayer = CAShapeLayer()
            maskLayer.path = maskPath.cgPath
            cell.layer.mask = maskLayer
            cell.layer.masksToBounds = true
        } else {
            cell.layer.mask = nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        return tableView.tag == 0 ?
                createHomeHeader(tableView, section: section) :
                createDetailHeader(tableView, section: section)
        
    }
    
    //缩短或完全移除 section 0 和 section 1 之间的间距
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return tableView.tag == 1 && section == 0 ? 0.01 : UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return tableView.tag == 1 && section == 0 ? UIView() : nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let vc = self.parentViewController as? CustomPickViewVC else { return }
        if tableView.tag == 0 {
            // 首页点击逻辑
            handleHomePageSelection(tableView: tableView, indexPath: indexPath, vc: vc)
        } else {
            // 设置项详情页点击逻辑
            handleDetailPageSelection(tableView: tableView, selectedIndexPath: indexPath, vc: vc)
        }
        
        // 统一取消选中
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            tableView.deselectRow(at: indexPath, animated: false)
        }

    }
    
    //MARK: - viewForHeaderInSection
    //首页头部
    private func createHomeHeader(_ tableView: UITableView, section: Int) -> UIView {
        
        let headerView = createBaseHeaderView(hasCornerRadius: true)
        let text = multilingualText[section == 0 ? 6 : 7]
        
        configureHeader(headerView,
                       text: text,
                       backgroundColor: UIColor(named: "DP_404040ff"),
                       textColor: UIColor(named: "DP_000000ff"),
                       isHintSection: false)
        
        return headerView
    }
    
    //详情页头部
    private func createDetailHeader(_ tableView: UITableView, section: Int) -> UIView {
        let isFirstSection = tableView.tag < 8
        let titleIndex = isFirstSection ? tableView.tag - 1 : tableView.tag - 8
        let titleArray = isFirstSection ? titleStrs[0] : titleStrs[1]
        let hintArray = isFirstSection ? titleHintStrs[0] : titleHintStrs[1]
        
        let text = section == 0 ? titleArray[titleIndex] : hintArray[titleIndex]
        let backgroundColor = section == 0 ? UIColor(named: "DP_404040ff") : .clear
        let textColor = UIColor(named: section == 0 ? "DP_000000ff" : "DP_808080")
        let hasCornerRadius = section == 0
        let isHintSection = section == 1
        
        let headerView = createBaseHeaderView(hasCornerRadius: hasCornerRadius)
        configureHeader(headerView,
                       text: text,
                       backgroundColor: backgroundColor,
                       textColor: textColor,
                       isHintSection: isHintSection)
        
        return headerView
    }
    
    //基础头部视图创建
    private func createBaseHeaderView(hasCornerRadius: Bool) -> UIView {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        if hasCornerRadius {
            headerView.layer.cornerRadius = 12
            headerView.clipsToBounds = true
            headerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        
        return headerView
    }
    
    //头部视图配置
    private func configureHeader(_ headerView: UIView,
                               text: String,
                               backgroundColor: UIColor?,
                               textColor: UIColor?,
                               isHintSection: Bool) {
        // 清除旧视图
        headerView.subviews.forEach { $0.removeFromSuperview() }
        
        // 背景视图
        let backgroundView = UIView()
        headerView.addSubview(backgroundView)
        backgroundView.backgroundColor = backgroundColor
        
        backgroundView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-1)
        }
        
        // 标签
        let label = UILabel()
        backgroundView.addSubview(label)
        label.text = text
        label.textColor = textColor
        label.font = UIFont(name: kSourceHanSansCN_Regular, size: 16)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        // 约束配置
        if isHintSection {
            label.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(8)
                make.left.equalToSuperview().offset(15)
                make.right.equalToSuperview().offset(-15)
                make.bottom.lessThanOrEqualToSuperview()
            }
        } else {
            label.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalToSuperview().offset(15)
                make.right.lessThanOrEqualToSuperview().offset(-15)
            }
        }
    }
    
    //MARK: - didSelectRowAt
    
    //首页点击处理
    private func handleHomePageSelection(tableView: UITableView, indexPath: IndexPath, vc: CustomPickViewVC) {
        // 计算新的 tag
        let baseTag = indexPath.row + 1
        tableView.tag = indexPath.section == 0 ? baseTag : baseTag + titleImgVs[0].count
        
        if indexPath.section == 0 {
            // 进入设置项详情页
            vc.currentPage = .settingEditpage
            menuBtn.isUserInteractionEnabled = false
            changeMenuBtnUI(imgStr: "DP_emarkInfoBack", titleStr: NSLocalizedString("Back", comment: "Back"))
            tableView.reloadData()
        } else {
            // 处理特殊功能（系统自检、恢复出厂设置）
            handleSpecialFunction(tableView: tableView, tag: tableView.tag, vc: vc)
        }
    }

    private func handleSpecialFunction(tableView: UITableView, tag: Int, vc: CustomPickViewVC) {
        switch tag {
        case 8:
            CustomAlert.showToast(title: NSLocalizedString("SystemSelfTest", comment: "系统自检"), vc: vc)
        case 9:
            CustomAlert.showToast(title: NSLocalizedString("FactoryReset", comment: "恢复出厂设置"), vc: vc)
        default:
            break
        }
        
        // 重置 tableView tag
        tableView.tag = 0
    }
    
    //详情页点击处理
    private func handleDetailPageSelection(tableView: UITableView, selectedIndexPath: IndexPath, vc: CustomPickViewVC) {
        
        guard selectedIndexPath.section == 0 else { return }
        
        let modelDataIndex = tableView.tag - 1 // tag 转换为数据索引
        
        // 行索引转数据值
        let modelDataI = tableviewtagTurntoModeldataI(tab.tag)
        let newValue = tableRowIndexTurnData(parentI: modelDataI, data: selectedIndexPath.row)
        
        // 更新数据
        if (0...6).contains(modelDataIndex) || modelDataIndex == 9 {
            updateRow(newValue, at: modelDataIndex)
        }
        
        // 通知代理
        settingPageViewDelegate?.settingPageView(self, didUpdateValue: newValue, at: modelDataIndex)
        
        // 更新选中状态
        // 取消所有可见 cell 的选中状态
        tableView.indexPathsForVisibleRows?.forEach { indexPath in
            if let cell = tableView.cellForRow(at: indexPath) as? SettingsCell {
                cell.setSelectedState(false)
            }
        }
        
        // 设置当前选中的 cell
        if let selectedCell = tableView.cellForRow(at: selectedIndexPath) as? SettingsCell {
            selectedCell.setSelectedState(true)
        }
    }
    
    ///   tabeview row 索引 转为model 数据
    /// - Parameters:
    ///   - parentI: model 数据索引, 0-电量限制,1-声音,2-自动关闭屏幕​​​​,3-自动关机,4-屏幕方向,5-斜坡步骤, 6-过流保护延迟, 9- USB线损补偿
    ///   - data: tabeview row 索引
    /// - Returns: model 数据
    private func tableRowIndexTurnData(parentI: Int, data: Int) -> Int{
        // tableview 行索引到 model 值的映射
        let rowToValueMappings: [Int: [Int: Int]] = [
            0: [0: 80, 1: 85, 2: 90, 3: 95, 4: 100],           // 电量限制
            3: [0: 0, 1: 5, 2: 10, 3: 15, 4: 20, 5: 30],       // 自动关机
            5: [0: 100, 1: 200, 2: 300, 3: 400, 4: 500,        // 斜坡步骤
                5: 600, 6: 700, 7: 800, 8: 900, 9: 1000],
            6: [0: 50, 1: 100, 2: 200, 3: 300, 4: 500, 5: 1000], // 过流保护延迟
            9: [0: 0, 1: 100, 2: 200, 3: 300, 4: 400, 5: 500,    // USB线损补偿
                6: 600, 7: 700, 8: 800, 9: 900, 10: 1000]
        ]
        
        // 默认值（行索引超出范围时返回的默认原始值）
        let defaultValueMappings: [Int: Int] = [
            0: 90,   // 电量限制默认90%
            3: 30,   // 自动关机默认30分钟
            5: 500,  // 斜坡步骤默认500mA
            6: 50,   // 过流保护延迟默认50ms
            9: 0     // USB线损补偿默认0mV
        ]
        
        // 查找映射值
        if let mapping = rowToValueMappings[parentI],
            let value = mapping[data] {
            return value
        }
        
        // 返回默认值
        return defaultValueMappings[parentI] ?? data
    }

}

extension SettingPageV: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag{
        case 0://设置主页
            return titleStrs[section].count
        case 1...4://单项(model 索引-> 0-电量限制,1-声音,2-自动关闭屏幕​​​​,3-自动关机)的设置详情页
            return section == 0 ? setGeneralItemArr(parentI: tableView.tag - 1).count : 0
        case 5://单项(model 索引-> 5-斜坡步骤)的设置详情页
            return section == 0 ? setGeneralItemArr(parentI: tableView.tag).count : 0
        case 6://单项(model 索引-> 9-USB线损补偿)的设置详情页
            return section == 0 ? setGeneralItemArr(parentI: 9).count : 0
        case 7://单项(model 索引-> 6斜坡步骤)的设置详情页
            return section == 0 ? setGeneralItemArr(parentI: 6).count : 0
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingscell", for: indexPath) as! SettingsCell
        cell.backgroundColor = UIColor(named: "DP_262626")
        
        if tableView.tag == 0{//设置主页
            cellConfiguration1(for: cell, at: indexPath)
        }else{//单项的设置详情页
            //仅显示 section 0
            if indexPath.section == 0 {
                cellEditConfiguration(for: cell, at: indexPath)
            }
        }
        
        return cell
    }
    
    //MARK: -
    
    //单项的设置详情页
    private func cellEditConfiguration(for cell: SettingsCell,at indexPath: IndexPath){
        
        let modelDataI = tableviewtagTurntoModeldataI(tab.tag)
        
        cell.titleImagV.isHidden = true
        cell.valueL.isHidden = true
        cell.editImgV.image = UIImage(named: "DP_Smallcheck")
        cell.titleL.text = setGeneralItemArr(parentI: modelDataI)[indexPath.row]

        cell.titleL.snp.remakeConstraints { make in
            make.left.equalTo(cell.snp.left).offset(13)
            make.centerY.equalToSuperview().offset(-1)
        }
        
        //更新 value 列表的选中行
        if let vc = self.parentViewController as? CustomPickViewVC {
            
            var data = 0
            var selectedI = 0
            
            switch tab.tag {
            case 1...4:
                data = vc.model.setParameterArr_new[tab.tag - 1]
                selectedI = dataTurnValueTableVRowIndex(parentI: tab.tag - 1, data: data)
            case 5: //斜坡步骤
                data = vc.model.setParameterArr_new[tab.tag]
                selectedI = dataTurnValueTableVRowIndex(parentI: tab.tag , data: data)
            case 6: //USB线损补偿
                data = vc.model.setParameterArr_new[9]
                selectedI = dataTurnValueTableVRowIndex(parentI: 9 , data: data)
            case 7: //过流保护延迟
                data = vc.model.setParameterArr_new[6]
                selectedI = dataTurnValueTableVRowIndex(parentI: 6 , data: data)
            default: break
            }
            cell.setSelectedState(selectedI == indexPath.row)
        }
    }
    
    //设置主页
    private func cellConfiguration1(for cell: SettingsCell,at indexPath: IndexPath){
        
        cell.titleImagV.isHidden = false
        cell.editImgV.isHidden = false
        cell.valueL.isHidden = false
        
        cell.editImgV.image = UIImage(named: "DP_tabEdit")
        cell.titleImagV.image = UIImage(named: titleImgVs[indexPath.section][indexPath.row])

        cell.titleL.text = titleStrs[indexPath.section][indexPath.row]
        cell.titleL.snp.remakeConstraints { make in
            make.left.equalTo(cell.snp.left).offset(37)
            make.centerY.equalToSuperview().offset(-1)
        }
        
        if indexPath.section == 0{
            
            if settingType == .noBattery && indexPath.row == 0{
                //隐藏 section 0 的第一项
                cell.alpha = 0
                cell.isHidden = true
            }else{
                cell.alpha = 1
                cell.isHidden = false
            }
            
            
            cell.valueL.text = initialValueStrs[indexPath.row > 3 ? indexPath.row+1 : indexPath.row] //跳过“屏幕方向”
            cell.valueL.snp.remakeConstraints { make in
                make.right.equalTo(cell.editImgV.snp.centerX).offset(-18)
                make.centerY.equalToSuperview().offset(-1)
            }
            
        }else if indexPath.section == 1{
            if indexPath.row == titleImgVs[indexPath.section].count - 1 {
                cell.editImgV.isHidden = true
                cell.valueL.snp.remakeConstraints { make in
                    make.right.equalTo(cell.snp.right).offset(-12)
                    make.centerY.equalToSuperview()
                }
                cell.valueL.text = verStr
            }else{
                cell.valueL.isHidden = true
            }
        }
        
    }
    
    ///  tabiew tag 转为 model 数据索引
    /// - Parameters:
    ///   - tabTag: tabiew tag
    /// - Returns: model 数据索引, 0-电量限制,1-声音,2-自动关闭屏幕​​​​,3-自动关机,4-屏幕方向,5-斜坡步骤, 6-过流保护延迟, 9- USB线损补偿
    private func tableviewtagTurntoModeldataI(_ tabTag: Int) -> Int{
        var modelDataI = tabTag
        switch tab.tag {
        case 1...4://-> modelDataI 0-电量限制,1-声音,2-自动关闭屏幕​​​​,3-自动关机
            modelDataI = tabTag-1
        case 5: //->  modelDataI 5-斜坡步骤
            modelDataI = tabTag
        case 6: //->  modelDataI 9- USB线损补偿
            modelDataI = 9
        case 7: //->  modelDataI 6-过流保护延迟
            modelDataI = tabTag-1
        default: break
        }
        return modelDataI
    }

}

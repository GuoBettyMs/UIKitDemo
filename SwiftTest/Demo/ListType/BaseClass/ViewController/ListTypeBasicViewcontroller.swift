//
//  ListTypeBasicViewcontroller.swift
//  SwiftTest
//
//  Created by user on 2025/4/10.
//
/**
    列表类型的通用视图控制器,封装了一些基础代理
    支持:
    1. UITableView
        -> 配置字母索引标题列
        -> 分区头部支持点击
        -> 单元格支持长按
    2.UICollectionView
        -> 自定义字母索引标题列
        -> 单元格支持长按
    
**/

import UIKit

class ListTypeBasicViewcontroller: UIViewController{

    //MARK: - Properties
    
    private enum Constants {
        static let customTableViewCell = "CustomTableViewCell"
        static let customCollectionViewCell = "CustomCollectionViewCell"
        static let customCollectionHeaderView = "CustomCollectionHeaderView"
        static let indexTitleWidth: CGFloat = 20
        static let indexTitleHeight: CGFloat = 20
        static let sectionHeaderHeight: CGFloat = 45
        static let defaultInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        static let minimumPressDurationFloat = 0.5 //长按手势的最短长按时间（秒）
    }
    var navigationItemTitleArr: [Any]? //列表类型数组
    var selectedIndex: Int = 0 //选定的列表类型
    var model = ListTypeBasicModel()

    private let tableView = UITableView()
    private var collectionView: UICollectionView!
    private var collectionViewSectionTitleLetterToIndex = [String: [Int]]() //collectionView 分区字母索引标题,如字母 "A" 对应第 0 和第 5 个分区
    private var collectionColumnCount = 2.0


    //MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillTransition(to size: CGSize,
                                   with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        handleOrientationChange(to: size, coordinator: coordinator)
    }

    //MARK: - Public methods
    
    func setupUI() {
        // 只在有 navigationController 时设置导航栏
        if navigationController != nil {
            setupNavigationTitle()
            setupNavigationNextButton()
        }
        setupConfigurationWithView()
        refreshContentView()
    }

    /**
        根据选定索引配置 BaseVC 视图控制器
    **/
    func configurationWithSelectedIndex(_ selectedIndex: Int) -> Any? {
        return nil
    }

    //根据列表类型配置 BaseVC 的基本数据
    func configurationWithSelectedListType(_ selectedListType: ListType) -> Any? {
        return nil
    }

    /**
        根据选定字符串配置 BaseVC 视图控制器
    **/
    func configurationWithSelectedTypeString(_ selectedTypeStr: String) -> Any? {
        return nil
    }
    
    //MARK: - Private methods
    
    //MARK: 导航栏
    //设置导航栏标题
    private func setupNavigationTitle() {
        let titleText: String = {
            guard let item = navigationItemTitleArr?[selectedIndex] else { return "" }
            if let stringItem = item as? String {
                return stringItem
            } else if let listTypeItem = item as? ListType {
                return listTypeItem.rawValue
            }
            return ""
        }()
        
        navigationItem.title = "列表类型: \(titleText)"
        
        // 确保当前视图控制器已嵌入导航栈中
        if let navController = self.navigationController {
            configureGlobalNavigationBarAppearance(navi: navController)
        } else {
            print("BaseVC 当前控制器未嵌入导航控制器中")
        }
    }
    //设置导航栏右侧按钮
    private func setupNavigationNextButton() {
        
        let button = UIButton(type: .custom)
        button.setTitle("➷", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        
        // 关键：禁用 autoresizing mask 转换（避免 NSAutoresizingMaskLayoutConstraint）
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // 可选：设置最小尺寸，防止被压缩
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .vertical)
        
        // 添加点击事件,⚠️ 如果没有 navigationController，按钮仍然会被创建,但不会显示在界面上,点击可能无效
        button.addTarget(self, action: #selector(handleNavigationButtonTap), for: .touchUpInside)
        
        // 包装成 UIBarButtonItem
        let barButtonItem = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem = barButtonItem

    }

    //MARK: 配置内容视图
    private func setupConfigurationWithView(){
        
       guard let configuration: ListTypeBasicModel = {
           // 尝试多种方式获取，返回明确的类型
           if let config = configurationWithSelectedIndex(selectedIndex) as? ListTypeBasicModel {
               return config
           }
           
           if let selectedListType = navigationItemTitleArr?[selectedIndex] as? ListType,
              let config = configurationWithSelectedListType(selectedListType) as? ListTypeBasicModel {
               return config
           }
           
           if let selectedTypeStr = navigationItemTitleArr?[selectedIndex] as? String,
              let config = configurationWithSelectedTypeString(selectedTypeStr) as? ListTypeBasicModel {
               return config
           }
           
           return nil
       }() else {
           //所有方法都失败时，使用默认配置
           print("无法获取有效配置，使用默认配置")
           model = ListTypeBasicModel()
           return
       }
       
       // 安全赋值
       model = configuration
    }
    
    private func refreshContentView(){
        clearSubviews()
        
        let str: String = {
            guard let item = navigationItemTitleArr?[selectedIndex] else { return "" }
            if let stringItem = item as? String {
                return stringItem
            } else if let listTypeItem = item as? ListType {
                return listTypeItem.rawValue
            }
            return ""
        }()
        //根据选定字符串,添加对应的列表内容视图
        switch str {
        case "table":
            setUpTableView()
        case "collection":
            setUpCollectionView()
        default:
            setUpTextView()
        }

    }

    private func clearSubviews() {
        view.subviews.forEach { $0.removeFromSuperview() }
    }
    
    //MARK: 配置内容视图为 UITextView
    private func setUpTextView(){
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .systemFont(ofSize: 14)
        textView.backgroundColor = .systemGreen
        textView.textColor = .white
        textView.isEditable = false
        view.addSubview(textView)
        
        let displayText = formattedDisplayText()
        DispatchQueue.main.async {
            textView.text = displayText
        }
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func formattedDisplayText() -> String {
        var text = "=== Section Titles ===\n\n"
        text += model.sectionTitleArr.map { "• \($0)" }.joined(separator: "\n")
        
        text += "\n\n=== Type Titles ===\n"
        model.cellTitleArr.enumerated().forEach { index, subArray in
            text += "\nCategory \(index + 1):\n"
            text += subArray.map { "  - \($0)" }.joined(separator: "\n")
        }
        
        return text
    }
    //MARK: 配置内容视图为 UITableView
    private func setUpTableView(){

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.sectionHeaderHeight = Constants.sectionHeaderHeight
        tableView.sectionIndexColor = .red //索引标题文本颜色
        tableView.sectionIndexBackgroundColor = .clear //索引标题背景色
        tableView.register(
            UINib(nibName: Constants.customTableViewCell, bundle: Bundle.main),
            forCellReuseIdentifier: Constants.customTableViewCell
        )
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0  // Removes top spacing in grouped tables
        }else{
            // Fallback for earlier versions
            tableView.contentInset = UIEdgeInsets(top: -1, left: 0, bottom: 0, right: 0) //修复 UITableView 顶部多余的间距。
            tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))//设置最小高度的透明 header（覆盖系统间距）,leastNormalMagnitude 是系统能识别的最小正数（约 0.0000000000000000000000001），比 0 更安全（某些 iOS 版本会忽略 0）
        }
        
        // 设置约束：tableView 四边对齐安全区域
        //safeAreaLayoutGuide：确保内容不会被刘海、Home Indicator 或导航栏遮挡
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    //MARK: 配置内容视图为 UICollectionView
    private func setUpCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = Constants.defaultInset
        layout.scrollDirection = .vertical
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInset = Constants.defaultInset
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(
            UINib(nibName: Constants.customCollectionViewCell, bundle: Bundle.main),
            forCellWithReuseIdentifier: Constants.customCollectionViewCell
        )
        
        // 注册 Header（需继承 UICollectionReusableView）
        collectionView.register(
            CustomCollectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: Constants.customCollectionHeaderView
        )
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

       setupCollectionViewSectionIndexTitles()

   }

    //添加集合视图分区字母索引标题列
    private func setupCollectionViewSectionIndexTitles() {
        let indexScrollView = UIScrollView()
        indexScrollView.showsVerticalScrollIndicator = false
        indexScrollView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        view.addSubview(indexScrollView)

        // 设置约束（右侧贴边）
        indexScrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indexScrollView.widthAnchor.constraint(equalToConstant: 20),
            indexScrollView.heightAnchor.constraint(equalToConstant: CGFloat((model.sectionTitleArr.count)*20)),
            indexScrollView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            indexScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // 添加索引标签
        model.sectionTitleArr.enumerated().forEach { index, title in
            let firstLetter = String(title.prefix(1)).uppercased()//uppercased() 字符串转大写方法
            collectionViewSectionTitleLetterToIndex[firstLetter, default: []].append(index)
            
            let label = UILabel()
            label.text = firstLetter
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 12)
            label.isUserInteractionEnabled = true
            label.addGestureRecognizer(
                UITapGestureRecognizer(
                    target: self,
                    action: #selector(handleIndexTitleTap)
                )
            )
            
            indexScrollView.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: indexScrollView.centerXAnchor),
                label.topAnchor.constraint(equalTo: indexScrollView.topAnchor, constant: CGFloat(index) * 20),
                label.heightAnchor.constraint(equalToConstant: 20)
            ])
        }
    }
    
    // MARK: 屏幕方向切换处理
    private func handleOrientationChange(to size: CGSize, coordinator: UIViewControllerTransitionCoordinator) {
        
        let isLandscape = size.width > size.height
        print("方向切换至: \(isLandscape ? "横屏" : "竖屏"), 尺寸: \(size)")
        
        // 安全处理 collectionView
        coordinator.animate { [weak self] _ in
            
            guard let self = self, let collectionView = self.collectionView else { return }
            
            if model.listType == .collection {
                // 更新列数
                self.collectionColumnCount = isLandscape ? 4.0 : 2.0
                
                // 强制布局更新
                collectionView.collectionViewLayout.invalidateLayout()
            }else{
                self.view.layoutIfNeeded()
            }
           
        }
        
    }
    
    // MARK: - Actions
    
    //导航栏按钮事件
    @objc private func handleNavigationButtonTap() {
        guard let items = navigationItemTitleArr, !items.isEmpty else { return }
        
        if selectedIndex == items.count - 1 {
            navigationItem.title = "❗️This is the last one❗️"
        } else {
            selectedIndex += 1
            setupNavigationTitle()
            refreshContentView()//点击将内容视图更新为不同的列表类型视图
        }
    }
    
    //表格视图头部点击事件
    @objc func headerTapped(_ gesture: UITapGestureRecognizer) {
        guard let section = gesture.view?.tag else { return }
        print("Header tapped for section: \(section)")
    }
    
    //集合视图分区字母索引标题列的点击事件:“点击索引字母 → 弹出选项列表 → 快速跳转到对应分区”
//    整体流程图
//    用户点击索引字母 "S"
//            ↓
//    handleIndexTitleTap 被触发
//            ↓
//    查字典 → 得到 indices = [2, 5, 8]
//            ↓
//    创建 CustomSelectionViewController(
//        titles = ["Shanghai", "Shenzhen", "Suzhou"],
//        indices = [2, 5, 8]
//    )
//            ↓
//    弹窗显示三个按钮
//            ↓
//    用户点击 "Shenzhen"（button.tag = 5）
//            ↓
//    onSelect?(5) 被调用
//            ↓
//    主界面 collectionView.scrollToItem(section: 5, item: 0)
    @objc private func handleIndexTitleTap(_ gesture: UITapGestureRecognizer) {
        guard
            let label = gesture.view as? UILabel,                // 1. 确保点击的是 UILabel（索引字母标签）
            let letter = label.text?.uppercased(),               // 2. 获取字母并转大写（统一格式）
            let indices = collectionViewSectionTitleLetterToIndex[letter], // 3. 查找该字母对应的分区索引数组
            let collectionView = collectionView                  // 4. 确保 collectionView 存在
        else {
            return
        }
        
        //创建并展示选择弹窗,因为一个字母可能对应多个分区（如 “S” 可能有 “Shanghai”, “Shenzhen”, “Suzhou”），不能直接跳转，需让用户选择跳转到指定的分区
        let selectionVC = CustomSelectionViewController(
            titles: indices.map { model.sectionTitleArr[$0] }, // 获取每个分区的标题
            indices: indices                                   // 分区索引列表
        )
        
        selectionVC.onSelect = { index in
            guard collectionView.numberOfItems(inSection: index) > 0
            else {
                return
            }
            //用户选择后，滚动到该 section 的第一个 item
            let indexPath = IndexPath(item: 0, section: index)
            collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        }
        //集合视图跳转到指定的分区
        present(selectionVC, animated: true)
    }
    
    
    // MARK: - Debug
    private func printDebugInfo(for indexPath: IndexPath,
                              collectionView: UICollectionView,
                              flowLayout: UICollectionViewFlowLayout,
                              cellWidth: CGFloat) {
        // 1. 计算行数
        let itemCount = model.cellTitleArr[indexPath.section].count
        let rowCount = Int(ceil(Double(itemCount) / Double(self.collectionColumnCount)))
        
        // 2. 获取分区数
        let sectionCount = collectionView.numberOfSections
 

//        总高度 = Σ(每个分区高度) + Σ(分区间距)
//                  │           │
//                  │           └── 相邻分区的 footer 和 header 之间的间距
//                  └── (cell高度×行数 + 行间距 + 分区inset + header高度 + footer 高度)
        var manualHeight: CGFloat = 0
        
        for section in 0..<sectionCount {
            let itemsInSection = model.cellTitleArr[section].count
            let rowCount = ceil(Double(itemsInSection) / Double(collectionColumnCount))
            
            let sectionHeight = (cellWidth * CGFloat(rowCount))
                              + (flowLayout.minimumLineSpacing * CGFloat(rowCount - 1))
                              + flowLayout.sectionInset.top
                              + flowLayout.sectionInset.bottom
                              + headerHeight(for: section) // 3. 获取页眉页脚高度
                              + footerHeight(for: section) // 3. 获取页眉页脚高度
            
            manualHeight += sectionHeight
            
            // 系统默认行为：相邻分区的 footer 和 header 会紧贴在一起
    //        Section 1 Footer
    //        Section 2 Header // 无间距！
            // 添加分区间距（最后一个分区不加）
//            if section < sectionCount - 1 {
//                manualHeight += flowLayout.minimumLineSpacing * 2  // 示例：使用双倍行间距
//            }
        }
        
//        // 添加 collectionView 的 contentInset（如果需要）
//        totalHeight += collectionView.contentInset.top ?? 0
//        totalHeight += collectionView.contentInset.bottom ?? 0
        
        
        // 5. 计算手动宽度
        let manualWidth = (cellWidth * CGFloat(self.collectionColumnCount))
            + (flowLayout.minimumInteritemSpacing * CGFloat(self.collectionColumnCount - 1))
            + (flowLayout.sectionInset.left + flowLayout.sectionInset.right)
        
        // 6. 打印调试信息
        print("""
        --- Layout Debug Info ---
        列数: \(self.collectionColumnCount)
        行数: \(rowCount)
        分区数: \(sectionCount)
        Cell 宽度: \(cellWidth)
        行间距: \(flowLayout.minimumLineSpacing)
        cell 间距: \(flowLayout.minimumInteritemSpacing)
        分区内边距: \(flowLayout.sectionInset)
        collectionView 内边距: \(collectionView.contentInset)
        -------------------------
        自动计算宽度: \(collectionView.contentSize.width) = \(flowLayout.collectionViewContentSize.width)
        手动计算宽度: \(manualWidth)
        当前可见宽度: \(collectionView.bounds.width)
        -------------------------
        自动计算高度: \(collectionView.contentSize.height) = \(flowLayout.collectionViewContentSize.height)
        手动计算高度: \(manualHeight)
        当前可见高度: \(collectionView.bounds.height)
        """)
    }
    
    //  获取页眉高度
    private func headerHeight(for section: Int) -> CGFloat {
        guard let collectionView = collectionView,
              let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return 0
        }
        
        // 优先使用动态代理返回的高度
        if let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout,
           let height = delegate.collectionView?(collectionView,
                         layout: collectionView.collectionViewLayout,
                         referenceSizeForHeaderInSection: section).height {
            return height
        }
        // 其次使用默认高度
        return layout.headerReferenceSize.height
    }
    
    //  获取页脚高度
    private func footerHeight(for section: Int) -> CGFloat {
        guard let collectionView = collectionView,
              let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return 0
        }
        
        // 优先使用动态代理返回的高度
        if let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout,
           let height = delegate.collectionView?(collectionView,
                         layout: collectionView.collectionViewLayout,
                         referenceSizeForFooterInSection: section).height {
            return height
        }
        // 其次使用默认高度
        return layout.headerReferenceSize.height
    }

}

extension ListTypeBasicViewcontroller: UITableViewDelegate, UITableViewDataSource {
    //MARK: UITableViewDelegate
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderView = UIView()
        let bgColor = UIColor.fromStringHex(model.colorsArr[section % 18])
        sectionHeaderView.backgroundColor = bgColor
        
        // 添加点击手势
        let tapGesture = IndexedTapGestureRecognizer(target: self, action: #selector(headerTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        sectionHeaderView.addGestureRecognizer(tapGesture)
        sectionHeaderView.isUserInteractionEnabled = true // 确保视图可以响应手势
        tapGesture.view?.tag = section // 存储 section 信息到手势
        
        let sectionTitleLabel = UILabel()
        sectionTitleLabel.frame = sectionHeaderView.bounds
        sectionTitleLabel.autoresizingMask = [.flexibleWidth , .flexibleHeight]
        sectionTitleLabel.text = model.sectionTitleArr[section]
        sectionTitleLabel.textColor = .white
        sectionTitleLabel.font = .boldSystemFont(ofSize: 17)
        sectionTitleLabel.textAlignment = .center
        sectionHeaderView.addSubview(sectionTitleLabel)

        return sectionHeaderView
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { }

    //MARK: UITableViewDataSource
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        sectionTitleArr[section]
//    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        model.sectionTitleArr.count
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model.cellTitleArr[section].count
    }

    //索引标题
    // return list of section titles to display in section index view (e.g. "ABCD...Z#")
    open func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var listTitles = [String]()
        for item: String in model.sectionTitleArr {
            let titleStr = item.prefix(1)
            listTitles.append(String(titleStr))
        }
        return listTitles
    }

    //索引点击处理
    open func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
//        print("索引标题点击: \(index)")
        return index
    }

    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.customTableViewCell) as! CustomTableViewCell
        cell.accessoryType = .disclosureIndicator
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = .white
        } else {
            cell.backgroundColor = UIColor.fromIntHex(0xF5F5F5)
        }
        
        let cellTitle = model.cellTitleArr[indexPath.section][indexPath.row]
        cell.titleLabel?.text = cellTitle
        cell.titleLabel.textColor = .black
        cell.numberLabel.text = String(indexPath.row + 1)
        let bgColor = UIColor.fromStringHex(model.colorsArr[indexPath.section % 18])
        cell.numberLabel.backgroundColor = bgColor
        
        // 为单元格添加长按手势
        cell.longPresssAction = {
            print("UITableView cell longPresssAction, \(indexPath.row)")
        }
        
        return cell
    }

}

extension ListTypeBasicViewcontroller: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
    //MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { }
    
    //MARK: UICollectionViewDataSource
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        model.sectionTitleArr.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        model.cellTitleArr[section].count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.customCollectionViewCell, for: indexPath) as! CustomCollectionViewCell
        // Configure the cell
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = .white
        } else {
            cell.backgroundColor = UIColor.fromIntHex(0xE6E6FA)// kRGBColorFromHex(rgbValue: 0xF5F5F5)//白烟
        }
        cell.label.text = model.cellTitleArr[indexPath.section][indexPath.row]
        cell.longPresssAction = {
            print("collectionView cell longPresssAction, \(indexPath.row)")
            
        }
        return cell
    }
    
    // 返回 Header/Footer 视图
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: Constants.customCollectionHeaderView,
                for: indexPath
            ) as! CustomCollectionHeaderView
            let bgColor = UIColor.fromStringHex(model.colorsArr[indexPath.section % 18])
            header.backgroundColor = bgColor
            header.titleLabel.text = model.sectionTitleArr[indexPath.section]
            return header
        }
        
        return UICollectionReusableView() // 默认返回空视图
    }
    
    //MARK: UICollectionViewDelegateFlowLayout
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return CGSize(width: 100, height: 100) // 默认值
        }

        // 读取 Storyboard 中设置的 sectionInsets
        let sectionInsets = flowLayout.sectionInset
        let cellSpacing: CGFloat = flowLayout.minimumInteritemSpacing // Cell之间的间距
        
        // 计算可用宽度（总宽度 - 左右边距 - 所有间距）
        let totalHorizontalSpacing = (collectionColumnCount - 1) * cellSpacing
        let availableWidth = collectionView.bounds.width - sectionInsets.left - sectionInsets.right - totalHorizontalSpacing - collectionView.contentInset.left - collectionView.contentInset.right
        
        // 计算等宽Cell尺寸
        let cellWidth = availableWidth / collectionColumnCount
        
        if indexPath.section == 0 && indexPath.row == 0 {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.printDebugInfo(for: indexPath,
                                              collectionView: collectionView,
                                              flowLayout: flowLayout,
                                              cellWidth: cellWidth)
            }
        }
        
        // 保持正方形（高度=宽度）
        return CGSize(width: cellWidth, height: cellWidth)
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSizeMake(collectionView.bounds.width, 45)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSizeMake(collectionView.bounds.width, 45)
    }
    
}

//
//  BaseListVC.swift
//  SwiftTest
//
//  Created by user on 2025/4/8.
//

import UIKit

let kCustomTableViewCell = "CustomTableViewCell"
let kCustomCollectionViewCell = "CustomCollectionViewCell"
let kCustomCollectionHeaderView = "CustomCollectionHeaderView"
let kCustomCollectionFooterView = "CustomCollectionFooterView"

class BaseListVC: UIViewController {
    
    //MARK: - property
    public var cellTitleArr = [[String]]()
    public var sectionTitleArr = [String]()
    public var typeArr = [[Any]]()
    public var colorsArr = [
        "#5470c6",
        "#91cc75",
        "#fac858",
        "#ee6666",
        "#73c0de",
        "#3ba272",
        "#fc8452",
        "#9a60b4",
        "#ea7ccc",

        "#5470c6",
        "#91cc75",
        "#fac858",
        "#ee6666",
        "#73c0de",
        "#3ba272",
        "#fc8452",
        "#9a60b4",
        "#ea7ccc",
    ]

    private let minimumPressDurationFloat = 0.5 //长按手势的最短长按时间（秒）
    private var tableView = UITableView()
    private var collectionView: UICollectionView!
    private var collectionViewSectionTitleLetterToIndex = [String: [Int]]() //collectionView 分区字母索引标题
    private var collectionColumnCount = 2.0
    
    //MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .random()
        title = "Homepage"
        
        // 确保当前视图控制器已嵌入导航栈中
        if let navController = self.navigationController {
            configureGlobalNavigationBarAppearance(navi: navController)
        } else {
            print("BaseListVC 当前控制器未嵌入导航控制器中")
        }

    }
    
    override func viewWillTransition(to size: CGSize,
                                   with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        // 更新方向状态
        let newIsLandscape = size.width > size.height
        
        print("方向切换至: \(newIsLandscape ? "横屏" : "竖屏"), 尺寸: \(size)")
        
        // 安全处理 collectionView
        coordinator.animate { [weak self] _ in
            guard let self = self, let collectionView = self.collectionView else { return }
            
            // 更新列数
            self.collectionColumnCount = newIsLandscape ? 4.0 : 2.0
            
            // 强制布局更新
            collectionView.collectionViewLayout.invalidateLayout()
        }

    }
    
    //MARK: - public methods
    public func setUpView(listTyple: ListType){
        if listTyple == .table {
            setUpMainTableView()
        }else if listTyple == .collection{
            setUpMainCollectionView()
        }
    }
    
    //MARK: - private methods

    private func setUpMainTableView(){
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false // 必须关闭 autoresizingMask
        tableView.delegate = self
        tableView.dataSource = self
        tableView.sectionHeaderHeight = 45
        tableView.sectionIndexColor = .red
        tableView.register(UINib.init(nibName: kCustomTableViewCell, bundle: Bundle.main), forCellReuseIdentifier: kCustomTableViewCell)
        view.addSubview(tableView)

        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0  // Removes top spacing in grouped tables
        }else{
            // Fallback for earlier versions
            tableView.contentInset = UIEdgeInsets(top: -1, left: 0, bottom: 0, right: 0) //修复 UITableView 顶部多余的间距。
            tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))//设置最小高度的透明 header（覆盖系统间距）,leastNormalMagnitude 是系统能识别的最小正数（约 0.0000000000000000000000001），比 0 更安全（某些 iOS 版本会忽略 0）
        }
        
        // 设置约束：tableView 四边对齐安全区域
        //safeAreaLayoutGuide：确保内容不会被刘海、Home Indicator 或导航栏遮挡
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func setUpMainCollectionView() {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        flowLayout.scrollDirection = .vertical
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false // 必须关闭 autoresizingMask
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib.init(nibName: kCustomCollectionViewCell, bundle: Bundle.main), forCellWithReuseIdentifier: kCustomCollectionViewCell)
        // 注册 Header（需继承 UICollectionReusableView）
        collectionView.register(
            CustomCollectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: kCustomCollectionHeaderView
        )
        collectionView.register(
            CustomCollectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: kCustomCollectionFooterView
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

    private func setupCollectionViewSectionIndexTitles() {
        let indexScrollView = UIScrollView()
        indexScrollView.showsVerticalScrollIndicator = false
        indexScrollView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        view.addSubview(indexScrollView)
        
        // 设置约束（右侧贴边）
        indexScrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indexScrollView.widthAnchor.constraint(equalToConstant: 20),
            indexScrollView.heightAnchor.constraint(equalToConstant: CGFloat((sectionTitleArr.count)*20)),
            indexScrollView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            indexScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        // 添加索引标签
        for (i, title) in sectionTitleArr.enumerated() {
            let firstLetter = String(title.prefix(1)).uppercased() //uppercased() 字符串转大写方法
            collectionViewSectionTitleLetterToIndex[firstLetter, default: []].append(i)
            
//            //保留字母首次出现的索引
//            if titleLetterToIndex[firstLetter] == nil { // 仅当字母未记录时存储
//                titleLetterToIndex[firstLetter] = i
//            }
//            //保留字母最后出现的索引
//            titleLetterToIndex[firstLetter] = i // 出现相同字母会覆盖

            let label = UILabel()
            label.text = String(title.prefix(1)) // 获取第一个字符
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 12)
            indexScrollView.addSubview(label)
            
            // 设置标签约束
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: indexScrollView.centerXAnchor),
                label.topAnchor.constraint(equalTo: indexScrollView.topAnchor, constant: CGFloat(i) * 20),
                label.heightAnchor.constraint(equalToConstant: 20)
            ])
            
            // 添加点击手势
            label.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleIndexTap(_:)))
            label.addGestureRecognizer(tap)
        }
        
//        print("titleLetterToIndex: \(titleLetterToIndex)")
        
    }
    
    private func printDebugInfo(for indexPath: IndexPath,
                              collectionView: UICollectionView,
                              flowLayout: UICollectionViewFlowLayout,
                              cellWidth: CGFloat) {
        // 1. 计算行数
        let itemCount = self.cellTitleArr[indexPath.section].count
        let rowCount = Int(ceil(Double(itemCount) / Double(self.collectionColumnCount)))
        
        // 2. 获取分区数
        let sectionCount = collectionView.numberOfSections
 

//        总高度 = Σ(每个分区高度) + Σ(分区间距)
//                  │           │
//                  │           └── 相邻分区的 footer 和 header 之间的间距
//                  └── (cell高度×行数 + 行间距 + 分区inset + header高度 + footer 高度)
        var manualHeight: CGFloat = 0
        
        for section in 0..<sectionCount {
            let itemsInSection = cellTitleArr[section].count
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

extension BaseListVC: UITableViewDelegate, UITableViewDataSource {
    //MARK: UITableViewDelegate
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderView = UIView()
        let bgColor = UIColor.fromHex(colorsArr[section % 18])
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
        sectionTitleLabel.text = sectionTitleArr[section]
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
        sectionTitleArr.count
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellTitleArr[section].count
    }

    // return list of section titles to display in section index view (e.g. "ABCD...Z#")
    open func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var listTitles = [String]()
        for item: String in sectionTitleArr {
            let titleStr = item.prefix(1)
            listTitles.append(String(titleStr))
        }
        return listTitles
    }

    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCustomTableViewCell) as! CustomTableViewCell
        cell.accessoryType = .disclosureIndicator
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = .white
        } else {
            cell.backgroundColor = UIColor.fromHex(0xE6E6FA)// kRGBColorFromHex(rgbValue: 0xF5F5F5)//白烟
        }

        let bgColor = UIColor.fromHex(colorsArr[indexPath.section % 18])
        let cellTitle = cellTitleArr[indexPath.section][indexPath.row]
        cell.titleLabel?.text = cellTitle
        cell.titleLabel.textColor = .black
        cell.numberLabel.text = String(indexPath.row + 1)
        cell.numberLabel.backgroundColor = bgColor
        
        // 为单元格添加长按手势
        addLongPressGesture(to: cell, at: indexPath)
        
        return cell
    }

    //MARK: Actions
    
    @objc func headerTapped(_ gesture: UITapGestureRecognizer) {
        guard let section = gesture.view?.tag else { return }
        print("Header tapped for section: \(section)")
    }

    private func addLongPressGesture(to cell: UITableViewCell, at indexPath: IndexPath) {
        // 防止重复添加手势
        if cell.gestureRecognizers == nil || cell.gestureRecognizers?.isEmpty == true {
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
            longPressGesture.minimumPressDuration = minimumPressDurationFloat
            cell.addGestureRecognizer(longPressGesture)
        }
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard let cell = gesture.view as? UITableViewCell else { return }
        
        if gesture.state == .began {
            if let indexPath = tableView.indexPath(for: cell) {
                print("Cell long pressed at row: \(indexPath.row)")

                // 显示提示框
                let alert = UIAlertController(
                    title: "Long Press",
                    message: "You long pressed row \(indexPath.row)",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

extension BaseListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
    //MARK: UICollectionViewDelegate
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { }
    
    //MARK: UICollectionViewDataSource
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        sectionTitleArr.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cellTitleArr[section].count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCustomCollectionViewCell, for: indexPath) as! CustomCollectionViewCell
        // Configure the cell
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor.fromHex( 0xF5F5F5)
        } else {
            cell.backgroundColor = UIColor.fromHex( 0xE6E6FA)
        }
        cell.label.text = cellTitleArr[indexPath.section][indexPath.row]
        cell.longPresssAction = {
            print("collectionView cell longPresssAction, \(indexPath.row)")
            
        }
        return cell
    }
    
    // 返回 Header/Footer 视图
    open func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: kCustomCollectionHeaderView,
                for: indexPath
            ) as! CustomCollectionHeaderView
            let bgColor = UIColor.fromHex(colorsArr[indexPath.section % 18])
            header.backgroundColor = bgColor
            header.titleLabel.text = sectionTitleArr[indexPath.section]
            return header
        }else if kind == UICollectionView.elementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: kCustomCollectionFooterView,
                for: indexPath
            ) as! CustomCollectionHeaderView
            let bgColor = UIColor.fromHex(colorsArr[indexPath.section % 18])
            footer.backgroundColor = bgColor
            footer.titleLabel.backgroundColor = .random()
            footer.titleLabel.text = "Footer"
            
            return footer
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
    
    
    
    //MARK: - Actions
    @objc func handleIndexTap(_ gesture: UITapGestureRecognizer) {
     
        guard let label = gesture.view as? UILabel,
              let letter = label.text?.uppercased(),
              let indices = collectionViewSectionTitleLetterToIndex[letter] else{
            return
        }
 
        let selectionVC = CustomSelectionViewController(
            titles: indices.map { sectionTitleArr[$0] },
            indices: indices
        )
        selectionVC.onSelect = { [weak self] index in
            let indexPath = IndexPath(item: 0, section: index)
            self?.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        }
        present(selectionVC, animated: true)
        
    }
    
}

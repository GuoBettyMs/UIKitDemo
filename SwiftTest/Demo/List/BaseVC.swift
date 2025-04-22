//
//  BaseVC.swift
//  SwiftTest
//
//  Created by user on 2025/4/10.
//
/**
    列表类型基本视图控制器
**/

import UIKit

class BaseVC: UIViewController{

    //MARK: - Properties
    
    private enum Constants {
        static let customTableViewCell = "CustomTableViewCell"
        static let customCollectionViewCell = "CustomCollectionViewCell"
        static let customCollectionHeaderView = "CustomCollectionHeaderView"
        static let indexTitleWidth: CGFloat = 20
        static let indexTitleHeight: CGFloat = 20
        static let sectionHeaderHeight: CGFloat = 45
        static let defaultInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
    }
    var navigationItemTitleArr: [Any]?
    var selectedIndex: Int = 0
    var model = BaseModel()

    private var collectionView: UICollectionView!
    private var collectionViewSectionTitleLetterToIndex = [String: [Int]]() //collectionView 分区字母索引标题
    private var collectionColumnCount = 2.0


    //MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
    }

    override func viewWillTransition(to size: CGSize,
                                   with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        handleOrientationChange(to: size, coordinator: coordinator)
    }

    //MARK: - Public methods
    
    func setupUI() {
        view.backgroundColor = .white
        setupTitle()
        setupNavigationNextButton()
        setupConfigurationWithView()
        refreshContentView()
    }

    func configurationWithSelectedIndex(_ selectedIndex: Int) -> Any? {
        return nil
    }

    func configurationWithSelectedListType(_ selectedListType: ListType) -> Any? {
        return nil
    }

    func configurationWithSelectedTypeString(_ selectedTypeStr: String) -> Any? {
        return nil
    }
    
    //MARK: - Private methods
    
    private func setupTitle() {
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
    
    private func setupNavigationNextButton() {
        let button = UIBarButtonItem(
            title: "➷",
            style: .plain,
            target: self,
            action: #selector(handleNavigationButtonTap)
        )
        
        button.setTitleTextAttributes([
            .foregroundColor: UIColor.red,
            .font: UIFont.systemFont(ofSize: 28, weight: .bold)
        ], for: .normal)
        
        navigationItem.rightBarButtonItem = button
    }

    private func setupConfigurationWithView(){

        var chartConfiguration =  configurationWithSelectedIndex(selectedIndex)
        if chartConfiguration == nil {
            let selectedListType = navigationItemTitleArr?[selectedIndex]
            if selectedListType != nil && ((selectedListType as? ListType) != nil) {
                chartConfiguration = configurationWithSelectedListType(selectedListType as! ListType)
            }
        }
        if chartConfiguration == nil {
            let selectedTypeStr = navigationItemTitleArr?[selectedIndex]
            chartConfiguration = configurationWithSelectedTypeString(selectedTypeStr as! String)
        }
        if (chartConfiguration is BaseModel) {
            model = chartConfiguration as! BaseModel
        }
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

    private func setUpTableView(){
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.sectionHeaderHeight = Constants.sectionHeaderHeight
        tableView.sectionIndexColor = .red
        tableView.register(
            UINib(nibName: Constants.customTableViewCell, bundle: Bundle.main),
            forCellReuseIdentifier: Constants.customTableViewCell
        )
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        } else {
            tableView.contentInset = UIEdgeInsets(top: -1, left: 0, bottom: 0, right: 0)
            tableView.tableHeaderView = UIView(
                frame: CGRect(x: 0, y: 0,
                width: 0,
                height: CGFloat.leastNormalMagnitude
            ))
        }
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func setUpCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = Constants.defaultInset
        layout.scrollDirection = .vertical
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(
            UINib(nibName: Constants.customCollectionViewCell, bundle: Bundle.main),
            forCellWithReuseIdentifier: Constants.customCollectionViewCell
        )
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
        
        model.sectionTitleArr.enumerated().forEach { index, title in
            let firstLetter = String(title.prefix(1)).uppercased()
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
    
    private func handleOrientationChange(to size: CGSize, coordinator: UIViewControllerTransitionCoordinator) {
        let isLandscape = size.width > size.height
        print("方向切换至: \(isLandscape ? "横屏" : "竖屏"), 尺寸: \(size)")
        
        coordinator.animate { [weak self] _ in
            self?.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Actions
    @objc private func handleNavigationButtonTap() {
        guard let items = navigationItemTitleArr, !items.isEmpty else { return }
        
        if selectedIndex == items.count - 1 {
            navigationItem.title = "❗️This is the last one❗️"
        } else {
            selectedIndex += 1
            setupTitle()
            refreshContentView()
        }
    }
    
    @objc private func handleIndexTitleTap(_ gesture: UITapGestureRecognizer) {
        guard
            let label = gesture.view as? UILabel,
            let letter = label.text?.uppercased(),
            let indices = collectionViewSectionTitleLetterToIndex[letter],
            let collectionView = collectionView
        else {
            return
        }
        
        let selectionVC = CustomSelectionViewController(
            titles: indices.map { model.sectionTitleArr[$0] },
            indices: indices
        )
        
        selectionVC.onSelect = { index in
            guard collectionView.numberOfItems(inSection: index) > 0
            else {
                return
            }
            
            let indexPath = IndexPath(item: 0, section: index)
            collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        }
        
        present(selectionVC, animated: true)
    }
}

extension BaseVC: UITableViewDelegate, UITableViewDataSource {
    //MARK: UITableViewDelegate
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderView = UIView()
        let bgColor = UIColor.fromHex(model.colorsArr[section % 18])
        sectionHeaderView.backgroundColor = bgColor
        
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

    // return list of section titles to display in section index view (e.g. "ABCD...Z#")
    open func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var listTitles = [String]()
        for item: String in model.sectionTitleArr {
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
        
        let cellTitle = model.cellTitleArr[indexPath.section][indexPath.row]
        cell.titleLabel?.text = cellTitle
        cell.titleLabel.textColor = .black
        cell.numberLabel.text = String(indexPath.row + 1)
        let bgColor = UIColor.fromHex(model.colorsArr[indexPath.section % 18])
        cell.numberLabel.backgroundColor = bgColor
        
        return cell
    }

}

extension BaseVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCustomCollectionViewCell, for: indexPath) as! CustomCollectionViewCell
        // Configure the cell
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = .white
        } else {
            cell.backgroundColor = UIColor.fromHex(0xE6E6FA)// kRGBColorFromHex(rgbValue: 0xF5F5F5)//白烟
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
                withReuseIdentifier: kCustomCollectionHeaderView,
                for: indexPath
            ) as! CustomCollectionHeaderView
            let bgColor = UIColor.fromHex(model.colorsArr[indexPath.section % 18])
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
        let cellSpacing: CGFloat = 10 // Cell之间的间距
        
        // 计算可用宽度（总宽度 - 左右边距 - 所有间距）
        let totalHorizontalSpacing = (collectionColumnCount - 1) * cellSpacing
        let availableWidth = collectionView.bounds.width - sectionInsets.left - sectionInsets.right - totalHorizontalSpacing
        
        // 计算等宽Cell尺寸
        let cellWidth = availableWidth / collectionColumnCount
        
//        if indexPath.section == 0 && indexPath.row == 0 {
//            print("""
//            当前列数: \(collectionColumnCount)
//            Cell尺寸: \(cellWidth) x \(cellWidth)
//            实际总宽度: \(collectionView.bounds.width)
//            计算后总宽度: \(columnCount * cellWidth + (columnCount - 1) * cellSpacing + sectionInsets.left + sectionInsets.right)
//            """)
//        }
        
        // 保持正方形（高度=宽度）
        return CGSize(width: cellWidth, height: cellWidth)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSizeMake(collectionView.bounds.width, 45)
    }
    

    
}

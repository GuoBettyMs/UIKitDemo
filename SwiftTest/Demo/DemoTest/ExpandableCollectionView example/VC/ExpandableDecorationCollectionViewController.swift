//
//  ExpandableDecorationCollectionViewController.swift
//  SwiftTest
//
//  Created by user on 2026/2/6.
//
// 带装饰的可展开/折叠 CollectionView
//
//装饰背景会根据分区的展开/折叠状态自动调整大小
//分区折叠时，装饰背景只显示header部分
//分区展开时，装饰背景包含所有items
//
//每个分区都有独特的背景颜色和可选的背景图片
//支持圆角和阴影效果
//添加了平滑的展开/折叠动画

import UIKit

class ExpandableDecorationCollectionViewController: TestBaseVC<UIView> {
    
    // MARK: - Properties
    
    var sections: [SectionItem] = []
    private let cellIdentifier = "Cell"
    private let headerIdentifier = "Header"
    private let isFlowLayout = true //是否使用瀑布布局
    // 新增：标记是否正在处理toggle，避免重复点击
    private var isProcessingToggle: Bool = false
    
    // MARK: - UI Components
    
    private lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            collectionView.backgroundColor = .systemBackground
        }
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // 注册Cell
        collectionView.register(
            ExpandableCollectionViewCell.self,
            forCellWithReuseIdentifier: cellIdentifier
        )
        
        // 注册Section Header
        collectionView.register(
            ExpandableSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: headerIdentifier
        )
        
        
        return collectionView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
        
        collectionView.delegate = self // 添加 UIScrollViewDelegate 滚动监听
        
    }
    
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "带装饰的可展开/折叠 CollectionView"
        if #available(iOS 13.0, *) {
            view.backgroundColor = .random()
        }
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func createLayout() -> UICollectionViewLayout {
        if #available(iOS 13.0, *) {
            if isFlowLayout{
                // Fallback on earlier versions
                let layout = SectionDecorationLayout()
                layout.minimumLineSpacing = 8
                layout.minimumInteritemSpacing = 8
                layout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
                layout.scrollDirection = .vertical

                // 设置代理
                layout.decorationDelegate = self
                
                return layout
            }else{
                let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
                    return self?.createSectionLayout(for: sectionIndex)
                }
                // 添加全局配置
                let config = UICollectionViewCompositionalLayoutConfiguration()
                config.interSectionSpacing = 8
                layout.configuration = config
                
                return layout
            }
        }
        return UICollectionViewLayout.init()
    }
    
    @available(iOS 13.0, *)
    private func createSectionLayout(for sectionIndex: Int) -> NSCollectionLayoutSection {
        // Item大小
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(44)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Group大小
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(44)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        // Section
        let section = NSCollectionLayoutSection(group: group)
        
        // 展开/折叠控制 item 间距
        section.interGroupSpacing = sections[sectionIndex].isExpanded ? 8 : 0

        
        // Section Header
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(60)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        // 边距
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 16,
            bottom: 16,
            trailing: 16
        )
        
        
        return section
    }
    
    // MARK: - Data
    
    private func loadData() {
        sections = [
            SectionItem(
                title: "工作事项",
                color: .systemBlue,
                items: ["会议准备", "报告撰写", "客户跟进", "团队协调"],
                isExpanded: true,
                decorationImage: "section_bg_1", // 自定义装饰图片
                decorationColor: UIColor.systemBlue.withAlphaComponent(0.5)
            ),
            SectionItem(
                title: "学习计划",
                color: .systemGreen,
                items: ["Swift学习", "算法练习", "设计模式", "项目实战", "性能优化"],
                isExpanded: true,
                decorationImage: "section_bg_2",
                decorationColor: UIColor.systemGreen.withAlphaComponent(0.5)
            ),
            SectionItem(
                title: "个人生活",
                color: .systemOrange,
                items: ["健身锻炼", "阅读书籍", "朋友聚会", "家庭时间"],
                isExpanded: false,
                decorationImage: nil, // 不使用图片，只用背景色
                decorationColor: UIColor.systemOrange.withAlphaComponent(0.5)
            ),
            SectionItem(
                title: "购物清单",
                color: .systemPurple,
                items: ["水果蔬菜", "日常用品", "电子产品", "衣物鞋帽", "家居装饰"],
                isExpanded: false, // 默认折叠
                decorationImage: "section_bg_3",
                decorationColor: UIColor.systemPurple.withAlphaComponent(0.5)
            ),
            SectionItem(
                title: "旅行计划",
                color: .systemRed,
                items: ["行程规划", "酒店预订", "景点门票", "行李准备", "保险购买"],
                isExpanded: false,
                decorationImage: nil,
                decorationColor: UIColor.systemRed.withAlphaComponent(0.5)
            )
        ]
        
        collectionView.reloadData()
    }
    
    // MARK: - Toggle Section
    private func toggleSection(at index: Int) {
        // 1. 防抖：防止快速连续点击
        guard !isProcessingToggle else { return }
        isProcessingToggle = true
        
        // 2. 更新数据源（这是核心，Layout 会读取这个状态）
        let isExpanding = !sections[index].isExpanded
        sections[index].isExpanded = isExpanding
        
        // 3. 准备 Item 的 IndexPath
        let itemIndexPaths = sections[index].items.indices.map {
            IndexPath(item: $0, section: index)
        }
        
        // 4. 执行批量动画
        collectionView.performBatchUpdates {
            if isExpanding {
                // 展开：插入items
                collectionView.insertItems(at: itemIndexPaths)
            } else {
                // 折叠：删除items
                collectionView.deleteItems(at: itemIndexPaths)
            }
        } completion: { [weak self] finished in
            guard let self = self else { return }
            
            // 5. 动画结束后的处理
            // 只需要更新 Header 的 UI（比如箭头方向），不需要刷新 Layout
            self.updateSectionHeader(at: index)
            
            // ❌ 删除：layout.refreshDecoration(for: index)
            // ❌ 删除：self.refreshVisibleSectionDecorations()
            // 原因：performBatchUpdates 结束后，系统已经自动调用了 layoutIfNeeded，
            // 只要 Layout 逻辑正确，背景会自动更新。
            
            if isExpanding {
                // 稍微延迟一点滚动，确保布局已经稳定
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    //滚动到展开的section
                    self.scrollToSectionIfNeeded(at: index)
                }
            }
            
            // 7. 解锁
            self.isProcessingToggle = false
        }
    }
    
    // 刷新可见区域的装饰视图
    private func refreshVisibleSectionDecorations() {
        guard let layout = collectionView.collectionViewLayout as? SectionDecorationLayout else { return }
        
        // 1. 仅获取可见区域的 Section，不要获取所有 Section (性能优化)
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visibleSections = Set(collectionView.indexPathsForVisibleItems.map { $0.section })
        
        Log.debug("刷新可见分区: \(visibleSections), 可见区域: \(visibleRect)")
        
        // 2. 核心修复：不要 reload，而是标记布局失效
        // 这会触发 layoutAttributesForElements 被调用，从而重新生成背景属性
        layout.forceInvalidate()
        
        // 3. 强制 CollectionView 在下一次循环中重新布局
        // 注意：不要在这里调用 layoutIfNeeded()，否则会阻塞主线程导致卡顿
        collectionView.collectionViewLayout.invalidateLayout()
    }
    

    private func updateSectionHeader(at index: Int) {
        // 更新section header的显示
        let header = collectionView.supplementaryView(
            forElementKind: UICollectionView.elementKindSectionHeader,
            at: IndexPath(item: 0, section: index)
        ) as? ExpandableSectionHeaderView
        
        header?.updateExpandState(isExpanded: sections[index].isExpanded)
    }
    
    private func scrollToSectionIfNeeded(at index: Int) {
        // 获取section的布局属性
        guard let layoutAttributes = collectionView.layoutAttributesForSupplementaryElement(
            ofKind: UICollectionView.elementKindSectionHeader,
            at: IndexPath(item: 0, section: index)
        ) else { return }
        
        let headerFrame = layoutAttributes.frame
        
        // 如果header不在可见区域内，滚动到该位置
        if !collectionView.bounds.intersects(headerFrame) {
            collectionView.scrollToItem(
                at: IndexPath(item: 0, section: index),
                at: .top,
                animated: false
            )
        }
    }
}

// MARK: - UICollectionViewDataSource
extension ExpandableDecorationCollectionViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 根据展开状态返回items数量
        return sections[section].isExpanded ? sections[section].items.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: cellIdentifier,
            for: indexPath
        ) as! ExpandableCollectionViewCell
        
        let item = sections[indexPath.section].items[indexPath.item]
        let sectionColor = sections[indexPath.section].color
        
        cell.configure(
            title: item,
            index: indexPath.item + 1,
            color: sectionColor
        )
        
        return cell
      
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: headerIdentifier,
            for: indexPath
        ) as! ExpandableSectionHeaderView
        
        let section = sections[indexPath.section]
        header.configure(
            title: section.title,
            color: section.color,
            isExpanded: section.isExpanded,
            itemCount: section.items.count
        )
        
        // 添加点击手势
        header.onTap = { [weak self] in
            self?.toggleSection(at: indexPath.section)
        }
        
        return header
    }
}

// MARK: - UICollectionViewDelegate
extension ExpandableDecorationCollectionViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let item = sections[indexPath.section].items[indexPath.item]
        print("点击了：\(item)")
        
        // 显示选中效果
        if let cell = collectionView.cellForItem(at: indexPath) {
            UIView.animate(withDuration: 0.2, animations: {
                cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }) { _ in
                UIView.animate(withDuration: 0.2) {
                    cell.transform = .identity
                }
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ExpandableDecorationCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 48 // 考虑装饰背景的内边距
        return CGSize(width: width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 32, height: 60)
    }

}
// MARK: - SectionDecorationLayoutDelegate
extension ExpandableDecorationCollectionViewController: SectionDecorationLayoutDelegate {
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: SectionDecorationLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        // 根据展开状态调整内边距
        let topInset: CGFloat = sections[section].isExpanded ? 12 : 16
        let bottomInset: CGFloat = sections[section].isExpanded ? 12 : 16
        
        return UIEdgeInsets(
            top: topInset,
            left: 16,
            bottom: bottomInset,
            right: 16
        )
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: SectionDecorationLayout,
                        headerForSectionAt section: Int) -> CGSize {
        // Header 尺寸
        return CGSize(width: collectionView.bounds.width - 32, height: 60)
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: SectionDecorationLayout,
                        footerForSectionAt section: Int) -> CGSize {
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: SectionDecorationLayout,
                        decorationImageForSectionAt section: Int) -> String? {
        // 使用模型中的装饰图片
        return sections[section].decorationImage
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: SectionDecorationLayout,
                        filletDisplayedForSectionAt section: Int) -> Bool {
        // 所有分区都有圆角
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: SectionDecorationLayout,
                        decorationImgaeDisplayedForSectionAt section: Int) -> Bool {
        // 如果有图片就显示
        return sections[section].decorationImage != nil
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: SectionDecorationLayout,
                        decorationColorForSectionAt section: Int) -> UIColor {
        // 使用模型中的背景色
        return sections[section].decorationColor
    }
}
// 仅保留 scrollViewDelegate 的 刷新（滚动停止后才刷新）
extension ExpandableDecorationCollectionViewController: UIScrollViewDelegate {
    
    // 滚动停止时刷新装饰视图
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        refreshVisibleSectionDecorations()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            refreshVisibleSectionDecorations()
        }
    }
}

//
//  SectionDecorationLayout.swift
//  SwiftTest
//
//  Created by user on 2024/8/1.
//
// 自定义带装饰的瀑布布局

import UIKit

class SectionDecorationLayout: UICollectionViewFlowLayout {
    weak var decorationDelegate: SectionDecorationLayoutDelegate?
    private var decorationBackgroundAttrs: [Int:SectionDecorationViewCollectionViewLayoutAttributes] = [:]// 保存所有自定义的section背景的布局属性
    //标记是否正在刷新，避免重复刷新
    private var isRefreshing: Bool = false
        
    override init() {
        super.init()
        // 背景View注册
        self.register(SectionBackgroundReusableView.self, forDecorationViewOfKind: SectionBackgroundReusableView.BACKGAROUND_CID)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 预处理所有装饰视图的布局属性
    override func prepare() {
        
        // 加锁：避免重复prepare
        guard !isRefreshing else { return }
        isRefreshing = true
        
        super.prepare()
        
        guard let collectionView = collectionView,
              let delegate = decorationDelegate,
              collectionView.numberOfSections > 0 else {
            
            decorationBackgroundAttrs.removeAll()
            isRefreshing = false
            return
        }
        
        // 仅更新有变化的分区（而非全量更新）
        for section in 0..<collectionView.numberOfSections {
            // 优化：仅当分区item数量变化/首次加载时更新
            let currentItemCount = collectionView.numberOfItems(inSection: section)
            let oldAttrs = decorationBackgroundAttrs[section]
            let needUpdate = oldAttrs == nil ||
                            (oldAttrs?.frame.height ?? 0) == 0 ||
                            (currentItemCount > 0 && oldAttrs?.frame.height == 60) || // 从折叠→展开
                            (currentItemCount == 0 && oldAttrs?.frame.height ?? 0 > 60)    // 从展开→折叠
            
            if needUpdate {
                createOrUpdateDecoration(for: section, delegate: delegate)
            }
        }
        
        isRefreshing = false
        
        
    }
    
    // 创建/更新单个分区的装饰属性
    private func createOrUpdateDecoration(for section: Int, delegate: SectionDecorationLayoutDelegate) {
        guard let collectionView = collectionView else { return }
        
        let numberOfItems = collectionView.numberOfItems(inSection: section)
        let sectionInset = delegate.collectionView(
            collectionView: collectionView,
            layout: self,
            insetForSectionAt: section
        )
        
        var sectionFrame: CGRect = .zero
        
        if numberOfItems > 0 {
            // 分区展开：基于items计算frame
            guard let firstItem = layoutAttributesForItem(at: IndexPath(item: 0, section: section)),
                  let lastItem = layoutAttributesForItem(at: IndexPath(item: numberOfItems - 1, section: section)) else {
                // 如果无法获取items，回退到只显示header
                createHeaderOnlyDecoration(for: section, delegate: delegate)
                return
            }
            // 合并所有cell的frame
            sectionFrame = firstItem.frame.union(lastItem.frame)
            
            // 包含header的frame
            if let headerAttrs = layoutAttributesForSupplementaryView(
                ofKind: UICollectionView.elementKindSectionHeader,
                at: IndexPath(item: 0, section: section)
            ) {
                sectionFrame = sectionFrame.union(headerAttrs.frame)
            }
            
        } else {
            // 分区折叠：只显示header
            createHeaderOnlyDecoration(for: section, delegate: delegate)
            return
        }
        
        // 调整frame以适配内边距
        sectionFrame.origin.x = sectionInset.left
        sectionFrame.origin.y -= sectionInset.top
        
        // 宽度修正：使用collectionView的实际宽度（适配旋转/尺寸变化）
        sectionFrame.size.width = collectionView.bounds.width - sectionInset.left - sectionInset.right
        sectionFrame.size.height += sectionInset.top + sectionInset.bottom
        
        // 创建装饰属性
        let attrs = SectionDecorationViewCollectionViewLayoutAttributes(
            forDecorationViewOfKind: SectionBackgroundReusableView.BACKGAROUND_CID,
            with: IndexPath(item: 0, section: section)
        )
        
        attrs.frame = sectionFrame
        attrs.zIndex = -1
        
        attrs.backgroundColor = delegate.collectionView(collectionView, layout: self, decorationColorForSectionAt: section)
                attrs.imageName = delegate.collectionView(collectionView, layout: self, decorationImageForSectionAt: section)
                attrs.cornerRadius = delegate.collectionView(collectionView, layout: self, filletDisplayedForSectionAt: section) ? 12 : 0
                
                // 缓存属性
                decorationBackgroundAttrs[section] = attrs

    }
    

    // 折叠状态下只显示header的装饰属性
    private func createHeaderOnlyDecoration(for section: Int, delegate: SectionDecorationLayoutDelegate) {
        guard let collectionView = collectionView else { return }
        
        let sectionInset = delegate.collectionView(
            collectionView: collectionView,
            layout: self,
            insetForSectionAt: section
        )
        
        // 获取header frame
        var sectionFrame: CGRect = .zero
        
        if let headerAttributes = layoutAttributesForSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            at: IndexPath(item: 0, section: section)
        ) {
            sectionFrame = headerAttributes.frame
        } else {
            // 估算header位置
            let headerSize = delegate.collectionView(
                collectionView: collectionView,
                layout: self,
                headerForSectionAt: section
            )
            // 计算Y位置：基于前序分区的实际高度
                        var yPosition: CGFloat = 0
                        for prevSection in 0..<section {
                            let prevItemCount = collectionView.numberOfItems(inSection: prevSection)
                            let prevHeaderSize = delegate.collectionView(collectionView: collectionView, layout: self, headerForSectionAt: prevSection)
                            let prevInset = delegate.collectionView(collectionView: collectionView, layout: self, insetForSectionAt: prevSection)
                            
                            // 计算前序分区总高度
                            let prevCellHeight = CGFloat(prevItemCount) * 50 // cell固定高度50
                            let prevTotalHeight = prevHeaderSize.height + prevCellHeight + prevInset.top + prevInset.bottom + minimumLineSpacing
                            yPosition += prevTotalHeight
                        }
                        
                        sectionFrame = CGRect(
                            x: sectionInset.left,
                            y: yPosition + sectionInset.top,
                            width: collectionView.bounds.width - sectionInset.left - sectionInset.right,
                            height: headerSize.height
                        )
        }
        
        // 扩展frame以包含inset
        sectionFrame.origin.y -= sectionInset.top
        sectionFrame.size.height += sectionInset.top + sectionInset.bottom
        
        // 创建装饰属性
        let attrs = SectionDecorationViewCollectionViewLayoutAttributes(
            forDecorationViewOfKind: SectionBackgroundReusableView.BACKGAROUND_CID,
            with: IndexPath(item: 0, section: section)
        )
        
        attrs.frame = sectionFrame
        attrs.zIndex = -1
        attrs.backgroundColor = delegate.collectionView(collectionView, layout: self, decorationColorForSectionAt: section)
                attrs.imageName = delegate.collectionView(collectionView, layout: self, decorationImageForSectionAt: section)
                attrs.cornerRadius = delegate.collectionView(collectionView, layout: self, filletDisplayedForSectionAt: section) ? 12 : 0
                
                decorationBackgroundAttrs[section] = attrs
        
    }
    
    // 重写：返回所有可见元素（包括装饰视图）
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let originalAttributes = super.layoutAttributesForElements(in: rect) else { return nil }
        var allAttributes = originalAttributes
        
        // 遍历所有分区，添加与rect相交的装饰属性
                for (section, decorationAttrs) in decorationBackgroundAttrs {
                    if rect.intersects(decorationAttrs.frame) {
                        // 移除重复属性，避免布局冲突
                        allAttributes.removeAll {
                            $0.representedElementKind == SectionBackgroundReusableView.BACKGAROUND_CID &&
                            $0.indexPath.section == section
                        }
                        allAttributes.append(decorationAttrs)
                    }
                }
                
        
        return allAttributes
    }
    // 重写：返回指定分区的装饰属性
    override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        guard elementKind == SectionBackgroundReusableView.BACKGAROUND_CID else {
                    return nil
                }
        return decorationBackgroundAttrs[indexPath.section]
        
    }
    
    // 滚动时刷新布局，确保装饰视图位置正确
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {

        guard let collectionView = collectionView else { return true }
        
        // 仅当宽度变化/高度变化明显时刷新
        return abs(newBounds.width - collectionView.bounds.width) > 1 ||
               abs(newBounds.height - collectionView.bounds.height) > 1
        
    }
    
    // 确保自定义属性被正确传递
    override class var layoutAttributesClass: AnyClass {
        return SectionDecorationViewCollectionViewLayoutAttributes.self
    }
        
    
    // 强制刷新指定分区的装饰视图
    func refreshDecoration(for section: Int) {
        guard let collectionView = collectionView, let delegate = decorationDelegate else { return }
        createOrUpdateDecoration(for: section, delegate: delegate)
         
        // 使用performBatchUpdates避免刷新闪烁
        collectionView.performBatchUpdates {
            collectionView.reloadSections(IndexSet(integer: section))
        }
    }
}

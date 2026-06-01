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
        // ❌ 1. 移除 isRefreshing 锁
        // 原因：在 performBatchUpdates 动画过程中，系统会高频调用 prepare()。
        // 加锁会导致第一次调用后，后续的调用被拦截，背景视图无法跟随 Cell 的动画移动，造成空白或滞后。
        
        super.prepare()
        
        guard let collectionView = collectionView,
              let delegate = decorationDelegate,
              collectionView.numberOfSections > 0 else {
            decorationBackgroundAttrs.removeAll()
            return
        }
        
        // ❌ 2. 移除 needUpdate 判断
        // 原因：不要试图去比较 oldAttrs 和 currentItemCount。
        // 在动画过程中，Cell 的 frame 每一帧都在变，我们需要每一帧都重新计算背景的高度，
        // 而不是只在“状态改变”的那一瞬间计算。
        
        // ✅ 3. 清空并全量重建
        // 每次 prepare 都是基于当前这一刻的“快照”来重建所有背景。
        decorationBackgroundAttrs.removeAll(keepingCapacity: true)
        
        for section in 0..<collectionView.numberOfSections {
            let numberOfItems = collectionView.numberOfItems(inSection: section)
            
            // 创建属性对象
            let attrs = SectionDecorationViewCollectionViewLayoutAttributes(
                forDecorationViewOfKind: SectionBackgroundReusableView.BACKGAROUND_CID,
                with: IndexPath(item: 0, section: section)
            )
            
            // 获取边距
            let sectionInset = delegate.collectionView(
                collectionView: collectionView,
                layout: self,
                insetForSectionAt: section
            )
            
            var sectionFrame: CGRect = .zero
            
            // ✅ 4. 核心逻辑：基于当前的 Item 状态计算 Frame
            if numberOfItems > 0 {
                // --- 展开状态 ---
                // 尝试获取第一个和最后一个 Cell 的位置
                // 注意：在动画过程中，这些位置是实时变化的，这正是我们想要的
                guard let firstItem = layoutAttributesForItem(at: IndexPath(item: 0, section: section)),
                      let lastItem = layoutAttributesForItem(at: IndexPath(item: numberOfItems - 1, section: section)) else {
                    // 如果拿不到 Cell 属性（极少见），回退到 Header 模式
                    createHeaderOnlyDecoration(for: section, delegate: delegate, into: attrs)
                    decorationBackgroundAttrs[section] = attrs
                    continue
                }
                
                // 计算内容区域：从第一个 Cell 顶部 到 最后一个 Cell 底部
                sectionFrame = firstItem.frame.union(lastItem.frame)
                
                // 包含 Header
                if let headerAttrs = layoutAttributesForSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionHeader,
                    at: IndexPath(item: 0, section: section)
                ) {
                    sectionFrame = sectionFrame.union(headerAttrs.frame)
                }
                
                // 应用边距
                sectionFrame.origin.x = sectionInset.left
                sectionFrame.origin.y -= sectionInset.top
                
                // 宽度修正：使用collectionView的实际宽度（适配旋转/尺寸变化）
                sectionFrame.size.width = collectionView.bounds.width - sectionInset.left - sectionInset.right
                sectionFrame.size.height += sectionInset.top + sectionInset.bottom
                
            } else {
                // --- 折叠状态 ---
                // 直接复用折叠逻辑
                createHeaderOnlyDecoration(for: section, delegate: delegate, into: attrs)
            }
            
            // ✅ 5. 统一应用样式
            attrs.frame = sectionFrame
            attrs.zIndex = -1
            attrs.backgroundColor = delegate.collectionView(collectionView, layout: self, decorationColorForSectionAt: section)
            attrs.imageName = delegate.collectionView(collectionView, layout: self, decorationImageForSectionAt: section)
            attrs.cornerRadius = delegate.collectionView(collectionView, layout: self, filletDisplayedForSectionAt: section) ? 12 : 0
            
            // 存入字典
            decorationBackgroundAttrs[section] = attrs
        }
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
        
    //MARK: -
    // 折叠状态下只显示header的装饰属性
    // 修改 createHeaderOnlyDecoration 签名，直接修改传入的 attrs，避免重复代码
    private func createHeaderOnlyDecoration(for section: Int, delegate: SectionDecorationLayoutDelegate, into attrs: SectionDecorationViewCollectionViewLayoutAttributes) {
        guard let collectionView = collectionView else { return }
        
        let sectionInset = delegate.collectionView(
            collectionView: collectionView,
            layout: self,
            insetForSectionAt: section
        )
        
        var sectionFrame: CGRect = .zero
        
        if let headerAttributes = layoutAttributesForSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            at: IndexPath(item: 0, section: section)
        ) {
            sectionFrame = headerAttributes.frame
        } else {
            // 计算Y位置：基于前序分区的实际高度
            // 估算逻辑（仅在 Header 属性还没生成时生效，例如初始化瞬间）
            var yPosition: CGFloat = 0
            for prevSection in 0..<section {
                let prevItemCount = collectionView.numberOfItems(inSection: prevSection)
                let prevHeaderSize = delegate.collectionView(collectionView: collectionView, layout: self, headerForSectionAt: prevSection)
                let prevInset = delegate.collectionView(collectionView: collectionView, layout: self, insetForSectionAt: prevSection)
                // 计算Y位置：基于前序分区的实际高度
                let prevCellHeight = CGFloat(prevItemCount) * 50// cell固定高度50
                let prevTotalHeight = prevHeaderSize.height + prevCellHeight + prevInset.top + prevInset.bottom + minimumLineSpacing
                yPosition += prevTotalHeight
            }
            // 估算header位置
            let headerSize = delegate.collectionView(collectionView: collectionView, layout: self, headerForSectionAt: section)
            sectionFrame = CGRect(
                x: sectionInset.left,
                y: yPosition + sectionInset.top,
                width: collectionView.bounds.width - sectionInset.left - sectionInset.right,
                height: headerSize.height
            )
        }
        
        // 应用边距
        sectionFrame.origin.y -= sectionInset.top
        sectionFrame.size.height += sectionInset.top + sectionInset.bottom
        attrs.frame = sectionFrame
    }
    
    // 仅标记布局需要重新计算，不触发 reload
    func forceInvalidate() {
        // 清除缓存，下一次 layoutAttributesForElements 会重新 prepare
        decorationBackgroundAttrs.removeAll()
        invalidateLayout()
    }
}

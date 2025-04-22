//
//  SectionDecorationLayout.swift
//  SwiftTest
//
//  Created by user on 2024/8/1.
//

import UIKit

class SectionDecorationLayout: UICollectionViewFlowLayout {
    
    weak var decorationDelegate: SectionDecorationLayoutDelegate?
    
    // 保存所有自定义的section背景的布局属性
    private var decorationBackgroundAttrs: [Int:UICollectionViewLayoutAttributes] = [:]
    
    // MARK:  View Life Cycle
    override init() {
        super.init()
        // 背景View注册
        self.register(SectionBackgroundReusableView.self, forDecorationViewOfKind: SectionBackgroundReusableView.BACKGAROUND_CID)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 布局配置数据
    override func prepare() {
        super.prepare()
        // 如果collectionView当前没有分区，则直接退出
        guard let numberOfSections = self.collectionView?.numberOfSections
            else {
                return
        }
        // 不存在cardDecorationDelegate就退出
        guard let delegate = decorationDelegate else {
            return
        }
        if decorationBackgroundAttrs.count > 0 {
            decorationBackgroundAttrs.removeAll()
        }
        for section:Int in 0..<numberOfSections {
            // 获取该section下第一个，以及最后一个item的布局属性
            guard let numberOfItems = self.collectionView?.numberOfItems(inSection: section),
                numberOfItems > 0,
                let firstItem = self.layoutAttributesForItem(at:
                    IndexPath(item: 0, section: section)),
                let lastItem = self.layoutAttributesForItem(at:
                    IndexPath(item: numberOfItems - 1, section: section))
                else {
                    continue
            }
            var sectionInset:UIEdgeInsets = self.sectionInset
            /// 获取该section的内边距
            let inset:UIEdgeInsets = delegate.collectionView(collectionView: self.collectionView!, layout: self, insetForSectionAt: section)
            if !(inset == .zero) {
                sectionInset = inset
            }
            
            //MARK: 分区frame受collectionView的内边距影响
//            /// 获取该section header的size
//            let headerSize = delegate.collectionView(collectionView: self.collectionView!, layout: self, headerForSectionAt: section)
//            var sectionFrame:CGRect = .zero
//            if self.scrollDirection == .horizontal {
//                let hx = (firstItem.frame.origin.x) - headerSize.width + sectionInset.left
//                let hy = (firstItem.frame.origin.y) + sectionInset.top
//                let hw = ((lastItem.frame.origin.x) + (lastItem.frame.size.width)) - sectionInset.right
//                let hh = ((lastItem.frame.origin.y) + (lastItem.frame.size.height)) - sectionInset.bottom
//                sectionFrame = CGRect(x:  hx , y: hy, width: hw, height: hh)
//                sectionFrame.origin.y = sectionInset.top
//                sectionFrame.size.width = sectionFrame.size.width-sectionFrame.origin.x
//                sectionFrame.size.height = self.collectionView!.frame.size.height - sectionInset.top - sectionInset.bottom
//                
//            } else {
//                let vx = (firstItem.frame.origin.x)
//                let vy = (firstItem.frame.origin.y) - headerSize.height + sectionInset.top
//                let vw = ((lastItem.frame.origin.x) + (lastItem.frame.size.width))
//                let vh = ( (lastItem.frame.origin.y) + (lastItem.frame.size.height) ) - sectionInset.bottom
//                sectionFrame = CGRect(x:  vx , y: vy, width: vw, height: vh + 10)
//                sectionFrame.origin.x = sectionInset.left
//                sectionFrame.size.width = (self.collectionView?.frame.size.width)! - sectionInset.left - sectionInset.right
//                sectionFrame.size.height = sectionFrame.size.height - sectionFrame.origin.y
//            }
            
            //MARK: 分区frame不受collectionView的内边距影响
            //union 操作符用于合并两个矩形区域,firstItem.frame 和 lastItem.frame 表示它们各自的边界矩形。通过 union 操作符，将这两个矩形合并成一个新的矩形，这个新的矩形包含了 firstItem 和 lastItem 的所有部分
            var sectionFrame = firstItem.frame.union(lastItem.frame)
            sectionFrame.origin.x = 0
            sectionFrame.origin.y -= sectionInset.top
            if self.scrollDirection == .horizontal {
                sectionFrame.size.width += sectionInset.left + sectionInset.right
                sectionFrame.size.height = (self.collectionView?.frame.size.height)!
            }else{
                sectionFrame.size.width = (self.collectionView?.frame.size.width)!
                sectionFrame.size.height += sectionInset.top + sectionInset.bottom
            }

            
            let attrs = SectionDecorationViewCollectionViewLayoutAttributes(forDecorationViewOfKind: SectionBackgroundReusableView.BACKGAROUND_CID, with: IndexPath(item: 0, section: section))
            let backgroundColor = delegate.collectionView(self.collectionView!, layout: self, decorationColorForSectionAt: section)
            attrs.frame = sectionFrame
            attrs.zIndex = -1//作为最底层
            attrs.backgroundColor = backgroundColor
            /// 优先保存颜色
            self.decorationBackgroundAttrs[section] = attrs
            
            /// 判断背景图片是否可见 不可见跳过
            let backgroundDisplayed = delegate.collectionView(self.collectionView!, layout: self, decorationImgaeDisplayedForSectionAt: section)
            guard backgroundDisplayed == true else {
                continue
            }
            ///  如果背景图片名称为nil，跳过
            guard let imageName = delegate.collectionView(self.collectionView!, layout: self, decorationImageForSectionAt: section) else {
                continue
            }
            attrs.imageName = imageName
            
            
            let displayedFillet = delegate.collectionView(self.collectionView!, layout: self, filletDisplayedForSectionAt: section)
            guard displayedFillet == false else {
                continue
            }
            // 将该section的布局属性保存起来
            self.decorationBackgroundAttrs[section] = attrs
        }
        
    }
    
    override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let section = indexPath.section
        if elementKind  == SectionBackgroundReusableView.BACKGAROUND_CID {
            return self.decorationBackgroundAttrs[section]
        }
        return super.layoutAttributesForDecorationView(ofKind: elementKind,
                                                       at: indexPath)
    }
    
    // 返回rect范围下父类的所有元素的布局属性以及子类自定义装饰视图的布局属性
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attrs = super.layoutAttributesForElements(in: rect)
        attrs?.append(contentsOf: self.decorationBackgroundAttrs.values.filter {
            return rect.intersects($0.frame)
        })
        return attrs
    }
}


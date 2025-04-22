//
//  SectionDecorationViewCollectionViewLayoutAttributes.swift
//  SwiftTest
//
//  Created by user on 2024/9/14.
//

import Foundation
import UIKit

/// section装饰背景的布局属性
class SectionDecorationViewCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
    
    // 装饰背景图片
    var imageName: String?
    // 背景色
    var backgroundColor = UIColor.white

    /// 所定义属性的类型需要遵从 NSCopying 协议
    /// - Parameter zone:
    /// - Returns:
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! SectionDecorationViewCollectionViewLayoutAttributes
        copy.imageName = self.imageName
        copy.backgroundColor = self.backgroundColor
        return copy
    }
    
    /// 所定义属性的类型还要实现相等判断方法（isEqual）
    /// - Parameter object:
    /// - Returns: 是否相等
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? SectionDecorationViewCollectionViewLayoutAttributes else {
            return false
        }
        if self.imageName != rhs.imageName {
            return false
        }
        if !self.backgroundColor.isEqual(rhs.backgroundColor) {
            return false
        }
        return super.isEqual(object)
    }
}

//MARK: - 
protocol SectionDecorationLayoutDelegate: NSObjectProtocol {
    
    /// Section背景的边距
    ///
    /// - Parameters:
    ///   - collectionView: collectionView
    ///   - layout: layout
    ///   - insetForSectionAtIndex: section
    /// - Returns: 边距
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout:SectionDecorationLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets
    
    
    /// 获取 Section Header 宽高
    ///
    /// - Parameters:
    ///   - collectionView: collectionView
    ///   - layout: layout
    ///   - headerForSectionAtIndex: section
    /// - Returns: 宽高
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout:SectionDecorationLayout,
                        headerForSectionAt section: Int) -> CGSize
    
    
    /// 获取 section footer 宽高
    ///
    /// - Parameters:
    ///   - collectionView: collectionView
    ///   - layout: layout
    ///   - footerForSectionAtIndex: section
    /// - Returns: 宽高
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout:SectionDecorationLayout,
                        footerForSectionAt section: Int) -> CGSize
    
    
    /// 指定section的背景图片名字，默认为nil
    ///
    /// - Parameters:
    ///   - collectionView: collectionView
    ///   - collectionViewLayout: layout
    ///   - section: section
    /// - Returns: 图片字符
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: SectionDecorationLayout,
                        decorationImageForSectionAt section: Int) -> String?
    
    
    
    /// 指定section背景图的圆角，默认值为true
    ///
    /// - Parameters:
    ///   - collectionView: collectionView
    ///   - collectionViewLayout: layout
    ///   - section: section
    /// - Returns: 图片字符
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: SectionDecorationLayout,
                        filletDisplayedForSectionAt section: Int) -> Bool
    
    /// 指定section是否显示背景图片，默认值为false
    ///
    /// - Parameters:
    ///   - collectionView: collectionView
    ///   - collectionViewLayout: layout
    ///   - section: section
    /// - Returns: Bool
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: SectionDecorationLayout,
                        decorationImgaeDisplayedForSectionAt section: Int) -> Bool
    
    /// 指定section背景颜色，默认为白色
    ///
    /// - Parameters:
    ///   - collectionView: collectionView
    ///   - collectionViewLayout: layout
    ///   - section: section
    /// - Returns: UIColor
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: SectionDecorationLayout,
                        decorationColorForSectionAt section: Int) -> UIColor
    
}

extension SectionDecorationLayoutDelegate {
    
    /// 设置Section 背景图 的内边距
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout:SectionDecorationLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    /// 获取 Section Header 宽高 (设置section背景图是否占据头的size)
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout:SectionDecorationLayout,
                        headerForSectionAt section: Int) -> CGSize {
        print("设置\(section)背景图是否占据头的size")
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout:SectionDecorationLayout,
                        footerForSectionAt section: Int) -> CGSize {
        return CGSize(width: 0, height: 0)
    }
    
    /// 获取 Section 背景图
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: SectionDecorationLayout,
                        decorationImageForSectionAt section: Int) -> String? {
        return nil
    }
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: SectionDecorationLayout,filletDisplayedForSectionAt section: Int) -> Bool {
        return true
    }
    
    /// 是否显示 Section 背景图
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: SectionDecorationLayout,
                        decorationImgaeDisplayedForSectionAt section: Int) -> Bool {
        return false
    }
    
    /// 是否显示单独设置 Section 背景颜色
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: SectionDecorationLayout,
                        decorationColorForSectionAt section: Int) -> UIColor {
        return UIColor.clear
    }
    
}

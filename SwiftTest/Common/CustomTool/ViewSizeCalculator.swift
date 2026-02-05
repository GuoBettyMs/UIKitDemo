//
//  ViewSizeCalculator.swift
//  SwiftTest
//
//  Created by user on 2025/4/22.
//

import  Foundation
import UIKit

// MARK: - 视图尺寸模型
/// 包含视图适配后的各种尺寸属性
struct ViewSizeModel {
    let width: CGFloat
    let height: CGFloat
    let fontSize: CGFloat
    let cornerRadius: CGFloat  // 更符合Swift命名规范（去掉冗余的"Size"）
}

// MARK: - 尺寸计算工具
struct ViewSizeCalculator {
    
    /// 计算适配后的视图尺寸
    /// - Parameters:
    ///   - designScreenWidth: 设计稿基准宽度（默认1170）
    ///   - designWidth: 设计稿中元素的原始宽度
    ///   - designHeight: 设计稿中元素的原始高度
    ///   - designFontSize: 设计稿中的字体大小
    ///   - designCornerRadius: 设计稿中的圆角大小
    /// - Returns: 适配当前屏幕的尺寸模型
    static func calculateAdaptiveSize(
        designScreenWidth: CGFloat = 1170,
        designWidth: CGFloat,
        designHeight: CGFloat,
        designFontSize: CGFloat,
        designCornerRadius: CGFloat
    ) -> ViewSizeModel {
        // 安全检查
        guard designScreenWidth > 0 else {
            assertionFailure("设计稿宽度必须大于0")
            return ViewSizeModel(width: 0, height: 0, fontSize: 0, cornerRadius: 0)
        }
        
        // 获取当前有效内容宽度（考虑安全区域）
        let contentWidth = min(devicePageContentW, UIScreen.main.bounds.height)
        Log.debug("当前计算宽度: \(contentWidth)")
        
        // 计算宽度比例（基于内容宽度与设计稿宽度的比例）
        let widthRatio = contentWidth / designScreenWidth
        
        // 高度按比例缩放（保持宽高比）
        let adaptedHeight = designHeight * widthRatio
        
        return ViewSizeModel(
            width: designWidth * widthRatio,
            height: adaptedHeight,
            fontSize: designFontSize * widthRatio,
            // 圆角按高度比例缩放（保持视觉比例）
            cornerRadius: designCornerRadius * (adaptedHeight / designHeight)
        )
    }
    
    static func example(){
        let buttonSize = ViewSizeCalculator.calculateAdaptiveSize(
            designWidth: 200,
                designHeight: 60,
                designFontSize: 16,
                designCornerRadius: 8
            )
        print("""
            适配后尺寸：
            宽度: \(buttonSize.width)
            高度: \(buttonSize.height)
            字体: \(buttonSize.fontSize)
            圆角: \(buttonSize.cornerRadius)
        """)
        
    }
    
}

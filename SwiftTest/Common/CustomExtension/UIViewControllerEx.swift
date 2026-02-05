//
//  UIViewControllerEx.swift
//  SwiftTest
//
//  Created by user on 2026/2/2.
//

import UIKit

extension UIViewController {
    // MARK: - 快速添加软键盘处理
    /// 为控制器的主视图添加软键盘处理
    /// - Parameters:
    ///   - scrollView: 需要处理的滚动视图
    ///   - config: 配置选项
    /// - Returns: 键盘处理器实例
    @discardableResult
    func setupKeyboardHandler(for scrollView: UIScrollView? = nil, config: KeyboardHandlingConfig = KeyboardHandlingConfig()) -> KeyboardHandler? {
        return view.addKeyboardHandler(for: scrollView, config: config)
    }
    
    /// 为多个滚动视图添加键盘处理
    func setupMultipleKeyboardHandlers(scrollViews: [UIScrollView], config: KeyboardHandlingConfig = KeyboardHandlingConfig()) -> [KeyboardHandler] {
        var handlers: [KeyboardHandler] = []
        
        for scrollView in scrollViews {
            if let handler = view.addKeyboardHandler(for: scrollView, config: config) {
                handlers.append(handler)
            }
        }
        
        return handlers
    }
    
}

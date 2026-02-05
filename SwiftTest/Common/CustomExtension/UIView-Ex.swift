//
//  UIView-Ex.swift
//  SwiftTest
//
//  Created by user on 2025/4/22.
//

import UIKit

extension UIView {
    // MARK: - 快速添加软键盘处理
    private struct AssociatedKeys {
        
        //Void?（即 Optional<()>）是一个零大小的类型，因为 keyboardHandler 是 static，地址在整个程序生命周期中唯一且不变, &AssociatedKeys.keyboardHandler 可以取到一个稳定、唯一、合法的指针地址
        static var keyboardHandler: Void?
    }
    
    /// 获取关联的软键盘处理器
    var keyboardHandler: KeyboardHandler? {
        return objc_getAssociatedObject(self, &AssociatedKeys.keyboardHandler) as? KeyboardHandler
    }
    
    /// 为当前视图中的 UIScrollView 添加软键盘处理
    /// - Parameters:
    ///   - scrollView: 需要处理的滚动视图（如果为 nil，自动查找第一个 UIScrollView）
    ///   - config: 配置选项
    /// - Returns: 软键盘处理器实例
    @discardableResult
    func addKeyboardHandler(for scrollView: UIScrollView? = nil, config: KeyboardHandlingConfig = KeyboardHandlingConfig()) -> KeyboardHandler? {
        
        let targetScrollView: UIScrollView? = scrollView ?? findFirstScrollView()
                
        guard let validScrollView = targetScrollView else {
            print("⚠️ 未找到可用的 UIScrollView")
            return nil
        }
        
        let handler = KeyboardHandler(scrollView: validScrollView, config: config)
        objc_setAssociatedObject(self, &AssociatedKeys.keyboardHandler, handler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        return handler
    }

    
    /// 移除软键盘处理器
    func removeKeyboardHandler() {
        objc_setAssociatedObject(self, &AssociatedKeys.keyboardHandler, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func findFirstScrollView() -> UIScrollView? {
        if let scrollView = self as? UIScrollView {
            return scrollView
        }
        
        for subview in subviews {
            if let scrollView = subview.findFirstScrollView() {
                return scrollView
            }
        }
        
        return nil
    }
    

    //MARK: 指定第一反应者
    private func findFirstResponder() -> UIView? {
        if self.isFirstResponder {
            return self
        }

        for subView in self.subviews {
            if let firstResponder = subView.findFirstResponder() {
                return firstResponder
            }
        }

        return nil
    }
}

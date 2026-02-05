//
//  KeyboardHandler.swift
//  SwiftTest
//
//  Created by user on 2026/2/2.
//
//通用的软键盘处理工具类

import UIKit

/// 软键盘处理配置
struct KeyboardHandlingConfig {
    /// 底部额外偏移（如工具栏高度）
    var bottomOffset: CGFloat = 0
    /// 键盘上方额外间距
    var extraSpacing: CGFloat = 20
    /// 是否自动滚动到活跃输入框
    var autoScrollToField: Bool = true
    /// 动画持续时间
    var animationDuration: TimeInterval = 0.25
}

/// 软键盘处理器
class KeyboardHandler {
    
    private weak var scrollView: UIScrollView?
    private var config: KeyboardHandlingConfig
    private var originalContentInset: UIEdgeInsets = .zero
    private var originalScrollIndicatorInsets: UIEdgeInsets = .zero
    private var keyboardHeight: CGFloat = 0
    private var isKeyboardVisible: Bool = false
    
    /// 初始化键盘处理器
    /// - Parameters:
    ///   - scrollView: 需要处理的滚动视图
    ///   - config: 配置选项
    init(scrollView: UIScrollView, config: KeyboardHandlingConfig = KeyboardHandlingConfig()) {
        self.scrollView = scrollView
        self.config = config
        setupKeyboardObservers()
    }
    
    deinit {
        removeKeyboardObservers()
    }
    
    // MARK: - 公开方法
    
    /// 更新配置
    func updateConfig(_ config: KeyboardHandlingConfig) {
        self.config = config
    }
    
    /// 手动触发键盘调整（用于界面变化后）
    func manuallyAdjustForKeyboard() {
        guard isKeyboardVisible, let scrollView = scrollView else { return }
        adjustScrollViewForKeyboard(height: keyboardHeight, scrollView: scrollView)
    }
    
    /// 主动滚动指定的输入框
    func scrollToTextField(_ textField: UIView, animated: Bool = true) {
        guard let scrollView = scrollView else { return }
        scrollToView(textField, in: scrollView, animated: animated)
    }
    
    /// 获取当前键盘高度
    var currentKeyboardHeight: CGFloat {
        return keyboardHeight
    }
    
    // MARK: - 私有方法
    
    private func setupKeyboardObservers() {
        let notifications = [
            UIResponder.keyboardWillShowNotification,
            UIResponder.keyboardWillHideNotification,
            UIResponder.keyboardWillChangeFrameNotification
        ]
        
        notifications.forEach { name in
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleKeyboardNotification(_:)),
                name: name,
                object: nil
            )
        }
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    //监听软键盘状态,调整文本框位置
    @objc private func handleKeyboardNotification(_ notification: Notification) {
        guard let scrollView = scrollView,
              let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }
        
        let isShowing = notification.name == UIResponder.keyboardWillShowNotification
        let isHiding = notification.name == UIResponder.keyboardWillHideNotification
        let isChanging = notification.name == UIResponder.keyboardWillChangeFrameNotification
        
        // 保存原始值（只在第一次显示时保存）
        if isShowing && !isKeyboardVisible {
            originalContentInset = scrollView.contentInset
            originalScrollIndicatorInsets = scrollView.scrollIndicatorInsets
        }
        
        if isShowing || isChanging {
            isKeyboardVisible = true
            keyboardHeight = keyboardFrame.height
            adjustScrollViewForKeyboard(height: keyboardHeight, scrollView: scrollView)
            
            if config.autoScrollToField, let activeField = findActiveTextField(in: scrollView) {
                scrollToView(activeField, in: scrollView, animated: true)
            }
        } else if isHiding {
            isKeyboardVisible = false
            keyboardHeight = 0
            restoreScrollView(scrollView)
        }
        
        // 同步键盘动画
        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve), animations: {
            scrollView.layoutIfNeeded()
        })
    }
    
    //调整文本框位置到软键盘上方
    private func adjustScrollViewForKeyboard(height: CGFloat, scrollView: UIScrollView) {
        let bottomInset = height - config.bottomOffset
        
        // 确保 inset 不为负
        let safeBottomInset = max(bottomInset, 0)
        
        let newContentInset = UIEdgeInsets(
            top: originalContentInset.top,
            left: originalContentInset.left,
            bottom: safeBottomInset,
            right: originalContentInset.right
        )
        
        scrollView.contentInset = newContentInset
        scrollView.scrollIndicatorInsets = newContentInset
    }
    
    private func restoreScrollView(_ scrollView: UIScrollView) {
        scrollView.contentInset = originalContentInset
        scrollView.scrollIndicatorInsets = originalScrollIndicatorInsets
    }
    
    //滚动文本框的父视图 scrollView
    private func scrollToView(_ view: UIView, in scrollView: UIScrollView, animated: Bool = true) {
        // 将视图坐标系转换到 scrollView 的 contentView
        let targetFrame = view.convert(view.bounds, to: scrollView)
        
        // 计算可见区域（减去键盘高度和额外间距）
        let visibleFrame = CGRect(
            x: 0,
            y: 0,
            width: scrollView.bounds.width,
            height: scrollView.bounds.height - keyboardHeight - config.extraSpacing
        )
        
        // 如果视图不在可见区域内，滚动到合适位置
        if !visibleFrame.contains(targetFrame) {
            // 扩展一点区域让视图完全可见
            var rectToShow = targetFrame
            rectToShow.size.height += config.extraSpacing
            
            scrollView.scrollRectToVisible(rectToShow, animated: animated)
        }
    }
    
    private func findActiveTextField(in view: UIView) -> UIView? {
        if view.isFirstResponder && (view is UITextField || view is UITextView) {
            return view
        }
        
        for subview in view.subviews {
            if let found = findActiveTextField(in: subview) {
                return found
            }
        }
        
        return nil
    }
}

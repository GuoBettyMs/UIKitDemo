//
//  UIView-Ex.swift
//  SwiftTest
//
//  Created by user on 2025/4/22.
//

import UIKit

extension UIView {
    
    //MARK: 监听软键盘收起, ScrollView 偏移恢复初始值
    /// - Returns:
    /// 监听软键盘收起
    func recoverScrollViewForKeyboard(){
        guard let scrollView = self as? UIScrollView else {
            print("View must be a UIScrollView to use this function")
            return
        }
        scrollView.transform = CGAffineTransform.identity
    }
    
    //MARK: 监听软键盘弹出,调整 ScrollView 偏移
    /// - Returns:
    /// 监听软键盘弹出
    func adjustScrollViewForKeyboard(notification: NSNotification, in viewController: UIViewController) {
        guard let scrollView = self as? UIScrollView else {
            print("View must be a UIScrollView to use this function")
            return
        }

        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height// 获取键盘最后的Frame值

        // 将当前选定的文本框作为第一反应者
        guard let firstResponder = self.findFirstResponder() else { return }

        let editingTextField = firstResponder.convert(firstResponder.bounds, to: viewController.view)// 获取当前编辑的文本框在当前 viewController.view 的坐标
        let textFieldBottomHeight = UIScreen.main.bounds.height - (editingTextField.origin.y + editingTextField.size.height)// 获取<当前编辑的文本框底部>到<当前 viewController.view 底部>的距离
        let distanceToKeyboard = keyboardHeight - textFieldBottomHeight//比较<文本框到屏幕的底部高度 textFieldBottomHeight>和<软键盘高度 keyboardHeight>

        //由于软键盘永远是与屏幕底部对齐,若 keyboardHeight > textFieldBottomHeight,说明文本框被软键盘遮挡,文本框的父级 scrollView 需要发生位移
        if distanceToKeyboard > 0 {
            scrollView.transform = CGAffineTransform(translationX: 0, y: -distanceToKeyboard)//scrollView 移动 distanceToKeyboard(交叉偏移量) 个单位
        }
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

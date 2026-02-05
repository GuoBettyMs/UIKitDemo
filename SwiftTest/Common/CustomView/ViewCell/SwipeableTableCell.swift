//
//  SwipeableTableCell.swift
//  SwiftTest
//
//  Created by user on 2026/2/2.
//
// 实现一个可以左右滑动的 UITableViewCell

import UIKit

class SwipeableTableCell: UITableViewCell {
    
    private let panGesture = UIPanGestureRecognizer() //滑动手势
    private var startX: CGFloat = 0
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupGesture() {
        panGesture.delegate = self
        panGesture.addTarget(self, action: #selector(handlePan(_:)))
        contentView.addGestureRecognizer(panGesture)
    }
    
    // MARK: - UIGestureRecognizerDelegate 协议中的方法
    
    // 1. 过滤触摸：不让手势接收按钮的触摸
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldReceive touch: UITouch) -> Bool {
        // 如果触摸的是按钮，让按钮优先
        if touch.view is UIButton {
            return false
        }
        return true
    }
    
    // 2. 控制开始：只允许水平滑动
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else {
            return true
        }
        
        let velocity = pan.velocity(in: self)
        // 水平速度 > 垂直速度 时才允许开始
        let isHorizontal = abs(velocity.x) > abs(velocity.y)
        
        // 还要检查是否在边缘开始（更好的用户体验）
        let location = pan.location(in: self)
        let isNearEdge = location.x < 30 || location.x > bounds.width - 30
        
        return isHorizontal && isNearEdge
    }
    
    // 3. 处理冲突：允许与tableView的滚动同时识别
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // 如果是tableView的pan手势，允许同时识别
        // 这样用户可以先滑动cell，如果滑不动再滚动tableView
        if otherGestureRecognizer is UIPanGestureRecognizer,
           let scrollView = otherGestureRecognizer.view as? UIScrollView {
            return true
        }
        return false
    }
    
    // MARK: - 手势处理
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        
        switch gesture.state {
        case .began:
            startX = contentView.frame.origin.x
            
        case .changed:
            let newX = startX + translation.x
            // 限制滑动范围
            contentView.frame.origin.x = min(max(newX, -100), 100)
            
        case .ended, .cancelled:
            // 弹性回弹或完成滑动
            UIView.animate(withDuration: 0.3) {
                self.contentView.frame.origin.x = 0
            }
            
        default:
            break
        }
    }
}

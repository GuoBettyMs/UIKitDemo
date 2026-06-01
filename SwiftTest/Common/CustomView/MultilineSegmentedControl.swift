//
//  MultilineSegmentedControl.swift
//  SwiftTest
//
//  Created by user on 2026/3/2.
//
// 支持多行文本的自定义分段控制器(默认 UISegmentedControl 的文字只能单行显示)

import UIKit


class MultilineSegmentedControl: UISegmentedControl {
    
    // MARK: - 私有属性
   
    /// 用于承载自定义 Label 的透明容器
    private let overlayView = UIView()
    /// 存储自定义 Label 的数组
    private var customLabels: [UILabel] = []
    
    // MARK: - 初始化
    
    override init(items: [Any]?) {
        super.init(items: items)
        setupControl()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupControl()
    }
    
    // MARK: - 设置与布局
    private func setupControl() {
        // 1. 隐藏系统原生文本（避免重影）
        setTitleTextAttributes([.foregroundColor: UIColor.clear], for: .normal)
        setTitleTextAttributes([.foregroundColor: UIColor.clear], for: .selected)

        // 2. 彻底移除背景和分割线（关键步骤）
        let transparentImage = UIImage()
        setBackgroundImage(transparentImage, for: .normal, barMetrics: .default)
        setBackgroundImage(transparentImage, for: .selected, barMetrics: .default)
        setBackgroundImage(transparentImage, for: .highlighted, barMetrics: .default)
        setDividerImage(transparentImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)

        // 3. 清除 tintColor（去掉边框颜色）
        tintColor = .clear
        backgroundColor = .clear
        if #available(iOS 13.0, *) {
            selectedSegmentTintColor = .clear
        }

        // 4. 移除系统胶囊视图（UILiquidLensView）
        DispatchQueue.main.async {
            for subview in self.subviews {
                if String(describing: type(of: subview)).contains("LiquidLens") {
                    subview.alpha = 0
                    subview.isHidden = true
                }
            }
        }

        // 5. 自定义透明遮罩层
        overlayView.isUserInteractionEnabled = false
        overlayView.backgroundColor = .clear
        addSubview(overlayView)

        // 6. 监听事件
        addTarget(self, action: #selector(updateLabelStyles), for: .valueChanged)

        // 7. 延迟创建 Label，确保布局稳定
        DispatchQueue.main.async {
            self.createLabels()
        }
    }

    /// 创建自定义 Label
    private func createLabels() {
        // 清空旧数据
        customLabels.forEach { $0.removeFromSuperview() }
        customLabels.removeAll()
        
        
        for index in 0..<numberOfSegments {
            // 获取标题（兼容 String 和 UIImage）
            // 如果是字符串
            if let title = titleForSegment(at: index) {
                let label = UILabel()
                label.text = title
                label.numberOfLines = 0
                label.lineBreakMode = .byWordWrapping
                label.textAlignment = .center
                label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
                label.isUserInteractionEnabled = false
                
                overlayView.addSubview(label)
                customLabels.append(label)
            }
            // 如果是图片， UISegmentedControl 原生支持图片，
            // 但如果是多行文本控件，通常只处理 String。
            // 如果需要处理图片，可以在这里添加 UIImageView 的逻辑
        }
        
        setNeedsLayout()
        updateLabelStyles()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 1. 确保遮罩层撑满整个控件
        overlayView.frame = bounds
        
        guard numberOfSegments > 0 else { return }
        
        // 2. 计算每个 Segment 的宽度并布局 Label
        let segmentWidth = bounds.width / CGFloat(numberOfSegments)
        
        for (index, label) in customLabels.enumerated() {
            let x = CGFloat(index) * segmentWidth
            // 这里的 height 暂时设为 bounds.height，后续会通过 intrinsicContentSize 自适应
            label.frame = CGRect(x: x, y: 0, width: segmentWidth, height: bounds.height)
            
            // 3. 关键：设置 preferredMaxLayoutWidth 以支持自动换行计算高度
            // 减去一点边距防止文字贴边
            label.preferredMaxLayoutWidth = segmentWidth - 16
            label.setNeedsLayout()
            label.layoutIfNeeded()
        }
        
        // 4. 根据内容调整控件高度 (可选，如果父视图依赖 intrinsicContentSize)
        // 这里简单处理，通常由父视图的约束决定高度
    }
    
    // MARK: - 样式更新
    
    @objc private func updateLabelStyles() {
        let selectedIndex = selectedSegmentIndex
        
        for (index, label) in customLabels.enumerated() {
            let isSelected = (index == selectedIndex)
            
            // 使用动画让切换更平滑
            UIView.animate(withDuration: 0.2) {
                label.textColor = isSelected ? .systemBlue : .darkGray
                label.font = isSelected ?
                    UIFont.systemFont(ofSize: 14, weight: .bold) :
                    UIFont.systemFont(ofSize: 14, weight: .regular)
            }
        }
    }
    
    // MARK: - 重写 setTitle (防止外部调用导致状态不一致)
    
    override func setTitle(_ title: String?, forSegmentAt segment: Int) {
        super.setTitle(title, forSegmentAt: segment)
        // 如果外部修改了标题，需要同步修改我们的 Label
        if segment < customLabels.count {
            customLabels[segment].text = title
            setNeedsLayout()
        }
    }
}

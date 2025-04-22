//
//  CustomSlider.swift
//  SwiftTest
//
//  Created by user on 2025/4/16.
//
//自定义带标题的 Slider 

import UIKit

struct CustomSliderConfig {
    let title: String
    let min: Float
    let max: Float
    let initialValue: Float
    var handler: (Float, UILabel) -> Void
}

class CustomSlider {
    // MARK: - Usage Example
    static func example(in parentView: UIView) -> ([UISlider], [UILabel]) {
        let configs = [
            CustomSliderConfig(
                title: "Slider 1",
                min: 0,
                max: 100,
                initialValue: 10,
                handler: { value, label in
                    label.text = String(format: "%.1f", value)
                }
            )
        ]
        return addMultiSlider(in: parentView, configs)
    }
    
    // MARK: - Public API

    /// 添加带标题的 Slider 控件数组
    /// - Parameters:
    ///   - parent: 父视图
    ///   - configs: 控件配置
    /// - Returns: 返回 Slider 数组和 Label数组（便于外部进一步自定义）
    static func addMultiSlider(in parent: UIView, _ configs: [CustomSliderConfig]) -> ([UISlider], [UILabel]) {
        var sliders = [UISlider]()
        var labels = [UILabel]()
        
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        parent.addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
        }
        
        for (_, config) in configs.enumerated() {
            let (slider, label) = createSlider(with: config)
            sliders.append(slider)
            labels.append(label)
            
            let stackView = UIStackView(arrangedSubviews: [label, slider])
            stackView.axis = .vertical
            stackView.spacing = 8
            mainStackView.addArrangedSubview(stackView)
        }
        
        return (sliders, labels)
    }
    
    // MARK: - Private Implementation
    /// 添加一个带标题的 Slider 控件
    /// - Parameters:
    ///   - config: 控件配置
    ///   - index: Slider 索引
    /// - Returns: 返回创建的 Slider 和 Label（便于外部进一步自定义）
    private static func createSlider(
        with config: CustomSliderConfig
    ) -> (slider: UISlider, label: UILabel) {
        let slider = UISlider()
        slider.minimumValue = config.min
        slider.maximumValue = config.max
        slider.value = config.initialValue
        
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = config.title
        label.textColor = .black
        
        setupValueChangeHandler(for: slider, label: label, handler: config.handler)
        
        return (slider, label)
    }
    
    
    /// Slider 事件处理
    /// - Parameter slider: 控件
    /// - Parameter label: 控件数值便签
    /// - Returns: 返回携带 (控件数值和控件数值便签) 的逃逸闭包
    private static func setupValueChangeHandler(
        for slider: UISlider,
        label: UILabel,
        handler: @escaping (Float, UILabel) -> Void
    ) {
        if #available(iOS 14.0, *) {// iOS 14 以下版本使用 Target-Action
            slider.addAction(
                UIAction { _ in
                    handler(slider.value, label)
                },
                for: .valueChanged
            )
        } else {// iOS 14 以下版本使用 Target-Action
            let target = SliderTarget(handler: handler)
            target.retainedLabel = label
            
            objc_setAssociatedObject(
                slider,
                SliderTarget.key,
                target,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )//通过 objc_setAssociatedObject 将辅助对象与 Slider 关联（避免被释放）
            
            slider.addTarget(
                target,
                action: #selector(SliderTarget.valueChanged(_:)),
                for: .valueChanged
            )
        }
    }
    
    // MARK: - Helper Class
    // 用于 iOS 14 以下版本的辅助类
    private class SliderTarget {
        static var key = "com.customslider.target"
        
        let handler: (Float, UILabel) -> Void
        weak var retainedLabel: UILabel? //使用 weak 引用 UILabel 防止循环引用
        
        init(handler: @escaping (Float, UILabel) -> Void) {
            self.handler = handler
        }
        
        @objc func valueChanged(_ sender: UISlider) {
            guard let label = retainedLabel else { return }
            handler(sender.value, label)
        }
    }
}

//
//  MultilineSegmentedControl.swift
//  SwiftTest
//
//  Created by user on 2026/3/2.
//
// 多行文本分段控制器(默认 UISegmentedControl 的文字只能单行显示)

import UIKit

class MultilineSegmentedControl: UISegmentedControl {
    
    // 数组顺序存储
    private var labels: [UILabel?] = []
    private var isConfiguring = false
    
    override init(items: [Any]?) {
        super.init(items: items)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        addTarget(self, action: #selector(updateStyles), for: .valueChanged)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard !isConfiguring else { return }
        
        // 重新扫描并配置所有 Label
        scanAndConfigureLabels()
        updateStyles()
    }
    
    private func scanAndConfigureLabels() {
        // 重置 labels 数组
        labels = Array(repeating: nil, count: numberOfSegments)
        
        // 遍历所有子视图，找到所有 UILabel
        var foundLabels: [UILabel] = []
        
        func findAllLabels(in view: UIView) {
            for subview in view.subviews {
                if let label = subview as? UILabel {
                    foundLabels.append(label)
                }
                findAllLabels(in: subview)
            }
        }
        
        for subview in subviews {
            findAllLabels(in: subview)
        }
        
        // 根据标题内容匹配 Label 到对应的分段
        for i in 0..<numberOfSegments {
            guard let title = titleForSegment(at: i) else { continue }
            
            // 清理标题（移除换行符用于匹配）
            let cleanTitle = title.replacingOccurrences(of: "\n", with: "")
            
            // 找到包含该标题的 Label
            for label in foundLabels {
                if let labelText = label.text,
                   labelText.replacingOccurrences(of: "\n", with: "") == cleanTitle {
                    labels[i] = label
                    configureLabel(label, at: i)
                    break
                }
            }
        }
    }
    
    private func configureLabel(_ label: UILabel, at index: Int) {
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        
        // 计算最大宽度
        let segmentWidth = bounds.width / CGFloat(numberOfSegments)
        label.preferredMaxLayoutWidth = segmentWidth - 16
        
        // 强制重新布局
        label.setNeedsLayout()
        label.layoutIfNeeded()
    }
    
    @objc private func updateStyles() {
        let selectedIndex = selectedSegmentIndex
        
        for (index, label) in labels.enumerated() {
            guard let label = label else { continue }
            
            let isSelected = (index == selectedIndex)
            
//            // 设置字体和颜色
            //根据isSelected状态为 Label 设置粗体 / 常规体字体, 会出现单行或单行截断
            label.textColor = isSelected ? .systemBlue : .darkGray
            
        }
    }
    
    override func setTitle(_ title: String?, forSegmentAt segment: Int) {
        super.setTitle(title, forSegmentAt: segment)
        // 清除缓存，强制重新扫描
        labels = []
        setNeedsLayout()
    }
}



//MARK: 完全自定义控件 SegmentedControl
//class MultilineSegmentedControl: UIView {
//    
//    private var buttons: [UIButton] = []
//    private let stackView = UIStackView()
//    
//    var selectedIndex: Int = 0 {
//        didSet {
//            updateButtonStyles()
//        }
//    }
//    
//    var titles: [String] = [] {
//        didSet {
//            setupButtons()
//        }
//    }
//    
//    var valueChangedHandler: ((Int) -> Void)?
//    
//    init(items: [String]) {
//        self.titles = items
//        super.init(frame: .zero)
//        setupView()
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupView()
//    }
//    
//    private func setupView() {
//        stackView.axis = .horizontal
//        stackView.distribution = .fillEqually
//        stackView.spacing = 4
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(stackView)
//        
//        NSLayoutConstraint.activate([
//            stackView.topAnchor.constraint(equalTo: topAnchor),
//            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
//            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
//        ])
//        
//        setupButtons()
//    }
//    
//    private func setupButtons() {
//        buttons.forEach { $0.removeFromSuperview() }
//        buttons.removeAll()
//        
//        for (index, title) in titles.enumerated() {
//            let button = UIButton(type: .custom)
//            button.setTitle(title, for: .normal)
//            button.titleLabel?.numberOfLines = 0
//            button.titleLabel?.textAlignment = .center
//            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
//            button.backgroundColor = .lightGray
//            button.layer.cornerRadius = 8
//            button.tag = index
//            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
//            
//            buttons.append(button)
//            stackView.addArrangedSubview(button)
//        }
//        
//        updateButtonStyles()
//    }
//    
//    private func updateButtonStyles() {
//        for (index, button) in buttons.enumerated() {
//            let isSelected = (index == selectedIndex)
//            button.backgroundColor = isSelected ? .systemBlue : .lightGray
//            button.setTitleColor(isSelected ? .white : .darkGray, for: .normal)
//            button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: isSelected ? .bold : .regular)
//        }
//    }
//    
//    @objc private func buttonTapped(_ sender: UIButton) {
//        selectedIndex = sender.tag
//        valueChangedHandler?(selectedIndex)
//    }
//    
//    // 保持与 UISegmentedControl 相似的接口
//    func titleForSegment(at index: Int) -> String? {
//        guard index < titles.count else { return nil }
//        return titles[index]
//    }
//}

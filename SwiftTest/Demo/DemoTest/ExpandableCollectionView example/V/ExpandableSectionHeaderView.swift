//
//  ExpandableSectionHeaderView.swift
//  SwiftTest
//
//  Created by user on 2026/2/6.
//
//自定义 Section Header View

import UIKit

class ExpandableSectionHeaderView: UICollectionReusableView {
    
    // MARK: - Properties
    
    var onTap: (() -> Void)?
    
    // MARK: - UI Components
    
    private let containerView: UIView = {
        let view = UIView()
        if #available(iOS 13.0, *) {
            view.backgroundColor = .secondarySystemBackground
        } else {
            // Fallback on earlier versions
        }
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        if #available(iOS 13.0, *) {
            label.textColor = .label
        } else {
            // Fallback on earlier versions
        }
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        if #available(iOS 13.0, *) {
            label.textColor = .secondaryLabel
        } else {
            // Fallback on earlier versions
        }
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let expandButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let colorIndicator: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(colorIndicator)
        containerView.addSubview(titleLabel)
        containerView.addSubview(countLabel)
        containerView.addSubview(expandButton)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
            colorIndicator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            colorIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            colorIndicator.widthAnchor.constraint(equalToConstant: 8),
            colorIndicator.heightAnchor.constraint(equalToConstant: 32),
            
            titleLabel.leadingAnchor.constraint(equalTo: colorIndicator.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            expandButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            expandButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            expandButton.widthAnchor.constraint(equalToConstant: 24),
            expandButton.heightAnchor.constraint(equalToConstant: 24),
            
            countLabel.trailingAnchor.constraint(equalTo: expandButton.leadingAnchor, constant: -12),
            countLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
    
    private func setupGesture() {
        // 添加整个header的点击手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
        
        // 按钮也响应点击
        expandButton.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }
    
    // MARK: - Configuration
    
    func configure(title: String, color: UIColor, isExpanded: Bool, itemCount: Int) {
        titleLabel.text = title
        colorIndicator.backgroundColor = color
        countLabel.text = "\(itemCount) 项"
        
        updateExpandState(isExpanded: isExpanded)
    }
    
    func updateExpandState(isExpanded: Bool) {
        let imageName = isExpanded ? "chevron.down" : "chevron.right"
        if #available(iOS 13.0, *) {
            let image = UIImage(systemName: imageName)
            UIView.transition(with: expandButton, duration: 0.3, options: .transitionFlipFromTop) {
                self.expandButton.setImage(image, for: .normal)
            }
        } else {
            // Fallback on earlier versions
        }
        
        // 添加旋转动画
        let rotationAngle: CGFloat = isExpanded ? .pi : 0
        UIView.animate(withDuration: 0.3) {
            self.expandButton.transform = CGAffineTransform(rotationAngle: rotationAngle)
        }
    }
    
    // MARK: - Actions
    
    @objc private func handleTap() {
        // 添加点击反馈
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
            if #available(iOS 13.0, *) {
                self.containerView.backgroundColor = .tertiarySystemBackground
            } else {
                // Fallback on earlier versions
            }
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.containerView.transform = .identity
                if #available(iOS 13.0, *) {
                    self.containerView.backgroundColor = .secondarySystemBackground
                } else {
                    // Fallback on earlier versions
                }
            }
        }
        
        // 通知外部点击事件
        onTap?()
    }
    
    // MARK: - Highlight Effects
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let touch = touches.first, containerView.frame.contains(touch.location(in: self)) {
            containerView.alpha = 0.7
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        containerView.alpha = 1.0
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        containerView.alpha = 1.0
    }
}

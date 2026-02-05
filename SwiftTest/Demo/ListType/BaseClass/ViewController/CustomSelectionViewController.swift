//
//  CustomSelectionViewController.swift
//  SwiftTest
//
//  Created by user on 2025/4/9.
//
/**
    自定义模态弹窗，用于展示多个选项
**/

import UIKit

class CustomSelectionViewController: UIViewController {
    
    var onSelect: ((Int) -> Void)?
    
    init(titles: [String], indices: [Int]) {
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overCurrentContext //实现“半透明浮层”效果（背景仍可见）
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.backgroundColor = .systemGreen
        stackView.layer.cornerRadius = 10

        for (i, title) in titles.enumerated() {
            let button = UIButton(type: .system)
            button.tag = indices[i] // ⭐️ 用 tag 存储真实的 section 索引
            button.setInsetTitle(title: title, fontSize: 14, topInset: 8, leftInset: 8, bottomInset: 8, rightInset: 8)
            button.addTarget(self, action: #selector(didSelectItem(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
        ])
        
    }
    
    @objc private func didSelectItem(_ sender: UIButton) {
        //先 dismiss 弹窗，再 回调 onSelect
        dismiss(animated: true) {
            self.onSelect?(sender.tag)// 回调传回 section 索引
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

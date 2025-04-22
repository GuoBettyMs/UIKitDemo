//
//  CustomSelectionViewController.swift
//  SwiftTest
//
//  Created by user on 2025/4/9.
//
/**
    选择控制器
**/

import UIKit

class CustomSelectionViewController: UIViewController {
    
    var onSelect: ((Int) -> Void)?
    
    init(titles: [String], indices: [Int]) {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
        
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.backgroundColor = .systemGreen
        stackView.layer.cornerRadius = 10
        
        let titleL = UILabel()
        titleL.textAlignment = .center
        titleL.backgroundColor = .systemGreen
        titleL.text = "选择位置"
        
        for (i, title) in titles.enumerated() {
            let button = UIButton(type: .system)
            button.tag = indices[i]
            button.setInsetTitle(title: title, fontSize: 14, topInset: 8, leftInset: 8, bottomInset: 8, rightInset: 8)
            button.addTarget(self, action: #selector(didSelectItem(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
        
//        view.addSubview(titleL)
//        titleL.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
//            titleL.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            titleL.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            titleL.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            stackView.topAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
        ])
        

    }
    
    @objc private func didSelectItem(_ sender: UIButton) {
        dismiss(animated: true) {
            self.onSelect?(sender.tag)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

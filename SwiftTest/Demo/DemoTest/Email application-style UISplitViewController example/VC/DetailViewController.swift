//
//  DetailViewController.swift
//  SwiftTest
//
//  Created by user on 2026/2/5.
//
//详情视图控制器

import UIKit

class DetailViewController: UIViewController {
    
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()
    
    var mailItem: MailItem? {
        didSet {
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            // Fallback on earlier versions
        }
        
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.numberOfLines = 0
        bodyLabel.font = .systemFont(ofSize: 16)
        bodyLabel.numberOfLines = 0
        
        [titleLabel, bodyLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            bodyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bodyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func updateUI() {
        guard let item = mailItem else {
            title = "选择邮件"
            titleLabel.text = "请从左侧选择一封邮件"
            bodyLabel.text = "请从左侧选择一封邮件"
            return
        }
        
        title = item.title
        titleLabel.text = item.title
        bodyLabel.text = """
        发件人: \(item.subtitle)
        日期: \(item.date)
        
        尊敬的用户：
        
        欢迎使用我们的邮件应用！这是一封示例邮件，展示了如何在UISplitViewController中显示详细内容。
        
        UISplitViewController是一个强大的容器视图控制器，用于管理主从界面。在iPad和Mac上，它可以同时显示两个视图控制器，而在iPhone上，它会自动适应为导航界面。
        
        希望这个示例对你有帮助！
        
        祝好，
        开发团队
        """
    }
}

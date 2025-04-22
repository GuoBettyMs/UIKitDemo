//
//  MVC.swift
//  SwiftTest
//
//  Created by user on 2024/7/9.
//

import UIKit

/// - Returns:
/// 负责处理用户操作事件，并将其转换为对Model的操作，更新Model，并通知View更新。
class MVC: UIViewController {

    private var userView = View()//立即初始化的变量,在对象创建时，v 就会被赋值
    private var userModel: Model!//隐式解包的可选类型,在初始化时不能立即赋值，但确保在第一次访问之前会被赋值
    
    override func loadView() {
        view = userView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Simulate loading user data
        userModel = Model(name: "John Doe")// 确保在使用之前进行赋值,否则会导致运行时错误。
        userView.update(with: userModel.name)
    }

}

//MARK: -
/// - Returns:
/// 负责UI的显示。View从Model获取数据并展示给用户
class View: UIView{
    private let nameLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func update(with name: String) {
        nameLabel.text = name
    }
}


//MARK: -
/// - Returns:
/// 负责数据和业务逻辑的处理。Model直接处理数据的获取、存储和操作
class Model {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

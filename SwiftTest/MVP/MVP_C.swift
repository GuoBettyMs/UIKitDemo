//
//  MVP_C.swift
//  SwiftTest
//
//  Created by user on 2024/7/9.
//

import UIKit

/// - Returns:
///  1.不包含业务逻辑和视图更新逻辑 2.负责视图的初始化和绑定
class MVP_C: UIViewController {

    private var userView: UserView!
    private var userPresenter: UserPresenter!
    
    override func loadView() {
        userView = UserView()
        view = userView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userModel = UserModel(name: "John Doe")
        userPresenter = UserPresenter(view: userView, userModel: userModel)
        userPresenter.loadUser()
    }

}

/// - Returns:
/// 负责处理所有的业务逻辑
class UserPresenter {
    private weak var view: UserViewProtocol?
    private var userModel: UserModel
    
    init(view: UserViewProtocol, userModel: UserModel) {
        self.view = view
        self.userModel = userModel
    }
    
    func loadUser() {//view通过代理接收model数据
        view?.displayUserName(userModel.name)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            self.userModel.name = "MVP"
            self.view?.displayUserName(self.userModel.name)
        
        })
    }
}

/// - Returns:
/// 遵守自定义代理
class UserView: UIView, UserViewProtocol {
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
    
    func displayUserName(_ name: String) {
        nameLabel.text = name
    }
}
protocol UserViewProtocol: AnyObject {
    func displayUserName(_ name: String)
}
class UserModel {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

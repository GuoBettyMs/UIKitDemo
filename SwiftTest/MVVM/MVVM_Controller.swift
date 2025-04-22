//
//  MVVM_Controller.swift
//  SwiftTest
//
//  Created by user on 2024/7/9.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

/// - Returns:
///  1.不包含业务逻辑和视图更新逻辑 2.负责视图的初始化和绑定
class MVVM_Controller: UIViewController {

    private var userView: MVVM_View!
    private var userViewModel: MVVM_ViewModel!
    private let disposeBag = DisposeBag()
    
    override func loadView() {
        userView = MVVM_View()
        view = userView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userModel = MVVM_Model(name: "Jon")
        userViewModel = MVVM_ViewModel(user: userModel)
        
        // 绑定按钮点击事件到ViewModel
        userView.btn.rx.tap
            .bind(to: userViewModel.buttonTapped)
            .disposed(by: disposeBag)

        // 绑定ViewModel的数据到UI
        userViewModel.name
            .bind(to: userView.nameLabel.rx.text)
            .disposed(by: disposeBag)
        
    }

}

/// - Returns:
///  UI显示
class MVVM_View: UIView {
    let nameLabel = UILabel()
    let btn = UIButton()
    private let disposeBag = DisposeBag()
    
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
        
        addSubview(btn)
        btn.snp.makeConstraints { make in
            make.width.equalTo(30)
            make.height.equalTo(30)
            make.top.equalTo(nameLabel.snp.bottom)
            make.centerX.equalTo(nameLabel.snp.centerX)
        }
        btn.backgroundColor = .blue
    }
}

/// - Returns:
/// 1.业务逻辑 2.用户事件处理
class MVVM_ViewModel{
    
    let name: BehaviorRelay<String> = BehaviorRelay(value: "Initial Data")
    let buttonTapped = PublishRelay<Void>()
    private let disposeBag = DisposeBag()
    
    init(user: MVVM_Model) {
        buttonTapped
            .subscribe(onNext: { [weak self] in
                self?.clickEvent("user: mvmvm")
            })
            .disposed(by: disposeBag)
        
        
    }
    
    func clickEvent(_ title:String){
        name.accept(title)
    }

}

/// - Returns:
///  负责数据和业务逻辑的处理
class MVVM_Model {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

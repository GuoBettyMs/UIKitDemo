//
//  TestBaseVC.swift
//  SwiftTest
//
//  Created by user on 2026/1/16.
//

import NVActivityIndicatorView
import AudioToolbox
import RxCocoa
import RxSwift
import SnapKit
import UIKit


class TestBaseVC<Container: UIView>: UIViewController {
    
    var disposedBag = DisposeBag()
    var container: Container { view as! Container }
    var onDismiss: (() -> Void)?//定义返回回调闭包
    
    override func loadView() {
        super.loadView()
        if view is Container {
            
        }else {
            view = Container()
        }

        // 🔴 配置导航栏
        setupNavigationBar()
        
        //全屏返回手势
        let screen = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenBack(screenEdgePan:)))
        screen.edges = .right
        view.addGestureRecognizer(screen)
        
    }
    
    deinit {//对象销毁时彻底清理所有资源
        print("BaseVC 销毁, 子控制器被释放")
        
    }
    
    //MARK: -
    private func setupNavigationBar() {
        // 设置导航栏标题颜色
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        
        // 设置导航栏背景色
        navigationController?.navigationBar.barTintColor = .systemBlue
        navigationController?.navigationBar.tintColor = .white // 返回按钮颜色
        
        // 创建自定义返回按钮
        let backButton = UIButton(type: .system)
        if #available(iOS 13.0, *) {
            backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        backButton.setTitle(" 返回", for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        
        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backBarButtonItem
        
        // 或者使用最简单的：
        // navigationItem.leftBarButtonItem = UIBarButtonItem(
        //     title: "← 返回",
        //     style: .plain,
        //     target: self,
        //     action: #selector(goBack)
        // )
    }
    
    //MARK: -
    func presentVC(_ vc: UIViewController){
        
        // 添加回调
        onDismiss = { [weak self] in
            Log.debug("vc 已关闭，自动返回")
            self?.navigationController?.popViewController(animated: true)
        }
        
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.present(nav, animated: true)
        }

    }
    
    //MARK: -
    
    @objc private func goBack() {
        dismiss(animated: true)
    }
    
    @objc func screenBack(screenEdgePan: UIScreenEdgePanGestureRecognizer) {
        
        let x = screenEdgePan.translation(in: view).x
        if screenEdgePan.state == .ended {
            if x < 50 {
                Log.debug("全屏返回")
            }
        }
    }

}

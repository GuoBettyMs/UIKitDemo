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
        
        
        // 添加回调
        onDismiss = { [weak self] in
            guard let self = self else { return }
            
            // 1. 如果当前控制器是导航控制器的根控制器，且该导航控制器是被 present 的
            if let nav = self.navigationController,
               nav.viewControllers.first == self,
               nav.presentingViewController != nil {
                Log.debug("是 present 进来的导航控制器（根控制器），执行 dismiss 关闭整个导航控制器")
                nav.dismiss(animated: true)
            }
            // 2. 如果是 push 进来的（非根控制器）
            else if let nav = self.navigationController, nav.viewControllers.contains(self) {
                Log.debug("是 push 进来的，执行 pop 关闭 vc")
                nav.popViewController(animated: true)
            }
            // 3. 如果是单独 present 的（没有导航控制器包装）
            else if self.presentingViewController != nil {
                Log.debug("是 present 进来的，执行 dismiss 关闭 vc")
                self.dismiss(animated: true)
            }
            // 4. 无法确定
            else {
                Log.debug("无法确定呈现方式，不做任何操作")
            }
        }
        
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
        
        let destVC = vc
        let nav = UINavigationController(rootViewController: destVC)
        nav.modalPresentationStyle = .fullScreen

        // 获取当前控制器的 presenting 控制器
        if let presentingVC = self.presentingViewController {
            // 先关闭当前控制器，完成后再从 presenting 控制器上 present 新的导航控制器
            self.dismiss(animated: false) {
                print("先关闭当前控制器，完成后再从 presenting 控制器上 present 新的导航控制器")
                presentingVC.present(nav, animated: true)
            }
        } else {
            // 降级处理：直接 present（理论上不会走到这里）
            print("降级处理：直接 present")
            self.present(nav, animated: true)
        }
        
//        // 添加回调
//        onDismiss = { [weak self] in
//            Log.debug("onDismiss, vc 已关闭，自动返回")
//            self?.navigationController?.popViewController(animated: true)
//        }
//        
//        let nav = UINavigationController(rootViewController: vc)
//        nav.modalPresentationStyle = .fullScreen
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//            self.present(nav, animated: true)
//        }

    }
    
    //MARK: -
    
    @objc private func goBack() {
        onDismiss?()
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

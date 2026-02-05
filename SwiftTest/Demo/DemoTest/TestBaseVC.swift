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

        //全屏返回手势
        let screen = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenBack(screenEdgePan:)))
        screen.edges = .right
        view.addGestureRecognizer(screen)
        
    }
    
    deinit {//对象销毁时彻底清理所有资源
        print("BaseVC 销毁, 子控制器被释放")
        
    }
    
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
    
    @objc func screenBack(screenEdgePan: UIScreenEdgePanGestureRecognizer) {
        
        let x = screenEdgePan.translation(in: view).x
        if screenEdgePan.state == .ended {
            if x < 50 {
                Log.debug("全屏返回")
            }
        }
    }

}

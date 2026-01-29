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
    
    override func loadView() {
        super.loadView()
        if view is Container {
            
        }else {
            view = Container()
        }

    }
    
    deinit {//对象销毁时彻底清理所有资源
        print("BaseVC 销毁, 子控制器被释放")
        
    }

}

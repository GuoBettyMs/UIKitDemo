//
//  RightVC.swift
//  SwiftTest
//
//  Created by user on 2024/10/23.
//

import UIKit
import SnapKit
import RxSwift

class RightVC<Container: BaseV>: UIViewController {
    
    var container: Container { view as! Container }
    
    var backButton = UIBarButtonItem()
    let baseM = RightBaseM()
    
    var disposedBag = DisposeBag()
    
    
    override func loadView() {
        super.loadView()
        if view is Container {
            
        }else {
            view = Container()
        }
//        view.backgroundColor = .random()
//        view.isUserInteractionEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initConfigure()
        
        
    }
    
    deinit {
        print("RightVC 销毁")
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - private methods

    private func initConfigure(){
        
        addNavi()
        event()
        setupRotationHandling()
        
    }
    
    /// - Returns:
    /// 基本导航栏
    private func addNavi(){
        
        backButton = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        if #available(iOS 13.0, *) {
            backButton.image = UIImage(systemName: "arrowshape.turn.up.backward.fill")?.withRenderingMode(.alwaysTemplate)
        } else {
            backButton.image = UIImage(named: "BackIcon")?.withRenderingMode(.alwaysTemplate)
        }
//        backButton.imageInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        backButton.tintColor = .darkGray
        backButton.accessibilityLabel = NSLocalizedString("Back", comment: "Back")
        navigationItem.leftBarButtonItem = backButton
        navigationItem.title = "RightVC"
        
    }
    
    /// - Returns:
    /// 基本事件
    private func event(){
        
        backButton.rx.tap.subscribe(onNext: { [weak self] in
            guard self != nil else{ return }

            if isSceneEntranceStoryboard {
                
                guard let fatherVC = self?.parent?.parent as? HomePageCollectionViewController else {
                    return
                }
                
                fatherVC.rightNaC.removeFromParent()
                fatherVC.rightNaC.view.removeFromSuperview()
                fatherVC.rightNaC = nil //销毁 rightVC, 避免占用内存
                isShowRightNaC = false
                
                DispatchQueue.main.async {
                    fatherVC.collectionView.snp.remakeConstraints{ make in
                        make.edges.equalTo(fatherVC.view.safeAreaLayoutGuide.snp.edges)
                    }
                }
                
            }else{
                if UIDevice.current.userInterfaceIdiom != .phone{
                    //将处理委托给父视图控制器,self 的父级是 UINavigationController, UINavigationController 的父级是 FatherViewController
                    guard let fatherVC = self?.parent?.parent as? FatherViewController else { return }
                    fatherVC.backEvent()
                }else{
                    self?.dismiss(animated: true)
                }
            }

        }).disposed(by: disposedBag)
        
        container.debugB.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let selfs = self else { return}
                selfs.baseM.addDebugEvent(uIBlk: {
                    selfs.container.addDebugUITV()
                    selfs.container.remakeConstraintsDebugUITV(debugUITextViewH: 260)
                })
                
            }).disposed(by: disposedBag)
        container.debugB.isAccessibilityElement = false
    }

    private func setupRotationHandling() {
        // 监听屏幕旋转
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleOrientationChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }
    
    @objc func handleOrientationChange() {
        
        //屏幕旋转事件执行顺序:
        //1. 立即执行（主线程）
        Log.debug("super.viewWillTransition(to:with:)执行前, isPortraitBool: \(isPortraitBool), \(UIScreen.main.bounds.width < UIScreen.main.bounds.height)")
    
        //2. 立即执行 override func viewWillTransition（主线程）
        
        //3. 延迟执行（主线程下一个运行循环）
        DispatchQueue.main.async {
            Log.debug("super.viewWillTransition(to:with:)执行后, isPortraitBool: \(isPortraitBool)")
        }
        
    }
    
    //MARK: - helper methods
    
    @objc func sliderchange(_ slider: UISlider, for event: UIEvent?){

//         let touchEvent = event?.allTouches?.first
//         switch touchEvent?.phase {
//         case .began:
//             break
//           
//         case .ended:
//             slider.setValue(slider.value, animated: false)

        //其他代码
        
//         default:
//             break
//         }
      
    }
    
}

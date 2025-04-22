//
//  FatherViewController.swift
//  SwiftTest
//
//  Created by user on 2024/10/23.
//

import UIKit
import SnapKit
import RxSwift

class FatherViewController: UIViewController {
    
    private var bleManager: BleManager?
    
    var isShowDetail = false

    let leftVC = LeftVC()
    var leftNaC = UINavigationController()
    var rightNaC: UINavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
//        configureBle()
        
    }
    
    // 立即执行（主线程）
    //当iPad屏幕旋转时，viewWillTransition(to:with:)会调用该方法
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        print("旋转后, UIScreen.main.bounds: \(UIScreen.main.bounds),  kWidth-kHeight:\(kWidth)-\(kHeight), size: \(size),")
        
        isPortraitBool = size.width > size.height ? false : true
        kWidth = size.width
        kHeight = size.height
        devicePageContentW = UIDevice.current.userInterfaceIdiom == .pad ? (isPortraitBool ? kWidth * 0.6 : kWidth * 0.4) :  kWidth
        
        updateLayout()

    }
    
    //MARK: - private methods
    
    private func setupViews() {
        leftNaC = UINavigationController(rootViewController: leftVC)
        self.addChild(leftNaC)
        self.view.addSubview(leftNaC.view)
        
        leftNaC.view.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
    }
    
    private func configureBle(){
        #if targetEnvironment(simulator)
        // 使用模拟数据
        bleManager = MockBleManager()
        #else
        // 使用真实蓝牙
        bleManager = BleManager()
        #endif

        bleManager?.scanDelegate = self
    }
    
    // MARK: - Helper Methods
    private func updateLayout() {
        
        DispatchQueue.main.async {
            if UIDevice.current.userInterfaceIdiom == .pad {
                
                var itemW = self.leftVC.leftV.itemW
                var itemH = self.leftVC.leftV.itemH
                let leftVCW = self.isShowDetail ? (isPortraitBool ? kWidth*0.4 : kWidth*0.6) : kWidth
                let numbersOfItemPerRow = self.isShowDetail ? (isPortraitBool ? 1.0 : 3.0) : (isPortraitBool ? 3.0 : 4.0)
                let flowLayoutSectionInsetLeft = (leftVCW - (itemW * numbersOfItemPerRow)) / (numbersOfItemPerRow + 1.0)
                
                self.leftNaC.view.snp.remakeConstraints { make in
                    make.left.top.bottom.equalToSuperview()
                    make.width.equalTo(leftVCW)
                }
                
                if let layout = self.leftVC.leftV.collectionV.collectionViewLayout as? UICollectionViewFlowLayout {
                    itemW = itemW >= leftVCW-flowLayoutSectionInsetLeft*CGFloat(numbersOfItemPerRow+1) ? itemW*0.9 : itemW
                    itemH = itemW >= leftVCW-flowLayoutSectionInsetLeft*CGFloat(numbersOfItemPerRow+1) ? itemH*0.9 : itemH
                    
                    layout.itemSize = CGSize(width: itemW, height: itemH)
                    layout.minimumInteritemSpacing = flowLayoutSectionInsetLeft/2
                    layout.sectionInset = UIEdgeInsets(top: 20, left: flowLayoutSectionInsetLeft, bottom: 20, right: flowLayoutSectionInsetLeft)
                    layout.invalidateLayout()
                    
                    // 延迟获取 contentSize，确保布局更新完成
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1, execute: {
                        self.leftVC.leftV.adjustPrivatebtnByHeight()

                        //根据新布局重新调整 menuView 位置
                        if let longpressView = self.leftVC.leftV.longpressVisualEffectView{
                            
                            let attributes = layout.layoutAttributesForElements(in: self.leftVC.leftV.collectionV.frame) ?? []
                            
                            if let selectedIndexPath = self.leftVC.leftV.selectedCellIndexPath, let attribute = attributes.first(where: { $0.indexPath == selectedIndexPath }) {
                                
                                let origin = attribute.frame.origin
                                let adjustedY = origin.y + self.leftVC.view.safeAreaInsets.top + self.leftVC.view.safeAreaInsets.bottom - self.leftVC.leftV.collectionV.contentOffset.y
                                
                                if adjustedY + (itemH - 30) < self.leftVC.leftV.collectionV.frame.maxY {
                                  longpressView.frame = CGRect(x: 0, y: 0, width: leftVCW, height: kHeight)
                                  self.leftVC.leftV.menuView?.frame = CGRect(x: origin.x, y: adjustedY + (itemH - 30), width: itemW, height: itemH)
                                } else {
                                  self.leftVC.leftV.removeMenuUI()
                                }
                            } else {
                                self.leftVC.leftV.removeMenuUI()
                            }
                        }
                    })
                }
            }
        }
    }

    /// - Returns:
    /// rightVC 的赋值
    private func getRootViewController(cellData: DeviceDBModel) -> UINavigationController {
        var rootViewController = UIViewController()
        switch cellData.identifier {
        case "*0":
            let vc = ViewController()
            rootViewController = vc
        default:
            let vc = DemoVC()
            rootViewController = vc
        }
        return UINavigationController(rootViewController: rootViewController)
    }
    
    //MARK: - public methods
    /// - Returns:
    /// leftVC.collectionV cell 点击事件
    func cellTapped(_ sender: UITapGestureRecognizer) {
        if let cell = sender.view as? Home_CollectionViewCell, let leftVC = leftNaC.viewControllers.first as? LeftVC ,let indexPath = leftVC.leftV.collectionV.indexPath(for: cell as UICollectionViewCell) {

            print("cellTapped indexPath: \(String(describing: cell.deviceL.text)),\(indexPath.row)")

            let cellData = leftVC.leftV.itemList_UI[leftVC.leftV.collectionV.tag == 0 ? 3 : indexPath.section][indexPath.row]
            
            if UIDevice.current.userInterfaceIdiom != .phone {
                self.isShowDetail = true
                
                updateLayout()
                
                if rightNaC != nil {
                    rightNaC.removeFromParent()
                    rightNaC.view.removeFromSuperview()
                }
                
                rightNaC = getRootViewController(cellData: cellData)
                self.addChild(rightNaC)
                self.view.addSubview(rightNaC.view)
                
                DispatchQueue.main.async {
                    self.rightNaC.view.snp.makeConstraints {  make in
                        make.right.equalToSuperview()
                        make.top.equalTo(leftVC.view.snp.top)
                        make.bottom.equalTo(leftVC.view.snp.bottom)
                        make.left.equalTo(leftVC.view.snp.right)
                    }
                }
            }else{
                
                let rightNaC = getRootViewController(cellData: cellData)
                rightNaC.modalPresentationStyle = .fullScreen
                present(rightNaC, animated: true)
            }
        }
    }

    /// - Returns:
    /// rightVC 的返回事件
    func backEvent(){
      
        isShowDetail = false

        rightNaC.removeFromParent()
        rightNaC.view.removeFromSuperview()
        rightNaC = nil //销毁 rightVC, 避免占用内存
        
        DispatchQueue.main.async {
            self.leftNaC.view.snp.remakeConstraints { make in
                make.left.right.top.bottom.equalToSuperview()
            }
        }
        
        updateLayout()
        
    }
    

}


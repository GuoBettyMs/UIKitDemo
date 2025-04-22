//
//  HomePageSplitVC.swift
//  SwiftTest
//
//  Created by user on 2024/8/2.
//

import UIKit
import SnapKit

protocol ViewControllerDelegate: AnyObject {
    func didSelect(_ str: String)
}


class HomePageSplitVC: UISplitViewController {
    
    var isPortraitBool = {
        if let window = UIApplication.shared.windows.first {
            return window.frame.size.width > window.frame.size.height ? false : true
        }
        return true
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadViewControllers()

    }

    private func loadViewControllers() {
        
        let masterController = PrimaryVC()
        masterController.vcdelegate = self //为左侧导航栏设置代理
        masterController.show(listCount: [4,1,1,6]) //设置左侧导航栏的数据源
//        masterController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width*0.6, height: UIScreen.main.bounds.height)
        
        let detailController = SecondaryVC()
        detailController.showLabel("SecondaryVC")
//        detailController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width*0.4, height: UIScreen.main.bounds.height)
        
        let masterNav = UINavigationController(rootViewController: masterController)
        let detailNav = UINavigationController(rootViewController: detailController)

        viewControllers = [masterNav,detailNav]
        preferredDisplayMode = UISplitViewController.DisplayMode.oneBesideSecondary

        
        print(",",self.view.frame.width ,masterNav.viewControllers[0].view.frame.width, masterController.view.frame)
       
    }

}

extension HomePageSplitVC: ViewControllerDelegate{
   
    /// - Returns:
    /// 执行代理方法, ,左侧导航栏与右侧详情页面进行联动
    func didSelect(_ str: String) {
        let vc = SecondaryVC()
        let detailNav = UINavigationController(rootViewController: vc)
        vc.showLabel(str)//向右侧详情页面传递 str 值
        self.showDetailViewController(detailNav, sender: nil)
    }
}

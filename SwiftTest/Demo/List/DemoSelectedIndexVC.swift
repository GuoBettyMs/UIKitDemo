//
//  DemoSelectedIndexVC.swift
//  SwiftTest
//
//  Created by user on 2025/4/10.
//


import UIKit

class DemoSelectedIndexVC: BaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()
 
    }

    /**
        根据选定索引配置 BaseVC 视图控制器
    **/
    override func configurationWithSelectedIndex(_ selectedIndex: Int) -> Any? {
        switch selectedIndex {
            case 0: return CustomDataForListComposer.table()
            case 1: return CustomDataForListComposer.collection()
            default: return CustomDataForListComposer.none()
        }
    }


}

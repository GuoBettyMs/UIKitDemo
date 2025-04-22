//
//  DemoSelectedTypeStringVC.swift
//  SwiftTest
//
//  Created by user on 2025/4/11.
//

import UIKit

class DemoSelectedTypeStringVC: BaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    /**
        根据选定字符串配置 BaseVC 视图控制器
    **/
    override func configurationWithSelectedTypeString(_ selectedTypeStr: String) -> Any? {
        switch selectedTypeStr{
        case "table": return CustomDataForListComposer.table()
        case "collection": return CustomDataForListComposer.collection()
        default: return CustomDataForListComposer.none()
        }
    }

}

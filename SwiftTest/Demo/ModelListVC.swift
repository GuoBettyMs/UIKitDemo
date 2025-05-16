//
//  ModelListVC.swift
//  SwiftTest
//
//  Created by user on 2025/4/8.
//

import UIKit

class ModelListVC: BaseListVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sectionTitleArr = [
            "TEST",
            "Nested Lists | 嵌套列表",
            "Mixed Chart | 混合图形",
            "Custom Style Chart| 一些自定义风格样式图表",
            "Pie Chart With Custom Style | 一些自定义风格样式饼图",
            "Column Chart With Custom Style | 一些自定义风格样式柱状图",
            "Bar Chart With Custom Style | 一些自定义风格样式条形图",
            "Line Chart With Custom Style | 一些自定义风格样式折线图",
            "Spine Chart With Custom Style | 一些自定义风格样式曲线图",
            "Area Chart With Custom Style | 一些自定义风格样式折线填充图",
            "Areaspline Chart With Custom Style | 一些自定义风格样式曲线填充图",
            "Scatter Chart With Custom Style | 一些自定义风格样式散点图",
            "Bubble Chart With Custom Style | 一些自定义风格样式气泡图",
        ]
        
        cellTitleArr = [
            [
                "frame与Bounds的区别",
                "编辑分享表格",
                "环形进度条",
                "test",
                "时区选择器"
            ],
            [
                "UITableView---表格视图",
                "UICollectionView---集合视图",
                "None---无视图"
            ],
            [],
            [],
            [],
            [],
            [],
            [],
            [],
            [],
            [],
            [],
            [],
            [],
            
        ]

        typeArr = [
            [],
            [
                ListType.table,
                ListType.collection,
                ListType.none
            ],
            [
                ListType.table,
                ListType.collection,
                ListType.none
            ],
            [
                "table",
                "collection",
                "none"
            ],
            [],
            [],
            [],
            [],
            [],
            [],
            [],
            [],
            [],
            [],

        ]

        
    }

}

extension ModelListVC{
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            let vc = DemoTestVC()
            vc.selectedIndex = indexPath.row
            vc.navigationItemTitle = cellTitleArr[indexPath.section][indexPath.row]
            vc.hidesBottomBarWhenPushed = true //是否自动隐藏底部标签栏
            navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = DemoSelectedListTypeVC()
            vc.selectedIndex = indexPath.row
            vc.navigationItemTitleArr = typeArr[indexPath.section]
            vc.hidesBottomBarWhenPushed = true //是否自动隐藏底部标签栏
            navigationController?.pushViewController(vc, animated: true)

        default: break
        }
        print("Cell clicked at row: \(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: true) // 取消选中
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let vc = DemoTestVC()
            vc.selectedIndex = indexPath.row
            vc.navigationItemTitle = cellTitleArr[indexPath.section][indexPath.row]
            vc.hidesBottomBarWhenPushed = true //是否自动隐藏底部标签栏
            navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = DemoSelectedListTypeVC()
            vc.selectedIndex = indexPath.row
            vc.navigationItemTitleArr = typeArr[indexPath.section]
            vc.hidesBottomBarWhenPushed = true //是否自动隐藏底部标签栏
            navigationController?.pushViewController(vc, animated: true)

        default: break
        }
        collectionView.deselectItem(at: indexPath, animated: true)// 取消选中
    }
}

//
//  DemoSelectedListTypeVC.swift
//  SwiftTest
//
//  Created by user on 2025/4/10.
//
// 表格视图,支持切换不同的列表视图

import UIKit

class DemoSelectedListTypeVC: ListTypeBasicViewcontroller {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItemTitleArr = [
            ListType.table,
            ListType.collection,
            ListType.none
        ]
        selectedIndex = 0

        setupUI()
        
    }
    
    //根据列表类型配置 BaseVC 的基本数据
    override func configurationWithSelectedListType(_ selectedListType: ListType) -> Any? {
        
        switch selectedListType{
        case .table:
            return CustomDataForListComposer.table()
        case .collection:
            return CustomDataForListComposer.collection()
        default:
            return CustomDataForListComposer.none()
        }
    }
//    /**
//        根据选定索引配置 BaseVC 视图控制器
//    **/
//    override func configurationWithSelectedIndex(_ selectedIndex: Int) -> Any? {
//        switch selectedIndex {
//            case 0: return CustomDataForListComposer.table()
//            case 1: return CustomDataForListComposer.collection()
//            default: return CustomDataForListComposer.none()
//        }
//    }
    
//    /**
//        根据选定字符串配置 BaseVC 视图控制器
//    **/
//    override func configurationWithSelectedTypeString(_ selectedTypeStr: String) -> Any? {
//        switch selectedTypeStr{
//        case "table": return CustomDataForListComposer.table()
//        case "collection": return CustomDataForListComposer.collection()
//        default: return CustomDataForListComposer.none()
//        }
//    }
}

extension DemoSelectedListTypeVC{
    
    //表格视图点击事件
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            let vc = DemoTestVC()
            vc.selectedIndex = indexPath.row
            vc.navigationItemTitle = model.cellTitleArr[indexPath.section][indexPath.row]
            vc.hidesBottomBarWhenPushed = true //是否自动隐藏底部标签栏
//            navigationController?.pushViewController(vc, animated: true)
            
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.present(nav, animated: true)
            }

        default: break
        }
//        print("section= \(indexPath.section), Cell clicked at row: \(indexPath.row), navigationItemTitle= \(model.cellTitleArr[indexPath.section][indexPath.row])")
        tableView.deselectRow(at: indexPath, animated: true) // 取消选中
    }

    //集合视图点击事件
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("collectionView didSelectRowAt ",indexPath)
        collectionView.deselectItem(at: indexPath, animated: true)// 取消选中
    }
}

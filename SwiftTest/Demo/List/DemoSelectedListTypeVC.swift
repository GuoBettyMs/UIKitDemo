//
//  DemoSelectedListTypeVC.swift
//  SwiftTest
//
//  Created by user on 2025/4/10.
//


import UIKit

class DemoSelectedListTypeVC: BaseVC {

    override func viewDidLoad() {
        super.viewDidLoad()

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
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tableView didSelectRowAt ",indexPath)
        tableView.deselectRow(at: indexPath, animated: true) // 取消选中
    }

    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("collectionView didSelectRowAt ",indexPath)
        collectionView.deselectItem(at: indexPath, animated: true)// 取消选中
    }
}

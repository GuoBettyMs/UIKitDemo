//
//  Enums.swift
//  SwiftTest
//
//  Created by user on 2026/1/27.
//

enum SettingType {
    case noBattery
    case battery
}

enum RowOperation { //index 保存的是初始 ProgramFileModel.index
    case rowAdd(index: Int) //列表新增行、列表行标题修改
    case rowDelete(index: Int) //列表删除行
    case celldataEdit(index: Int) //包含次列表的数据修改
    
    var isRowAdd: Bool {
        if case .rowAdd = self { return true }
        return false
    }
}

enum CustomPickviewPageIndex{
    case workpage
    case programHomepage_presetvalue
    case programEditpage_presetvalue
    case usbHomepage_presetvalue
    case usbEditpage_presetvalue
    case settingHomepage
    case settingEditpage
    case programmablepage
    case pDOpage
    case chargepage
    
    var index: Int {
        switch self {
        case .workpage: return 0
        case .programmablepage: return 1
        case .pDOpage: return 2
        case .chargepage: return 3
        case .programHomepage_presetvalue: return 4
        case .settingHomepage: return 5
        case .usbHomepage_presetvalue: return 6
            
        case .programEditpage_presetvalue: return 7
        case .usbEditpage_presetvalue: return 8
        case .settingEditpage: return 9
        
        }
    }
}

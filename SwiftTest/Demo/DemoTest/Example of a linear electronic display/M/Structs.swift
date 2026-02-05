//
//  Structs.swift
//  SwiftTest
//
//  Created by user on 2026/1/27.
//

import Foundation

//MARK: Preset page 上传状态结构体
struct UploadContext {
    
    var pendingOperations: [RowOperation] = [] //执行操作数组
    var commandIndex: Int = 0 // 当前执行第几个命令（从 0 开始）
    
    // 次列表分页状态
    let sublistTakeoverMaxCount = 10 //每分页发送 10 行数据
    var sublistTotalCount: Int = 0 // 次列表总行数
    var sublistCurrentPage: Int = 0 // 当前发送数据的分页索引（从 0 开始）
    //次列表每次最多发送 sublistTakeoverMaxCount 行,次列表有多少分页,相当于统计次列表需要发送多少次才能把全部数据发送完毕
    var sublistPages: Int { //分页总数
        max(1, Int(ceil(Double(sublistTotalCount) / Double(sublistTakeoverMaxCount))))
    }
    
    var isSublistUploading: Bool { sublistTotalCount > 0 }
    var isLastSublistPage: Bool { sublistCurrentPage == sublistPages - 1 } //是否是最后发送的次列表分页
    var isLastCommand: Bool { commandIndex == pendingOperations.count - 1 }//是否是最后执行的命令
    
    //存储已执行过的命令数量
    mutating func advanceToNextCommand() {
        commandIndex += 1
        resetSublistState()
    }
    
    //存储发送结束的次列表分页索引
    mutating func advanceSublistPage() {
        sublistCurrentPage += 1
    }
    
    private mutating func resetSublistState() {
        sublistTotalCount = 0
        sublistCurrentPage = 0
    }
}

//MARK: Programmable page 数据结构体
struct ProgramDataModel{
    var index: Int = 0 //sublist row index, 从 0 开始
    var voltageMin: Double = 0 //默认仅显示最小值
    var voltageMax: Double = 0
    var current: Double = 0
    var max_current20V_10ma: Double = 0
    var time: Int = 0
    var isSelected = false
    var reserved = 0
    var reserved1 = 0
}

//MARK: Preset page 数据结构体
struct ProgramFileModel{
    var index: Int //list row index, 从 0 开始
    var title: String
    var pDOPower: Int
    var dataModel: [ProgramDataModel]
    
    init(index: Int, title: String, pDOPower: Int, dataModel: [ProgramDataModel]) {
        self.index = index
        self.title = title
        self.pDOPower = pDOPower
        self.dataModel = dataModel
    }
}

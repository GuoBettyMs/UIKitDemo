//
//  LeftM.swift
//  SwiftTest
//
//  Created by user on 2024/11/8.
//

import Foundation

class LeftM{
    
    let demoTitle = ["","Vbus(V)","Ibus(A)","Power(W)"]
    var itemList: [[DeviceDBModel]] = [[], [], [], []] //原始数据
    
    init(){
        initData()
    }
    
    /// - Returns:
    /// 初始化数据
    func initData(){
        for i in 0...7{
            switch i {
            case 0...1:
                let item = DeviceDBModel("*0\(i)", true, false)
                itemList[0].insert(item, at: 0)
                itemList[3].insert(item, at: 0)
            case 2...4:
                let item = DeviceDBModel("*1\(i)", true, false)
                itemList[1].insert(item, at: 0)
                itemList[3].insert(item, at: 0)
            default:
                let item = DeviceDBModel("*2\(i)", true, false)
                itemList[2].insert(item, at: 0)
                itemList[3].insert(item, at: 0)
            }
        }
    }
    
    /// - Returns:
    /// 清除数据
    func clearLists(){
        for i in 0...3{
            itemList[i].removeAll()
        }
    }
    
    /// - Returns:
    /// 设备分类
    func classfyDevice(deviceName: String) -> Int{
        var sectionIndex: Int = 0
        
        if deviceName.prefix(2) == "*0" {
            sectionIndex = 0
        } else if deviceName.prefix(2) == "*1" {
            sectionIndex = 1
        } else {
            sectionIndex = 2
        }
        return sectionIndex
    }
    
    typealias CustomCompletion = ((Int, Int, Int) -> Void) //为一个函数类型定义了一个类型别名
   
    
    func addRandomItem(completion: CustomCompletion) {

        let randomIndex = Int.random(in: 0...itemList[3].count)
        var item = DeviceDBModel("*\(Int.random(in: 0...2))", true, false)
        item.username = "newitem-\(randomIndex)"

        let sectionI = self.classfyDevice(deviceName: item.identifier)
        let sectionIndex = Int.random(in: 0...itemList[sectionI].count)
        itemList[3].insert(item, at: randomIndex)
        itemList[sectionI].insert(item, at: sectionIndex)
        print("addRandomItem 添加 itemlist[3]Index: \(randomIndex), itemlist[\(sectionI)]Index:\(sectionIndex)")

        completion(randomIndex, sectionIndex, sectionI)
    }

    /// - Returns:
    /// 随机删除一个 item
   func deleteRandomItem(completion: CustomCompletion) {
       guard !itemList[3].isEmpty else { return }
       let randomIndex = Int.random(in: 0..<itemList[3].count)
       let iden = itemList[3][randomIndex].identifier
       let sectionI = self.classfyDevice(deviceName: iden)
       
       if let sectionIndex = self.itemList[sectionI].firstIndex(where: { $0.identifier == iden }) {
           itemList[3].remove(at: randomIndex)
           itemList[sectionI].remove(at: sectionIndex)
           print("deleteRandomItem 删除 itemlist[3]Index: \(randomIndex), itemlist[\(sectionI)]Index:\(sectionIndex)")
           
           completion(randomIndex, sectionIndex, sectionI)
       }
   }
    
    /// - Returns:
    /// 删除所选 item
    func deleteSeletedItem(_ identifier: String, _ cellI: IndexPath, blk: CustomCompletion){
        let sectionI = self.classfyDevice(deviceName: identifier)
        
        if let index = self.itemList[3].firstIndex(where: { $0.identifier == identifier }), let sectionIndex = self.itemList[sectionI].firstIndex(where: { $0.identifier == identifier }) {
            print("deleteSeletedItem 删除 \(identifier), cellIndexPath: \(cellI), itemlist[3]Index: \(index), itemlist[\(sectionI)]Index:\(sectionIndex)")
            
            self.itemList[3].remove(at: index)
            self.itemList[sectionI].remove(at: sectionIndex)
            
            blk(index, sectionIndex, sectionI)
        }
    }
    
    /// - Returns:
    /// 置顶所选 item
    func moveToUpSelectedItem(_ identifier: String, _ cellI: IndexPath, blk: CustomCompletion){
        let sectionI = self.classfyDevice(deviceName: identifier)
        
        if let index = self.itemList[3].firstIndex(where: { $0.identifier == identifier }), let sectionIndex = self.itemList[sectionI].firstIndex(where: { $0.identifier == identifier }) {
            
            print("moveToUpSelectedItem 置顶 \(identifier), cellIndexPath: \(cellI), itemlist[3]Index: \(index), itemlist[\(sectionI)]Index:\(sectionIndex)")
            
            let newItem = self.itemList[3][index]
            self.itemList[3].remove(at: index)
            self.itemList[3].insert(newItem, at: 0)
            self.itemList[sectionI].remove(at: sectionIndex)
            self.itemList[sectionI].insert(newItem, at: 0)
            
            blk(index, sectionIndex, sectionI)
        }
    }
    
    
    /// - Returns:
    /// 刷新所选 item
    func reloadSelectedItem(_ identifier: String, _ newitem: DeviceDBModel, blk: CustomCompletion){
        let sectionI = self.classfyDevice(deviceName: identifier)
        
        if let index = self.itemList[3].firstIndex(where: { $0.identifier == identifier }), let sectionIndex = self.itemList[sectionI].firstIndex(where: { $0.identifier == identifier }) {
            
            print("reloadSelectedItem 刷新 \(identifier), newitem: \(newitem.username), itemlist[3]Index: \(index), itemlist[\(sectionI)]Index:\(sectionIndex)")

            self.itemList[3][index] = newitem
            self.itemList[sectionI][sectionIndex] = newitem
            
            blk(index, sectionIndex, sectionI)
        }
    }
}

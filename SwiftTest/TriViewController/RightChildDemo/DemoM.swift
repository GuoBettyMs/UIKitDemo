//
//  DemoM.swift
//  SwiftTest
//
//  Created by user on 12/6/24.
//

struct Demo {
    
    var temperature = 0xde
    var tempSign = 0
    var per = 228
    var typeState = 2
    var voltages = 9
    var cycleCount = 1
    
//    var temperature = 0
//    var tempSign = 0
//    var per = 0
//    var typeState = 0
//    var voltages = 0
//    var cycleCount = -1
}

class DemoM: RightBaseM{
    
    var workData = Demo()
    
    override init() {
        super.init()
        
        workData.temperature = 0
        workData.tempSign = 0
        workData.per = 0
        workData.typeState = 0
        workData.voltages = 0
        workData.cycleCount = -1
    }
}

protocol CSVRepresentable {
    func toCSVString(withHeaders headers: [String]) -> String
}

extension CSVRepresentable {
    
    /// - Returns:
    /// 返回字符串, 遵守 CSVRepresentable 的结构体都可以共用该方法
    func toCSVString(withHeaders headers: [String]) -> String {
        //数组每个字符串插入"\t" (Tab键,制表键的简写）,达到换列的作用; \n 换行, joined(separator:) 数组转为字符串
        let csvString = headers.joined(separator: "\t") + "\n"
        // ... 实现根据自身属性生成 CSV 行的逻辑
        return csvString
    }
}
struct PortData: CSVRepresentable {

    var times: [String] = []
    var voltages: [Double] = []
    var currents: [Double] = []
    var powers: [Double] = []

    func toCSVString(withHeaders headers: [String]) -> String {
        var csvString = headers.joined(separator: "\t") + "\n"
                
        for i in 0..<times.count {
            let row = [times[i],
                       voltages[i].formatted(decimalPlaces: 1),
                       currents[i].formatted(decimalPlaces: 1),
                       powers[i].formatted(decimalPlaces: 1)]
            csvString += row.joined(separator: "\t") + "\n"
        }
        
        return csvString
    }
}

struct Student: CSVRepresentable {

    var name: [String] = []
    var num: [Double] = []

    func toCSVString(withHeaders headers: [String]) -> String {
        var csvString = headers.joined(separator: "\t") + "\n"
        
        for i in 0..<name.count {
            let row = [name[i], "\(num[i])", ""] // Empty string for "other"
            csvString += row.joined(separator: "\t") + "\n"
        }
        
        return csvString
    }
}

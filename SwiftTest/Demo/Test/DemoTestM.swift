//
//  DemoTestM.swift
//  SwiftTest
//
//  Created by user on 2025/4/16.
//

import Foundation

enum TableType {
    case powerData    // 第一个表格（电力数据）
    case studentData  // 第二个表格（学生数据）
    case frameData    // 第三个表格（框架数据）
}

struct TablePosition {
    var headerRange: Range<String.Index>
    var contentEndIndex: String.Index
}

//struct PowerData {
//    var times: [String]
//    var voltages: [Double]
//    var currents: [Double]
//    var powers: [Double]
//}
//
//struct StudentData {
//    var name: [String]
//    var num: [Double]
//}

class DemoTestM{
    
    // 表格
    var fileName: String = "data_export" // CSV 文件名
    var csvContent: String = "" // CSV 原始内容
    var tablePositions: [TableType: TablePosition] = [:] // 表格位置缓存
    var powerData = PortData(times: [], voltages: [], currents: [], powers: [])
    var studentData = Student(name: [], num: [])
    var frameData = Student(name: [], num: [])
    let tables: [(TableType, String)] = [
        (.powerData, "Time(s)\tVbus(V)\tIbus(A)\tPower(W)"),
        (.studentData, "Name\tNum\tOther"),
        (.frameData, "Name\tValue\tOther")
    ]
    
    //时区
    var timeZoneData:[String] = []
    
    //frame and bounds
    var sliderConfigs: [CustomSliderConfig] = []
    var sliderInit: [Int] = [100, 0, 100, 0, 50, 50]
    var sliderTitles: [String] = ["Frame Width", "Frame Y", "Bounds Width", "Bounds Y", "Position Y", "AnchorPoint Y"]
    private var sliderMin: [Int] = [50, -50, 50, -50, 0, 0]
    private var sliderMax: [Int] = [150, 50, 150, 50, 100, 100]
    
    init(){
        
        //表格数据初始化
        csvContent = "-- \(fileName) --\n"
        for i in 0..<tables.count{
            csvContent += tables[i].1+"\n"
            if i < tables.count-1{
                csvContent += "\n\n" // Add separation between tables
            }
        }
        updateTablePositions()
        
        //时区辨识符初始化
        timeZoneData = TimeZone.knownTimeZoneIdentifiers

        //滑块初始值
        for i in 0..<sliderTitles.count{
            sliderConfigs.append(CustomSliderConfig(title: sliderTitles[i], min: Float(sliderMin[i]), max: Float(sliderMax[i]), initialValue: Float(sliderInit[i]), handler: {_,_ in }
            ))
        }
        
    }
    
    // MARK: - 具体表格添加方法
    func addPowerDataRow(to table: TableType, time: String, voltage: Double, current: Double, power: Double) {
        let newRow = "\(time)\t\(voltage.formatted(decimalPlaces: 1))\t\(current.formatted(decimalPlaces: 1))\t\(power.formatted(decimalPlaces: 1))\n"
        addRow(to: table, content: newRow)
        
        // 更新数据模型
        powerData.times.append(time)
        powerData.voltages.append(voltage)
        powerData.currents.append(current)
        powerData.powers.append(power)
    }

    func addStudentRow(to table: TableType, name: String, num: Double) {
        let newRow = "\(name)\t\(num.formatted(decimalPlaces: 1))\n"
        addRow(to: table, content: newRow)
        
        // 更新数据模型
        switch table {
        case .studentData:
            studentData.name.append(name)
            studentData.num.append(num)
        case .frameData:
            frameData.name.append(name)
            frameData.num.append(num)
        default:
            break
        }
    }
    
    // MARK: 更新表格位置
    func updateTablePositions() {
        var currentIndex = csvContent.startIndex
        for (type, header) in tables {
            if let headerRange = csvContent.range(of: header, range: currentIndex..<csvContent.endIndex) {
                let contentEnd: String.Index
                if let nextHeaderRange = csvContent.range(of: "\n\n\\w", options: .regularExpression,
                                                        range: headerRange.upperBound..<csvContent.endIndex) {
                    contentEnd = nextHeaderRange.lowerBound
                } else {
                    contentEnd = csvContent.endIndex
                }
                tablePositions[type] = TablePosition(headerRange: headerRange, contentEndIndex: contentEnd)
                currentIndex = contentEnd
            }
        }
    }
    
    // MARK: 表格新增单行数据
    private func addRow(to table: TableType, content: String) {
        guard let position = tablePositions[table] else { return }
        
        // 插入新行
        csvContent.insert(contentsOf: content, at: position.contentEndIndex)
        
        // 计算新行长度（使用utf16.count保证多语言字符正确计算）
        let newRowLength = content.utf16.count
        
        // 更新当前表格的结束位置
        tablePositions[table]?.contentEndIndex =
            csvContent.utf16.index(position.contentEndIndex, offsetBy: newRowLength)
        
        // 更新后续表格的位置
        updateFollowingTablePositions(after: position.contentEndIndex, offset: newRowLength)
        
        // 可选：完全更新所有表格位置（更安全但性能略低）
        updateTablePositions()
    }
    
    // MARK: 表格新增多行数据
    func addRows(to table: TableType, contents: [String]) {
        guard !contents.isEmpty else { return }
        let combinedContent = contents.joined()
        addRow(to: table, content: combinedContent)
    }
    
    // MARK: 更新后续表格位置
    private func updateFollowingTablePositions(after insertionPoint: String.Index, offset: Int) {
        for (type, pos) in tablePositions {
            guard pos.headerRange.lowerBound > insertionPoint else { continue }
            
            // 计算新位置
            let newHeaderLower = csvContent.utf16.index(pos.headerRange.lowerBound, offsetBy: offset)
            guard newHeaderLower < csvContent.endIndex else { continue }
            
            let newHeaderUpper = csvContent.utf16.index(pos.headerRange.upperBound, offsetBy: offset)
            let newContentEnd = csvContent.utf16.index(pos.contentEndIndex, offsetBy: offset)
            
            tablePositions[type] = TablePosition(
                headerRange: newHeaderLower..<newHeaderUpper,
                contentEndIndex: newContentEnd
            )
        }
    }
}

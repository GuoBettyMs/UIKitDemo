//
//  BleManagerM.swift
//  SwiftTest
//
//  Created by user on 2024/12/18.
//

import Foundation
import CoreBluetooth

//MARK: - 常量与变量
let UUID_BLE_SERVE_AF00 = "0xAF00"
let UUID_BLE_SERVE_FEE0 = "0xFEE0"
let UUID_BLE_WRITE_FEE1 = "FEE1"  //FEE0特征
let UUID_BLE_WRITE_AF01 = "AF01"  //AF01特征
let UUID_BLE_WRITE_AF02 = "AF02"  //AF02特征
let UUID_BLE_WRITE_DB01 = "DB01"  //DB01特征
var specificServicesCBUUIDs: [CBUUID] {
    [CBUUID(string: UUID_BLE_SERVE_AF00),
     CBUUID(string:UUID_BLE_SERVE_FEE0)]
}

//MARK: - 结构体
// 定义数据包结构
struct BroadcastPacket {
    var bytes: [UInt8]
    var rssi: NSNumber?
    
    init(bytes: [UInt8]) {
        self.bytes = bytes
    }
}

// 定义扫描包结构
struct ScanPacket {
    var dataString: String
    
    init(dataString: String) {
        self.dataString = dataString
    }
}

//MARK: - 协议
// 定义外设协议
protocol PeripheralType {
    var name: String? { get }
    var identifier: UUID { get }
    // 添加其他需要的属性和方法
}

// 扫描代理协议
protocol ScanDelegate {
    func scanMockData(_ peripheral: PeripheralType,
                 _ broadcastPacket: BroadcastPacket,
                 _ scanPacket: ScanPacket)
    func scanData(_ peripheral: CBPeripheral,
                 _ broadcastPacket: BroadcastPacket,
                 _ scanPacket: ScanPacket)
}

//MARK: - 类
// 模拟的外设类
class MockPeripheral: PeripheralType {
    var name: String?
    var identifier: UUID = UUID()
    
    init(name: String? = nil) {
        self.name = name
    }
}

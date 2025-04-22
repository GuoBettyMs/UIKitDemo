//
//  MockBleManager.swift
//  SwiftTest
//
//  Created by user on 2024/12/18.
//

import CoreBluetooth


class MockBleManager: BleManager {

    private var mockPeripheral: PeripheralType?  // 模拟的外设

    // MARK: - Initialization
    override init() {
        super.init() //父级已设置蓝牙管理器代理
        
        simulateBluetoothState() //虚拟机无法蓝牙扫描,进行模拟
    }
    
    //MARK: - private mothods
    // 模拟蓝牙状态更新
    private func simulateBluetoothState() {
        print("MockBleManager - 模拟蓝牙已开启状态")
        self.handleBluetoothState(.poweredOn) // 模拟蓝牙已开启状态,省略扫描设备步骤
        
        // 无法执行回调,自行定义数据,模拟发现设备
        let mockPeripheral = self.createMockPeripheral()
        // 创建模拟的外设数据
        let mockAdvertisementData: [String: Any] = [
            "kCBAdvDataManufacturerData": Data(repeating: 0, count: 22),
            "kCBAdvDataLocalName": "MockDevice"
        ]
        let mockRSSI = NSNumber(value: -60) // 模拟 RSSI
        
        simulateDiscoverDevice(centralManager ?? CBCentralManager.init(), didDiscover: mockPeripheral , advertisementData: mockAdvertisementData, rssi: mockRSSI)
    }

    // 模拟发现设备
    private func simulateDiscoverDevice(_ central: CBCentralManager, didDiscover peripheral: PeripheralType, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        print("MockBleManager - 模拟发现设备: \(peripheral.name ?? "Unknown")")
        
        // 处理扫描数据
        if let manufacturerData = advertisementData["kCBAdvDataManufacturerData"] as? Data,
           let scanData = advertisementData["kCBAdvDataLocalName"] as? String {
            
            let manufacturerDatabyte = Array(manufacturerData)
            var broadcastPacket = BroadcastPacket(bytes: manufacturerDatabyte)
            broadcastPacket.rssi = RSSI
            let scanPacket = ScanPacket(dataString: scanData)
            
            //省略停止扫描步骤步骤
            
            mockPeripheral = peripheral //保存外设
            
            // 通知代理
            scanDelegate?.scanMockData(peripheral, broadcastPacket, scanPacket)
            

            // 无法执行回调,模拟连接设备
            simulateConnect(central, didConnect: peripheral)

        }
    }

    // 模拟连接设备
    private func simulateConnect(_ central: CBCentralManager, didConnect peripheral: PeripheralType) {
        print("MockBleManager - 模拟已连接到设备: \(peripheral.name ?? "Unknown")")
        
        //省略设置 mockPeripheral 代理步骤
        
        // 无法执行回调,模拟发现服务
        simulateDiscoverServices(peripheral)

    }
    
    //模拟发现服务
    private func simulateDiscoverServices(_ peripheral: PeripheralType) {
        
        print("MockBleManager - 模拟发现服务")
        // 无法执行回调,模拟发现特征
        simulateDiscoverCharacteristics(peripheral)
    }
    
    // 模拟发现特征
    private func simulateDiscoverCharacteristics(_ peripheral: PeripheralType)  {
        print("MockBleManager - 模拟发现特征")
        
    }
    // MARK: - Public Methods

    //MARK: - helper mothods

    // 创建模拟的外设
    private func createMockPeripheral() -> PeripheralType {
        // 注意：这里需要根据你的实际需求创建模拟外设
        // 这只是一个示例实现
        let mockPeripheral = MockPeripheral()
        mockPeripheral.name = "MockDevice"
        return mockPeripheral
    }

}

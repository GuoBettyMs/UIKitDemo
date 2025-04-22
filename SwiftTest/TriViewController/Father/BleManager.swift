//
//  BleManager.swift
//  SwiftTest
//
//  Created by user on 2024/11/21.
//
/*
前提: 项目 -> Build Settings -> Privacy - NSBluetoothAlwaysUsageDescription -> "App需要使用蓝牙来连接设备"
    Privacy - NSBluetoothPeripheralUsageDescription -> "App需要使用蓝牙来连接设备"
 
    1.中心设备初始化,赋值 delagate
    2.(自动回调蓝牙状态),当蓝牙开启时,扫描外设
        2.1 centralManagerDidUpdateState(:)
        2.2 scanForPeripherals(withServices: nil, options: nil)
    3.(自动回调发现外设),得到外设信息 advertisementData, 根据 key ["kCBAdvDataManufacturerData"]、["kCBAdvDataLocalName"]筛选到所需外设后,保存外设并连接
        3.1 centralManager:didDiscoverPeripheral:advertisementData:RSSI:
        3.2 centralManager.stopScan()
        3.3 self.peripheral = peripheral
        3.4 CBCentralManager.connect(peripheral, options: nil)
    4.(自动回调连接外设),设置 peripheral 代理,执行发现服务
        4.1 centralManager:didConnectPeripheral:
        4.2 peripheral.delegate = self
        4.3 peripheral.discoverServices(nil)
    5.(自动回调发现服务),执行发现特征
        5.1 peripheral:didDiscoverServices:
        5.2 CBPeripheral.discoverCharacteristics(nil, for: service)
    6.(自动回调发现特征),根据需要执行对特征的相关操作
        6.1 peripheral:didDiscoverCharacteristicsForService:error:
        6.2 CBPeripheral.readValue(for: characteristic)
        6.3 CBPeripheral.writeValue(data, for: characteristic, type: .withResponse)
        6.4 CBPeripheral.setNotifyValue(true, for: characteristic)
        相关回调
        更新: peripheral:didUpdateValueForCharacteristic:error:
        订阅: peripheral:didUpdateNotificationStateForCharacteristic:error:
        读取: peripheral:didWriteValueForCharacteristic:error:


*/
import CoreBluetooth

//CBCentralManagerDelegate 继承 NSObjectProtocol 协议,要遵循 NSObjectProtocol 协议，类必须继承自 NSObject
class BleManager: NSObject {

    // MARK: - Public Properties
    var scanDelegate: ScanDelegate? // 扫描代理协议
    var centralManager: CBCentralManager? // 蓝牙管理器
    var peripheral: CBPeripheral? // 保存发现的外设
    
    // MARK: - Private Properties
    private var connectTimer: Timer? //连接外设定时器
    private var reconnectCount = 0 //重新连接次数
    private let maxReconnectAttempts = 3 //最大重连次数
    private var isConnecting = false //监听设备是否正在连接
    private var isDisconnecting = false //监听设备是否断连

    // MARK: - Initialization
    // 初始类和蓝牙
    override init() {
        super.init()
        centralManager = CBCentralManager.init(delegate: self, queue: nil)

    }

    
    // MARK: - Private Methods
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        // 处理扫描数据
        if let manufacturerData = advertisementData["kCBAdvDataManufacturerData"] as? Data,
           let scanData = advertisementData["kCBAdvDataLocalName"] as? String {
            
            let manufacturerDatabyte = Array(manufacturerData)
            var broadcastPacket = BroadcastPacket(bytes: manufacturerDatabyte)
            broadcastPacket.rssi = RSSI
            let scanPacket = ScanPacket(dataString: scanData)

            if peripheral.name?.prefix(4) == "0000" && Int(truncating: RSSI) > -60 {
                Log.debug("""
                BleManager - CBCentralManager didDiscover called
                发现设备:
                - 设备(广播包中的名称): \(peripheral.name ?? "Unknown")
                - RSSI: \(RSSI)
                - scanPacket: \(scanPacket.dataString)
                """)

                // 停止扫描, 停止 didDiscover 回调
                stopScan()

                // 保存并连接设备
                self.peripheral = peripheral //未保存外设,无法执行回调 centralManager(_ :didConnect:)
//                scanDelegate?.scanData(peripheral, broadcastPacket, scanPacket) //通知代理
                isConnecting = true
                central.connect(peripheral, options: [
                    CBConnectPeripheralOptionNotifyOnDisconnectionKey: true // 断开连接时通知
                ])
                
            }
            
        }
    }
 
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        Log.debug("""
        BleManager - CBCentralManager didConnect called
        设备已连接:
        - 设备(广播包中的名称): \(peripheral.name ?? "Unknown")
        - 状态: \(peripheral.state.rawValue)
        """)
        
        isConnecting = false
        peripheral.delegate = self //设置 peripheral delagate
        
        // 添加延迟发现服务
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let _ = self,
                  peripheral.state == .connected else {
                Log.debug("设备已断开，取消发现服务")
                return
            }
            
            Log.debug("开始发现服务...")
            peripheral.discoverServices(nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
        Log.debug("""
        BleManager - CBCentralManager didFailToConnect called
        连接设备失败:
        - 名称: \(peripheral.name ?? "Unknown")
        - 错误: \(error?.localizedDescription ?? "无")
        - 状态: \(peripheral.state.rawValue)
        - 是否正在连接: \(isConnecting)
        """)
        // 如果不是主动断开，尝试重新连接
        if !isDisconnecting {
            reconnectToPeripheral(peripheral)
        }

    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        Log.debug("""
        BleManager - CBCentralManager didDisconnectPeripheral called
        设备断开连接:
        - 设备(通过 GATT 服务获取的实际设备名称): \(peripheral.name ?? "Unknown")
        - 错误: \(error?.localizedDescription ?? "无")
        - 状态: \(peripheral.state.rawValue)
        - 是否正在连接: \(isConnecting)
        """)
        // 如果不是主动断开，尝试重新连接
        if !isDisconnecting {
            reconnectToPeripheral(peripheral)
        }

    }

    // MARK: - Public Methods
    
    func handleBluetoothState(_ state: CBManagerState) {
        switch state {
        case .poweredOn:
            Log.debug("蓝牙已开启")
            #if !targetEnvironment(simulator)
                scanForPeripherals()
            #endif
            
        case .poweredOff:
            Log.debug("蓝牙已关闭")
            #if !targetEnvironment(simulator)
               disconnectAndCleanup()// 断开连接并清理状态
            #endif
            
        default:
            Log.debug("其他蓝牙状态：\(state)")
        }
    }
    
    func scanForPeripherals(){
        guard centralManager?.state == .poweredOn else {
            Log.debug("蓝牙未开启")
            return
        }
                
        peripheral = nil // 清理之前的数据
         
        /// - Parameter withServices: nil: 扫描所有可见的蓝牙设备
        /// - Parameter options  nil: 系统会自动过滤重复的广播包
//            centralManager?.scanForPeripherals(withServices: nil, options: nil)

        /// - Parameter withServices: specificServicesCBUUIDs,  只扫描特定服务 (specificServicesCBUUIDs) 的设备
        /// - Parameter AllowDuplicatesKey  true: 接收所有广播包，包括重复的, 常用于监控信号强度
        centralManager?.scanForPeripherals(withServices: specificServicesCBUUIDs , options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        Log.debug("开始扫描设备")
        
    }
    
    func stopScan(){
        centralManager?.stopScan()
        Log.debug("停止扫描设备")
    }

    // MARK: - Helper Methods

    /// 尝试连接设备
    private func reconnectToPeripheral(_ peripheral: CBPeripheral)  {
        guard reconnectCount < maxReconnectAttempts else {
            handleConnectionFailure()
            return
        }
        reconnectCount += 1
        Log.debug("尝试连接设备：\(peripheral.name ?? "Unknown")，第 \(reconnectCount) 次")

        self.isConnecting = true
        centralManager?.connect(peripheral, options: nil)

    }

    private func disconnectAndCleanup() {
        if let peripheral = peripheral {
            isDisconnecting = true
            centralManager?.cancelPeripheralConnection(peripheral) //断开连接
        }
        peripheral = nil
        connectTimer?.invalidate()
        connectTimer = nil
        reconnectCount = 0
        Log.debug("断连并清除 connectTimer")
    }
    
    private func handleConnectionFailure() {
        Log.debug("连接失败，已超过最大重试次数")
        disconnectAndCleanup()
    }
    
}
extension BleManager: CBPeripheralDelegate {
    // func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
    //     Log.debug("RSSI: \(RSSI)")
    // }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {

        if let error = error {
            Log.debug("发现服务失败：\(error.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else {
            Log.debug("没有发现服务")
            return
        }

        Log.debug("""
        BleManager - peripheral didDiscoverServices called
        发现服务:
        - 设备(通过 GATT 服务获取的实际设备名称): \(peripheral.name ?? "Unknown")
        - peripheral.identifier: \(peripheral.identifier.uuidString)
        - 服务数量: \(services.count)
        - 设备状态: \(peripheral.state.rawValue)
        """)

        for service in services {
            Log.debug("发现服务 UUID：\(service.uuid)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            Log.debug("特征发现失败: \(error.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else {
            Log.debug("服务无特征: \(service.uuid)")
            return
        }
        
        Log.debug("""
        BleManager - peripheral didDiscoverCharacteristicsFor called
        发现特征:
        - 设备(通过 GATT 服务获取的实际设备名称): \(peripheral.name ?? "Unknown")
        - 服务 uuid: \(service.uuid)
        - 特征数量: \(characteristics.count)
        - 设备状态: \(peripheral.state.rawValue)
        """)

        for characteristic in characteristics {
            Log.debug("""
            特征信息:
            - UUID 对象: \(characteristic.uuid)
            - UUID 字符串: \(characteristic.uuid.uuidString)
            """)

            if characteristic.properties.contains(.read) { // 如果特征支持读取，执行一次性读取, 结果看回调 peripheral:didUpdateValueForCharacteristic:error:
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) { // 如果特征支持通知，开启持续监听
                peripheral.setNotifyValue(true, for: characteristic)
            }
            
            if characteristic.properties.contains(.write) { // 如果特征支持写入
                let sendData: [UInt8]? = [31, 49]
                let hexString = sendData?.map { String(format: "%02x", $0) }.joined(separator: " ") ?? ""
                Log.debug("写入的16进制格式字符串: " + hexString)
                peripheral.writeValue(Data.init(sendData ?? []), for: characteristic, type: .withResponse)
            }
        }
    }

    /*
    触发条件:
    1. 当执行 readValue 操作时, 设备数据变化时, 会触发回调
    2. characteristic.properties.contains(.notify),通知更新时触发
    3. characteristic.properties.contains(.indicate),指示更新时触发,有确认机制
    */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        if let error = error {
            Log.debug("readValue(for:) 回调失败: \(error.localizedDescription)")
            return
        }

        Log.debug("""
        BleManager - peripheral didUpdateValueFor called
        特征值更新:
        - 触发方式: \(characteristic.isNotifying ? "通知更新" : "主动读取")
        """)

        let dataValue = [UInt8](characteristic.value ?? Data())
        let hexString = dataValue.map { String(format: "%02x", $0) }.joined(separator: " ") //将10进制的原数据转为16进制格式的字符串
        // let manufacturerString = String(bytes: dataValue, encoding: .utf8) //将10进制的原数据转为字符串

        // Log.debug("manufacturerString: \(manufacturerString ?? "Unknown")")
        Log.debug("hexString: \(hexString)")
    }

    // setNotifyValue( for: ) 回调
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: (any Error)?) {
        if let error = error {
            Log.debug("setNotifyValue( for: ) 回调失败: \(error.localizedDescription)")
            return
        }

        Log.debug("characteristic ID[\(characteristic.uuid.uuidString)] 开启持续监听 ")

    }

    // didWriteValueFor
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        if let error = error {
            Log.debug("didWriteValueFor 回调失败: \(error.localizedDescription)")
            return
        }
        Log.debug("didWriteValueFor 回调成功")
    }

}

extension BleManager: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        Log.debug("BleManager - centralManagerDidUpdateState called")
        handleBluetoothState(central.state)
    }

}
                

//
//  FatherViewController-Ex.swift
//  SwiftTest
//
//  Created by user on 2024/11/12.
//

import UIKit
import CoreBluetooth

extension FatherViewController: ScanDelegate {
    func scanMockData(_ peripheral: PeripheralType, _ broadcastPacket: BroadcastPacket, _ scanPacket: ScanPacket) {
        print("scanMockData peripheral.name：\(peripheral.name ?? "Unknown")")
        print("scanMockData RSSI: \(broadcastPacket.rssi ?? 0)")
        print("scanMockData Scan Data: \(scanPacket.dataString)")
    }
    
    func scanData(_ peripheral: CBPeripheral,
                 _ broadcastPacket: BroadcastPacket,
                 _ scanPacket: ScanPacket) {
        print("scanData peripheral.name：\(peripheral.name ?? "Unknown")")
        print("scanData RSSI: \(broadcastPacket.rssi ?? 0)")
        print("scanData Scan Data: \(scanPacket.dataString)")
    }
    
}

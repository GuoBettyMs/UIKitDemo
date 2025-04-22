//
//  MenuView.swift
//  SwiftTest
//
//  Created by user on 2024/11/4.
//

import UIKit

class MenuView: UIView {
    
    var menuBtns: [UIButton] = []
    
    /// - Returns:
    /// 纯代码加载UIView
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){

        self.backgroundColor = .lightGray
        
        for i in 0...2{
            let btn = UIButton()
            addSubview(btn)
            btn.snp.makeConstraints { make in
                make.width.equalTo(self.bounds.width)
                make.height.equalTo(self.bounds.height/3)
                make.top.equalToSuperview().offset(i*(Int(self.bounds.height)/3))
                make.left.equalToSuperview()
            }
            btn.setTitle("选项\(i+1)", for: .normal)
            menuBtns.append(btn)
        }
        //        print("height: \(self.bounds.height/3)")
    }
}

struct DeviceDBModel : Equatable, Hashable{//实现 Equatable 协议，可以比较两个结构体实例是否相等
    
    var identifier: String
    var username: String = ""
//    var peripheral: CBPeripheral?
//    var broadcastPacket: BroadcastPacket?
//    var scanPacket: ScanPacket?
    var isOnline = false
    var versionBool = false
//    var deviceInfo: DeviceInfo?
//    var deviceDB: DeviceDB?
    
    init(_ identifier: String,_ isOnline: Bool, _ versionBool: Bool) {
        
        self.identifier = identifier
        self.isOnline = isOnline
        self.versionBool = versionBool

    }
    /// - Returns:
    /// 定义了两个实例相等的条件
    static func == (lhs: DeviceDBModel, rhs: DeviceDBModel) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
//    init(_ identifier: String, _ peripheral: CBPeripheral?, _ broadcastPacket: BroadcastPacket?, _ scanPacket: ScanPacket?, _ isOnline: Bool, _ versionBool: Bool, _ deviceInfo: DeviceInfo, _ deviceDB: DeviceDB?) {
//
//        self.identifier = identifier
//        self.peripheral = peripheral
//        self.broadcastPacket = broadcastPacket
//        self.isOnline = isOnline
//        self.scanPacket = scanPacket
//        self.versionBool = versionBool
//        self.deviceInfo = deviceInfo
//        self.deviceDB = deviceDB
//
//    }
    
//    /// - Returns:
//    /// 定义了两个实例相等的条件
//    static func == (lhs: DeviceDBModel, rhs: DeviceDBModel) -> Bool {
//        return lhs.identifier == rhs.identifier &&
//               lhs.deviceDB?.deviceUUID == rhs.deviceDB?.deviceUUID
//    }
}

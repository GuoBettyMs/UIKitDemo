//
//  DetailViewController.swift
//  SwiftTest
//
//  Created by user on 2026/2/5.
//
//详情视图控制器, 支持蓝牙连接

import UIKit
import CoreBluetooth

class DetailViewController: UIViewController {
    
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()
    
    private var bleManager: BleManager? //蓝牙管理者
    
    var mailItem: MailItem? {
        didSet {
            updateUI()
        }
    }
    
    // MARK: - Navigation Items (延迟设置以避免约束警告)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if navigationItem.rightBarButtonItems == nil {
            setupNavigationBar()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    //MARK: -
    
    private func setupNavigationBar() {
//        navigationItem.leftBarButtonItem = editButtonItem
        
//        let composeButton = UIBarButtonItem(
//            barButtonSystemItem: .compose,
//            target: self,
//            action: #selector(composeMail)
//        )
        
        let bleSearchButton = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: self,
            action: #selector(bleSearchEvent)
        )
        
        navigationItem.rightBarButtonItems = [bleSearchButton]
    }
    
    private func setupUI() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            // Fallback on earlier versions
        }
        
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.numberOfLines = 0
        bodyLabel.font = .systemFont(ofSize: 16)
        bodyLabel.numberOfLines = 0
        
        [titleLabel, bodyLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            bodyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bodyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func updateUI() {
        guard let item = mailItem else {
            title = "选择邮件"
            titleLabel.text = "请从左侧选择一封邮件"
            bodyLabel.text = "请从左侧选择一封邮件"
            return
        }
        
        title = item.title
        titleLabel.text = item.title
        bodyLabel.text = """
        发件人: \(item.subtitle)
        日期: \(item.date)
        
        尊敬的用户：
        
        欢迎使用我们的邮件应用！这是一封示例邮件，展示了如何在UISplitViewController中显示详细内容。
        
        UISplitViewController是一个强大的容器视图控制器，用于管理主从界面。在iPad和Mac上，它可以同时显示两个视图控制器，而在iPhone上，它会自动适应为导航界面。
        
        希望这个示例对你有帮助！
        
        祝好，
        开发团队
        """
    }
    
    //MARK: - Actions
    @objc private func bleSearchEvent() { /* 实现蓝牙逻辑 */
        configureBle()
    }
    
    private func configureBle(){
        #if targetEnvironment(simulator)
        // 使用模拟数据
        bleManager = MockBleManager()
        #else
        // 使用真实蓝牙
        bleManager = BleManager()
        #endif

        bleManager?.scanDelegate = self
    }
    
}

extension DetailViewController: ScanDelegate {
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

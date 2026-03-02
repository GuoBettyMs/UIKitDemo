//
//  CustomLaunchViewController.swift
//  SwiftTest
//
//  Created by user on 2025/1/13.
//

import UIKit

class CustomLaunchViewController: UIViewController {

    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .random()
        // 获取 App 版本号
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "未知版本"
        versionLabel.text = "版本号: \(version)"
    }

}

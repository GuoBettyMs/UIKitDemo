//
//  DeviceDetailViewController.swift
//  SwiftTest
//
//  Created by user on 2025/1/15.
//

import UIKit

class DeviceDetailViewController: UIViewController {

    // MARK: - Property
    var deviceModel: DeviceDBModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = deviceModel?.identifier
        self.view.backgroundColor = .systemPink
        print("viewDidLoad: \(deviceModel?.identifier)")
       
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

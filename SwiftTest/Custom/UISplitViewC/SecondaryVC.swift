//
//  SecondaryVC.swift
//  SwiftTest
//
//  Created by user on 2024/9/20.
//

import UIKit

class SecondaryVC: UIViewController ,UISplitViewControllerDelegate{
    
    var titleStr = "Detail"
    let label = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "hah", style: .plain, target: self, action: #selector(hah))
        title = titleStr
        view.backgroundColor = .random()
        splitViewController?.delegate = self
        
        self.view.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        label.textColor = .black
    }
    
    func splitViewController(splitViewController: UISplitViewController, showDetailViewController vc: UIViewController, sender: AnyObject?) -> Bool {
           title = "\(sender!)"
           return true
       }
    
    func showLabel(_ str: String) {
        self.label.text = str
    }
    
    @objc func hah() {
    }
}

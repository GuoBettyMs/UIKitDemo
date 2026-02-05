//
//  CustomTableViewCell.swift
//  AAInfographicsDemo
//
//  Created by AnAn on 2022/9/30.
//  Copyright © 2022 An An. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    var longPresssAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        numberLabel.layer.cornerRadius = 10
        numberLabel.layer.masksToBounds = true
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(cellLongPressed(_:)))
        self.addGestureRecognizer(longPressGesture)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    deinit {
        // 在对象销毁时清除回调
        longPresssAction = nil
    }
    
    //MARK: -
    @objc func cellLongPressed(_ sender: UILongPressGestureRecognizer) {
//        print("cellLongPressed")
        longPresssAction?()
    }
    
}

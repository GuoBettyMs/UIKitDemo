//
//  DeviceStatusBehaveCell.swift
//  SwiftTest
//
//  Created by user on 2025/1/13.
//

import UIKit

class DeviceStatusBehaveCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    // MARK: - Property
    var tapAction: (() -> Void)?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
 
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func cellTapped(_ sender: UITapGestureRecognizer) {
        print("cellTapped")
       tapAction?()
        
        
        
    }
}

//
//  CustomCollectionViewCell.swift
//  SwiftTest
//
//  Created by user on 2025/4/8.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var label: UILabel!
    
    
    // MARK: - Property
//    var tapAction: (() -> Void)?
    var longPresssAction: (() -> Void)?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
 
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(cellLongPressed(_:)))
        self.addGestureRecognizer(longPressGesture)
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped(_:)))
//        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func cellLongPressed(_ sender: UILongPressGestureRecognizer) {
//        print("cellLongPressed")
        longPresssAction?()
    }
    
//    @objc func cellTapped(_ sender: UITapGestureRecognizer) {
////        print("cellTapped")
//        tapAction?()
//    }
}

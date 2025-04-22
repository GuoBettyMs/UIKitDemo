//
//  CustomCollectionHeaderView.swift
//  SwiftTest
//
//  Created by user on 2025/4/8.
//

import UIKit

class CustomCollectionHeaderView: UICollectionReusableView {
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.frame = bounds
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 17)
//        titleLabel.textAlignment = .center
        addSubview(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

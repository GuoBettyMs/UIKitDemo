//
//  CustomPickerRowView.swift
//  SwiftTest
//
//  Created by user on 2026/1/19.
//
// 自定义带图标的 view

import UIKit
import SnapKit

class CustomviewWithIcons: UIView {
    let imageView = UIImageView()
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI1()

    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupUI1()

    }
    private func setupUI1() {

        // 标题标签
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(2)
            make.centerX.equalToSuperview()
        }
        
        // 图像视图
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(titleLabel.snp.left).offset(-8)
            make.width.height.equalTo(20)
        }
        
    }
    
    func configure(imageName: String?, title: String, showImage: Bool) {
        titleLabel.attributedText = bahnschrift_formatted(title, 24)
        
        if showImage, let imageName = imageName {
            imageView.image = UIImage(named: imageName)
            imageView.isHidden = false
        } else {
            imageView.isHidden = true
        }
    }
    
    
}

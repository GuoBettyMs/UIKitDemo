//
//  NumberKeyCell.swift
//  SwiftTest
//
//  Created by user on 2026/1/15.
//
// 自定义数字键盘单元格

import UIKit
import SnapKit

class NumberKeyCell: UICollectionViewCell {
    static let identifier = "NumberKeyCell"
    
    let numberLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
//        label.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        label.textColor = UIColor(named: "DP_4d4d4d")
        return label
    }()
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .black
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override func prepareForReuse() {
            super.prepareForReuse()
            
        // 重置所有样式到默认状态
        resetToDefaultStyle()
    }
    
    private func resetToDefaultStyle() {
        // 重置背景色
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // 重置标签
        numberLabel.text = nil
        numberLabel.textColor = UIColor(named: "DP_4d4d4d")
        numberLabel.isHidden = false
        
        // 重置图标
        iconImageView.image = nil
        iconImageView.isHidden = true
        iconImageView.tintColor = .black
        
        // 重置交互状态
        isUserInteractionEnabled = true
//        alpha = 1.0
//        transform = .identity
        
        // 重置边框
        layer.borderColor = UIColor(named: "DP_d9d9d9ff")?.cgColor
        layer.borderWidth = 2
        
        // 重置圆角
        layer.cornerRadius = 5
    }
    
    private func setupUI() {

        layer.cornerRadius = 5
        layer.borderWidth = 2
        layer.borderColor = UIColor(named: "DP_d9d9d9ff")?.cgColor
        
        contentView.addSubview(numberLabel)
        contentView.addSubview(iconImageView)
        
        numberLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(24)
        }
    }
    
    func configure(with key: NumberKey) {
        
        // 先重置，确保没有残留样式
        resetToDefaultStyle()
        
        switch key.type {
        case .number(let num):
//            numberLabel.text = "\(num)"
            numberLabel.attributedText = bahnschrift_formatted("\(num)")
            numberLabel.isHidden = false
            iconImageView.isHidden = true
            
        case .decimalPoint:
//            numberLabel.text = "."
            numberLabel.attributedText = bahnschrift_formatted(".")
            numberLabel.isHidden = false
            iconImageView.isHidden = true
            
        case .icon(_):
            contentView.backgroundColor = UIColor(named: "DP_d9d9d9ff")
            contentView.layer.cornerRadius = 5
            numberLabel.isHidden = true
            iconImageView.isHidden = false
            iconImageView.image = UIImage(named: "DP_pickHidden")?.withRenderingMode(.alwaysTemplate)
        }
        
        if key.isEnabled {
            backgroundColor = .clear
            numberLabel.textColor = UIColor(named: "DP_4d4d4d")
        } else {
            backgroundColor = UIColor(named: "DP_E6E6E6ff")
            numberLabel.textColor = UIColor(named: "DP_cccccc")
        }
        
        isUserInteractionEnabled = key.isEnabled
    }
    
//    override var isHighlighted: Bool {
//        didSet {
//            UIView.animate(withDuration: 0.1) {
//                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.95, y: 0.95) : .identity
//                self.alpha = self.isHighlighted ? 0.7 : 1.0
//            }
//        }
//    }
    
}


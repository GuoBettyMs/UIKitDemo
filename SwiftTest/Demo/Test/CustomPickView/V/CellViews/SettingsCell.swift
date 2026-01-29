//
//  SettingsCell.swift
//  SwiftTest
//
//  Created by user on 2026/1/28.
//

import UIKit
import SnapKit

class SettingsCell: UITableViewCell{
    
    let titleImagV = UIImageView()
    let titleL = UILabel()
    let editImgV = UIImageView()
    let valueL = UILabel()
    let separoterlineV = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none  // 禁用点击高亮, 点击时没有系统默认高亮（灰色背景）
        setup1()
        
    }
    
    func setup1(){
        
        contentView.addSubview(separoterlineV)
        separoterlineV.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        separoterlineV.backgroundColor = UIColor(named: "DP_181818ff")
        
        contentView.addSubview(titleImagV)
        titleImagV.snp.makeConstraints { make in
            make.centerX.equalTo(contentView.snp.left).offset(16)
            make.centerY.equalToSuperview()
        }
        titleImagV.image = UIImage(named: "DP_chargeLimit")
        
        contentView.addSubview(titleL)
        titleL.snp.makeConstraints { make in
            make.left.equalTo(contentView.snp.left).offset(37)
            make.centerY.equalToSuperview()
        }
        titleL.textColor = .white
        titleL.font = UIFont(name: kSourceHanSansCN_Regular, size: 16)
        titleL.text = NSLocalizedString("ChargeLimit", comment: "Charge Limit")
//        titleL.numberOfLines = 0
//        titleL.lineBreakMode = .byWordWrapping
//        // 设置行间距
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.lineHeightMultiple = 0.7
//        let attributedString = NSAttributedString(
//            string: NSLocalizedString("ChargeLimit", comment: "Charge Limit"),
//            attributes: [
//                .font: UIFont(name: kSourceHanSansCN_Regular, size: 16) ?? UIFont.systemFont(ofSize: 16),
//                .foregroundColor: UIColor.white,
//                .paragraphStyle: paragraphStyle
//            ]
//        )
//        titleL.attributedText = attributedString
        
        contentView.addSubview(editImgV)
        editImgV.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.right).offset(-20)
            make.centerY.equalToSuperview()
        }
        editImgV.image = UIImage(named: "DP_tabEdit")
        
        contentView.addSubview(valueL)
        valueL.snp.makeConstraints { make in
            make.right.equalTo(editImgV.snp.centerX).offset(-18)
            make.centerY.equalToSuperview()
        }
        valueL.text = "90%"
        valueL.font = UIFont(name: kSourceHanSansCN_Regular, size: 16)
        valueL.textColor = UIColor(named: "DP_808080")
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSelectedState(_ isSelected: Bool) {
        editImgV.isHidden = !isSelected
        // 可以添加其他选中状态的样式变化
    }
}


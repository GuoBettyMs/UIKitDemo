//
//  ChargePageCell.swift
//  SwiftTest
//
//  Created by user on 2026/1/19.
//
// 根据 cell 数量,设置 cell 上下间距

import UIKit
import SnapKit

class ChargePageCell: UITableViewCell{
    
    let subviewsBgV = UIView()
    let titleL = UILabel()
    let valueL = UILabel()
    let uintL = UILabel()
    let titlebgV = UIView()
    let disImgV = UIImageView(image: UIImage(named: "DP_chargeDison"))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI1()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI1(){
        
        contentView.addSubview(subviewsBgV)
        subviewsBgV.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        subviewsBgV.backgroundColor = UIColor(named: "DP_404040ff")

        
        subviewsBgV.addSubview(titleL)
        titleL.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-2)
            make.left.equalTo(15)
        }
        titleL.font = UIFont(name: kSourceHanSansCN_Regular, size: 20)
        titleL.textColor = UIColor(named: "DP_999999")
        titleL.text = NSLocalizedString("BatteryType", comment: "Battery Type")
        
   //value bg view
        subviewsBgV.addSubview(titlebgV)
        titlebgV.snp.makeConstraints { make in
            make.width.equalTo(201)
            make.top.equalTo(subviewsBgV.snp.top)
            make.bottom.equalTo(subviewsBgV.snp.bottom)
            make.right.equalToSuperview()
        }
        titlebgV.backgroundColor = UIColor(named: "DP_262626")
//        titlebgV.layer.borderWidth = 2
//        titlebgV.layer.borderColor = UIColor(named: "DP_333333")?.cgColor

        titlebgV.addSubview(valueL)
        valueL.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(44)
        }
        valueL.attributedText = bahnschrift_formatted("LiPo")
        valueL.textColor = UIColor(named: "DP_ffffffff")
        
        titlebgV.addSubview(uintL)
        uintL.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(titlebgV.snp.right).offset(-62)
        }
        uintL.textColor = UIColor(named: "DP_999999")
        uintL.attributedText = bahnschrift_formatted("2S")
        
        subviewsBgV.addSubview(disImgV)
        disImgV.snp.makeConstraints { make in
            make.top.equalTo(3)
            make.right.equalTo(-3)
        }
        disImgV.isHidden = true
        
    }
    
    // 配置cell位置样式
    func configurePosition1(isFirst: Bool, isLast: Bool) {
        // 移除之前的约束
        subviewsBgV.snp.removeConstraints()
        
        // 重新设置约束
        subviewsBgV.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            
            if isFirst && isLast {
                // 只有一个cell的情况
                make.top.bottom.equalToSuperview()
            } else if isFirst {
                // 第一个cell
                make.top.equalToSuperview()
                make.bottom.equalToSuperview().offset(-1) // 留出间距的一半
            } else if isLast {
                // 最后一个cell
                make.top.equalToSuperview().offset(1) // 留出间距的一半
                make.bottom.equalToSuperview()
            } else {
                // 中间cell
                make.top.equalToSuperview().offset(1)
                make.bottom.equalToSuperview().offset(-1)
            }
        }
    }
    
    
    func configureDiscon(isSpecial: Bool, isOutputOpen: Bool){
        
        if isOutputOpen {
            disImgV.isHidden = isSpecial ? false : true
        }else{
            disImgV.isHidden = true
        }
        
        subviewsBgV.backgroundColor = UIColor(named: isSpecial ? "DP_FF0004" : "DP_404040ff")
        titlebgV.backgroundColor = UIColor(named: isSpecial ? "DP_FF0004" : "DP_262626")
        titleL.textColor = UIColor(named: isSpecial ? "DP_ffffffff" : "DP_000000ff")
        valueL.textColor = UIColor(named: isSpecial ? "DP_ffffffff" : "DP_FF0004")
        uintL.textColor = UIColor(named: isSpecial ? "DP_ffffffff" : "DP_999999")
        
    }
    
    // 配置 cell 颜色样式
    func configureColor1(isSpecial: Bool, isOutputOpen: Bool, isFullChargeIndicator: Bool){
 
        disImgV.isHidden = true
        
        if isOutputOpen {
            if isSpecial {
                subviewsBgV.backgroundColor = UIColor(named: isFullChargeIndicator ? "DP_00FF2B" : "DP_FF5500")
                titlebgV.backgroundColor = UIColor(named: isFullChargeIndicator ? "DP_00FF2B" : "DP_FF5500")
                titleL.textColor = UIColor(named: isFullChargeIndicator ? "DP_000000ff" : "DP_ffffffff")
                valueL.textColor = UIColor(named:isFullChargeIndicator ? "DP_000000ff" : "DP_ffffffff")
                uintL.textColor = UIColor(named: isFullChargeIndicator ? "DP_000000ff" : "DP_ffffffff")
            }else{
                //UITableView 会复用已经创建的 cell, 确保索引0的cell被复用到其他位置时，能被重置为默认样式
                subviewsBgV.backgroundColor = UIColor(named: "DP_404040ff")
                titlebgV.backgroundColor = UIColor(named: "DP_262626")
                titleL.textColor = UIColor(named: "DP_000000ff")
                valueL.textColor = UIColor(named: isFullChargeIndicator ? "DP_00FF2B" : "DP_FF5500")
                uintL.textColor = UIColor(named: "DP_999999")
                
            }
        }else{
            subviewsBgV.backgroundColor = UIColor(named: "DP_404040ff")
            titlebgV.backgroundColor = UIColor(named: "DP_262626")
            titleL.textColor = UIColor(named: "DP_000000ff")
            valueL.textColor = UIColor(named: isFullChargeIndicator ? "DP_00FF2B" : "DP_ffffffff")
            uintL.textColor = UIColor(named: "DP_999999")
        }
        
    }

}

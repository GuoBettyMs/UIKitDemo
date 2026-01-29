//
//  ChargeSettingCell.swift
//  SwiftTest
//
//  Created by user on 2026/1/19.
//
// UITableViewCell 子类,重写选中状态变化的方法,自定义选中时的背景色与文本色

import UIKit
import SnapKit

class ChargeSettingCell: UITableViewCell{
    
    let titleImagV = UIImageView()
    let titleL = UILabel()
    let directionImgV = UIImageView()
    let valueL = UILabel()
    let separoterlineV = UIView()
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // 设置选中样式为无
        self.selectionStyle = .none
        
        setupUI1()
 
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // 重置为非选中状态
        setSelected(false, animated: false)
    }
    
    // 重写选中状态变化的方法
   override func setSelected(_ selected: Bool, animated: Bool) {
       super.setSelected(selected, animated: animated)
       
       if selected {
           // 选中时的样式
           contentView.backgroundColor = UIColor(named: "DP_FFA600")
           valueL.textColor = UIColor(named: "DP_ffffffff")
           titleL.textColor = UIColor(named: "DP_000000ff")
           titleImagV.tintColor = UIColor(named: "DP_000000ff")
       } else {
           // 非选中时的样式 - 根据位置设置不同的背景色
           if let indexPath = (superview as? UITableView)?.indexPath(for: self) {
               updateBackgroundForIndexPath1(indexPath)
           } else {
               // 默认样式
               contentView.backgroundColor = UIColor(named: "DP_262626")
           }
       }
   }
    
    // 根据 indexPath 更新背景色
    private func updateBackgroundForIndexPath1(_ indexPath: IndexPath) {
        if indexPath.row == 0 {
            contentView.backgroundColor = UIColor(named: "DP_404040ff")
            titleL.textColor = UIColor(named: "DP_999999")
        } else if indexPath.row >= 1 && indexPath.row <= 5 {
            contentView.backgroundColor = UIColor(named: "DP_262626")
            valueL.textColor = UIColor(named: "DP_ffffffff")
            titleL.textColor = UIColor(named: "DP_999999")
            titleImagV.tintColor = UIColor(named: "DP_999999")
        } else {
            contentView.backgroundColor = UIColor(named: "DP_ffffffff")
            valueL.textColor = UIColor(named: "DP_262626")
            titleL.textColor = UIColor(named: "DP_999999")
        }
    }
    
    func setupUI1(){
        
        contentView.addSubview(separoterlineV)
        separoterlineV.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        separoterlineV.backgroundColor = UIColor(named: "DP_0d0d0dff")
       
        contentView.addSubview(titleImagV)
        titleImagV.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(15)
        }
        titleImagV.image = UIImage(named: "DP_Chemistry")?.withRenderingMode(.alwaysTemplate)
        titleImagV.tintColor = UIColor(named: "DP_999999")
        
        contentView.addSubview(titleL)
        titleL.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-2)
            make.left.equalToSuperview().offset(52)
        }
        titleL.font = UIFont(name: kSourceHanSansCN_Regular, size: 20)
        titleL.textColor = UIColor(named: "DP_999999")
        titleL.text = NSLocalizedString("Chemistry", comment: "Chemistry")
        
        
        contentView.addSubview(valueL)
        valueL.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-1)
            make.right.equalTo(-30)
        }
        valueL.font = UIFont(name: kSourceHanSansCN_Regular, size: 20)
        valueL.textColor = UIColor(named: "DP_ffffffff")
        valueL.text = "LiPo"
        
        
        contentView.addSubview(directionImgV)
        directionImgV.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-30)
        }
        directionImgV.image = UIImage(named: "DP_LastDataDown")
        directionImgV.tintColor = UIColor(named: "DP_ffffffff")
        directionImgV.isHidden = true
       
    }

}

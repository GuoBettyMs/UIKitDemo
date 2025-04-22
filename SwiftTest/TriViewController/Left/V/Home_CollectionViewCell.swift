//
//  Home_CollectionViewCell.swift
//  SwiftTest
//
//  Created by user on 2024/10/28.
//

import UIKit

class Home_CollectionViewCell: UICollectionViewCell {
    
    let deviceIconImgV = UIImageView()
    let deviceL = UILabel()
    let usenameL = UILabel()
    let statusL = UILabel()
    let perL = UILabel()
    let upgradeV = UIView()
    
    /// - Returns:
    /// 纯代码加载UIView
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        
        let lineV = UIView()
        addSubview(lineV)
        lineV.snp.makeConstraints { make in
            make.height.equalTo(2)
            make.width.equalTo(129)
            make.centerX.equalToSuperview()
//            make.left.equalTo(20)
//            make.right.equalTo(-20)
            make.centerY.equalToSuperview().offset(-5)
        }
        lineV.backgroundColor = UIColor(named: "Main-CollectionCellLine")

//        addSubview(deviceIconImgV)
//        deviceIconImgV.snp.makeConstraints{ make in
//            make.left.equalTo(lineV.snp.left)
//            make.bottom.equalTo(lineV.snp.top).offset(-10)
//        }
//        deviceIconImgV.image = UIImage(named: "PB10DW")?.withRenderingMode(.alwaysTemplate)
//        deviceIconImgV.tintColor = UIColor(named: "Main-CollectionCellLine")
        
        addSubview(usenameL)
        usenameL.snp.makeConstraints { make in
            make.right.equalTo(lineV.snp.right)
            make.bottom.equalTo(lineV.snp.top).offset(-8)
        }
        usenameL.textColor = UIColor(named: "Main-CollectionCellLine")
        usenameL.font = UIFont.systemFont(ofSize: 14)
        usenameL.textAlignment = .right
        usenameL.numberOfLines = 0
        usenameL.lineBreakMode = .byWordWrapping
        usenameL.isAccessibilityElement = false//设置不支持盲人模式
         
        addSubview(deviceL)
        deviceL.snp.makeConstraints { make in
            make.right.equalTo(lineV.snp.right)
            make.bottom.equalTo(usenameL.snp.top)
        }
        deviceL.textColor = UIColor(named: "Main-CollectionCellLine")
        deviceL.font = UIFont.systemFont(ofSize: 16)
        deviceL.isAccessibilityElement = false//设置不支持盲人模式

        addSubview(deviceIconImgV)
        deviceIconImgV.snp.makeConstraints{ make in
            make.left.equalTo(lineV.snp.left)
            make.centerY.equalTo(deviceL.snp.bottom)
        }
        deviceIconImgV.image = UIImage(named: "PB10DW")?.withRenderingMode(.alwaysTemplate)
        deviceIconImgV.tintColor = UIColor(named: "Main-CollectionCellLine")
        
        addSubview(statusL)
        statusL.snp.makeConstraints { make in
            make.left.equalTo(lineV.snp.left)
            make.top.equalTo(lineV.snp.bottom).offset(5)
        }
        statusL.textColor = UIColor(named: "Main-CollectionCellLine")
        statusL.font = UIFont.systemFont(ofSize: 14)
        statusL.isAccessibilityElement = false//设置不支持盲人模式
        
        addSubview(perL)
        perL.snp.makeConstraints { make in
            make.left.equalTo(lineV.snp.left)
            make.top.equalTo(statusL.snp.bottom).offset(2)
        }
        perL.textColor = UIColor(named: "Main-CollectionCellLine")
        perL.font = UIFont.systemFont(ofSize: 14)
        perL.isAccessibilityElement = false//设置不支持盲人模式
        
        addSubview(upgradeV)
        upgradeV.snp.makeConstraints { make in
            make.height.equalTo(36)
            make.width.equalTo(36)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        upgradeV.isHidden = true
        upgradeV.backgroundColor = UIColor(named: "Main-CollectinCellUpgrade")
 
        let path = UIBezierPath()
        path.move(to: CGPoint(x: upgradeV.frame.origin.x, y: upgradeV.frame.origin.y+36))//起点
        path.addLine(to: CGPoint(x: upgradeV.frame.origin.x+36, y: upgradeV.frame.origin.y))
        path.addLine(to: CGPoint(x: upgradeV.frame.origin.x+36, y: upgradeV.frame.origin.y+36))
        path.close()// 闭合曲线

        let shadowshapeLayer = CAShapeLayer()
        shadowshapeLayer.path = path.cgPath //存入UIBezierPath的路径
        shadowshapeLayer.fillColor = UIColor(named: "Main-CollectinCellUpgrade")?.cgColor //设置填充色
        shadowshapeLayer.lineWidth = 2  //设置路径线的宽度
        shadowshapeLayer.strokeColor = UIColor.clear.cgColor
        upgradeV.layer.mask = shadowshapeLayer

        let upgradeImg = UIImageView(image: UIImage(named: "Main-Upgrade"))
        upgradeV.addSubview(upgradeImg)
        upgradeImg.snp.makeConstraints { make in
            make.right.equalTo(-4)
            make.bottom.equalTo(-5)
        }
        
        self.backgroundColor = .random()
        self.layer.cornerRadius = 15
        self.clipsToBounds = true

    }
    
}

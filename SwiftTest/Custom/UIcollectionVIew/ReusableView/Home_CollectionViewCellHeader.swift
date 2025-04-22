//
//  Home_CollectionViewCellHeader.swift
//  SwiftTest
//
//  Created by user on 2024/8/2.
//

import UIKit

class Home_CollectionViewCellHeader: UICollectionReusableView {
    
    var isheaderClosed = false {//headerisClosed发生改变时,headerImgV自动修改图像
        didSet{
            headerImgV.image = UIImage(named: isheaderClosed ? "Main-ClassifyDown" : "Main-ClassifyUp")?.withRenderingMode(.alwaysTemplate)
        }
    }

    let headertitle = UILabel()
    let headerImgV = UIImageView()
    let headertitleStrs: [String] = [NSLocalizedString("Main-Powerbank", comment: "Powerbank"),
                                              NSLocalizedString("Main-PowerAdapter", comment: "Power Adapter"),
                                              NSLocalizedString("Main-WirelessCharger", comment: "Wireless Charger")]

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

        let bgV = UIView()
        addSubview(bgV)
        bgV.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        bgV.layer.cornerRadius = 10
        bgV.backgroundColor = .white
        
        bgV.addSubview(headertitle)
        headertitle.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        headertitle.font = UIFont.systemFont(ofSize: 15)
        headertitle.textColor = UIColor(named: "Main-ClassifyTitle")

        
        bgV.addSubview(headerImgV)
        headerImgV.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-15)
        }
        headerImgV.tintColor = UIColor(named: "Main-ClassifyHeaderBtnBG")
        
    }
}

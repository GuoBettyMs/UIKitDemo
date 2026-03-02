//
//  TitleContainer.swift
//  SwiftTest
//
//  Created by user on 2026/1/16.
//

import UIKit
import SnapKit
import NVActivityIndicatorView //NVActivityIndicatorView 的 .ballRotateChase 动画类型

class TitleContainer: UIView{

    let backBtn = UIButton()
    private let titleL = UILabel()
    let batTop = UIView()
    let barBGV = UIView()
    private let batBar = UIProgressView(progressViewStyle: .bar)//.bar: 进度条首尾不带圆角矩形; .default: 进度条首尾带圆角矩形
    let batValueL = UILabel()

    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        additionalSetup1()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    private func additionalSetup1(){
        
        addSubview(titleL)
        titleL.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        titleL.textColor = UIColor(named: "DP_ffffffff")
        titleL.text = NSLocalizedString("ChargeSetting_RegulatedDC", comment: "Regulated DC Power")
        titleL.font = UIFont(name: kManifoldExtendCF_bold, size: 20)
        
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backBtn)
        backBtn.snp.makeConstraints { make in
            make.width.height.equalTo(37)
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        backBtn.setImage(UIImage(named: "DP_Back"), for: .normal)
        
        batTop.translatesAutoresizingMaskIntoConstraints = false
        addSubview(batTop)
        batTop.snp.makeConstraints { make in
            make.width.equalTo(2)
            make.height.equalTo(4)
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }
        batTop.backgroundColor = .white
        //        batTop.addCorner(conrners: [UIRectCorner.bottomRight, UIRectCorner.topRight], radius: 1)
        
        barBGV.translatesAutoresizingMaskIntoConstraints = false
        addSubview(barBGV)
        barBGV.snp.makeConstraints { make in
            make.width.equalTo(20)
            make.height.equalTo(12)
            make.right.equalTo(batTop.snp.left)
            make.centerY.equalToSuperview()
        }
        barBGV.layer.cornerRadius = 3
        barBGV.backgroundColor = .white
        
        batBar.translatesAutoresizingMaskIntoConstraints = false
        barBGV.addSubview(batBar) // (14,6)
        batBar.snp.makeConstraints { make in
            make.top.equalTo(2)
            make.bottom.equalTo(-3)
            make.left.equalTo(2)
            make.right.equalTo(-2)
        }
        batBar.layer.cornerRadius = 0 // 移除圆角
        batBar.clipsToBounds = true
        batBar.layer.borderColor = UIColor.black.cgColor
        batBar.layer.borderWidth = 1
        batBar.trackTintColor = .black
        batBar.progressTintColor = .white
        batBar.progress = 0
        
        addSubview(batValueL)
        batValueL.snp.makeConstraints { make in
            make.right.equalTo(batBar.snp.left).offset(-8)
            make.centerY.equalToSuperview().offset(-1)
        }
        batValueL.font = UIFont(name: kSourceHanSansCN_Regular, size: 14)
        batValueL.textColor = .white
        batValueL.text = "-"
        
        if #available(iOS 13.0, *) {
            let refreshAIV = UIActivityIndicatorView(style: .medium)
            refreshAIV.color = .white
            addSubview(refreshAIV)
            refreshAIV.snp.makeConstraints { make in
                make.width.height.equalTo(25)
                make.right.equalTo(batBar.snp.left).offset(-38)
                make.centerY.equalToSuperview()
            }
            refreshAIV.startAnimating()
        }
    }
    
    // MARK: - Public Methods
    
    func setBatPer(_ per: Int){
       
        batBar.progress = per > 100 ? 1 : Float(per)/100.0
        batValueL.text = "\(per)"
    }

    /// 设置设备页面导航栏的标题
    func setTitle(_ menu: String){
        titleL.text = "\(menu)"
    }

}

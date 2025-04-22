//
//  UsbV.swift
//  Polylink
//
//  Created by user on 2024/12/13.
//

import UIKit
import SnapKit

class UsbV: UIView{
    
    let usbImgV = UIImageView()
    let usbTitleL = UILabel()
    let usbL = UILabel()
    let chargetimeL = UILabel()
    var usbImgStrArr = [["UsbOff", "UsbOut", "UsbIn"],
                        [NSLocalizedString("NP2Go-NotConnected", comment: "未连接"), NSLocalizedString("MA331-USBOUTPUT", comment: "输出"), NSLocalizedString("MA331-INPUT", comment: "输入")]]
    let usbStatus = ["未连接", "输出", "输入"]

    var currentProtocol: String = ""
    var currentValues: (v: String, c: String, p: String) = ("", "", "")

    override init(frame: CGRect) {
        super.init(frame: frame)
        additionalSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func additionalSetup(){
        
        // 创建一个容器视图来包含这两个元素
        let containerView = UIView()
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5)  // 容器高度为父视图的80%
            make.width.equalToSuperview()
        }

        containerView.addSubview(usbImgV)
        usbImgV.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(containerView.snp.height).multipliedBy(0.5)
        }
        usbImgV.contentMode = .center// 保持图片原始尺寸并居中
        usbImgV.image = UIImage(named: usbImgStrArr[0][0])
               
        // 添加标签
        containerView.addSubview(usbTitleL)
        usbTitleL.snp.makeConstraints { make in
            make.top.equalTo(usbImgV.snp.bottom)
            make.left.right.equalToSuperview()
        }
        usbTitleL.textAlignment = .center
        usbTitleL.text = "usbTitleL"
        
        containerView.addSubview(usbL)
        usbL.snp.makeConstraints { make in
            make.top.equalTo(usbTitleL.snp.bottom)
            make.left.right.equalToSuperview()
        }
        usbL.textAlignment = .center
        usbL.text = "usbL"

        containerView.addSubview(chargetimeL)
        chargetimeL.snp.makeConstraints { make in
            make.top.equalTo(usbL.snp.bottom)
            make.left.right.equalToSuperview()
        }
        chargetimeL.textAlignment = .center
        chargetimeL.text = "chargetimeL"
        

        usbTitleL.isAccessibilityElement = false
        usbL.isAccessibilityElement = false
        chargetimeL.isAccessibilityElement = false
        self.isAccessibilityElement = true
        self.accessibilityLabel = "USB未连接"
    }

}

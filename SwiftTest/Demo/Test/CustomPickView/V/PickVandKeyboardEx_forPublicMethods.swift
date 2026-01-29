//
//  PickVandKeyboardEx_forPublicMethods.swift
//  SwiftTest
//
//  Created by user on 2026/1/28.
//

import UIKit

// MARK: Public Methods

extension PickVandNumberKeyboard {
    
    /// 更改进度条的进度
    /// - Parameters:
    ///   - currentValue: 0,1,2
    func updateProgress(currentValue: Int){

        progressValue = Float(currentValue)*0.5
//        Log.debug(" currentValue= \(currentValue),  progress= \(progressValue)")
        
    }
    
    //MARK: 菜单栏

    func turnToSettingPageV(isShow: Bool, oldModeI: Int){
        
        switch oldModeI{
        case 0://工作区页面
            scrollView.isHidden = isShow
        case 1://可编程页面
            programmablePageV.isHidden = isShow
        case 3:
            chargePageV.isHidden = isShow
        case 4: //预设值页面
            presetPageV.isHidden = isShow
            
        default:
            break
        }
        
        settingPageV.isHidden = !isShow
        
    }
    
    func turnToChargePageV(isShow: Bool, oldModeI: Int){
        
        switch oldModeI{
        case 0://工作区页面切换到充电页面
            scrollView.isHidden = isShow
        case 1://可编程页面切换到充电页面
            programmablePageV.isHidden = isShow
        case 4: //预设值页面
            presetPageV.isHidden = isShow
        case 5:
            settingPageV.isHidden = isShow
        default:
            break
        }
        
        chargePageV.isHidden = !isShow
        
    }
    
    func turnToProgrammablePageV(isShow: Bool,oldModeI: Int){
        
        switch oldModeI{
        case 0://工作区页面切换到可编程页面
            scrollView.isHidden = isShow
        case 3://充电页面切换到可编程页面
            chargePageV.isHidden = isShow
        case 4: //预设值页面
            presetPageV.isHidden = isShow
        case 5:
            settingPageV.isHidden = isShow
        default:
            break
        }
        
        programmablePageV.isHidden = !isShow
        
    }

    
    func turnToPresetPageV(isShow: Bool,oldModeI: Int){
        
        switch oldModeI{
        case 0://工作区页面
            scrollView.isHidden = isShow
        case 1://可编程页面
            programmablePageV.isHidden = isShow
        case 3://充电页面
            chargePageV.isHidden = isShow
        case 5:
            settingPageV.isHidden = isShow
        default:
            break
        }
        
        presetPageV.isHidden = !isShow
        
    }
    
    
    //MARK: 设定按钮
    //设置实时按钮 ui
    func updateRealtimeBtnUI(isReal: Bool){

        realtimeChangesBtn.backgroundColor = UIColor(named: isReal ? "DP_0B8CE8ff" : "DP_ffffffff")
        if let img = realtimeChangesBtn.subviews[0] as? UIImageView{
            img.image = UIImage(named: isReal ? "DP_pickRealtimeOn" : "DP_pickRealtimeOff")
        }
        if let label = realtimeChangesBtn.subviews[1] as? UILabel{
            label.textColor = UIColor(named: isReal ? "DP_ffffffff" : "DP_0B8CE8ff")
        }
            
        pickConfirmBtn.backgroundColor = UIColor(named: isReal ? "DP_d9d9d9ff" : "DP_0B8CE8ff")
        
    }
    
    //恢复设定按钮默认圆角
    func recoverSetBtnMaskedCorners(isVolSetting: Bool){
        
        let index = isVolSetting ? 0 : 1
        setBtns[index].setValueTextColor(true)
        setBtns[index].backgroundColor = UIColor(named: "DP_404040ff")
        setBtns[index].layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        setBtns[index].cornerPathLocation = .none
        seperateLine.isHidden = true
        
    }
    
    //显示设定背景
    func showTimeandEnergyV1(isShow: Bool){
        
        seperateLine.isHidden = isShow
        setBgV.isHidden = isShow
        
        if !isShow{
            setBtns[0].snp.remakeConstraints { make in
                make.width.equalToSuperview().multipliedBy(0.49)
                make.height.equalTo(50)
                make.top.equalToSuperview()
                make.left.equalToSuperview()
            }
            
            setBgV.snp.remakeConstraints { make in
                make.height.equalTo(245)
                make.left.equalTo(setBtns[0].snp.left) //351
                make.right.equalTo(setBtns[1].snp.right)
                make.top.equalTo(setBtns[0].snp.bottom).offset(5)
                make.bottom.equalToSuperview()
            }
            
        }else{
            
           setBgV.snp.remakeConstraints { make in
               make.height.equalTo(245)
               make.left.equalTo(setBtns[0].snp.left) //351
               make.right.equalTo(setBtns[1].snp.right)
               make.top.equalTo(setBtns[0].snp.bottom).offset(5)
            }
            
            setBtns[0].snp.remakeConstraints { make in
                make.width.equalToSuperview().multipliedBy(0.49)
                make.height.equalTo(50)
                make.top.equalToSuperview()
                make.left.equalToSuperview()
                make.bottom.equalToSuperview()
            }
        }

    }
    
    //更改设定按钮圆弧 ui
    func showSettingV(isVolSetting: Bool){
        
        // 使用 CATransaction 禁用隐式动画
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        seperateLine.isHidden = false
        
        if isVolSetting{
            seperateLine.snp.remakeConstraints { make in
                make.left.equalTo(setBtns[0].snp.left)
                make.right.equalTo(setBtns[0].snp.right).offset(20)
                make.height.equalTo(16)
                make.bottom.equalTo(setBgV.snp.top)
            }
            
            setBgV.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            
            setBtns[0].setValueTextColor(false)
            setBtns[0].backgroundColor = UIColor(named: "DP_ffffffff")
            setBtns[0].layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            setBtns[0].cornerPathLocation = .none
            
            setBtns[1].setValueTextColor(true)
            setBtns[1].backgroundColor = UIColor(named: "DP_404040ff")
            setBtns[1].layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            setBtns[1].cornerPathLocation = .bottomLeft // 显示左下角

            bringSubviewToFront(setBtns[1])
        }else{
            
            seperateLine.snp.remakeConstraints { make in
                make.left.equalTo(setBtns[1].snp.left).offset(-20)
                make.right.equalTo(setBtns[1].snp.right)
                make.height.equalTo(16)
                make.bottom.equalTo(setBgV.snp.top)
            }
            
            setBgV.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            
            setBtns[1].setValueTextColor(false)
            setBtns[1].backgroundColor = UIColor(named: "DP_ffffffff")
            setBtns[1].layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            setBtns[1].cornerPathLocation = .none
            
            setBtns[0].setValueTextColor(true)
            setBtns[0].backgroundColor = UIColor(named: "DP_404040ff")
            setBtns[0].layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            setBtns[0].cornerPathLocation = .bottomRight // 显示右下角

            bringSubviewToFront(setBtns[0])
        }
        
        CATransaction.commit()
        
        // 手动触发布局
        self.setNeedsLayout()
        self.layoutIfNeeded()

    }
    
    ///切换设置模式 , 0:键盘 1:旋钮
    func swithcSetType(isVolSetting: Bool, setType: Int){

        if #available(iOS 13.0, *) {
            switchSetmodeBtn.setImage(UIImage(named: setType == 0 ? "DP_scrollwheel" : "DP_keyboard")?.withTintColor(.black), for: .normal)
        } else {
            switchSetmodeBtn.setImage(UIImage(named: setType == 0 ? "DP_scrollwheel" : "DP_keyboard"), for: .normal)
        }
        rampAndRealBtn.isHidden = !isVolSetting
        if isVolSetting{
            if setType == 0{
                if #available(iOS 13.0, *) {
                    rampAndRealBtn.setImage(UIImage(named: "DP_keyboard_squareWave")?.withTintColor(.black), for: .normal)
                } else {
                    rampAndRealBtn.setImage(UIImage(named: "DP_keyboard_squareWave"), for: .normal)
                }
            }else if setType == 1{
                if #available(iOS 13.0, *) {
                    rampAndRealBtn.setImage(UIImage(named: "DP_squareWave")?.withTintColor(.black), for: .normal)
                } else {
                    rampAndRealBtn.setImage(UIImage(named: "DP_squareWave"), for: .normal)
                }
            }
        }
        
        //从其它页面切换到工作区页面时,可能隐藏了部分子视图.恢复显示
        setBgV.subviews.forEach { $0.isHidden = false }
        

        textfield.isHidden = setType == 1
        textfieldUintL.text = isVolSetting ? "V" : "A"
        numberKeyboardV.isHidden = setType == 1
        
        pickV.isHidden = setType == 0
//        pickV.maxValue = isVolSetting ? 30.50 : 5.100
        pickValueBgV.isHidden = setType == 0
        pickHiddenBtn.isHidden = setType == 0
        pickConfirmBtn.isHidden = setType == 0
        realtimeChangesBtn.isHidden = setType == 0
        
        switch setType{
        case 0: //键盘
            textfield.isHidden = false
            pickV.isHidden = true
//            setTextfieldAttributedText(text: setBtns[isVolSetting ? 0 : 1].getSetvalue())
            setTextfieldAttributedText(text: "")

            rampAndRealBtn.snp.remakeConstraints { make in
                make.width.equalToSuperview().multipliedBy(0.19) //66/351
//                make.width.equalTo(66)
                make.height.equalTo(switchSetmodeBtn.snp.height)
                make.right.equalToSuperview().offset(-10)
                make.bottom.equalTo(switchSetmodeBtn.snp.bottom)
            }
            
            textfieldBgV.snp.remakeConstraints { make in
                make.top.equalTo(switchSetmodeBtn.snp.top)
                make.left.equalTo(switchSetmodeBtn.snp.right).offset(8)
                make.bottom.equalTo(switchSetmodeBtn.snp.bottom)
                if isVolSetting{
                    make.right.equalTo(rampAndRealBtn.snp.left).offset(-8) // 215
                }else{
                    make.right.equalToSuperview().offset(-10) //291
                }
            }
            
            textfieldUintL.snp.remakeConstraints { make in
                if isVolSetting {
//                    make.width.equalTo(35)
                    make.width.equalToSuperview().multipliedBy(0.16) //35/215
                }else{
//                    make.width.equalTo(66)
                    make.width.equalToSuperview().multipliedBy(0.23) //66/291
                }
                make.height.equalToSuperview()
                make.right.equalToSuperview()
                make.centerY.equalToSuperview()
            }
            textfieldUintL.attributedText = bahnschrift_formatted(textfieldUintL.text ?? "", 24, weight: .bold)
            
            
        case 1://旋钮
            pickV.isHidden = false//setType == 0
            textfieldBgV.snp.remakeConstraints { make in
                make.left.equalTo(switchSetmodeBtn.snp.right).offset(8) //291
                make.top.equalTo(switchSetmodeBtn.snp.top)
                make.bottom.equalTo(realtimeChangesBtn.snp.top).offset(-15)
                make.right.equalToSuperview().offset(-10)
            }

            rampAndRealBtn.snp.remakeConstraints { make in
                make.left.right.equalTo(switchSetmodeBtn)
                make.top.equalTo(switchSetmodeBtn.snp.bottom).offset(15)
                make.bottom.equalTo(realtimeChangesBtn.snp.top).offset(-15)
            }
            
            textfieldUintL.snp.remakeConstraints { make in
                make.width.equalToSuperview().multipliedBy(0.23) //66/291
//                make.width.equalTo(66)
                make.height.equalToSuperview()
                make.right.equalToSuperview()
                make.centerY.equalToSuperview()
            }
            textfieldUintL.attributedText = bahnschrift_formatted(textfieldUintL.text ?? "", 24, weight: .bold)
            
//            //切换设置值
//            pickV.currentValue = isVolSetting ? Double(setBtns[0].getSetvalue()) ?? 0 : Double(setBtns[1].getSetvalue()) ?? 0
            
        default:
            break
        }
    }
    
    //文本框模式,设置值
    func setTextfieldAttributedText(text: String){
        textfield.attributedText = createAttributedText(text: text)
    }
    
    // MARK: - Helper Methods

    private func createAttributedText(text: String) -> NSAttributedString {
        // 字体
        let descriptor = UIFontDescriptor(
            fontAttributes: [
                .name: kBahnschrift,
                .traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.regular]
            ]
        )
        let font = UIFont(descriptor: descriptor, size: 48)
        
        // 段落
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 41.0  // 设置行高
        paragraphStyle.lineSpacing = 0
        
        // 创建富文本
        let attributedString = NSMutableAttributedString(string: text)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor(named: "DP_0B8CE8ff") ?? .lightGray,
            .kern: 3,
            .baselineOffset: -4, // 向下偏移
            .paragraphStyle: paragraphStyle
        ]
        
        attributedString.addAttributes(attributes,
                                       range: NSRange(location: 0, length: text.count))
        
        return attributedString
    }
}

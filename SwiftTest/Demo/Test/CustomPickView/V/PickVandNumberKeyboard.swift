//
//  PickVandNumberKeyboard.swift
//  SwiftTest
//
//  Created by user on 2026/1/15.
//

import SnapKit
import UIKit

class AdaptiveCornerRadiusView: UIButton {
    /// 圆角比例：0.0 ~ 1.0，例如 0.5 表示圆角 = min(width, height) * 0.5（即胶囊或圆形）
    var cornerRadiusRatio: CGFloat = 0.16 // 默认 60%
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCornerRadius()
    }
    
    private func updateCornerRadius() {
        let radius = max(1, bounds.height) * cornerRadiusRatio
        layer.cornerRadius = radius
        
    }
}

class PickVandNumberKeyboard: UIView{

    //MARK: 设置页面
    let settingPageV = SettingPageV(frame: .zero, type: .battery)
    
    //MARK: 预设值页面
    let presetPageV = PresetPageV()
    
    //MARK: 可编程页面
    let programmablePageV = ProgrammablePageV()
    
    //MARK: 充电页面
    let chargePageV = ChargePageV()
    
    //MARK: 进度条与滑杆
    private let progressContaintBg = UIView()
    private var progress = UIProgressView()
    var progressValue:Float = 0.0 {
        didSet{
            //直接设置进度
            progress.setProgress(Float(progressValue), animated: false)
        }
    }
    let precisionSlider = UISlider()

    //MARK: 设置按钮
    let seperateLine = UIView()
    var setBtns = [CustomSetNumBtn]()
    let setBgV = UIView()
    
    let switchSetmodeBtn = UIButton() //设置模式的切换按钮
    let rampAndRealBtn = UIButton() //电压缓升按钮
    let textfieldBgV = UIView()  //文本框或者选择器的背景 view
    let textfieldUintL = UILabel()
    
    //文本框设置模式
    let numberKeyboardV = NumberKeyboardView() //自定义数字键盘,包含清除键等
    let textfield = UITextField() //文本框
    struct NumberInputConstants {
        static let maxValue: Double = 30.50
        static let maxDigitsBeforeDecimal = 2 // 整数部分最多2位（30）
        static let maxDigitsAfterDecimal = 2  // 小数部分最多2位（0.50）
    }

    
    //选择器设置模式
    let pickValueBgV = UIView()
    let rowNumbers = Array(0...9) //行选项
    let pickV = WheelNumberPicker() //选择器
    let pickHiddenBtn = UIButton() //选择器收起按钮
    let pickConfirmBtn = UIButton() //选择器确认按钮
    let realtimeChangesBtn = UIButton() //选择器实时更改按钮

    //MARK: AdaptiveCornerRadiusView
    var protectionVItems: [AdaptiveCornerRadiusView] = []
    let protectionV1 = AdaptiveCornerRadiusView()
    let protectionBgV = AdaptiveCornerRadiusView()
    
    
    //MARK: 导航栏与菜单栏
    let scrollView = UIScrollView()
    private let contentView = UIView()
    let titleContainer = TitleContainer() //自定义导航栏
    let menuBGV = BottommenuV() //底部菜单栏
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        additionalSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Private Methods
    private func additionalSetup(){
        
        //顶部
        addSubview(titleContainer)
        titleContainer.translatesAutoresizingMaskIntoConstraints = false
        titleContainer.snp.makeConstraints { make in
            make.left.equalTo(12) // 351
            make.right.equalTo(-12)
            make.height.equalTo(kNavigBarH) 
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
        }
        titleContainer.backgroundColor = .clear

        //底部
        menuBGV.translatesAutoresizingMaskIntoConstraints = false
        addSubview(menuBGV)
        menuBGV.snp.makeConstraints { make in
            make.width.equalToSuperview()  //375
            make.height.equalTo(90)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.snp.remakeConstraints { make in
            make.top.equalTo(titleContainer.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalTo(menuBGV.snp.top).offset(-10)
        }
        scrollView.showsHorizontalScrollIndicator = false

        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.snp.remakeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView.snp.width) // 显式绑定宽度，防止歧义
        }

        addAdaptiveCornerRadiusView()
        addSlider()
        addSetV()
        
        createprogrammablePageV1()
        createpresetPageV()
        createChargePageV1()
        createSettingPageV()
        
    }
    
    private func addAdaptiveCornerRadiusView(){

        let multilingualText = [
            NSLocalizedString("ConstantCurrent", comment: "Constant\nCurrent"),
            NSLocalizedString("OvercurrentProtection", comment: "Overcurrent\nProtection")
        ]
     
        contentView.addSubview(protectionBgV)
        protectionBgV.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(60)
            make.top.equalToSuperview().offset(10)
        }
        protectionBgV.backgroundColor = UIColor(named: "DP_002626ff")
        protectionBgV.layer.borderColor = UIColor(named: "DP_00ffff")?.cgColor
        protectionBgV.layer.borderWidth = 2
        
        for (vI, title) in multilingualText.enumerated() {
            let ocpBGV = AdaptiveCornerRadiusView()
            protectionBgV.addSubview(ocpBGV)
            ocpBGV.snp.makeConstraints { make in
                make.width.equalToSuperview().multipliedBy(vI == 0 ? 0.46 : 0.56) //vI == 0 ? 160/351 : 195/351
                make.height.equalToSuperview()//60
                make.centerY.equalToSuperview()
                if vI == 0 {
                    make.left.equalToSuperview()
                }else{
                    make.right.equalToSuperview()
                }
            }
            ocpBGV.backgroundColor = vI == 0 ? .clear : UIColor(named: "DP_00ffff")
            ocpBGV.layer.borderColor = vI == 0 ? UIColor.clear.cgColor : UIColor(named: "DP_002626ff")?.cgColor
            ocpBGV.layer.borderWidth = 4
            ocpBGV.layer.maskedCorners = vI == 0 ? [.layerMinXMinYCorner, .layerMinXMaxYCorner] : [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]

            let protectTitleL = UILabel()
            ocpBGV.addSubview(protectTitleL)
            protectTitleL.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().offset(-4)
            }
            protectTitleL.textColor = UIColor(named: vI == 0 ? "DP_00ffff" : "DP_002626ff")
            protectTitleL.font = UIFont(name: kSourceHanSansCN_Regular, size: 14)
            protectTitleL.text = title

            let ocpSignV = AdaptiveCornerRadiusView()
            ocpBGV.addSubview(ocpSignV)
            ocpSignV.snp.makeConstraints { make in
                make.height.equalTo(25)
                make.width.equalToSuperview().multipliedBy(vI == 0 ? 0.31 : 0.26) //vI == 0 ? 50/160 : 50/195
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset(-8)
            }
            ocpSignV.backgroundColor = UIColor(named: vI == 0 ?  "DP_00ffff" : "DP_002626ff")

            let ocpSignL = UILabel()
            ocpSignV.addSubview(ocpSignL)
            ocpSignL.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
            ocpSignL.textColor = UIColor(named: vI == 0 ? "DP_002626ff" : "DP_00ffff")
            ocpSignL.attributedText = bahnschrift_formatted(vI == 0 ? "CC" : "OCP")

            // 将 ocpBGV 发送到底层, 确保 ocpBGV 在边框下方
            protectionBgV.sendSubviewToBack(ocpBGV)
            protectionVItems.append(ocpBGV)
        }

//        protectionBgV.addSubview(protectionV1)
//        protectionV1.snp.makeConstraints { make in
//            make.edges.equalTo(protectionBgV)
//        }
//        protectionV1.backgroundColor = .clear
//        protectionV1.layer.borderColor = UIColor(named: "DP_00ffff")?.cgColor
//        protectionV1.layer.borderWidth = 2
        
    }
    
    private func addSlider(){
        let sliderContaintBg = UIView()
        contentView.addSubview(sliderContaintBg)
        sliderContaintBg.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(60)
            make.top.equalTo(protectionBgV.snp.bottom).offset(5)
        }
        // 确保containBg能够响应触摸事件
        sliderContaintBg.isUserInteractionEnabled = true
        
        sliderContaintBg.addSubview(precisionSlider)
        precisionSlider.snp.makeConstraints { make in
            make.width.equalTo(200)
           make.height.equalTo(40)
           make.center.equalToSuperview()
        }
        precisionSlider.backgroundColor = .clear
        precisionSlider.tintColor = UIColor(named: "DP_999999")
       
        let trackColor = UIColor(named: "DP_999999") ?? .gray
        let minTrack = UIImage.rightRectangleImage(with: trackColor, size: CGSize(width: 1, height: 5))
        let maxTrack = UIImage.rightRectangleImage(with: trackColor, size: CGSize(width: 1, height: 5))
        //通过自定义最小/最大轨道图像 或 利用 tint 颜色 + 限制高度 来实现缩小 UISlider 的可视高度，但又不影响点击区域
        precisionSlider.setMinimumTrackImage(minTrack, for: .normal)
        precisionSlider.setMaximumTrackImage(maxTrack, for: .normal)

        precisionSlider.setThumbImage(UIImage(named: "BL8_sliderThumbImage"), for: .normal)
        precisionSlider.minimumValue = 0
        precisionSlider.maximumValue = 2
        precisionSlider.value = 1
        precisionSlider.isContinuous = true  // 确保连续触发事件
        precisionSlider.isUserInteractionEnabled = true


        contentView.addSubview(progressContaintBg)
        progressContaintBg.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(10)
            make.height.equalTo(40)
            make.top.equalTo(sliderContaintBg.snp.bottom).offset(10)
        }
        
        progressContaintBg.addSubview(progress)
        progress.snp.makeConstraints { make in
            make.width.equalTo(200)
            make.height.equalTo(6)
            make.center.equalToSuperview()
        }
        progress.progress = 0.5
        progress.trackTintColor = .clear // 关键：用 image 覆盖，不使用 tint
        progress.progressTintColor = .clear

        let trackImg = UIImage.capsuleProgressImage(color: UIColor(named: "DP_999999") ?? .gray, height: 6)
        let progressImg = UIImage.capsuleProgressImage(color: UIColor(named: "BL8_aaaaffff") ?? .blue, height: 6)
        progress.trackImage = trackImg
        progress.progressImage = progressImg
        
    }
    
    //添加设定电压、设定电流背景 ui
    private func addSetV(){
        
        let barV = UIView()
        barV.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(barV) //父视图高度以子视图实际高度为准
        barV.snp.makeConstraints { make in
            make.left.equalTo(12) // 351
            make.right.equalTo(-12)
            make.centerX.equalToSuperview()
            make.top.equalTo(progressContaintBg.snp.bottom).offset(10)
            make.bottom.equalToSuperview() //确认 contentView 高度
        }
        
        barV.addSubview(seperateLine)
        seperateLine.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.55) // 193/351
            make.height.equalTo(16)
            make.left.equalToSuperview()
            make.bottom.equalTo(55)
        }
        seperateLine.backgroundColor = UIColor(named: "DP_ffffffff")
        seperateLine.isHidden = true
        
        //设定按钮
        let setBtn = CustomSetNumBtn()
        barV.addSubview(setBtn)
        setBtn.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.49) //173/351
            make.height.equalTo(50)
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.bottom.equalToSuperview() //确认 barV 高度
        }
        setBtn.setTitleText("V-SET")
        setBtn.setValueText("00.00")
        setBtn.setUnitText("V")
        
        let cursetBtn = CustomSetNumBtn()
        barV.addSubview(cursetBtn)
        cursetBtn.snp.makeConstraints { make in
            make.left.equalTo(setBtn.snp.right).offset(5)
            make.right.equalToSuperview()
            make.top.equalTo(setBtn.snp.top)
            make.bottom.equalTo(setBtn.snp.bottom)
        }
        
        setBtn.cornerPathLocation = .bottomLeft // 显示左下角
        cursetBtn.cornerPathLocation = .bottomRight // 显示右下角
        
        barV.addSubview(setBgV)
        setBgV.snp.makeConstraints { make in
            make.height.equalTo(245)
            make.left.equalTo(setBtn.snp.left) //351
            make.right.equalTo(cursetBtn.snp.right)
            make.top.equalTo(setBtn.snp.bottom).offset(5)
        }
        setBgV.backgroundColor = UIColor(named: "DP_ffffffff")
        setBgV.layer.cornerRadius = 10
        setBgV.isHidden = true
        
        setBtns.append(setBtn)
        setBtns.append(cursetBtn)
        
        
        addNumberKeyboardV()
        addPickV()
        
    }
    
   
    private func addNumberKeyboardV(){
        setBgV.addSubview(switchSetmodeBtn)
        switchSetmodeBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.width.equalToSuperview().multipliedBy(0.14) //50/351
            make.height.equalTo(50)
            make.left.equalTo(10)
        }
        switchSetmodeBtn.layer.cornerRadius = 5
        switchSetmodeBtn.backgroundColor = UIColor(named: "DP_d9d9d9ff")
        if #available(iOS 13.0, *) {
            switchSetmodeBtn.setImage(UIImage(named: "DP_keyboard")?.withTintColor(.black), for: .normal)
        } else {
            switchSetmodeBtn.setImage(UIImage(named: "DP_keyboard"), for: .normal)
        }

        setBgV.addSubview(numberKeyboardV)
        numberKeyboardV.snp.makeConstraints { make in
            make.top.equalTo(switchSetmodeBtn.snp.bottom).offset(5)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.bottom.equalToSuperview().offset(-15)
        }
        numberKeyboardV.translatesAutoresizingMaskIntoConstraints = false
        numberKeyboardV.isHidden = true
        
        setBgV.addSubview(rampAndRealBtn)
        rampAndRealBtn.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.19) //66/351
            make.height.equalTo(switchSetmodeBtn.snp.height)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalTo(switchSetmodeBtn.snp.bottom)
        }
        rampAndRealBtn.layer.cornerRadius = 5
        rampAndRealBtn.backgroundColor = UIColor(named: "DP_EDCCFF")
        if #available(iOS 13.0, *) {
            rampAndRealBtn.setImage(UIImage(named: "DP_keyboard_squareWave")?.withTintColor(.black), for: .normal)
            rampAndRealBtn.setImage(UIImage(named: "DP_sinewave")?.withTintColor(.black), for: .selected)
        } else {
            rampAndRealBtn.setImage(UIImage(named: "DP_keyboard_squareWave"), for: .normal)
            rampAndRealBtn.setImage(UIImage(named: "DP_sinewave"), for: .selected)
        }
        
        rampAndRealBtn.isHidden = true

        
        setBgV.addSubview(textfieldBgV)
        textfieldBgV.snp.makeConstraints { make in
            make.top.equalTo(switchSetmodeBtn.snp.top)
            make.left.equalTo(switchSetmodeBtn.snp.right).offset(8) //215
            make.right.equalTo(rampAndRealBtn.snp.left).offset(-8)
            make.bottom.equalTo(switchSetmodeBtn.snp.bottom)
        }
        textfieldBgV.layer.cornerRadius = 5
        textfieldBgV.backgroundColor = UIColor(named: "DP_d9d9d9ff")
        textfieldBgV.clipsToBounds = true
        

        textfieldBgV.addSubview(textfieldUintL)
        textfieldUintL.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.16) //35/215
//            make.width.equalTo(35)
            make.height.equalToSuperview()
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        textfieldUintL.textColor = UIColor(named: "DP_d9d9d9ff")
        textfieldUintL.backgroundColor = UIColor(named: "DP_4d4d4d")
        textfieldUintL.attributedText = bahnschrift_formatted("V", 24)
        
        textfieldBgV.addSubview(textfield)
        textfield.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalTo(textfieldUintL.snp.left)
            make.centerY.equalToSuperview()
        }
        textfield.textAlignment = .center
    }
    
    private func addPickV(){
        
        setBgV.addSubview(pickHiddenBtn)
        pickHiddenBtn.snp.makeConstraints { make in
            make.height.equalTo(50)
//            make.height.equalTo(self.snp.width).multipliedBy(0.13) //50/375
            make.left.equalTo(switchSetmodeBtn.snp.left)
            make.right.equalTo(switchSetmodeBtn.snp.right)
            make.bottom.equalToSuperview().offset(-15)
        }
        if #available(iOS 13.0, *) {
            pickHiddenBtn.setImage(UIImage(named: "DP_pickHidden")?.withTintColor(.black), for: .normal)
        } else {
            pickHiddenBtn.setImage(UIImage(named: "DP_pickHidden"), for: .normal)
        }
        pickHiddenBtn.layer.cornerRadius = 5
        pickHiddenBtn.backgroundColor = UIColor(named: "DP_d9d9d9ff")
        

        setBgV.addSubview(pickConfirmBtn)
        pickConfirmBtn.snp.makeConstraints { make in
            make.height.equalTo(pickHiddenBtn.snp.height) //50
            make.bottom.equalTo(pickHiddenBtn.snp.bottom)
            make.left.equalTo(textfieldUintL.snp.left)
            make.right.equalTo(textfieldUintL.snp.right)
        }
        pickConfirmBtn.layer.cornerRadius = 5
        pickConfirmBtn.backgroundColor = UIColor(named: "DP_d9d9d9ff")
        if #available(iOS 13.0, *) {
            pickConfirmBtn.setImage(UIImage(named: "DP_pickConfirm")?.withTintColor(.white), for: .normal)
        } else {
            pickConfirmBtn.setImage(UIImage(named: "DP_pickConfirm"), for: .normal)
        }

        setBgV.addSubview(realtimeChangesBtn)
        realtimeChangesBtn.snp.makeConstraints { make in
            make.height.equalTo(pickHiddenBtn.snp.height) //50
            make.left.equalTo(pickHiddenBtn.snp.right).offset(8)
            make.right.equalTo(pickConfirmBtn.snp.left).offset(-8)
            make.bottom.equalTo(pickHiddenBtn.snp.bottom)
        }
        realtimeChangesBtn.layer.cornerRadius = 5
        realtimeChangesBtn.layer.borderWidth = 1
        realtimeChangesBtn.layer.borderColor = UIColor(named: "DP_0B8CE8ff")?.cgColor
        realtimeChangesBtn.backgroundColor = UIColor(named: "DP_0B8CE8ff")
        
        let imgV = UIImageView()
        realtimeChangesBtn.addSubview(imgV)
        imgV.image = UIImage(named: "DP_pickRealtimeOn")
        
        let label = UILabel()
        realtimeChangesBtn.addSubview(label)
        label.font = UIFont(name: kSourceHanSansCN_Regular, size: 16)
        label.text = NSLocalizedString("RealtimeChanges", comment: "Real-time Changes")
        if GetCurrentLanguage() == "cn"{
            imgV.snp.makeConstraints { make in
                make.centerX.equalToSuperview().offset(-30)
                make.centerY.equalToSuperview()
            }
            
            label.snp.makeConstraints { make in
                make.left.equalTo(imgV.snp.right).offset(10)
                make.centerY.equalToSuperview()
            }
        }else{
            imgV.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(15)
                make.centerY.equalToSuperview()
            }
            
            label.snp.makeConstraints { make in
                make.left.equalTo(imgV.snp.right).offset(10)
                make.centerY.equalToSuperview()
            }
        }
        
        textfieldBgV.addSubview(pickValueBgV)
        pickValueBgV.snp.makeConstraints { make in
//            make.height.equalTo(self.snp.width).multipliedBy(0.11) //40/375
            make.height.equalTo(40)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(5)
            make.right.equalTo(textfieldUintL.snp.left).offset(-5)
        }
        pickValueBgV.layer.cornerRadius = 5
        pickValueBgV.backgroundColor = UIColor(named: "DP_0B8CE8ff")
        
        textfieldBgV.addSubview(pickV)
        pickV.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.right.equalTo(textfieldUintL.snp.left).offset(-12)
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        pickV.translatesAutoresizingMaskIntoConstraints = false

        
    }
    
    private func createChargePageV1(){
        chargePageV.translatesAutoresizingMaskIntoConstraints = false
        addSubview(chargePageV)
        chargePageV.snp.makeConstraints { make in
            make.left.equalTo(12) // 351
            make.right.equalTo(-12)
            make.top.equalTo(titleContainer.snp.bottom).offset(10)
            make.bottom.equalTo(menuBGV.snp.top).offset(-15)
        }
        chargePageV.isHidden = true
    }
    
    private func createprogrammablePageV1(){
        
        programmablePageV.translatesAutoresizingMaskIntoConstraints = false
        addSubview(programmablePageV)
        programmablePageV.layer.cornerRadius = 10
        programmablePageV.clipsToBounds = true
        programmablePageV.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.top.equalTo(titleContainer.snp.bottom).offset(10)
            make.bottom.equalTo(menuBGV.snp.top).offset(-15)
        }
        programmablePageV.isHidden = true
        
    }
    
    private func createpresetPageV(){
        
        presetPageV.translatesAutoresizingMaskIntoConstraints = false
        addSubview(presetPageV)
        presetPageV.layer.cornerRadius = 10
        presetPageV.clipsToBounds = true
        presetPageV.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.top.equalTo(titleContainer.snp.bottom).offset(10)
            make.bottom.equalTo(menuBGV.snp.top).offset(-15)
        }
        presetPageV.isHidden = true
        
    }
    
    private func createSettingPageV(){
        
        settingPageV.translatesAutoresizingMaskIntoConstraints = false
        addSubview(settingPageV)
        settingPageV.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.top.equalTo(titleContainer.snp.bottom).offset(10)
            make.bottom.equalTo(menuBGV.snp.top).offset(-15)
        }
        settingPageV.isHidden = true
        
    }
}

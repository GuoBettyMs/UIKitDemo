//
//  BottommenuV.swift
//  SwiftTest
//
//  Created by user on 2026/1/16.
//
//带弹出菜单栏的底部 view

import UIKit
import SnapKit

class BottommenuV: UIView{

    var menuItemTapHandler: ((Int) -> Void)? //点击事件闭包
    
    var menuPreviousIndex = 0 //记录菜单选项旧索引
    var menuBackgroundView = UIView()
    var menuVBtns: [UIButton] = []
    let menuV = UIStackView()
    private let menuitemStr = [NSLocalizedString("ChargeSetting_RegulatedDC", comment: "Regulated DC Power"),
                               NSLocalizedString("ProgrammableDCPower", comment: "Programmable DC Power"),
                               NSLocalizedString("USB_PD", comment: "USB-C PD-SRC"),
                               NSLocalizedString("Charger", comment: "Charger"),
                               NSLocalizedString("EditPresetValues", comment: "Edit Preset Values"),
                               NSLocalizedString("Setting", comment: "Setting"),
                               NSLocalizedString("OperationManual", comment: "User Manual")]
    
    private let menuitemImgVStr = ["DP_RegulatedPower", "DP_ProgrammablePower", "DP_UsbC_SRC", "DP_Charge", "DP_edit", "DP_SettingIcon", "DP_operationManual"]
    
    let remoteControlBtn = UIButton()
    private let titleL = UILabel()
    private let multilingualText = [NSLocalizedString("RequestRomoteControl", comment: "Request Romote Control"),
                                    NSLocalizedString("DisconnectRomoteControl", comment: "Disconnect Romote Control")]
   
    let menuSettingBtn = UIButton()
    let presetValuesBtn = UIButton()
    
    private let items = [
        ("DP_edit", NSLocalizedString("EditPresetValues", comment: "Edit Preset Values")),
        ("DP_ProgrammablePower", NSLocalizedString("ProgrammableDCPower1", comment: "Programmable\nDC Power")),
        ("DP_UsbC_SRC", NSLocalizedString("USB-C\nPD-SRC", comment: "USB-C\nPD-SRC"))
    ]
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        additionalSetup1()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///父视图的布局变化、自身尺寸或约束变化,会调用以下方法
    override func layoutSubviews() {
        super.layoutSubviews()
        
        menuSettingBtn.layer.cornerRadius = menuSettingBtn.bounds.height / 2
        remoteControlBtn.layer.cornerRadius = remoteControlBtn.bounds.height / 2
        
        // 设置阴影路径,避免系统实时计算阴影形状，消耗较多性能
        let shadowPath = UIBezierPath(roundedRect: self.bounds,
                                    byRoundingCorners: [.topLeft, .topRight],
                                    cornerRadii: CGSize(width: 35, height: 35))
        self.layer.shadowPath = shadowPath.cgPath
        
    }

    deinit {
        menuItemTapHandler = nil
        print("BottommenuV invalidate")
    }
    
    // MARK: - Private Methods
    
    private func additionalSetup1(){
        
        self.backgroundColor = .black
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowRadius = 2
        self.layer.shadowOffset = CGSizeMake(0,-2)
        self.layer.shadowOpacity = 0.1
        self.layer.cornerRadius = 35
        self.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner] // 左右上角
        
        menuSettingBtn.translatesAutoresizingMaskIntoConstraints = false
        addSubview(menuSettingBtn)
        menuSettingBtn.snp.makeConstraints { make in
            make.width.equalTo(50)
            make.height.equalTo(50)
            make.left.equalTo(12)
            make.top.equalToSuperview().offset(12)
        }
        menuSettingBtn.backgroundColor = UIColor(named: "DP_181818ff")
        menuSettingBtn.layer.cornerRadius = 25
        menuSettingBtn.setImage(UIImage(named: "DP_menu"), for: .normal)

        addSubview(remoteControlBtn)
        remoteControlBtn.snp.makeConstraints { make in
            make.top.equalTo(menuSettingBtn.snp.top)
            make.bottom.equalTo(menuSettingBtn.snp.bottom)
            make.right.equalToSuperview().offset(-12)
            make.left.equalTo(menuSettingBtn.snp.right).offset(10)
        }
        remoteControlBtn.backgroundColor = UIColor(named: "DP_261900ff")
        remoteControlBtn.layer.borderWidth = 1
        remoteControlBtn.layer.borderColor = UIColor(named: "DP_FFA600")!.cgColor
        remoteControlBtn.layer.cornerRadius = 10
        
        remoteControlBtn.addSubview(titleL)
        titleL.font = UIFont(name: kSourceHanSansCN_Bold, size: 16)
        titleL.textColor = UIColor(named: "DP_FFA600")
        titleL.text = multilingualText[0]
        titleL.textAlignment = UIDevice.current.userInterfaceIdiom == .phone ? .right : .center
        
        let imgV = UIImageView(image: UIImage(named: "DP_remoteConnect")?.withRenderingMode(.alwaysTemplate))
        remoteControlBtn.addSubview(imgV)
        imgV.tintColor = UIColor(named: "DP_FFA600")

        imgV.snp.makeConstraints { make in
            make.left.equalTo(21)
            make.centerY.equalToSuperview()
        }
        
        titleL.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().offset(28)
        }

        
    }

    //创建工作模式选择菜单
    func createMenuV(parentV: UIView){
        
        menuBackgroundView.backgroundColor = .clear
        parentV.addSubview(menuBackgroundView)
        menuBackgroundView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(-90) //底部菜单按钮高度90
        }
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hidePickV))
//        menuBackgroundView.addGestureRecognizer(tapGesture)

        menuBackgroundView.addSubview(menuV)
        menuV.snp.makeConstraints { make in
            make.height.equalTo(menuitemStr.count*(50+2)-2) //菜单栏每项高度50,间距2
            make.width.equalTo(238)
            make.left.equalTo(12)
            make.bottom.equalToSuperview()
        }
        menuV.axis = .vertical
        menuV.spacing = 2
        menuV.distribution = .fillEqually
        menuV.layer.cornerRadius = 10
        menuV.clipsToBounds = true
        menuV.backgroundColor = .white
        menuV.isUserInteractionEnabled = true // 确保 menuV 能够接收触摸事件
        
        for i in 0..<menuitemStr.count{
            let item = UIButton()
            menuV.addArrangedSubview(item)
            item.backgroundColor = i == 0 ? UIColor(named: "DP_d9d9d9ff") : .clear
            item.layer.cornerRadius = 10
            item.layer.borderColor = UIColor.white.cgColor
            item.layer.borderWidth = 2
            // 确保按钮能够接收触摸事件
            item.isUserInteractionEnabled = true
            
            let imgV = UIImageView(image: UIImage(named: menuitemImgVStr[i])?.withRenderingMode(.alwaysTemplate))
            item.addSubview(imgV)
            imgV.snp.makeConstraints { make in
                make.centerX.equalTo(item.snp.left).offset(27)
                make.centerY.equalToSuperview()
            }
            imgV.tintColor = .black//i < 4 ? UIColor(named: "DP_d9d9d9ff") : .black
            
            let label = UILabel()
            item.addSubview(label)
            label.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.left.equalTo(imgV.snp.centerX).offset(21)
            }
            label.textColor = .black//i < 4 ? UIColor(named: "DP_d9d9d9ff") : .black
            label.font = UIFont(name: kSourceHanSansCN_Regular, size: 14)
            label.text = menuitemStr[i]
            
            if i == 3 || i == menuitemStr.count-2 {
                let lineV = UIView()
                item.addSubview(lineV)
                lineV.snp.makeConstraints { make in
                    make.width.equalToSuperview()
                    make.height.equalTo(1)
                    make.centerX.equalToSuperview()
                    make.bottom.equalToSuperview().offset(1)
                }
                lineV.backgroundColor = .black
            }
            
            item.tag = i
            //在 viewcontroll 设置点击事件,初始化时 menuV 未加载无法设 menuVBtns 事件
            item.addTarget(self, action: #selector(menuItemTapped(_:)), for: .touchUpInside)
            menuVBtns.append(item)
        }
    }

    
     //添加菜单项点击事件处理
    @objc private func menuItemTapped(_ sender: UIButton) {
        
        let menuI = sender.tag
        // 防止重复点击
        guard menuPreviousIndex != menuI else { return }
        
        menuItemTapHandler?(menuI)
    }

//    // MARK: - Public Methods
   
    /// 修改菜单选项 ui
    /// - Parameters:
    ///   - selectedI: 选中项,0-Regulated DC Power, 1-Programmable DC Power, 2-USB-C PD-SRC, 3-Charger, 4-edit, 5-Setting, 6-说明书
    func changeMenuItemBgColor(_ selectedI: Int){

        guard selectedI >= 0 && selectedI < menuVBtns.count else {
            return }

        menuVBtns.enumerated().forEach { (index, item) in
            item.backgroundColor = index == selectedI ? UIColor(named: "DP_d9d9d9ff") : .clear
//            
//            guard let imgV = menuVBtns[index].subviews[0] as? UIImageView else {
//                return
//            }
//            
//            guard let label = menuVBtns[index].subviews[1] as? UILabel else {
//                return
//            }
//            
//            imgV.tintColor = index == selectedI ? .black : UIColor(named: "DP_d9d9d9ff")
//            label.textColor = index == selectedI ? .black : UIColor(named: "DP_d9d9d9ff")
//            
        }
        menuPreviousIndex = selectedI
    }
    
    //菜单按钮 ui
    func changeMenuBtnUI(_ isShowMenu: Bool){
        
        menuBackgroundView.isHidden = !isShowMenu
        menuSettingBtn.backgroundColor = isShowMenu ? .white : UIColor(named: "DP_181818ff")
        menuSettingBtn.setImage(UIImage(named: isShowMenu ? "DP_menuSettingShow" : "DP_menu"), for: .normal)
        
    }
    
    //修改远程按钮 ui
    func changeRemoteBtnBgColorandText1(isEnble: Bool){
        remoteControlBtn.backgroundColor = UIColor(named: isEnble ? "DP_FFA600" : "DP_261900ff")
        titleL.text = multilingualText[!isEnble ? 0 : 1]
        titleL.textColor = !isEnble ? UIColor(named: "DP_FFA600") : .black
        
        if let imgV = remoteControlBtn.subviews[1] as? UIImageView {
            imgV.tintColor = UIColor(named: !isEnble ? "DP_FFA600" : "DP_000000ff" )
        }
    }
}

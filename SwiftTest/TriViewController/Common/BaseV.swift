//
//  BaseV.swift
//  SwiftTest
//
//  Created by user on 2024/11/21.
//

import UIKit
import SnapKit

class BaseV: UIView {
    
    let testSlider = UISlider()
    
    let eleV = BatteryV()
    let usbV = UsbV()
    let scrollView = UIScrollView()
    let contentView = UIView()
    let versionL = UILabel()
    let debugB = UIButton()
    lazy var debugUITV = UITextView()
    var isDebugUITVAdded = false
    
    /// - Returns:
    /// 纯代码加载UIView
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI(){

        addSubview(scrollView)
        scrollView.snp.makeConstraints{ make in
            make.edges.equalTo(self.safeAreaLayoutGuide.snp.edges)
        }
//        scrollView.showsVerticalScrollIndicator = false
//        scrollView.delaysContentTouches = false  //当scrollView滑动时, 不执行touch-down 手势
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints{ make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        
//        scrollView.backgroundColor = .red
//        contentView.backgroundColor = .green
//        versionL.backgroundColor = .random()
//        debugB.backgroundColor = .green
    }
    
    func addEleV(){
        contentView.addSubview(eleV)
        eleV.snp.makeConstraints { make in
            make.width.height.equalTo(300)
            make.center.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        eleV.backgroundColor = .clear
    }
    
    func addUsbV(){
        contentView.addSubview(usbV)
        usbV.snp.makeConstraints { make in
            make.width.height.equalTo(300)
            make.center.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        usbV.backgroundColor = .clear
    }
    
    func addTestSlider(){

        contentView.addSubview(testSlider)
        testSlider.snp.makeConstraints { make in
            make.width.equalTo(UIScreen.main.bounds.size.width).multipliedBy(0.8)
            make.height.equalTo(10)
            make.center.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
}



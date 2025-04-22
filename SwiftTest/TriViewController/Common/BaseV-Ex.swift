//
//  BaseV-Ex.swift
//  SwiftTest
//
//  Created by user on 2024/12/13.
//

import UIKit

enum VersionDisplayType {
    case firmwareOnly
    case cyclesOnly
    case both
}

extension BaseV: UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        DispatchQueue.main.async {

            let visibleH = self.safeAreaLayoutGuide.layoutFrame.height//安全区域
            let actualH = self.scrollView.contentSize.height+self.scrollView.contentInset.bottom//contentSize 只表示内容本身的大小,不考虑内边距
            let contentOffsetY = scrollView.contentOffset.y//获取 scrollView 当前偏移量

            self.versionL.isHidden = contentOffsetY + visibleH < actualH// 判断是否滚动到底部

//            Log.debug("self.safeAreaInsets.bottom == 0, versionL.isHidden: \(self.versionL.isHidden) , actualH: \(actualH), visibleH: \(visibleH), contentOffsetY: \(contentOffsetY) ")
        }
        
    }
}
extension BaseV{
    //MARK: 增加版本按钮
    func addVerBtn(){
//         print("addVerBtn called from: \(Thread.callStackSymbols)")
        self.scrollView.delegate = self

        self.addSubview(self.versionL)
        self.versionL.snp.makeConstraints{ make in
            make.height.equalTo(25)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
        }
        self.versionL.textAlignment = .center
        self.versionL.font = UIFont.systemFont(ofSize: 11)
        self.versionL.textColor = .darkText
        self.versionL.isUserInteractionEnabled = true
        self.versionL.text = "\(NSLocalizedString("firmware", comment: "Firmware")): --"
        self.versionL.isAccessibilityElement = true

        self.versionL.addSubview(self.debugB)
        self.debugB.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.width.equalTo(100)
            make.centerX.centerY.equalToSuperview()
        }
        
        DispatchQueue.main.async {
            //versionL 父级不是 scrollView,为 scrollView 增加底部内边距后,可确保 scrollView 滚动范围有包含到 versionL,令视觉上 versionL 能正常显示(实际 versionL 的显示区域是在 scrollView的 底部内边距)
            self.scrollView.contentInset.bottom = self.safeAreaInsets.bottom == 0 ? 34 : self.safeAreaInsets.bottom//全面屏设备(没有 home 键或者 iOS 11 以上), safeAreaInsets.bottom 为34 ;非全面屏设备(有 home 键或者 iOS 11 以下),safeAreaInsets.bottom 为0

            let visibleH = self.safeAreaLayoutGuide.layoutFrame.height//等同于 UIScreen.main.bounds.height-kStatusbarFrameheight-kNavigationFrameheight-safeAreaInsets.bottom
            let actualH = self.scrollView.contentSize.height+self.scrollView.contentInset.bottom//contentSize 只表示内容本身的大小,不考虑内边距
            self.versionL.isHidden = actualH > visibleH

            Log.debug("addVerBtn, actualH: \(actualH), visibleH: \(visibleH)")
        }
    }

    func updateVersionLabel(type: VersionDisplayType, isLocalizedStr: Bool, cycle: String? = nil, ver: String? = nil) {
        switch type {
        case .firmwareOnly:
            guard let ver = ver else { return }
            versionL.text = isLocalizedStr ?
                "\(NSLocalizedString("pb50-firmware", comment: "Firmware")): \(ver)" :
                "固件版本: \(ver)"
                
        case .cyclesOnly:
            guard let cycle = cycle else { return }
            versionL.text = isLocalizedStr ?
                "\(NSLocalizedString("MAG20-Charging Cycles:", comment: "Cycles")): \(cycle)" :
                "循环次数: \(cycle)"
                
        case .both:
            guard let cycle = cycle, let ver = ver else { return }
            versionL.text = isLocalizedStr ?
                "\(NSLocalizedString("MAG20-Charging Cycles:", comment: "Cycles")): \(cycle)   \(NSLocalizedString("pb50-firmware", comment: "Firmware")): \(ver)" :
                "循环次数: \(cycle)   固件版本: \(ver)"
        }
    }
    
    //MARK: 增加调试显示框
    func addDebugUITV(){
        // 防止重复添加
        guard !isDebugUITVAdded else { return }
        isDebugUITVAdded = true
        
        // 确保 versionL 已添加
        guard versionL.superview != nil else {
            print("Warning: versionL not added to view hierarchy")
            return
        }
        
        scrollView.delegate = nil
        debugUITV = addDebugUITextView(addView: contentView, topView: versionL)
        remakeConstraintsDebugUITV(debugUITextViewH: 260)
    }

    func remakeConstraintsDebugUITV(debugUITextViewH: CGFloat){
        
        DispatchQueue.main.async {
            self.scrollView.contentInset.bottom = self.safeAreaInsets.bottom == 0 ? 34+debugUITextViewH : self.safeAreaInsets.bottom+debugUITextViewH
            
            self.versionL.snp.remakeConstraints{ make in
                make.height.equalTo(25)
                make.centerX.equalTo(self.contentView.snp.centerX)
                make.top.equalTo(self.contentView.snp.bottom)
            }
            
//            Log.debug("remakeConstraintsDebugUITV,  contentInset.bottom : \(self.scrollView.contentInset.bottom)")
        }
    }

    func removeDebugUITV() {
        debugUITV.removeFromSuperview()
        isDebugUITVAdded = false
        scrollView.contentInset.bottom = safeAreaInsets.bottom == 0 ? 34 : safeAreaInsets.bottom
        
        scrollView.delegate = self
        versionL.snp.remakeConstraints{ make in
            make.height.equalTo(25)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
        }
        
    }

    func showDebugUITVText(_ string: String){
        debugUITV.text = string
    }
}


//
//  UsbV-Ex.swift
//  Polylink
//
//  Created by user on 2024/12/13.
//

import UIKit

extension UsbV{
    
    //MARK: 更新 usb 时间
    func updateUsbTime(_ text: String, isLocalizedStr: Bool = true){
        chargetimeL.text = text
//        chargetimeL.accessibilityLabel = isLocalizedStr ? "充电时长是"+(text) : "充电时长是"+(text)
    }
    
    //MARK: 更新 usb 数据
    func updateUsbData(_ v: Int, _ c: Int, _ p: Int, a: Int,_ protocolName: String, isLocalizedStr: Bool = true){

        let volStr = MathUtil.format(double:  Double(abs(v + 4))/1000.0, decimalPlaces: a)+"V"
        let curStr = MathUtil.format(double:  Double(abs(c + 4))/1000.0, decimalPlaces: a)+"A"
        let powStr = MathUtil.format(double:  Double(abs(p + 4))/1000.0, decimalPlaces: a)+"W"
        currentValues = (
            v: v != 0 ? volStr : "",
            c: c != 0 ? curStr : "",
            p: p != 0 ? powStr : ""
        )
        currentProtocol = protocolName
 
        usbL.text = "\(currentValues.v) \(currentValues.c) \(currentValues.p) \(currentProtocol)"
        
        updateAccessibilityLabel(isLocalizedStr: isLocalizedStr)
    }
    
    //MARK: 更新 usb 状态
    func updateUsbImg(_ usbType: Int, isLocalizedStr: Bool = true){
        
        usbImgV.image = UIImage(named: usbImgStrArr[0][usbType])
        usbTitleL.text = isLocalizedStr ? usbImgStrArr[1][usbType] : usbStatus[usbType]
        updateAccessibilityLabel(isLocalizedStr: isLocalizedStr)
    }

    //MARK: 无障碍文本
    private func updateAccessibilityLabel(isLocalizedStr: Bool = true) {

        var accessibilityComponents: [String] = []
        
        if !currentValues.v.isEmpty {
            accessibilityComponents.append(currentValues.v.replacingOccurrences(of: "V", with: isLocalizedStr ? NSLocalizedString("V", comment: "伏") : "伏"))
        }
        if !currentValues.c.isEmpty {
            accessibilityComponents.append(currentValues.c.replacingOccurrences(of: "A", with: isLocalizedStr ? NSLocalizedString("A", comment: "安") : "安"))
        }
        if !currentValues.p.isEmpty {
            accessibilityComponents.append(currentValues.p.replacingOccurrences(of: "W", with:isLocalizedStr ? NSLocalizedString("W", comment: "瓦") : "瓦"))
        }
        
        let valuesText = accessibilityComponents.isEmpty ? "" : accessibilityComponents.joined(separator: " ")
        let protocolPrefix = isLocalizedStr ? NSLocalizedString("protocol", comment: "Protocol") : "协议"
        let protocolText = currentProtocol.isEmpty ? "" : "，\(protocolPrefix)：\(currentProtocol)"
        let currentUsbStatus = usbTitleL.text
        self.accessibilityLabel = "USB\(String(describing: currentUsbStatus))\(valuesText.isEmpty ? "" : "，\(valuesText)")\(protocolText)"

    }
}

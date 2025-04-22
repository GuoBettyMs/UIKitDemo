//
//  BatteryV.swift
//  Polylink
//
//  Created by user on 2024/12/13.
//

import UIKit
import SnapKit

class BatteryV: UIView{
    
    let eleL = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        additionalSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func additionalSetup(){

        addSubview(eleL)
        eleL.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        eleL.text = "100%"
        
        eleL.isAccessibilityElement = false
        self.isAccessibilityElement = true
        self.accessibilityLabel = "当前电量是100%"
    }
    
    func updateBatteryCapacityData(per: Int, isLocalizedStr: Bool = true){
        eleL.text = "\(per)%"
        updateAccessibilityLabel(isLocalizedStr: isLocalizedStr)
    }
    
    private func updateAccessibilityLabel(isLocalizedStr: Bool = true) {
        guard let text = eleL.text?.replacingOccurrences(of: "%", with: ""), !text.isEmpty else {
            self.accessibilityLabel = ""
            return
        }
        
        let prefix = !isLocalizedStr ?
            NSLocalizedString("CurrentPower", comment: "The current power is") :
            "当前电量是"
            
        let suffix = !isLocalizedStr ?
            NSLocalizedString("Percent", comment: "percent") :
            "%"
            
        self.accessibilityLabel = prefix + text + suffix
    }
}

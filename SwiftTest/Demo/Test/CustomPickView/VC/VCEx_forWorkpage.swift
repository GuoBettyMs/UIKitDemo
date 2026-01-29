//
//  VCEx_forWorkpage.swift
//  SwiftTest
//
//  Created by user on 2026/1/23.
//

import UIKit

//MARK: -  主页处理扩展
extension CustomPickViewVC {

    //MARK: 主页滑杆
    func sliderEvent(){
        //只监听松手事件
        container.precisionSlider.addTarget(self, action: #selector(presicionSliderTouchDown), for: .touchDown)
        container.precisionSlider.addTarget(self, action: #selector(presicionSliderTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    @objc private func presicionSliderTouchDown() {
        triggerSelectionVibration()
    }

    
    @objc private func presicionSliderTouchUp(_ sender: UISlider) {
        let x = sender.value
        let target: Int = (x < 0.5) ? 0 : (x < 1.5) ? 1 : 2
            
        sender.value = Float(target)//在松手时直接设值
        
        container.updateProgress(currentValue: target)
      
        triggerImpactVibration()
    }
    
    //MARK: 主页设定按钮
    func setBtnEvent(){
        
        //设置滚轮的自定义代理
        container.pickV.delegate = self
        
        //设置文本框的自定义代理
        container.numberKeyboardV.delegate = self
        container.textfield.delegate = self

        
        for pickV_tag in 0...1{
            //VC 通过 container 持有 DP3005BarandSetV 的强引用,引用链为： vc（强）→ container（强）→ pickVandNumberKeyboard（强）→ setpickBGVs（强）→ pickBGV（数组元素，强持有）
            
            //设置按钮事件
            container.setBtns[pickV_tag].rx.tap
                .subscribe(onNext: { [weak self] _ in
                    guard let selfs = self else { return }
                   
                        if !selfs.model.isOutputSetOpen{
                            selfs.model.isOutputSetOpen = true
                            selfs.container.showTimeandEnergyV1(isShow: false)
                        }
                        
                        if selfs.model.setBtnClickedI == pickV_tag{
                            Log.debug(" \(pickV_tag) is cliked, 不再显示 showSettingV ")
                            return
                        }
                        
                        //保存当前设定类型, true 是设定电压, false 设定电流
                        selfs.model.isOutputVolSet = pickV_tag == 0

//                        Log.debug("is OutputVol Set= \(selfs.model.isOutputVolSet)")

                        selfs.container.showSettingV(isVolSetting: selfs.model.isOutputVolSet)
                        selfs.container.swithcSetType(isVolSetting: selfs.model.isOutputVolSet, setType: selfs.model.isOutputVolSet ? selfs.model.currentVolSettype : selfs.model.currentCurSettype)
                        
                        DispatchQueue.main.async {
                            selfs.container.layoutIfNeeded() // 确保 pickV frame 已确定
                            
                            let targetValue = selfs.model.isOutputVolSet
                                ? Double(selfs.container.setBtns[0].getSetvalue()) ?? 0
                                : Double(selfs.container.setBtns[1].getSetvalue()) ?? 0
                            
                            selfs.container.pickV.currentValue = targetValue
                            
                            selfs.container.pickV.maxValue = selfs.model.isOutputVolSet ? 30.50 : 5.100
                            
                            switch pickV_tag{
                            case 0:
                                Log.debug("current Vol Set type(0-键盘, 1-滚轮)= \(selfs.model.currentVolSettype), vol Realtime Status= \(selfs.model.volRealtimeStatus)")
                                
                                if selfs.model.currentVolSettype == 0 {
                                    //更新数字键盘 ui
                                    selfs.updateKeyboardState(for: selfs.container.textfield.text ?? "")
                                }else if selfs.model.currentVolSettype == 1{
                                    //更新滚轮实时按钮 ui
                                    selfs.container.updateRealtimeBtnUI(isReal: selfs.model.volRealtimeStatus)
                                }
                                
                            case 1:
                                Log.debug("current Cur Set type(0-键盘, 1-滚轮)= \(selfs.model.currentCurSettype), cur Realtime Status= \(selfs.model.curRealtimeStatus)")
                                
                                if selfs.model.currentCurSettype == 0 {
                                    //更新数字键盘 ui
                                    selfs.updateKeyboardState(for: selfs.container.textfield.text ?? "")
                                }else if selfs.model.currentCurSettype == 1{
                                    //更新滚轮实时按钮 ui
                                    selfs.container.updateRealtimeBtnUI(isReal: selfs.model.curRealtimeStatus)
                                }
                            default:
                                break
                            }
                        }
                        selfs.model.setBtnClickedI = pickV_tag
         
                    
                }).disposed(by: disposedBag)
        
        }
        
        
        //切换设置模式的按钮事件
        container.switchSetmodeBtn.rx.tap
            .subscribe(onNext: { [weak self] _ in
                //[weak self] 捕获 DP3005VC 实例（self），避免了闭包对 DP3005VC 的强引用，后续调用 selfs.container 也不会产生新的强引用链。
                guard let selfs = self else { return }

                if selfs.model.isOutputVolSet {
//                    Log.debug("vol Setting Mode(0-键盘, 1-滚轮): \(selfs.model.currentVolSettype)")
                    
                    selfs.model.currentVolSettype = selfs.model.currentVolSettype == 0 ? 1 : 0
                    
                    selfs.container.swithcSetType(isVolSetting: true, setType: selfs.model.currentVolSettype)
                    
                    if selfs.model.currentVolSettype == 0 {
//                        Log.debug("更新数字键盘 ui")
                        selfs.updateKeyboardState(for: selfs.container.textfield.text ?? "")
                    }else if selfs.model.currentVolSettype == 1{
//                        Log.debug("更新滚轮实时按钮 ui")
                        selfs.container.updateRealtimeBtnUI(isReal: selfs.model.volRealtimeStatus)
                    }
                    
                }else{
                    Log.debug("cur Setting Mode(0-键盘, 1-滚轮): \(selfs.model.currentCurSettype)")
                    
                    selfs.model.currentCurSettype = selfs.model.currentCurSettype == 0 ? 1 : 0
                    
                    selfs.container.swithcSetType(isVolSetting: false, setType: selfs.model.currentCurSettype)
                    //更新数字键盘 ui
                    if selfs.model.currentCurSettype == 0 {
                        selfs.updateKeyboardState(for: selfs.container.textfield.text ?? "")
                    }else if selfs.model.currentCurSettype == 1{
                        //更新滚轮实时按钮 ui
                        selfs.container.updateRealtimeBtnUI(isReal: selfs.model.curRealtimeStatus)
                    }
                }

            }).disposed(by: disposedBag)
        
        
        //滚轮模式,设置电压或电流实时更改
        container.realtimeChangesBtn.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let selfs = self else { return }
                
                //bit0电压 bit1电流 0:关闭 1:开启
                var realtimeChangesArr: [Int8] = CustomBitTool.splitToBits(selfs.model.remoteConnectSettingArr_new[3])
                
                if selfs.model.isOutputVolSet {
                    selfs.model.volRealtimeStatus = !selfs.model.volRealtimeStatus
                    realtimeChangesArr[0] = selfs.model.volRealtimeStatus ? 1 : 0

                }else{
                    selfs.model.curRealtimeStatus = !selfs.model.curRealtimeStatus
                    realtimeChangesArr[1] = selfs.model.curRealtimeStatus ? 1 : 0

                }
                
                let data = CustomBitTool.combineBits(realtimeChangesArr)
                
                Log.debug(" realtimeChanges result: \(CustomBitTool.splitToBits(selfs.model.remoteConnectSettingArr_new[3])) update to  \(realtimeChangesArr), newdata: \(data)")
//
//                selfs.sendRemoteControldata(at: 3, data)
                selfs.container.updateRealtimeBtnUI(isReal: selfs.model.isOutputVolSet ? realtimeChangesArr[0]==1 : realtimeChangesArr[1]==1)

            }).disposed(by: disposedBag)
        
        //滚轮模式,收起滚轮
        container.pickHiddenBtn.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let selfs = self else { return }
                
                selfs.model.setBtnClickedI = -1
                selfs.container.recoverSetBtnMaskedCorners(isVolSetting: selfs.model.isOutputVolSet)
                
                selfs.model.isOutputSetOpen = false
                selfs.container.showTimeandEnergyV1(isShow: true)

            }).disposed(by: disposedBag)
        
        
        //电压缓升按钮状态
        container.rampAndRealBtn.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let selfs = self else { return }
                
                selfs.container.rampAndRealBtn.isSelected = !selfs.container.rampAndRealBtn.isSelected
                
                let data = selfs.container.rampAndRealBtn.isSelected ? 1 : 0
                Log.debug("缓升按钮(0:关闭,正弦波 1:开启): \(data)")
                //selfs.sendRemoteControldata(at: 4, data)

            }).disposed(by: disposedBag)

        //滚轮一键确认事件
        container.pickConfirmBtn.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let selfs = self else { return }
                
                //一键确认发送命令
                if selfs.model.isOutputVolSet {
                    if !selfs.model.volRealtimeStatus {
                        
                        let data = round(selfs.model.data_v * 100)
                        Log.debug("执行发送命令,电压一键设定数值: \(selfs.model.dataVArr_new) = \(selfs.model.data_v)V = \(data) * 10mV, \(Int(data))")
                        //selfs.sendRemoteControldata(at: 1, Int(data))
                        
                        selfs.container.setBtns[0].setValueText("\(selfs.model.data_v.formattedWithLeadingZero())")
                    }
                }else{
                    if !selfs.model.curRealtimeStatus {
                        let data = round(selfs.model.data_i * 1000)
                        Log.debug("执行发送命令,电流设定数值:  = \(selfs.model.dataIArr_new) = \(selfs.model.data_i)A = \(data)mA, \(Int(data))")
                        //selfs.sendRemoteControldata(at: 2, Int(data))
                        
                        selfs.container.setBtns[1].setValueText("\(selfs.model.data_i.formatted(decimalPlaces: 3))")
                    }
                }
                
            }).disposed(by: disposedBag)
    }
    
    
}

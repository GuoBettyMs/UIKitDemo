//
//  VCEx_forBottomMenu.swift
//  SwiftTest
//
//  Created by user on 2026/1/16.
//

import UIKit

//MARK: - 菜单栏处理扩展
extension CustomPickViewVC {
 
    func bottomMenuEvent(){
        
        programmablepageListControlEvent1()
        chargepageRemoteControlEvent1()
        presetPageUpLoadEvent()
        settingpageEvent()
        
        //菜单键点击事件处理
        container.menuBGV.menuSettingBtn.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let selfs = self else { return }

                if !selfs.model.isMenuVCreate {
                    
                    selfs.container.menuBGV.createMenuV(parentV: selfs.view)
                    selfs.container.menuBGV.changeMenuBtnUI(true)
                    //刷新菜单选项
                    selfs.container.menuBGV.changeMenuItemBgColor(selfs.currentPage.index)
                    
                    selfs.model.isShowWorkmodeMenu = true
                    selfs.model.isMenuVCreate = true
                    
//                    Log.debug("MenuV  Create, 菜单选项=\(selfs.currentPage.index)")
                } else {
                    
                    selfs.model.isShowWorkmodeMenu = !selfs.model.isShowWorkmodeMenu
                    selfs.container.menuBGV.changeMenuBtnUI(selfs.model.isShowWorkmodeMenu)
                    //刷新菜单选项
                    selfs.container.menuBGV.changeMenuItemBgColor(selfs.currentPage.index)
                    
//                    Log.debug("MenuV show staus: \(selfs.model.isShowWorkmodeMenu), 菜单选项=\(selfs.currentPage.index) ")
                }
                
            }).disposed(by: disposedBag)
        
        //菜单选项点击事件
        container.menuBGV.menuItemTapHandler = { [weak self] menuI in
            guard let self = self else { return }
            
            Log.debug("菜单项 \(menuI) 被点击")
            ////0-Regulated DC Power, 1-Programmable DC Power, 2-USB-C PD-SRC, 3-Charger, 4-Setting
            switch menuI{
            case 0:
                showRegulatedModePge()
            case 1:
                showProgrammableModePge()
            case 2:
                showUSBModePge()
            case 3: //可展开的 tableview
                showChargerModePge()
            case 4:
                showPresetModePage()
            case 5:
                showSettingModePage()
            case 6:
                showUserManual()
            default:
                break
            }
            
        }
        
        //远程连接请求按钮事件
        container.menuBGV.remoteControlBtn.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let selfs = self else { return }

                // ✅ 添加防重复点击
                guard !selfs.model.isShowingRemoteControlAlert else {
                     Log.debug("远程控制弹窗已在显示中，忽略点击")
                     return
                 }
                selfs.container.menuBGV.remoteControlBtn.isSelected = !selfs.container.menuBGV.remoteControlBtn.isSelected
                let status = selfs.container.menuBGV.remoteControlBtn.isSelected
                selfs.presentRemoteControlAlert(status: status)
                
            }).disposed(by: disposedBag)
    }
    
    //MARK: 远程连接按钮
    //工作区页面远程连接按钮 ui
    private func updateRemoteBtnUI(_ status: Bool){
        
        DispatchQueue.main.async { [weak self] in
            guard let selfs = self else { return }
            
            //设置控制按钮 ui
            selfs.container.menuBGV.changeRemoteBtnBgColorandText1(isEnble: status)
            
            //可能手动在设备断开连接,修改菜单栏 ui
            //刷新菜单选项
            selfs.container.menuBGV.changeMenuItemBgColor(selfs.currentPage.index)

            if !status && selfs.model.isOutputSetOpen {
                //收起设定
                selfs.model.setBtnClickedI = -1
                selfs.container.recoverSetBtnMaskedCorners(isVolSetting: selfs.model.isOutputVolSet)
                selfs.model.isOutputSetOpen = false
                selfs.container.showTimeandEnergyV1(isShow: true)

            }

//            Log.debug(" model.remoteStatus:\( status), currentPage: \(selfs.currentPage)")
            
            if let remoteControlAlert = selfs.currentRemoteControlAlert, remoteControlAlert.isBeingPresented || selfs.presentedViewController == remoteControlAlert {
                
                remoteControlAlert.dismiss(animated: false, completion: nil) //关闭弹窗
                selfs.model.isShowingRemoteControlAlert = false
            }
            
        }
    }
    private func presentRemoteControlAlert(status: Bool) {
       
        // 重置取消标志
        model.isRemoteControlCancelled = false
        
        // 每次新建
        let alert = UIAlertController(
            title: status ? "等待设备确认远程控制" : "等待设备关闭远程控制",
            message: nil,
            preferredStyle: .alert
        )
            
        // 可添加取消按钮（用于手动关闭）
        alert.addAction(UIAlertAction(title: "取消", style: .cancel) { [weak self] _ in

            Log.debug("取消远程控制请求")
            // 1. 设置取消标志
            self?.model.isRemoteControlCancelled = true
            
            self?.resetRemoteControlState()
            
            alert.dismiss(animated: false) {
                self?.updateRemoteBtnUI(false)
            }
        })
            
        if #available(iOS 13.0, *) {
            alert.overrideUserInterfaceStyle = .unspecified
        } else {
            // Fallback on earlier versions
        }
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = view.bounds
            popover.permittedArrowDirections = .any
        }

        // 设置状态
        model.isShowingRemoteControlAlert = true
            
        startRemoteControlTimeout(for: alert)
        present(alert, animated: false, completion: {
            // 创建可取消的 work item
            let delayedWorkItem = DispatchWorkItem { [weak self] in
                guard let self = self,
                      !self.model.isRemoteControlCancelled,
                      self.currentRemoteControlAlert == alert // 确保是当前弹窗
                else {
                    Log.debug("已取消或弹窗已关闭远程控制请求")
                    return
                }

                if self.currentPage == .workpage || self.currentPage == .programmablepage
                    || self.currentPage == .pDOpage || self.currentPage == .chargepage {
                    
                    self.updateRemoteBtnUI(status)
                } else {
                    alert.dismiss(animated: false)
                    self.resetRemoteControlState()
                }
            }

            // 保存以便后续取消
            self.remoteControlDelayedUpdateWorkItem = delayedWorkItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: delayedWorkItem)
        })
    }

    private func startRemoteControlTimeout(for alert: UIAlertController) {
        
        // 取消上一个工作块
        remoteControlTimeoutWorkItem?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self,
                  !self.model.isRemoteControlCancelled,  // 检查取消标志
                  self.currentRemoteControlAlert == alert // 确保是当前 alert
            else { return }
            
            Log.debug("远程控制请求超时")
            alert.dismiss(animated: true) { // 关闭弹窗
                self.showTimeoutAlert()
                self.resetRemoteControlState()// 重置状态
                self.updateRemoteBtnUI(false)
            }
        }
        
        remoteControlTimeoutWorkItem = workItem
        currentRemoteControlAlert = alert
        
        DispatchQueue.main.asyncAfter(deadline: .now() + model.remoteControlTimeout, execute: workItem)// 10秒后执行超时任务
        
    }
    // 重置状态
    private func resetRemoteControlState() {
       
        model.isRemoteControlCancelled = true
        remoteControlTimeoutWorkItem?.cancel()
        remoteControlDelayedUpdateWorkItem?.cancel()

        remoteControlTimeoutWorkItem = nil
        remoteControlDelayedUpdateWorkItem = nil
        currentRemoteControlAlert = nil
        model.isShowingRemoteControlAlert = false
        
    }
    
    private func showTimeoutAlert() {
        let alert = UIAlertController(title: "请求超时",
                                    message: "设备未响应，请检查连接后重试",
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    

    
    //MARK: 工作模式菜单事件
    
    func showRegulatedModePge(){
    
        switch currentPage {
        case .programmablepage:
            self.container.turnToProgrammablePageV(isShow: false, oldModeI: 0)

        case .chargepage:
            self.container.turnToChargePageV(isShow: false, oldModeI: 0)

        case .programHomepage_presetvalue:
            self.container.turnToPresetPageV(isShow: false, oldModeI: 0)
//
//        case .programEditpage_presetvalue:
//            self.container.connectpageSwitchtoPresetpage(isShow: false)
//            model.workStatus.currentMode = workingpage.index
//
//        case .usbHomepage_presetvalue:
//            self.container.connectpageSwitchtoPresetpage(isShow: false)
//            model.workStatus.currentMode = workingpage.index
//
//        case .usbEditpage_presetvalue:
//            self.container.connectpageSwitchtoPresetpage(isShow: false)
//            model.workStatus.currentMode = workingpage.index
//
        case .settingHomepage:
            self.container.turnToSettingPageV(isShow: false, oldModeI: 0)
//
//        case .settingEditpage:
//            self.container.connectpageSwitchtoSettingpage(isShow: false)
//            model.workStatus.currentMode = workingpage.index

        default:
            break

        }

        previousPage = currentPage
        currentPage = .workpage
        workingpage = .workpage
        container.titleContainer.setTitle(NSLocalizedString("ChargeSetting_RegulatedDC", comment: "Regulated DC Power"))

//        Log.debug("page \(previousPage) turn to \(currentPage)")
        container.menuBGV.changeMenuItemBgColor(0)
        model.isShowWorkmodeMenu = false
        container.menuBGV.changeMenuBtnUI(false)
    }
    
    func showProgrammableModePge(){
        
        switch currentPage {
        case .workpage,
                .chargepage,
                .programHomepage_presetvalue:
            container.turnToProgrammablePageV(isShow: true, oldModeI: currentPage.index)
            workingpage = currentPage
            
        case .settingHomepage:
            container.turnToProgrammablePageV(isShow: true, oldModeI: currentPage.index)

        default: break
        }

        previousPage = currentPage
        self.currentPage = .programmablepage
        self.workingpage = .programmablepage
        self.container.titleContainer.setTitle(NSLocalizedString("ProgrammableDCPower", comment: "Programmable\nDC Power"))

        //预防首次查询时,解析出错导致数据为空
        if model.initialProgrammablePageDatas.isEmpty {
            Log.debug("首次加载《可编程列表》全部行")

            loadProgrammablePageDataArr()
        }else{
            Log.debug("重新加载《可编程列表》全部行")
            model.initialProgrammablePageDatas = []
            loadProgrammablePageDataArr()
        }
//        Log.debug("page \(previousPage) turn to \(currentPage)")
        
        container.menuBGV.changeMenuItemBgColor(1)
        model.isShowWorkmodeMenu = false
        container.menuBGV.changeMenuBtnUI(false)
    }
    
    func showUSBModePge(){
        
//        switch currentPage {
//        case .workpage:
//            self.container.workpageTurntoOtherMode1(newModeI: 2)
//
//        case .programmablepage:
//            self.container.programpageSwitchtoPDOMode1(currentmodeI: 2)
//
//        case .chargepage:
//            self.container.chargeModeSwitchtoOtherpage(newModeI: 2)
//
//
//        case .programHomepage_presetvalue,
//                .usbHomepage_presetvalue,
//                .programEditpage_presetvalue,
//                .usbEditpage_presetvalue:
//            if previousPage == .programmablepage || previousPage == .pDOpage{
//                //恢复原状
//                self.container.restoreToWorkingmode1(oldModeI: previousPage == .programmablepage ? 1 : 2)
//            }
//            self.container.connectpageSwitchtoPresetpage(isShow: false)
//            self.container.workpageTurntoOtherMode1(newModeI: 2)
//
//        case .settingHomepage:
//            if previousPage == .programmablepage || previousPage == .pDOpage{
//                //恢复原状
//                self.container.restoreToWorkingmode1(oldModeI: previousPage == .programmablepage ? 1 : 2)
//            }
//            self.container.connectpageSwitchtoSettingpage(isShow: false)
//            self.container.workpageTurntoOtherMode1(newModeI: 2)
//
//        default: break
//        }
//
//        previousPage = currentPage
//        self.currentPage = .pDOpage
//        self.workingpage = .pDOpage
//        self.container.titleContainer.setTitle(NSLocalizedString("USB-C PD-SRC", comment: "USB-C PD-SRC"))
//
//        model.pDOworkStatus.currentMode = 2
//        //当前可编程数据/ PDO 数据读取
//        let setRequest = SettingItemsReq()
//        setRequest.cmd = 0xE4
//        kBleManager.packOnlyOnceMap[UInt8(0xE5)] = setRequest
//
//        if previousPage != .programmablepage {
//            //当前可编程工作/ SRC 模式状态查询
//            let workReq = SettingItemsReq()
//            workReq.cmd = 0xDE
//            kBleManager.packCycleList.append((workReq))
//        }
//
//        Log.debug("page \(previousPage) turn to \(currentPage), 切换到 PDO 页面")
//
//        container.menuBGV.changeMenuItemBgColor(2)
//        model.isShowWorkmodeMenu = false
//        container.changeMenuBtnUI(false, currentPage: currentPage)
    }
    
    func showChargerModePge(){
        
        switch currentPage {
        case .workpage,
                .programmablepage,
                .programHomepage_presetvalue:
            container.turnToChargePageV(isShow: true, oldModeI: currentPage.index)
            workingpage = currentPage

        case .settingHomepage:
            container.turnToChargePageV(isShow: true, oldModeI: currentPage.index)
            
        default: break
        }
        
        previousPage = currentPage
        self.currentPage = .chargepage
        self.workingpage = .chargepage
        self.container.titleContainer.setTitle(NSLocalizedString("Charger", comment: "Charger"))

//        Log.debug("page \(previousPage) turn to \(currentPage)")

        container.menuBGV.changeMenuItemBgColor(3)
        model.isShowWorkmodeMenu = false
        container.menuBGV.changeMenuBtnUI(false)
    }
    
    //显示预设值页面
    func showPresetModePage(){

        switch currentPage {
        case .workpage,
                .programmablepage,
                .chargepage:
            container.turnToPresetPageV(isShow: true, oldModeI: currentPage.index)
            workingpage = currentPage

        case .settingHomepage:
            self.container.turnToPresetPageV(isShow: true, oldModeI: currentPage.index)
        default: break
        }

        previousPage = currentPage
        currentPage = .programHomepage_presetvalue
        container.titleContainer.setTitle(NSLocalizedString("EditPresetValues", comment: "Edit Preset Values"))

        //预防首次查询时,解析出错导致数据为空
        if model.initialPresetListDatas.isEmpty {
            Log.debug("首次加载《预设值列表》全部行")
            loadPresetPageDataArr()
        }else{
            Log.debug("重新加载《预设值列表》全部行")
            model.initialPresetListDatas = []
            loadPresetPageDataArr()
        }

//        Log.debug("page \(previousPage) turn to \(currentPage)")

        container.menuBGV.changeMenuItemBgColor(4)
        model.isShowWorkmodeMenu = false
        container.menuBGV.changeMenuBtnUI(false)
    }
    
    //显示系统设置页面
    func showSettingModePage(){

        switch currentPage {
        case .workpage,
                .programmablepage,
                .chargepage:
            container.turnToSettingPageV(isShow: true, oldModeI: currentPage.index)
            workingpage = currentPage

        case .programHomepage_presetvalue:
            self.container.turnToSettingPageV(isShow: true, oldModeI: currentPage.index)
        default: break
        }

        previousPage = currentPage
        currentPage = .settingHomepage
        container.titleContainer.setTitle(NSLocalizedString("Setting", comment: "Setting"))

        loadSettingDataArr()
            
//        Log.debug("page \(previousPage) turn to \(currentPage)")

        container.menuBGV.changeMenuItemBgColor(5)
        model.isShowWorkmodeMenu = false
        container.menuBGV.changeMenuBtnUI(false)
    }
    
    //显示说明书链接
    private func showUserManual(){
        
//        changeMenuItemBgColor(6)
//        isShowWorkmodeMenu = false
//        menuBackgroundView.isHidden = true

        Log.debug("show User Manual")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            //默认浏览器(如 safari )打开链接
            UIApplication.shared.open(URL(string: "https://isdt.co/down/pdf/MP305.pdf")!)
        })
       

    }
}

//
//  CustomPickViewVC.swift
//  SwiftTest
//
//  Created by user on 2026/1/16.
//

import Foundation
import UIKit

extension CustomPickViewVC: SettingPageViewDelegate{
    
    func settingPageView(_ view: SettingPageV, didUpdateValue value: Int, at dataIndex: Int) {
        
        model.setParameterArr_new[dataIndex] = value
        model.setParameterArr_origin = model.setParameterArr_new
    }
     
}

class CustomPickViewVC: TestBaseVC<PickVandNumberKeyboard>{

    let model = CustomPickViewM()
    var onDismiss: (() -> Void)?//定义返回回调闭包
    
    var workingpage = CustomPickviewPageIndex.workpage//有远程功能的页面
    var previousPage = CustomPickviewPageIndex.workpage
    var currentPage = CustomPickviewPageIndex.workpage

    var remoteControlDelayedUpdateWorkItem: DispatchWorkItem?
    var remoteControlTimeoutWorkItem: DispatchWorkItem?
    var currentRemoteControlAlert: UIAlertController? //当前远程控制请求提示框
    
    var keyboardHeight: CGFloat = 0 //可编程或者预设值页面编辑文本框时,弹出的软键盘高度
    
    var activeTextField: UITextField? //可编程页面的活跃的文本框
    var presetSublistActiveTextField: UITextField?//预设值页面活跃的文本框

    
    //MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        events()

        
    }
    
    
    deinit {
        // 移除监听
        model.presetEditstateObservers.forEach { observer in
            NotificationCenter.default.removeObserver(observer)
        }
        
        NotificationCenter.default.removeObserver(self)
        
        if remoteControlTimeoutWorkItem != nil {
            remoteControlTimeoutWorkItem?.cancel()
            remoteControlTimeoutWorkItem = nil
        }

        print("CustomPickViewVC 被释放") // 确认是否调用
    }
    
    //MARK: -
    private func initUI(){
        //隐藏自身导航栏
        navigationController?.navigationBar.isHidden = true
       
        if let window = UIApplication.shared.windows.first {
            if #available(iOS 13.0, *) {
                window.overrideUserInterfaceStyle = .dark
            } else {
            }
        }
        view.backgroundColor = UIColor(named: "DP_0d0d0dff")
        //允许设置页面断联时,仍支持退回到主页
        self.container.isUserInteractionEnabled = true
        self.container.titleContainer.backBtn.isUserInteractionEnabled = true

    }
    
    private func events(){
        
        naviEvent1()
        
        sliderEvent()
        setBtnEvent()
        
        bottomMenuEvent()
        
        setupKeyboardObservers() //监听非标题文本框的软键盘
        setupPresetSubListEditStateObservation() //监听预设值《次列表》所有单元格的编辑状态变化
        setupPresetListEditStateObservation()
        
    }
    
    //MARK: -
    //监听可编程页面的非标题文本框的软键盘
    func setupKeyboardObservers() {
        let notifications = [
            UIResponder.keyboardWillShowNotification,
            UIResponder.keyboardWillHideNotification,
            UIResponder.keyboardWillChangeFrameNotification
        ]
        
        notifications.forEach { name in
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleKeyboardNotification(_:)),
                name: name,
                object: nil
            )
        }
    }
    
    @objc private func handleKeyboardNotification(_ notification: Notification) {
        
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }
            
        let isShowing = notification.name == UIResponder.keyboardWillShowNotification
        let isChanging = notification.name == UIResponder.keyboardWillChangeFrameNotification
        
        if isShowing || isChanging {
            
            keyboardHeight = keyboardFrame.height
            adjustForKeyboard1()
        } else {
//            Log.debug("恢复 scrollView.contentInset ")
            keyboardHeight = 0
            let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            
            if currentPage == .programmablepage {
                container.programmablePageV.scrollView.contentInset = insets
                container.programmablePageV.scrollView.scrollIndicatorInsets = insets
                
            }else if currentPage == .programEditpage_presetvalue{
                container.presetPageV.sublistScrollView.contentInset = insets
                container.presetPageV.sublistScrollView.scrollIndicatorInsets = insets
            }
            
        }
        
        // 动画同步
        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve), animations: {
            self.view.layoutIfNeeded()
        })
        
    }
    
    //自动调整文本框位置到软键盘上方
    private func adjustForKeyboard1() {
        
        //scrollView 底部不与屏幕底部对齐, 调整 contentInset 时要 scrollView 底部与屏幕底部的约束差  (底部菜单栏高度 90)
        let offsetH = 90
        
        if currentPage == .programmablepage {
            
            // 如果有活跃的文本框，滚动 scrollview  令活跃的文本框处于可见位置
            if let textField = activeTextField {
                
                container.programmablePageV.scrollView.contentInset = UIEdgeInsets(
                    top: 0,
                    left: 0,
                    bottom: keyboardHeight - CGFloat(offsetH) - 35,//软键盘自定义的工具栏高度35
                    right: 0
                )
                
                container.programmablePageV.scrollView.scrollIndicatorInsets = container.programmablePageV.scrollView.contentInset
                
//                Log.debug("adjustForKeyboard1 - programEditpage_presetvalue,  keyboardHeight= \(keyboardHeight), bottom= \(keyboardHeight - CGFloat(offsetH) + 0)")
                
                let textFieldFrame = textField.convert(textField.bounds, to: container.programmablePageV.contentView)
                container.programmablePageV.scrollView.scrollRectToVisible(textFieldFrame, animated: true)
            }
        }else if  currentPage == .programEditpage_presetvalue {
            // 如果有活跃的文本框，滚动 scrollview  令活跃的文本框处于可见位置
            if let textField = presetSublistActiveTextField {

                container.presetPageV.sublistScrollView.contentInset = UIEdgeInsets(
                    top: 0,
                    left: 0,
                    bottom: keyboardHeight - CGFloat(offsetH) - 35,
                    right: 0
                )

                container.presetPageV.sublistScrollView.scrollIndicatorInsets = container.presetPageV.sublistScrollView.contentInset

                let textFieldFrame = textField.convert(textField.bounds, to: container.presetPageV.sublistContentView)
                container.presetPageV.sublistScrollView.scrollRectToVisible(textFieldFrame, animated: true)
            }
        }
        
    }
    
    //MARK: -
    //MARK: 设置页面
    func settingpageEvent(){
        
        container.settingPageV.settingPageViewDelegate = self
        
        container.settingPageV.menuBtn.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let selfs = self else { return }
                
                selfs.container.settingPageV.menuBtn.isSelected = !selfs.container.settingPageV.menuBtn.isSelected
                selfs.container.settingPageV.settingType = selfs.container.settingPageV.menuBtn.isSelected ? SettingType.noBattery : SettingType.battery
                
                
            }).disposed(by: disposedBag)
    }
    
    func loadSettingDataArr(){
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            for (index, queryValue) in self.model.setParameterArr_origin.enumerated() {
                if index != 4{ //ui 跳过“屏幕方向”
                    self.container.settingPageV.updateRow(queryValue, at: index)
                }
            }
        }
    }
    
    //MARK: -
    //MARK: 充电页面

    //输出按钮事件
    func chargepageRemoteControlEvent1(){
        
        container.chargePageV.outputBtn.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let selfs = self else { return }

                selfs.container.chargePageV.outputBtn.isSelected = !selfs.container.chargePageV.outputBtn.isSelected
//                    Log.debug("outputBtn.isSelected= \(selfs.container.chargePageV.outputBtn.isSelected)")
                selfs.container.chargePageV.setOutput1(isEnble: selfs.container.chargePageV.outputBtn.isSelected)
                selfs.container.chargePageV.expandBselist(isEnble: selfs.container.chargePageV.outputBtn.isSelected)
                    
            }).disposed(by: disposedBag)
    }

    //MARK: -
    //MARK: 导航栏
    func naviEvent1(){

        container.titleContainer.backBtn.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let selfs = self else { return }
                
                switch selfs.currentPage{
                case .programHomepage_presetvalue:
                    selfs.container.presetPageV.endEditing(true)
                    
                    //情况: 1.未编辑未上传(不处理) 2.未编辑且上传(已防呆) 3.编辑且未上传 4.编辑且上传(正常发送命令)
                    if !selfs.model.pendingOperations.isEmpty && !selfs.model.isupLoadBtnClick {//编辑且未上传
                        //恢复旧数据
                        selfs.model.initialPresetListDatas = selfs.model.oldPresetListDatas
                        selfs.container.presetPageV.showPresetlist(with: selfs.model.initialPresetListDatas)
                        Log.debug("back , 预设值页面恢复旧数据 ")
                    }
                    
                    selfs.model.isupLoadBtnClick = false
                    selfs.model.pendingOperations = []//清空对列表的编辑记录
                    selfs.model.presetWriteCommandIArr = [] //清空对列表的编辑记录
                    
                    //清空列表数据,下次进入该页面重新查询
                    selfs.model.initialPresetListDatas = []
                    
                    Log.debug("selfs.previousPage= \(selfs.previousPage), workingpage= \(selfs.workingpage)")
                    switch selfs.workingpage {
                    case .workpage:
                        selfs.showRegulatedModePge()
                        
                    case .programmablepage:
                        selfs.showProgrammableModePge()
                        
                    case .chargepage:
                        selfs.showChargerModePge()
                        
                    default: break
                    }
                    
                case .programEditpage_presetvalue:
                    if selfs.container.presetPageV.selectedRowI >= 0 && selfs.container.presetPageV.selectedRowI < selfs.container.presetPageV.presetPageRows.count {
                        
                        selfs.container.presetPageV.presetPageRows[selfs.container.presetPageV.selectedRowI].titleTextField.isUserInteractionEnabled = false
                        
                        selfs.model.presetWriteCommandIArr.append(selfs.container.presetPageV.selectedRowI)
                        Log.debug("presetvalue program row[\(selfs.container.presetPageV.selectedRowI)] edit page 返回 presetvalue program home page")
                    }
                    
                    
                    selfs.container.presetPageV.restoreAllRows(with: selfs.container.presetPageV.getCurrentClickedRowV())
                    selfs.container.presetPageV.setCurrentClickedRowV(nil)
                    selfs.container.presetPageV.setCurrentClickedRowI(-1)
                    
                    selfs.currentPage = CustomPickviewPageIndex.programHomepage_presetvalue

                case .usbHomepage_presetvalue:
//                    selfs.container.programListV.endEditing(true)
//                    
//                    //情况: 1.未编辑未上传(不处理) 2.未编辑且上传(已防呆) 3.编辑且未上传 4.编辑且上传(正常发送命令)
//                    if !selfs.presetWriteCommandIArr.isEmpty && !selfs.isupLoadBtnClick {
//                        //恢复旧数据
//                        selfs.initialPDOlistDatas = selfs.oldPDOListDatas
//                        selfs.container.programListV.showPDOlist(with: selfs.initialPDOlistDatas)
//                        Log.debug("back , 预设值页面 PDO 恢复旧数据 ")
//                    }
//                    
//                    selfs.isupLoadBtnClick = false
//                    selfs.presetWriteCommandIArr = [] //清空对列表的编辑记录
//                    
//                    //清空列表数据,下次进入该页面重新查询
//                    selfs.initialPDOlistDatas = []
                    
//                    Log.debug("selfs.previousPage= \(selfs.previousPage), workingpage= \(selfs.workingpage)")

                    switch selfs.workingpage {
                    case .workpage:
                        selfs.showRegulatedModePge()
                        
                    case .programmablepage:
                        selfs.showProgrammableModePge()
                        
                    case .pDOpage:
                        selfs.showUSBModePge()
                        
                    case .chargepage:
                        selfs.showChargerModePge()
                        
                    default: break
                    }
//                    
                case .usbEditpage_presetvalue:
//                    if selfs.container.programListV.selectedPDORowI >= 0 && selfs.container.programListV.selectedPDORowI < selfs.container.programListV.usbRowViews.count {
//                        
//                        selfs.container.programListV.usbRowViews[selfs.container.programListV.selectedPDORowI].titleTextField.isUserInteractionEnabled = false
//                        
//                        // 确保视图结束编辑
//                        selfs.view.endEditing(true)
//                        
//                        Log.debug("presetvalue PDO row[\(selfs.container.programListV.selectedPDORowI)] edit page 返回 presetvalue PDO home page")
//                    }
//                    
//                    selfs.container.programListV.restorePDOAllRows(with: selfs.container.programListV.getCurrentClickedPDORowV())
//                    selfs.container.programListV.setCurrentClickedPDORowV(nil)
//                    selfs.container.programListV.setCurrentClickedPDORowI(-1)

                    selfs.currentPage = CustomPickviewPageIndex.usbHomepage_presetvalue
                    
                case .settingHomepage:
                    Log.debug("selfs.previousPage= \(selfs.previousPage), workingpage= \(selfs.workingpage)")

                    switch selfs.workingpage {
                    case .workpage:
                        selfs.showRegulatedModePge()
                        
                    case .programmablepage:
                        selfs.showProgrammableModePge()
                        
                    case .chargepage:
                        selfs.showChargerModePge()
                        
                    default: break
                    }
                    Log.debug("\(selfs.previousPage), setting page 返回 home page")
                    
                case .settingEditpage:
                    selfs.container.settingPageV.backHome()
                    
                case .workpage:
                    selfs.backtoDemoTestVC()
                    
                case .programmablepage:
                    selfs.backtoDemoTestVC()
                    
                case .pDOpage:
                    selfs.backtoDemoTestVC()
                    
                case .chargepage:
                    selfs.backtoDemoTestVC()
                }
                
            }).disposed(by: disposedBag)
    }
    
    private func backtoDemoTestVC(){
        //  先执行回调，再 dismiss
        onDismiss?()
                        
        dismiss(animated: true) {
            Log.debug("CustomPickViewVC 已关闭")
        }
    }
    
}

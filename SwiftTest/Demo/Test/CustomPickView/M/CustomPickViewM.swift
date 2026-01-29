//
//  CustomPickViewM.swift
//  SwiftTest
//
//  Created by user on 2026/1/16.
//

import Foundation

class CustomPickViewM{
    
    //MARK: 系统设置
    //设置参数: 0-电量限制,1-声音,2-自动关闭屏幕​​​​,3-自动关机,4-屏幕方向,5-斜坡步骤, 6-过流保护延迟,7-系统自检(0:不自检 1:自检),8-恢复出厂设置(0:不恢复出厂设置 1:恢复出厂设置) 9-USB线损补偿
    var setParameterArr_new = [90, 3, 0, 30, 1, 500, 50, 0, 0, 0]
    var setParameterArr_origin = [90, 3, 0, 30, 1, 500, 50, 0, 0, 0]
    
    //MARK: 预设值页面
    var oldPresetListDatas: [ProgramFileModel] = []
    var initialPresetListDatas: [ProgramFileModel] = []
    var presetlistDisplayOrder: [Int] = []  // 存储 initialPresetListDatas 的索引,用于后续添加删除操作后可查找正确的 ProgramFileModel.index
    
    //上传
    var uploadContext = UploadContext() //上传状态
    var isupLoadBtnClick = false //判断是否上传过参数
    
    //文本框编辑
    var presetSublistCellIndex = -1
    
    //统计编辑操作
    var pendingOperations: [RowOperation] = [] //执行操作数组, 保存的是初始 ProgramFileModel.index,可具体到哪种操作
    var presetWriteCommandIArr: [Int] = [] // 即将发送写入命令的行索引, 存的是数据索引,从 0 开始

    var presetEditstateObservers: [NSObjectProtocol] = [] //观察者,用于监听《列表 cell 》子类编辑状态
    

    //MARK: 可编程页面
    var dCcurrentWorkRow = 1 //当前工作行
    var initialProgrammablePageDatas: [ProgramDataModel] = []
    var sublistCellIndex = -1 //《可编程列表》单元格索引
    
    //MARK:  工作页
    //远程控制连接
    let remoteControlTimeout: TimeInterval = 10.0 // 10秒超时
    var isShowingRemoteControlAlert = false //是否显示提示框
    var isRemoteControlCancelled = false //是否提示框被取消
    //1-设定输出电压(10mV),2-设定输出电流(mA),3-实时更改(bit0电压 bit1电流 0:关闭 1:开启)
    var remoteConnectSettingArr_new = [0, 0, 0, 0, 0, 0, 0, 0, 0]
    var remoteConnectSettingArr_origin = [0, 0, 0, 0, 0, 0, 0, 0, 0]

    
    //底部菜单
    var isShowWorkmodeMenu = false //是否显示底部菜单栏
    var isMenuVCreate = false //底部菜单栏是否创建过
    
    //设定电压电流
    var isOutputSetOpen = false //设定 view 开启标识
    var isOutputVolSet = true //是否开启电压设定
    var setBtnClickedI = -1 //已点击的设定按钮索引
    var currentVolSettype = 0  //电压设定模式,0-键盘.1-滚轮
    var currentCurSettype = 0  //电流设定模式,0-键盘.1-滚轮
    var volRealtimeStatus = false //电压实时数据开关状态
    var curRealtimeStatus = false
    var hasClearedTrailingDigits = false // 添加属性来跟踪电压设定值是否已经清零过
    var hasClearedCurTrailingDigits = false // 添加属性来跟踪电流设定值是否已经清零过
    
    var data_v = 0.0 //单位: V
    var dataVArr_new = [0,0,0,0,0]//总长度为 5（2位整数 + 1位小数点 + 2位小数）
    var dataVArr_origin = [0,0,0,0,0]
    
    var data_i = 0.000  //单位: A
    var dataIArr_new = [0,0,0,0,0] //总长度为 5（1位整数 + 1位小数点 + 3位小数）
    var dataIArr_origin = [0,0,0,0,0]
    
    
}

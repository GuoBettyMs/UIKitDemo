//
//  File.swift
//  SwiftTest
//
//  Created by user on 2024/6/3.
//

import UIKit



//MARK: - 异常
enum VendingMachineError: Error {
    case invalidIndex
    case outOfRange
}

//MARK: - 常量与变量
//FileManager.default 文件系统的类的单例,是全局唯一实例
//urls(for:) 方法可能返回多个 URL,通常情况下，文档目录只有一个,所以 urls(for:)[0]
//.documentDirectory 表示要获取应用程序的文档目录,该目录存储应用程序产生的数据
//.userDomainMask, 指用户域,是用户专属的存储空间
let kDocumentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] //获取应用程序的文档目录的 URL

//TestFlight 标识,true 表示应用程序下载于 TestFlight
let isRunningTestFlightBeta = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"

/**导航栏高度**/
// 非全面屏设备(44 pt), 全面屏设备(44 pt)
var kNavigBarH: CGFloat = {
    return UIDevice.current.userInterfaceIdiom == .pad ? 50 : UINavigationController().navigationBar.frame.size.height//44
}()

/**状态栏高度**/
//非全面屏设备(20 pt), 全面屏设备(44 pt)
var kStatusBarH: CGFloat = {
    if #available(iOS 13.0, *) {
        guard let windowScene = (UIApplication.shared.connectedScenes.first as? UIWindowScene) else { return 0}
        return windowScene.statusBarManager?.statusBarFrame.height ?? 30
    }else{
        return UIApplication.shared.statusBarFrame.height
    }
}()

/// - Returns:
/// 设备页面宽度
var devicePageContentW: CGFloat = {
    if UIDevice.current.userInterfaceIdiom == .pad{
        if isPortraitBool {//竖屏
            return (UIScreen.main.bounds.width-2)*0.6
        }
        return (UIScreen.main.bounds.width-2)*0.4

    }else{
        return UIScreen.main.bounds.width
    }
}()

/**屏幕高度**/
var kHeight: CGFloat = 0.0
/**屏幕宽度**/
var kWidth:CGFloat = 0.0
/**status+nav**/
var kTopSafeArea: CGFloat = 0.0
/**底部安全区域**/
var kBottomInsetsSafeArea: CGFloat = 0.0
/** 顶部 安全区域 */
var kTopInsetsSafeArea: CGFloat = 0.0
/**tabBar高度*/
var kTabBarHeight: CGFloat = 0.0
/**底部安全区域 + tabBar**/
var kBottomSafeArea: CGFloat = 0.0
/**屏幕方向**/
var isPortraitBool = {
    if let window = UIApplication.shared.windows.first {
        return window.frame.size.width > window.frame.size.height ? false : true
    }
    return true
}()

var isSceneEntranceStoryboard = true //主页入口是否为故事版
var isShowRightNaC = false //是否显示右侧页面

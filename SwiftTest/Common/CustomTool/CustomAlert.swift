//
//  CustomAlert.swift
//  SwiftTest
//
//  Created by user on 2025/4/22.
//
// 封装 UIViewController

import UIKit

struct CustomAlert{

    static func showAdaptiveAlert(
        on vc: UIViewController,
        with title: String,
        message: String? = nil,
        actions: [UIAlertAction] = [UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default)],
        sourceView: UIView? = nil // iPad锚点视图
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        for action in actions {
            alert.addAction(action)
        }
        
        // iPad适配
        if let popover = alert.popoverPresentationController {
            popover.sourceView = sourceView ?? vc.view
            popover.sourceRect = sourceView?.bounds ?? vc.view.bounds
        }
        
        vc.present(alert, animated: true)
    }
 
    static func showToast(
        title: String,
        message: String? = nil,
        vc: UIViewController,
        duration: TimeInterval = 1,
        interfaceStyle: UIUserInterfaceStyle = .unspecified
    ) {
        let alert = UIAlertController.init(title: title, message: nil, preferredStyle: .alert)
        alert.message = message // 新增消息内容
        if #available(iOS 13.0, *) {
            alert.overrideUserInterfaceStyle = interfaceStyle
        } else {
            // Fallback on earlier versions
        }
        let popover = alert.popoverPresentationController
        if (popover != nil) {
            popover?.sourceView = vc.self.view
            popover?.sourceRect = vc.self.view.bounds
            popover?.permittedArrowDirections  = .any
        }
        vc.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            alert.dismiss(animated: true, completion: nil)
        }
        
        // 添加淡入淡出动画
        alert.view.alpha = 0
        UIView.animate(withDuration: 0.3) {
            alert.view.alpha = 1
        }
    }
    
    static func usage(vc: UIViewController){
        showAdaptiveAlert(
            on: vc,
            with: "操作确认",
            message: "是否保存修改？",
            actions: [
                UIAlertAction(title: "保存", style: .default) { _ in
                    // 保存成功后显示短暂提示
                    showToast(title: "保存成功", vc: vc)
                },
                UIAlertAction(title: "不保存", style: .destructive)
            ]
        )
    }
}

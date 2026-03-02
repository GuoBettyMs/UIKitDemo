//
//  CustomAlert.swift
//  SwiftTest
//
//  Created by user on 2025/4/22.
//
// 封装提示框

import UIKit

class CustomAlert{

    // 1.定义关联对象的 Key：使用 static UInt8 变量，而不是 String
    private struct AssociatedKeys {
        static var cancelHandlerKey: UInt8 = 0
        static var confirmHandlerKey: UInt8 = 0
    }
    
    // 定义回调类型，允许用户不传某些回调
    typealias AlertActionHandler = () -> Void
    
    // 内部调度器：用于在 iOS 14 下接收 Selector 消息
    // 因为 showCustomAlert 是 static 的，没有 self 实例可以作为 Target
    @objc private class ActionDispatcher: NSObject {
        static let shared = ActionDispatcher()
        
        @objc func handleCancel(_ sender: UIButton) {
            if let handler = objc_getAssociatedObject(sender, &AssociatedKeys.cancelHandlerKey) as? AlertActionHandler {
                handler()
            }
            dismissAlert(for: sender)
        }
        
        @objc func handleConfirm(_ sender: UIButton) {
            if let handler = objc_getAssociatedObject(sender, &AssociatedKeys.confirmHandlerKey) as? AlertActionHandler {
                handler()
            }
            dismissAlert(for: sender)
        }
        
        private func dismissAlert(for sender: UIButton) {
            guard let alertView = sender.superview else { return }
            guard let parent = alertView.superview else { return }
            
            // 比较 tag, 查找遮罩层
            var dimmingView: UIView?
            for sub in parent.subviews {
                if sub.tag == 9999 {
                    dimmingView = sub
                    break
                }
            }
            
            guard let dimming = dimmingView else {
                // 如果找不到遮罩，直接移除
                alertView.removeFromSuperview()
                return
            }
            
//            UIView.animate(withDuration: 0.25, animations: {
//                dimming.alpha = 0
//                alertView.alpha = 0
//                alertView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
//            }) { _ in
                dimming.removeFromSuperview()
                alertView.removeFromSuperview()
//            }
        }
    }
    
    //MARK: 自定义 ui 警告框
    /// 不会自动消失的自定义提示框
    static func showCustomAlert(
        on vc: UIViewController,
        with title: String,
        cancelHandler: AlertActionHandler? = nil,
        confirmHandler: AlertActionHandler? = nil,
        sourceView: UIView? = nil // iPad锚点视图
    ){
        // 1. 创建背景遮罩
         let dimmingView = UIView()
         dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
//         dimmingView.alpha = 0
        dimmingView.tag = 9999 // 设置 Tag 方便查找背景遮罩
         vc.view.addSubview(dimmingView)
         dimmingView.snp.makeConstraints { make in
             make.edges.equalToSuperview()
         }
         
         // 2. 创建主容器 View
         let alertView = UIView()
         alertView.backgroundColor = UIColor(named: "DP_333333")
         alertView.layer.cornerRadius = 20
         alertView.clipsToBounds = true
//         alertView.alpha = 0 // 初始透明用于动画
         vc.view.addSubview(alertView)
         
         // 固定尺寸约束
         alertView.snp.makeConstraints { make in
             make.width.equalTo(306)
             make.height.equalTo(130)
             make.center.equalToSuperview()
         }
         
        // --- iPad 锚点逻辑 ---
        if UIDevice.current.userInterfaceIdiom == .pad, let source = sourceView {
            // 移除中心约束，改为相对于 sourceView 定位
            alertView.snp.remakeConstraints { make in
                make.width.equalTo(306)
                make.height.equalTo(130)
                // 将 alertView 的顶部对齐到 sourceView 的底部，并水平居中于 sourceView
                make.top.equalTo(source.snp.bottom).offset(10)
                make.centerX.equalTo(source)
            }
           
            //确保不超出屏幕边界
            vc.view.layoutIfNeeded() // 立即布局以获取真实 frame
            if alertView.frame.maxX > vc.view.bounds.width - 20 {
                 alertView.snp.remakeConstraints { make in
                     make.width.equalTo(306)
                     make.height.equalTo(130)
                     make.right.equalTo(vc.view.safeAreaLayoutGuide).offset(-20)
                     make.top.equalTo(source.snp.bottom).offset(10)
                 }
            } else if alertView.frame.minX < 20 {
                 alertView.snp.remakeConstraints { make in
                     make.width.equalTo(306)
                     make.height.equalTo(130)
                     make.left.equalTo(vc.view.safeAreaLayoutGuide).offset(20)
                     make.top.equalTo(source.snp.bottom).offset(10)
                 }
            }
        }
        
         // 3. 标题 Label
         let titleLabel = UILabel()
         alertView.addSubview(titleLabel)
         titleLabel.numberOfLines = 0
            titleLabel.lineBreakMode = .byWordWrapping
         titleLabel.textAlignment = .center
         titleLabel.font = UIFont(name: kSourceHanSansCN_Regular, size: 14)
         titleLabel.text = title
         titleLabel.textColor = .white
        
        // --- 核心逻辑：判断是否换行以决定对齐方式 ---
//        // 计算文本在当前字体和最大宽度下的预计高度或行数
//        let maxWidth = 306 - 20  // 容器宽(306) - 左边距(20) - 右边距(20) = 266
//        let font = UIFont(name: kSourceHanSansCN_Regular, size: 14) ?? UIFont.systemFont(ofSize: 14)
//        let textString = title as NSString
//
//        // 计算单行所需的宽度
//        let attributes: [NSAttributedString.Key: Any] = [.font: font]
//
//        // 计算预期高度
//        let expectedHeight = textString.boundingRect(
//            with: CGSize(width: Double(maxWidth), height: .greatestFiniteMagnitude),
//            options: [.usesLineFragmentOrigin, .usesFontLeading],
//            attributes: attributes, // 使用上面定义的字典
//            context: nil
//        ).height
//
//        // 判断逻辑：如果预计高度 > 单行字体高度，说明会换行
//        let isMultiline = expectedHeight > font.lineHeight
//
//        if isMultiline {
//            titleLabel.textAlignment = .left // 多行：左对齐
//        } else {
//            titleLabel.textAlignment = .center // 单行：居中
//        }
        
         titleLabel.snp.makeConstraints { make in
             make.top.equalTo(alertView).offset(10)
             make.left.right.equalTo(alertView).inset(20)
             make.bottom.equalTo(alertView).offset(-70) //底部按钮高度40+底部按钮约束20+ titleLabel 与底部按钮约束10
         }
         
         // 4. 取消按钮
         let cancelActionBtn = UIButton(type: .custom)
         alertView.addSubview(cancelActionBtn)
         cancelActionBtn.backgroundColor = UIColor(named: "DP_4d4d4d")
         cancelActionBtn.layer.cornerRadius = 10
         
         let cancelLabel = UILabel()
         cancelLabel.text = NSLocalizedString("Cancel", comment: "Cancel")
         cancelLabel.font = UIFont(name: kSourceHanSansCN_Regular, size: 14)
         cancelLabel.textColor = .white
         cancelLabel.textAlignment = .center
         cancelActionBtn.addSubview(cancelLabel)
         
         cancelLabel.snp.makeConstraints { make in
             make.center.equalToSuperview()
         }
         
         cancelActionBtn.snp.makeConstraints { make in
             make.width.equalTo(120)
             make.height.equalTo(40)
             make.bottom.equalTo(alertView).offset(-20)
             make.right.equalTo(alertView.snp.centerX).offset(-13) // 中线向左偏移
         }
         
         // 5. 继续按钮
         let continueActionBtn = UIButton(type: .custom)
         alertView.addSubview(continueActionBtn)
         continueActionBtn.backgroundColor = UIColor(named: "DP_4d4d4d")
         continueActionBtn.layer.cornerRadius = 10
         
         let continueLabel = UILabel()
         continueLabel.text = NSLocalizedString("继续", comment: "Continue")
         continueLabel.font = UIFont(name: kSourceHanSansCN_Regular, size: 14)
         continueLabel.textColor = UIColor(named: "DP_ff4657ff")
         continueLabel.textAlignment = .center
         continueActionBtn.addSubview(continueLabel)
         
         continueLabel.snp.makeConstraints { make in
             make.center.equalToSuperview()
         }
         
         continueActionBtn.snp.makeConstraints { make in
             make.width.equalTo(120)
             make.height.equalTo(40)
             make.bottom.equalTo(alertView).offset(-20)
             make.left.equalTo(alertView.snp.centerX).offset(13)
         }
        
         
         // --- 核心逻辑：绑定点击事件 ---
        
        // 定义关闭弹窗的闭包
        let dismissAlert: () -> Void = {
//            UIView.animate(withDuration: 0.25, animations: {
//                dimmingView.alpha = 0
//                alertView.alpha = 0
//                alertView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
//            }) { _ in
                dimmingView.removeFromSuperview()
                alertView.removeFromSuperview()
//            }
        }
        
        // 通用处理函数
        func handleAction(_ handler: AlertActionHandler?) {
            handler?()// 执行外部传入的回调
            dismissAlert() // 关闭弹窗
        }
        
        if #available(iOS 15.0, *) {
            // iOS 15+ 使用 UIAction
            cancelActionBtn.addAction(UIAction { _ in
                handleAction(cancelHandler) // 执行外部传入的取消回调
            }, for: .touchUpInside)
            
            continueActionBtn.addAction(UIAction { _ in
                handleAction(confirmHandler)
            }, for: .touchUpInside)
            
        }else{
            // iOS 14 及以下：使用关联对象 + Selector,利用关联对象存储闭包，避免内存泄漏需小心处理
            
            // 1. 存储闭包
            objc_setAssociatedObject(cancelActionBtn, &AssociatedKeys.cancelHandlerKey, cancelHandler, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            objc_setAssociatedObject(continueActionBtn, &AssociatedKeys.confirmHandlerKey, confirmHandler, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            
            // 2. 添加 Target-Action, Target 不再是 self，而是单例调度器 ActionDispatcher.shared
            let dispatcher = ActionDispatcher.shared
            
            cancelActionBtn.addTarget(dispatcher, action: #selector(ActionDispatcher.handleCancel(_:)), for: .touchUpInside)
            continueActionBtn.addTarget(dispatcher, action: #selector(ActionDispatcher.handleConfirm(_:)), for: .touchUpInside)
            
    
        }
        
//        // --- 显示动画 ---
//        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
//            dimmingView.alpha = 1
//            alertView.alpha = 1
//            alertView.transform = .identity
//        }, completion: nil)

    }
    
    //MARK: 交互式警告框
    static func showAdaptiveAlert(
        on vc: UIViewController,
        with title: String,
        message: String? = nil,
        actions: [UIAlertAction] = [UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default)],
        sourceView: UIView? = nil // iPad锚点视图
    ) {
        // 创建标准警告框
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        // 排序按钮：取消按钮应该在左边（iOS规范）
        let sortedActions = actions.sorted { action1, action2 in
            if action1.style == .cancel && action2.style != .cancel {
                return false // 取消按钮放最后
            }
            return true
        }
        
        // 添加用户操作按钮
        for action in sortedActions {
            alert.addAction(action)
        }
        
        
        // iPad适配
        if let popover = alert.popoverPresentationController {
            popover.sourceView = sourceView ?? vc.view
            popover.sourceRect = sourceView?.bounds ?? vc.view.bounds
        }
        
        vc.present(alert, animated: true)
    }
 
    //MARK: 短暂提示
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
        }
        
        let popover = alert.popoverPresentationController
        if (popover != nil) {
            popover?.sourceView = vc.self.view
            popover?.sourceRect = vc.self.view.bounds
            popover?.permittedArrowDirections  = .any
        }
        vc.present(alert, animated: true)
        
        // 定时自动关闭
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

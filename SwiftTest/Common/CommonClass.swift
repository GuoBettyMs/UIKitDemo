//
//  CommonClass.swift
//  SwiftTest
//
//  Created by user on 2024/6/4.
//

import UIKit

// 创建自定义 Segment 控件
// Segment 文本可换行显示
class MultilineSegmentedControl: UISegmentedControl {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for segment in subviews {
            for subview in segment.subviews {
                if let label = subview as? UILabel {
                    label.numberOfLines = 0
                    label.lineBreakMode = .byWordWrapping
                    label.textAlignment = .center
                }
            }
        }
    }
}


//MARK: - 手势
class IndexedTapGestureRecognizer: UITapGestureRecognizer {
    var indexPath: IndexPath?
}

extension IndexedTapGestureRecognizer: UIGestureRecognizerDelegate{
    /// - Returns:
    /// 解决手势事件与 UITableView 的点击事件冲突
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchV = touch.view{
            if touchV.superview?.classForCoder == UITableViewCell.classForCoder() {
//                Logger.debug("touchV: \(touchV.classForCoder)")
                return false// 阻止手势识别器接收此触摸
            }
        }
        return true //默认允许接收触摸
    }
}

//MARK: - 导航栏 
class NavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance.init()
            appearance.backgroundColor = .systemGreen//导航栏背景色
            appearance.shadowImage = UIImage()
            appearance.titleTextAttributes = [
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18, weight: .medium),
                NSAttributedString.Key.foregroundColor : UIColor.white
            ]//导航栏标题的文本字体色
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
        }else{
            let bar = UINavigationBar.appearance()
            bar.backgroundColor = .green
            bar.titleTextAttributes = [
                NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18, weight: .medium),
                NSAttributedString.Key.foregroundColor : UIColor.white
            ]
            bar.shadowImage = UIImage()
        }
    }
}


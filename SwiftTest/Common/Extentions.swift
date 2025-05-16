//
//  Extentions.swift
//  SwiftTest
//
//  Created by user on 2024/9/14.
//

import Foundation
import UIKit

// MARK: - 坐标值、尺寸值、几何类型统一显示 decimalPlaces 位小数
extension CGRect {
    func formatted(decimalPlaces: Int = 2) -> String {
        let format = "(%.\(decimalPlaces)f, %.\(decimalPlaces)f, %.\(decimalPlaces)f, %.\(decimalPlaces)f)"
        return String(format: format,
                    origin.x, origin.y, width, height)
    }
}

extension CGPoint {
    func formatted(decimalPlaces: Int = 2) -> String {
        let format = "(%.\(decimalPlaces)f, %.\(decimalPlaces)f)"
        return String(format: format, x, y)
    }
}

extension CGSize {
    func formatted(decimalPlaces: Int = 2) -> String {
        let format = "(%.\(decimalPlaces)f, %.\(decimalPlaces)f)"
        return String(format: format, width, height)
    }
}

extension Float {

    /// 将数值格式化为指定小数位数的字符串,直接截断多余小数位（不保证四舍五入）
    /// - Parameters:
    ///   - decimalPlaces: 小数位数
    /// - Returns: 返回的是字符串（用于显示）
    func formatted(decimalPlaces: Int = 2) -> String {
        let format = "%.\(decimalPlaces)f"
        return String(format: format, self)
    }
    

    /// 对数值本身按照指定的小数位数进行数学上的四舍五入
    /// - Parameters:
    ///   - places: 小数位数
    /// - Returns:返回的是数值（可继续计算）
    func rounded(to places: Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return (self * divisor).rounded() / divisor // 先放大→取整→缩小
    }
}

extension Double {
    //多余小数会四舍五入，不足不补零（如 1.5 格式化为 1.50 需手动处理）
    func formatted(decimalPlaces: Int = 1) -> String {
        let format = "%.\(decimalPlaces)f"
        return String(format: format, self)
    }
}

extension Decimal {//Decimal 计算速度比 Float 慢约10倍
    /// 格式化为指定位数字符串
    func formatted(_ decimalPlaces: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = decimalPlaces
        formatter.maximumFractionDigits = decimalPlaces
        formatter.numberStyle = .decimal
        return formatter.string(from: self as NSDecimalNumber) ?? "\(self)"
    }
}

// MARK: - 扩展：便捷初始化方法
extension NSNotification.Name {
    static let deviceOffline = NSNotification.Name.init("deviceOffline")
    static let deviceOnline = NSNotification.Name.init("deviceOnline")
}


//MARK: - 比较
extension Comparable {
    func isDifferent(from other: Self) -> Bool {
        return self != other
    }
}


//MARK: -
extension UITextField {

    //MARK: 带“完成”按钮的工具栏
    /// - Returns:
    /// 软键盘增加自定义工具栏
    func addKeyboardDoneToolbar(target: Any, action: Selector) {
        let doneToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 35))

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: NSLocalizedString("Complete", comment: "完成"), style: .done, target: target, action: action)

        doneToolbar.setItems([flexSpace, doneButton], animated: false)
        doneToolbar.sizeToFit()

        self.inputAccessoryView = doneToolbar
    }
}

//MARK: -
extension UIViewController {
    var window: UIWindow? {
        if #available(iOS 13, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let delegate = windowScene.delegate as? SceneDelegate, let window = delegate.window else { return nil }
                   return window
        }
        
        guard let delegate = UIApplication.shared.delegate as? AppDelegate, let window = delegate.window else { return nil }
        return window
    }

}

//MARK: -
extension UIView {
    func addCorner(corners: UIRectCorner, radius: CGFloat) {
        // 确保在下次布局周期执行
        DispatchQueue.main.async {
            let path = UIBezierPath(
                roundedRect: self.bounds,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.layer.mask = mask
        }
    }
}
//MARK: -
extension UIButton{
    
    //MARK: 设置有内边距的标题
    /// - Returns:
    /// 按钮设置有内边距的标题
    func setInsetTitle(title: String, fontSize: CGFloat = 12, topInset: CGFloat = 0, leftInset: CGFloat = 12, bottomInset: CGFloat = 0, rightInset: CGFloat = 12){
        if #available(iOS 15, *){
            var configuration = UIButton.Configuration.plain()
            configuration.baseForegroundColor = .black
            configuration.contentInsets = NSDirectionalEdgeInsets(top: topInset, leading: leftInset, bottom: bottomInset, trailing: rightInset)
            configuration.titleLineBreakMode = .byWordWrapping
            configuration.titleAlignment = .center
            // 多行居中解决方案
            let attributedTitle = AttributedString(title, attributes:
                AttributeContainer([
                    .font: UIFont.systemFont(ofSize: fontSize),
                    .paragraphStyle: {
                        let style = NSMutableParagraphStyle()
                        style.alignment = .center
                        return style
                    }()
                ])
            )
            configuration.attributedTitle = attributedTitle
          
            self.configuration = configuration
        }else{
            setTitleColor(.black, for: .normal)
            titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
            titleLabel?.text = title
            titleLabel?.numberOfLines = 0
            titleLabel?.lineBreakMode = .byWordWrapping
            titleLabel?.textAlignment = .center
            contentEdgeInsets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        }
    }
    
}


//MARK: -
extension NSAttributedString {
    //MARK: 设置富文本
    /// - Returns:
    /// 设置富文本
    static func attributedString(headIndent: CGFloat, string: String, fontSize: CGFloat, foregroundColor: UIColor) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = headIndent //首行锁进

        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: foregroundColor,
            .font: UIFont.systemFont(ofSize: fontSize),
            .paragraphStyle: paragraphStyle
        ]

        return NSAttributedString(string: string, attributes: attributes)
    }
}
//MARK: -
extension NSMutableAttributedString{
    //MARK: 设置带图片与文字的富文本
    /// - Returns:
    ///  富文本中图片与文字垂直居中对齐
    static func imgAndAttrStr(imgStr: String, titleStr: String, font: UIFont) -> NSMutableAttributedString {
        
        let img = UIImage(named: imgStr)!
        let imgH = font.pointSize
        let imgW = img.size.width*(font.pointSize/img.size.height)//等比放大 img 的宽
        
        let imgAttch = NSTextAttachment()
        imgAttch.image = img
        imgAttch.bounds = CGRect(x: 0, y: (font.ascender+font.descender-imgH)/2, width: imgW, height: imgH)//ascender: 指 text 基准线以上的最高 y 坐标; descender 指 text 基准线以下的最低 y 坐标
    //        let mid = font.descender + font.capHeight
    //        imgAttch.bounds = CGRect(x: 0, y: font.descender - imgH / 2 + mid + 2, width: imgW, height: imgH)
        
        let style = NSMutableParagraphStyle()
        style.firstLineHeadIndent = font.pointSize * 1.3//首行缩进

        let attrStr = NSMutableAttributedString(string: " ", attributes: [.paragraphStyle : style])
        attrStr.append(NSAttributedString(attachment: imgAttch))
        attrStr.append(NSAttributedString(string: "  "))
        attrStr.append(NSAttributedString(string: titleStr))

    //        Logger.debug("字体中线位置: mid: \((font.ascender+font.descender-imgH)/2),\(font.descender - imgH / 2 + mid + 2)")
        
        return attrStr
    }
}

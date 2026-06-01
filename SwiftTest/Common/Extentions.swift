//
//  Extentions.swift
//  SwiftTest
//
//  Created by user on 2024/9/14.
//

import Foundation
import UIKit

// MARK: -
extension CharacterSet {
    // 自定义 ASCII 可打印字符集（32-126）
    static var asciiPrintable: CharacterSet {
        var characters = CharacterSet()
        // ASCII 可打印字符范围：32-126
        for i in 32...126 {
            if let scalar = UnicodeScalar(i) {
                characters.insert(scalar)
            }
        }
        return characters
    }
    
}
//MARK: - 扩展 UIImageView 添加 padding 属性
extension UIImageView {
    func setImageWithPadding(_ image: UIImage?, padding: CGFloat, backgroundColor: UIColor) {
        self.image = image
        self.backgroundColor = backgroundColor
        self.contentMode = .center
        
        // 创建带内边距的容器
        let containerView = UIView()
        containerView.backgroundColor = .clear
        containerView.isUserInteractionEnabled = false
        
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(padding)
        }
        
        // 将图片移到容器中
        if let image = image {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            containerView.addSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
}


// MARK: -
extension UIImage {

    /// 创建一个可用于 UIProgressView 的圆角进度图（胶囊形）
    /// - Parameters:
    ///   - color: 进度条颜色
    ///   - height: 高度（如 6）
    /// - Returns: 可拉伸的 UIImage, 无论进度多长，始终只有两端是圆角，中间是直的
    static func capsuleProgressImage(color: UIColor, height: CGFloat) -> UIImage {
        let radius = height / 2
        let capWidth = radius // 圆角部分宽度 = 半径
        
        // 总宽度 = 左圆角 + 1px 可拉伸区 + 右圆角（至少 1px 中间区）
        let width = max(1, capWidth * 2 + 1)
        let size = CGSize(width: width, height: height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        let rect = CGRect(origin: .zero, size: size)
        color.setFill()
        
        // 画完整胶囊
        let path = UIBezierPath(roundedRect: rect, cornerRadius: radius)
        path.fill()
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            return UIImage()
        }
        
        // 设置 capInsets，保护左右圆角不被拉伸
        let capInsets = UIEdgeInsets(
            top: 0,
            left: capWidth,      // 左边 capWidth 不拉伸
            bottom: 0,
            right: capWidth      // 右边 capWidth 不拉伸
        )
        
        return image.resizableImage(withCapInsets: capInsets, resizingMode: .stretch)
    }
    
    
    /// 用作直线轨道（UISlider）、分割线、背景色块等不需要圆角的场景
    /// - Returns: 直角矩形（无圆角）的纯色图
    /// - Note: 内部由 UIRectFill(...)  绘制
    static func rightRectangleImage(with color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
}

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
    //会四舍五入，不足不补零（如 1.5 格式化为 1.50 需手动处理）
    /*
     let p: Int = 13650
     let p1 = Double(p) / 1000.0
     p1.formatted(decimalPlaces: 1) 保留1位小数,结果是 “13.7”
     */
    func formatted(decimalPlaces: Int = 1) -> String {
        let format = "%.\(decimalPlaces)f"
        return String(format: format, self)
    }
    
    //整数只有1位时,前置补0, 如 5 输出“05.00”
    func formattedWithLeadingZero(decimalPlaces: Int = 2) -> String {
        // 首先格式化小数部分
        let format = "%.\(decimalPlaces)f"
        let fullString = String(format: format, self)
        
        // 检查整数部分
        let components = fullString.split(separator: ".")
        guard components.count == 2 else { return fullString }
        
        var integerPart = String(components[0])
        let decimalPart = String(components[1])
        
        // 如果整数部分只有1位，前面补0
        if integerPart.count == 1 && self >= 0 {
            integerPart = "0" + integerPart
        }
        
        return "\(integerPart).\(decimalPart)"
    }
    
    //固定形式, 几位整数 + 几位小数
    func formatDigits(_ rawValue: Double, numberofIntegerdigits: Int, numberofFractiondigits: Int) -> String {
        
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = numberofIntegerdigits  // 整数部分，不足补0
        formatter.minimumFractionDigits = numberofFractiondigits // 小数部分
        formatter.maximumFractionDigits = numberofFractiondigits // 小数部分
        
        return (formatter.string(from: NSNumber(value: rawValue)) ?? "00.00")
    }
    
}

//extension Decimal {//Decimal 计算速度比 Float 慢约10倍
//    /// 格式化为指定位数字符串
//    func formatted(_ decimalPlaces: Int = 2) -> String {
//        let formatter = NumberFormatter()
//        formatter.minimumFractionDigits = decimalPlaces
//        formatter.maximumFractionDigits = decimalPlaces
//        formatter.numberStyle = .decimal
//        return formatter.string(from: self as NSDecimalNumber) ?? "\(self)"
//    }
//}

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
    
    //MARK: 自定义每条边框
    enum BorderSide {
        case top, bottom, left, right
    }
    func removeBorder(side: BorderSide) {
        let name = "border_\(side)"
        layer.sublayers?.removeAll { $0.name == name }
    }
    
    // 自定义每条边框
    func addBorder(side: BorderSide, color: UIColor, width: CGFloat) {
        // 移除已有的同位置边框
        removeBorder(side: side)
            
        // 确保使用正确的 bounds
        let currentBounds = self.bounds

        // 检查 bounds 是否有效
        guard currentBounds.width > 0 && currentBounds.height > 0 else {
            // 如果 bounds 无效，延迟执行
            DispatchQueue.main.async { [weak self] in
                self?.addBorder(side: side, color: color, width: width)
            }
            return
        }

        let borderLayer = CALayer()
        borderLayer.name = "border_\(side)" // 添加标识
        borderLayer.backgroundColor = color.cgColor

        // 使用 CGRect 而不是 bounds，确保 frame 正确
        let frame: CGRect
        switch side {
        case .top:
            frame = CGRect(x: 0, y: 0, width: layer.bounds.width, height: width)
        case .bottom:
            frame = CGRect(x: 0, y: layer.bounds.height - width,
                          width: layer.bounds.width, height: width)
        case .left:
            frame = CGRect(x: 0, y: 0, width: width, height: layer.bounds.height)
        case .right:
            frame = CGRect(x: layer.bounds.width - width, y: 0,
                          width: width, height: layer.bounds.height)
        }

        borderLayer.frame = frame
        layer.addSublayer(borderLayer)
        
    }
    
    //MARK: 自定义每个角的大小
    // CACornerMask 到 UIRectCorner 的转换方法
    func convertToUIRectCorner(_ maskedCorners: CACornerMask) -> UIRectCorner {
        var rectCorners: UIRectCorner = []
        
        if maskedCorners.contains(.layerMinXMinYCorner) {
            rectCorners.insert(.topLeft)
        }
        if maskedCorners.contains(.layerMaxXMinYCorner) {
            rectCorners.insert(.topRight)
        }
        if maskedCorners.contains(.layerMinXMaxYCorner) {
            rectCorners.insert(.bottomLeft)
        }
        if maskedCorners.contains(.layerMaxXMaxYCorner) {
            rectCorners.insert(.bottomRight)
        }
        
        return rectCorners
    }
    
    // UIRectCorner 到 CACornerMask 的转换方法
    func convertToCACornerMask(_ rectCorners: UIRectCorner) -> CACornerMask {
        var maskedCorners: CACornerMask = []
        
        if rectCorners.contains(.topLeft) {
            maskedCorners.insert(.layerMinXMinYCorner)
        }
        if rectCorners.contains(.topRight) {
            maskedCorners.insert(.layerMaxXMinYCorner)
        }
        if rectCorners.contains(.bottomLeft) {
            maskedCorners.insert(.layerMinXMaxYCorner)
        }
        if rectCorners.contains(.bottomRight) {
            maskedCorners.insert(.layerMaxXMaxYCorner)
        }
        
        return maskedCorners
    }
    
    //兼容性处理,定义每个角的大小
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        if #available(iOS 11.0, *) {
            layer.cornerRadius = radius
            layer.maskedCorners = convertToCACornerMask(corners)
            layer.masksToBounds = true
        } else {
            // 旧版本使用路径方法,不支持平滑动画
            let path = UIBezierPath(
                roundedRect: bounds,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
            
            //需要在 override func layoutSubviews() ,手动更新（bounds改变时）
//                override func layoutSubviews() {
//                    super.layoutSubviews()
//                    // 每次 bounds 改变都需要重新应用
//                    addCorner(corners: [.topLeft, .topRight], radius: 12)
//                }
        }
    }
    
    //MARK: 返回父级视图控制器
    //以下 parentViewController 仅通过 UIResponder 链（next 属性）进行弱引用遍历查找的，整个过程中没有将 VC 存储为 UIView 的属性，也没有建立强引用关系
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self //定义了一个可选类型的 Responder 变量（本质是弱引用语义，因 UIResponder 未被强持有）。
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController //返回的是可选类型的临时引用
            }
        }
        return nil
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

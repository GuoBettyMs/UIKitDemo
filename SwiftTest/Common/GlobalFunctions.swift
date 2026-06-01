//
//  File.swift
//  SwiftTest
//
//  Created by user on 2024/11/21.
//

import Foundation
import UIKit
import AudioToolbox
import Alamofire

// MARK: - 震动
//滚动中的震动 - 使用 UISelectionFeedbackGenerator（轻量）
func triggerSelectionVibration() {
    if #available(iOS 10.0, *) {
        // 滚动时每变化一格震动一次
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    } else {
        AudioServicesPlaySystemSound(1519)
    }
}

// 停止时的震动 - 使用 UIImpactFeedbackGenerator(.medium)
func triggerImpactVibration() {
    if #available(iOS 10.0, *) {
        // 用户松手时的确认反馈
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    } else {
        AudioServicesPlaySystemSound(1520)
    }
}


func isShockOrBeep(){
   
    let soundMiddle = SystemSoundID(1519)
    AudioServicesPlaySystemSound(soundMiddle)

    var soundID:SystemSoundID = 0
    //获取声音地址
    let path = Bundle.main.path(forResource: "beep", ofType: "mp3")
    //地址转换
    let baseURL = NSURL(fileURLWithPath: path!)
    //赋值
    AudioServicesCreateSystemSoundID(baseURL, &soundID)
    AudioServicesPlaySystemSound (soundID)
    
}

// MARK: - 获取当前语言
func GetCurrentLanguage() -> String {

    let preferredLang = Bundle.main.preferredLocalizations.first! as NSString
    switch String(describing: preferredLang) {
    case "en-US", "en-CN":
        return "en"//英文
    case "zh-Hans-US","zh-Hans":
        return "cn"//中文
    default:
        return "en"
    }
}


//MARK: - Bahnschrift 字体

//带"TM"商标的自定义字体
func bahnschrift_formattedWithTM(_ str: String, showTM: Bool = false) -> NSMutableAttributedString {
    var traits: [UIFontDescriptor.TraitKey: Any] = [:]
    
    // 同时设置字重和字形宽度
    if #available(iOS 16.0, *) {
        traits = [
            .weight: UIFont.Weight.light,
            .width: UIFont.Width.compressed // 宽度：compressed (最接近 semicondensed)
        ]
    } else {
        traits = [
            .weight: UIFont.Weight.light,
        ]
    }
    
    // 创建字体描述符
    let descriptor = UIFontDescriptor(
        fontAttributes: [
            .name: kBahnschrift,// 字体家族名
            .traits: traits
        ]
    )
    let baseFont = UIFont(descriptor: descriptor, size: 20)// 设置基础字体
    
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineHeightMultiple = 0.8
    paragraphStyle.alignment = .center
    paragraphStyle.lineBreakMode = .byWordWrapping
    
    let fullText = showTM ? str + "TM" : str
    let res = NSMutableAttributedString(
        string: fullText,
        attributes: [
            .paragraphStyle: paragraphStyle,
            .font: baseFont,
            .kern: 0.25,// 调整此值控制间距（单位：磅）
            .baselineOffset: -2
        ]
    )
    
    // 如果显示TM，设置上标效果
    if showTM {
        let tmRange = NSRange(location: str.count, length: 2)
        
        // 创建TM的小号字体
        let tmDescriptor = UIFontDescriptor(
            fontAttributes: [
                .name: kBahnschrift,
                .traits: traits
            ]
        )
        let tmFont = UIFont(descriptor: tmDescriptor, size: 7) // 缩小上标字体
        // 上标效果
        res.addAttribute(.baselineOffset, value: 6, range: tmRange) // 向上偏移
        res.addAttribute(.font, value: tmFont, range: tmRange) // 应用小号字体
    }
    
    return res
}


/// 自定义字体
/// - Parameters:
///   - label: 标签
func bahnschrift_formatted(_ str: String, _ size: CGFloat = 20, weight: UIFont.Weight = .regular, alignment: NSTextAlignment = .center, baseline: CGFloat = 0, kern: CGFloat = 0) -> NSMutableAttributedString{

    var font: UIFont
    let bahnschriftFontName = getBahnschriftFontName(for: weight)
    
    if let customFont = UIFont(name: bahnschriftFontName, size: size) {
        // 先尝试使用 Bahnschrift 字体
        font = customFont
//            Log.debug("formattedString, 3005 使用 Bahnschrift 字体: \(bahnschriftFontName)")
    }else {
        // 如果自定义字体不可用，使用系统字体
        font = UIFont.systemFont(ofSize: size, weight: weight)
//            Log.debug("formattedString, 3005 Bahnschrift 字体不可用，使用系统字体")
    }
    
    let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.lineSpacing = 41.0  // 设置行高
    paragraphStyle.alignment = alignment  // 居中
    
    return NSMutableAttributedString(
        string: str,
        attributes: [
            .font: font,
            .baselineOffset: baseline,
            .kern: kern, // 调整此值控制间距（单位：磅）
            .paragraphStyle: paragraphStyle  // 使用初始化好的段落样式
        ]
    )
    
}

// 根据字重获取对应的 Bahnschrift 字体名称
//        3005 字体家族: Bahnschrift
//        3005  - Bahnschrift
//        3005  - Bahnschrift_Light
//        3005  - Bahnschrift_SemiLight
//        3005  - Bahnschrift_SemiBold
//        3005  - Bahnschrift_Bold
//        3005  - Bahnschrift_SemiCondensed
//        3005  - Bahnschrift_Light-SemiCondensed
//        3005  - Bahnschrift_SemiLight-SemiCondensed
//        3005  - Bahnschrift_SemiBold-SemiCondensed
//        3005  - Bahnschrift_Bold-SemiCondensed
//        3005  - Bahnschrift_Condensed
//        3005  - Bahnschrift_Light-Condensed
//        3005  - Bahnschrift_SemiLight-Condensed
//        3005  - Bahnschrift_SemiBold-Condensed
//        3005  - Bahnschrift_Bold-Condensed
 func getBahnschriftFontName(for weight: UIFont.Weight) -> String {
    switch weight {
    case .ultraLight, .thin:
        return "Bahnschrift_Light"
    case .light:
        return "Bahnschrift_Light"
    case .regular:
        return "Bahnschrift"
    case .medium:
        return "Bahnschrift"
    case .semibold:
        return "Bahnschrift_SemiBold"
    case .bold:
        return "Bahnschrift_Bold"
    case .heavy, .black:
        return "Bahnschrift_Bold"
    default:
        return "Bahnschrift"
    }
}

// MARK: - 样式配置
func configureGlobalNavigationBarAppearance(navi: UINavigationController){
    if #available(iOS 13.0, *) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground() // Key step: Removes default background/blur
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear // Removes the bottom separator line
        appearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 18, weight: .medium),
            .foregroundColor: UIColor.black
        ]//导航栏标题的文本字体色
        navi.navigationBar.standardAppearance = appearance
        navi.navigationBar.scrollEdgeAppearance = appearance
        navi.navigationBar.compactAppearance = appearance // iPad 横屏用
    } else {
        // Legacy iOS (< 13)
        navi.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navi.navigationBar.shadowImage = UIImage()
        navi.navigationBar.isTranslucent = true
        navi.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 18, weight: .medium),
            .foregroundColor: UIColor.black
        ]
    }

}

//配置 UITabBar
func configureGlobalTabBarAppearance() {
    if #available(iOS 15.0, *) {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        
        // 设置选中/未选中颜色
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.systemBlue,
            .font: UIFont.systemFont(ofSize: 12, weight: .semibold)
        ]
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.systemGray,
            .font: UIFont.systemFont(ofSize: 12)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    } else {
        UITabBar.appearance().tintColor = .systemBlue
        UITabBar.appearance().unselectedItemTintColor = .systemGray
    }
}



//MARK: - 角度转弧度
/// 角度转弧度, 用于绘制圆弧
/// - Parameter angle: 角度
/// - Returns:
func angleToRadian(_ angle: Double)->CGFloat {
    return CGFloat(angle/Double(180.0) * .pi)
}


//MARK: -
//MARK: 标签3D转换
/// - Returns:
/// 变形
func labelTransform3D(eleL: UILabel){
    // 创建一个变形
    var transform = CATransform3DIdentity
    let xAngle = -10//负值逆时针,CATransform3DRotate以弧度为单位，1 弧度约等于 57.3 度,需要转换CGFloat(Double(xAngle)/Double(180.0) * .pi)
    let yAngle = 30
    transform.m34 = -1.0 / 500.0// 应用透视
    transform = CATransform3DRotate(transform, CGFloat(Double(xAngle)/Double(180.0) * .pi), 1, 0, 0)// 绕 x 轴旋转
    transform = CATransform3DRotate(transform, CGFloat(Double(yAngle)/Double(180.0) * .pi), 0, 1, 0)// 绕 y 轴旋转
    eleL.layer.transform = transform
}

//MARK: - 网络请求
/// - Returns:
///  网络请求, 示例网址: let httpStr = "http://itunes.apple.com/cn/lookup?id=6471041609"
func webRequire(httpStr: String){

//    //原生 URLSession（Apple 官方 API）
//    //适用场景: 轻量级请求
//    if let url = URL(string: httpStr) {
//        let task = URLSession.shared.dataTask(with: url) { data, response, error in
//            if let error = error {
//                print("Error: \(error)")
//                return
//            }
//            if let data = data, let responseString = String(data: data, encoding: .utf8) {
//                print("Response: \(responseString)")
//            }
//        }
//        task.resume()
//    }
//
//
//    //Alamofire（完整版）
//    //适用场景: 复杂请求（需配置）
//    let headers:HTTPHeaders = ["Cache-Control":"no-store"]
//    let method:HTTPMethod = HTTPMethod(rawValue: "GET")
//
//    AF.request(httpStr, method: method, parameters: nil, encoding: URLEncoding.default, headers: headers, interceptor: nil).responseData(completionHandler: { response in
//        switch response.result {
//            case .success(let data):
//            print("success")
//            case .failure(let error):
//            print(error)
//        }
//    })
    
    //Alamofire（简化版）
    //适用场景: 快速调试
    AF.request(httpStr)
        .response { response in
            switch response.result {
            case .success(_):
                print("Request successful")
                
            case .failure(let error):
                print("Request failed: \(error)")
                
            }
        }
}
//MARK: -
/// 访问活动窗口,添加 view
func keyWindowAdd(_ view: UIView){
    if #available(iOS 13.0, *){
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        window?.addSubview(view)
    }else{
        UIApplication.shared.keyWindow!.addSubview(view)
    }
}

//MARK: -

//MARK: debug弹框
func addDebugUITextView(addView: UIView, topView: UIView) -> UITextView {
    
    let debugUITextView = UITextView()
    addView.addSubview(debugUITextView)
    debugUITextView.snp.makeConstraints { make in
        make.top.equalTo(topView.snp.bottom).offset(10)
        make.left.equalTo(10)
        make.right.equalTo(-10)
        make.height.equalTo(200)
    }
    debugUITextView.font = .systemFont(ofSize: 16)
    debugUITextView.isEditable = false
    debugUITextView.backgroundColor = .clear
    debugUITextView.layer.cornerRadius = 5.0//设置圆角半径
    debugUITextView.layer.borderWidth = 1.0 //设置边框宽度
    debugUITextView.layer.borderColor = UIColor.random().cgColor//设置边框颜色

    return debugUITextView
}



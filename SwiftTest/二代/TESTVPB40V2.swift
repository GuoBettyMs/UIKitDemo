//
//  TESTVPB40V2.swift
//  SwiftTest
//
//  Created by user on 2024/7/1.
//

import UIKit
import SnapKit

class TESTVPB40V2: UIView {

    var kDevicePageContentW: CGFloat = {
        if UIDevice.current.userInterfaceIdiom == .pad{
            if UIDevice.current.orientation == .portrait || UIDevice.current.orientation ==  .portraitUpsideDown{//竖屏
                return (UIScreen.main.bounds.width-2)*0.6-40
            }
            return (UIScreen.main.bounds.width-2)*0.4-40

        }else{
            return UIScreen.main.bounds.width-40//content左右边距各为20
        }
    }()
    
    /// - Returns:
    /// 纯代码加载UIView
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        print("TESTVPB40V2 Object was deallocated")
    }
    func setup(){
        
        self.backgroundColor = UIColor.green
        
        let imaV = UIImageView(image: UIImage(named: "cat")!)
        addSubview(imaV)
        imaV.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
        
        let eleL = UILabel()
        imaV.addSubview(eleL)
        eleL.snp.makeConstraints { make in
            make.centerX.equalTo(imaV.snp.centerX).offset(15)
            make.bottom.equalTo(imaV.snp.bottom).offset(-10)
        }
        eleL.textColor = .white
        eleL.textAlignment = .center
        eleL.attributedText = setAttrText(text: "20", num: 200, weight: .medium)+setAttrText(text: "%", num: 40, weight: .black)//由粗到细:black>heavy>bold>semibold>medium>regular>light(亮)>thin(细)>ultralight

        // 创建一个变形
        var transform = CATransform3DIdentity
        let xAngle = -10//负值逆时针,CATransform3DRotate以弧度为单位，1 弧度约等于 57.3 度,需要转换CGFloat(Double(xAngle)/Double(180.0) * .pi)
        let yAngle = 30
        transform.m34 = -1.0 / 500.0// 应用透视
        transform = CATransform3DRotate(transform, CGFloat(Double(xAngle)/Double(180.0) * .pi), 1, 0, 0)// 绕 x 轴旋转
        transform = CATransform3DRotate(transform, CGFloat(Double(yAngle)/Double(180.0) * .pi), 0, 1, 0)// 绕 y 轴旋转
        eleL.layer.transform = transform
        
        
    }
    
    func setAttrText(text:String, num: CGFloat, weight: UIFont.Weight)->NSMutableAttributedString{
        let res = NSMutableAttributedString(string:text)
        res.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: getNumscale(num), weight: weight), range: NSRange(location: 0, length: res.length))//range:从字符串的起始位置开始，长度为字符串的长度
        
        return res
    }
    
    /// width: 一个字符的宽度
    func getNumscale(_ width:CGFloat) -> CGFloat{
        return (width*(kDevicePageContentW+40))/1170
    }
}

extension NSAttributedString {
    //拼接两个富文本
    static func +(lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
        let mutableAttributedString = NSMutableAttributedString(attributedString: lhs)
        mutableAttributedString.append(rhs)
        return mutableAttributedString
    }
}

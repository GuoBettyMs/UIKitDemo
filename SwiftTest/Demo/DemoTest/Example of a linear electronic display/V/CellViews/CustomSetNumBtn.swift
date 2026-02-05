//
//  CustomSetNumBtn.swift
//  SwiftTest
//
//  Created by user on 2026/1/16.
//
// 自定义的 UIButton 子类,可绘制 UIButton 底部两个角的自定义边框路径

import UIKit
import SnapKit

class CustomSetNumBtn: UIButton{
    enum CornerPathLocation {
        case bottomLeft
        case bottomRight
        case none
    }
    private let shapeLayer = CAShapeLayer()
    private let cornerRadius: CGFloat = 10
    private let lineWidth: CGFloat = 5
    private let extensionWidth: CGFloat = 10
    //底部角边框路径位置
    var cornerPathLocation: CornerPathLocation = .none {
        didSet {
            guard cornerPathLocation != oldValue else { return }
            updateCornerPath() //更新边框路径
        }
    }
    
    private let cursetTitleL = UILabel()
    private let cursetValueL = UILabel()
    private let cursetUnitL = UILabel()
 
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)

        additionalSetup1()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        updateCornerPath()
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Private Methods

    //更新边框路径
    private func updateCornerPath() {
        guard cornerPathLocation != .none else {
            shapeLayer.isHidden = true
            shapeLayer.path = nil
            return
        }
        
        shapeLayer.isHidden = false
        
        // 调整形状图层的位置和大小
        let extendedBounds = CGRect(
            x: -extensionWidth / 2,
            y: -extensionWidth / 2,
            width: bounds.width + extensionWidth,
            height: bounds.height + extensionWidth
        )
        
        // 创建路径
        let path = UIBezierPath()
        let offset = extensionWidth / 2
        
        switch cornerPathLocation {
        case .bottomLeft:// 左下角路径
            let startPoint = CGPoint(x: -lineWidth/2 + offset,
                                     y: bounds.height - cornerRadius * 2 + offset)
            let arcCenter = CGPoint(x: cornerRadius + offset,
                                    y: bounds.height - cornerRadius + offset)
            
            path.move(to: startPoint)
            path.addLine(to: CGPoint(x: startPoint.x,
                                     y: bounds.height - cornerRadius + offset))
            path.addArc(withCenter: arcCenter,
                       radius: cornerRadius + lineWidth/2,
                       startAngle: .pi,
                       endAngle: .pi/2,
                       clockwise: false)
            path.addLine(to: CGPoint(x: bounds.width + offset,
                                     y: bounds.height + lineWidth/2 + offset))
            
        case .bottomRight:// 右下角路径
            // 起点：右侧，在按钮边界外侧
            let startPoint = CGPoint(x: bounds.width + lineWidth/2 + offset,
                                     y: bounds.height - cornerRadius * 2 + offset)
            path.move(to: startPoint)
            // 向下绘制到圆弧起点
            path.addLine(to: CGPoint(x: startPoint.x,
                                     y: bounds.height - cornerRadius + offset))
            // 绘制右下角外侧圆弧（顺时针方向）
            let arcCenter = CGPoint(x: bounds.width - cornerRadius + offset,// X坐标在右侧
                                    y: bounds.height - cornerRadius + offset) // Y坐标在底部
            path.addArc(withCenter: arcCenter,
                       radius: cornerRadius + lineWidth/2,
                       startAngle: 0,
                       endAngle: .pi/2,
                       clockwise: true)
            // 向左绘制到底部中间
            path.addLine(to: CGPoint(x: bounds.width/2 + offset,
                                     y: bounds.height + lineWidth/2 + offset))
        case .none:
            break
        }
        
        shapeLayer.frame = extendedBounds
        shapeLayer.path = path.cgPath
        
    }
      
    private func additionalSetup1(){
        
        backgroundColor = UIColor(named: "DP_404040ff")
        self.layer.cornerRadius = 10
        self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        // 配置形状图层
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor(named: "DP_0d0d0dff")?.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineCap = .round
        layer.insertSublayer(shapeLayer, at: 0)
        
        addSubview(cursetTitleL)
        cursetTitleL.snp.makeConstraints { make in
            make.right.equalTo(self.snp.centerX).offset(-25)
            make.centerY.equalToSuperview()
        }
        cursetTitleL.textColor = UIColor(named: "DP_999999")
        cursetTitleL.attributedText = bahnschrift_formatted("I-SET", 14)

        addSubview(cursetValueL)
        cursetValueL.snp.makeConstraints { make in
            make.left.equalTo(cursetTitleL.snp.right).offset(21)
            make.centerY.equalToSuperview()
        }
        cursetValueL.textColor = .white
        cursetValueL.attributedText = bahnschrift_formatted("0.000")
        
        addSubview(cursetUnitL)
        cursetUnitL.snp.makeConstraints { make in
            make.left.equalTo(cursetValueL.snp.right).offset(8)
            make.centerY.equalToSuperview()
        }
        cursetUnitL.textColor = UIColor(named: "DP_999999")
        cursetUnitL.attributedText = bahnschrift_formatted("A")
        
    }
    
    //MARK: - Public Methods
    /// 只读模式下,设置标题
    func setTitleText(_ text: String){
        cursetTitleL.text = text
    }

    /// 只读模式下,设置数值
    func setValueText(_ text: String){
        cursetValueL.text = text
    }
    
    func setValueTextColor(_ isRecover: Bool){
        cursetValueL.textColor = UIColor(named: isRecover ? "DP_ffffffff" : "DP_000000ff")
    }
    
    /// 只读模式下,设置单位
    func setUnitText(_ text: String){
        cursetUnitL.text = text
    }
    
    func getSetvalue() -> String{
        return cursetValueL.text ?? "0"
    }
    
}

extension CustomSetNumBtn: UITextFieldDelegate{
    
    //文本框输入过程,自动对文本进行检查
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 获取当前文本
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        // 如果是删除操作，允许
        if string.isEmpty {
            return true
        }
        
        // 检查输入合法性
        if !isValidNumberInput(newText) {
            return false
        }

        return true
    }
    
    // 检查输入是否为合法数字
    private func isValidNumberInput(_ text: String) -> Bool {
        // 允许删除
        if text.isEmpty { return true }
        
        // 检查是否是数字或小数点
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
        let characterSet = CharacterSet(charactersIn: text)
        if !allowedCharacters.isSuperset(of: characterSet) {
            return false
        }
        
        // 检查小数点数量（最多一个）
        if text.components(separatedBy: ".").count > 2 {
            return false
        }
        
        // 检查小数位数（最多三位）
        if let dotRange = text.range(of: ".") {
            let decimalPart = text[dotRange.upperBound...]
            if decimalPart.count > 3 {
                return false
            }
        }
        
        return true
    }
}

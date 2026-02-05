//
//  CircleView.swift
//  SwiftTest
//
//  Created by user on 2024/9/27.
//

import UIKit

class CircleView: UIView {
    
    private let progressLayer: CAShapeLayer = {
        // 形状图层，初始化与属性配置
        let circle = CAShapeLayer()
        circle.fillColor = UIColor.clear.cgColor
        return circle
    }()
    
    private let progressBackgroundLayer: CAShapeLayer = {
        // 形状图层，初始化与属性配置
        let circle = CAShapeLayer()
        circle.fillColor = UIColor.clear.cgColor
        return circle
    }()
    
    private let roundLayer: CAShapeLayer = {
        // 形状图层，初始化与属性配置
        let circle = CAShapeLayer()
        circle.fillColor = UIColor.clear.cgColor
        return circle
    }()
    
    private let roundLayer1: CAShapeLayer = {
        // 形状图层，初始化与属性配置
        let circle = CAShapeLayer()
        circle.fillColor = UIColor.clear.cgColor
        return circle
    }()
    
    private let roundLayer2: CAShapeLayer = {
        // 形状图层，初始化与属性配置
        let circle = CAShapeLayer()
        return circle
    }()
    
    //MARK: color
    @IBInspectable private var progressColor: UIColor? = UIColor.clear
    @IBInspectable private var progressBackgroundColor: UIColor? = UIColor.clear
    @IBInspectable private var roundColor: UIColor? = UIColor.clear
    @IBInspectable private var roundColor1: UIColor? = UIColor.clear
    @IBInspectable private var roundColor2: UIColor? = UIColor.clear

    @IBInspectable private var progressWidth: CGFloat = 0
    @IBInspectable private var progressBackgroundWidth: CGFloat = 0
    
    @IBInspectable private var roundWidth: CGFloat = 0
    @IBInspectable private var roundWidth1: CGFloat = 0
    @IBInspectable private var roundWidth2: CGFloat = 0
    
    private var voltageL: UILabel? // 中心文本显示
    private var connectIV = UIImageView(image: UIImage(named: "ConnectIcon"))
    private var percentageL: UILabel?
    private var electricityIV = UIImageView(image: UIImage(named: "NP2Go-Lightning"))

    //MARK: 当前进度
    @IBInspectable private var progress: Double = 0 {
        didSet {
            if progress > 100 {
                progress = 100
            }else if progress < 0 {
                progress = 0
            }
            if oldValue != progress {
                progressLayer.strokeEnd = CGFloat(progress)/100.0
                switch device {
                case "NP2":
                    percentageL!.text = "\(Int(progress))"
                default:
                    break
                }
            }
        }
    }
    
    private var state: Int = -1 {
        didSet {
            if oldValue != state {
                progressLayer.strokeColor = progressColor?.cgColor
                progressBackgroundLayer.strokeColor = progressBackgroundColor?.cgColor
                roundLayer.strokeColor = roundColor?.cgColor
                roundLayer1.strokeColor = roundColor1?.cgColor
                roundLayer2.strokeColor = roundColor2?.cgColor
                roundLayer2.fillColor = roundColor2?.cgColor

            }
        }
    }
    
    var stateIcon: Int = -1 {
        didSet {
            if oldValue != stateIcon {
               
            }
        }
    }
    
    var device = ""
    
    
    // 视图创建，通过指定 frame
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
   // 视图创建，通过指定 storyboard
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup(){
        
        backgroundColor = UIColor.clear

        // 添加上，要动画的图层
        layer.addSublayer(progressBackgroundLayer)
        layer.addSublayer(progressLayer)
        
        layer.addSublayer(roundLayer)
        layer.addSublayer(roundLayer1)
        layer.addSublayer(roundLayer2)
        
        voltageL = UILabel.init(frame: bounds)
        voltageL?.text = "33.2V"
        addSubview(voltageL!)
        voltageL?.textColor = UIColor.white
        voltageL?.textAlignment = NSTextAlignment.center
        
        connectIV.frame = CGRect(x: bounds.size.width/2-30, y: bounds.size.height/2-30, width: 60, height: 60)
        addSubview(connectIV)
        //voltageL?.isHidden = true
        
        percentageL = UILabel.init(frame: CGRect(x: 0, y: bounds.size.width/2-28, width: bounds.size.width, height: 28))
        percentageL!.text = "0"
        addSubview(percentageL!)
        //percentageL?.font = UIFont(name: "HarmonyOS_Sans_Condensed_Light", size: 32)
        percentageL!.textColor = UIColor.white
        percentageL!.textAlignment = NSTextAlignment.center
        
        electricityIV.frame = CGRect(x: bounds.size.width/2-20, y: bounds.size.height/2+5, width: 40, height: 40)
        addSubview(electricityIV)
        electricityIV.contentMode = .center
        //percentageL?.isHidden = true
        //electricityIV.isHidden = true
        
        voltageL!.isHidden = true
        connectIV.isHidden = true
        percentageL!.isHidden = true
        electricityIV.isHidden = true
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 考虑到视图的布局，如通过 auto layout,
        // 需动画图层的布局，放在这里
        
        let x = frame.size.width / 2.0
        let y = frame.size.height / 2.0
        
        let progressPath = UIBezierPath(arcCenter: CGPoint(x: x, y: y), radius: (frame.size.width - progressWidth)/2, startAngle: angleToRadian(-90), endAngle: angleToRadian(270), clockwise: true)
        progressLayer.strokeEnd = CGFloat(progress)/100.0
        progressLayer.strokeColor = progressColor?.cgColor
        progressLayer.lineWidth = progressWidth
        progressLayer.path = progressPath.cgPath
  
        let progressBackgroundPath = UIBezierPath(arcCenter: CGPoint(x: x, y: y), radius: (frame.size.width - progressWidth)/2, startAngle: angleToRadian(-90), endAngle: angleToRadian(270), clockwise: true)
//        progressBackgroundLayer.strokeEnd = 1
        progressBackgroundLayer.strokeColor = progressBackgroundColor?.cgColor
        progressBackgroundLayer.lineWidth = progressBackgroundWidth
        progressBackgroundLayer.path = progressBackgroundPath.cgPath

        let roundPath = UIBezierPath(arcCenter: CGPoint(x: x, y: y), radius: (frame.size.width - progressWidth*2 - roundWidth)/2, startAngle: angleToRadian(-90), endAngle: angleToRadian(270), clockwise: true)
        roundLayer.strokeColor = roundColor?.cgColor
        roundLayer.lineWidth = roundWidth
        roundLayer.path = roundPath.cgPath
        
        let roundPath1 = UIBezierPath(arcCenter: CGPoint(x: x, y: y), radius: (frame.size.width - progressWidth*2 - roundWidth*2 - roundWidth1)/2, startAngle: angleToRadian(-90), endAngle: angleToRadian(270), clockwise: true)
        roundLayer1.strokeColor = roundColor1?.cgColor
        roundLayer1.lineWidth = roundWidth1
        roundLayer1.path = roundPath1.cgPath
        
        let roundPath2 = UIBezierPath(arcCenter: CGPoint(x: x, y: y), radius: (frame.size.width - progressWidth*2 - roundWidth*2 - roundWidth1*2 - roundWidth2)/2, startAngle: angleToRadian(-90), endAngle: angleToRadian(270), clockwise: true)
//        roundLayer2.fillColor = roundColor2?.cgColor
        roundLayer2.strokeColor = roundColor2?.cgColor
        roundLayer2.lineWidth = roundWidth2
        roundLayer2.path = roundPath2.cgPath
    
        //roundLayer.strokeEnd = 0.5

    }

    //MARK: 进度条进度值（可以设置是否播放动画，以及动画时间）
    /// progressValue 进度值，stateValue 状态值
    func setProgress(_ progressValue: Double,_ stateValue: Int) {

        progress = progressValue
        state = stateValue
        //进度条动画
        //        CATransaction.begin()
        //        CATransaction.setDisableActions(!anim)
        //        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name:
        //                                                                        CAMediaTimingFunctionName.easeInEaseOut))
        //        CATransaction.setAnimationDuration(duration)
//        progressLayer.strokeEnd = CGFloat(progress)/100.0
        //        CATransaction.commit()

    }
    
    func setProgress(_ progressValue: Double) {
        progress = progressValue
    }
    
    //MARK: 将角度转为弧度
    fileprivate func angleToRadian(_ angle: Double)->CGFloat {
        return CGFloat(angle/Double(180.0) * .pi)
    }
    
    // MARK: - 设置
    // MARK: 设置进度条圆角
    func progresslineRound() {
        progressLayer.lineCap = CAShapeLayerLineCap.round
    }
    
    // MARK: 设置进度条阴影
    func progressShadow() {
        progressLayer.shadowOpacity = 0.2
        progressLayer.shadowOffset = CGSize.zero
    }
    
    func setWidth(kProgressWidth: CGFloat, outerW: CGFloat,
                  mediumW: CGFloat, innerW: CGFloat) {
        progressWidth = kProgressWidth
        progressBackgroundWidth = kProgressWidth
        roundWidth = outerW
        roundWidth1 = mediumW
        roundWidth2 = innerW
    }
    func setWidth1(kProgressWidth: CGFloat, kRoundWidth: CGFloat) {
        progressWidth = kProgressWidth
        progressBackgroundWidth = kProgressWidth
        roundWidth = kRoundWidth
    }
    
    // MARK: 设置显示内容
    func setIsHiddenView(voltageBool: Bool, connectBool: Bool, percentageBool: Bool, electricityBool: Bool){
        voltageL?.isHidden = voltageBool
        connectIV.isHidden = connectBool
        percentageL?.isHidden = percentageBool
        electricityIV.isHidden = electricityBool
    }

    // MARK: 设置字体
    func setVoltageLUIFont(name: String, size: CGFloat) {
        voltageL!.font = UIFont(name: name, size: size)
    }
    func setPercentageLUIFont(name: String, size: CGFloat) {
        percentageL!.font = UIFont(name: name, size: size)
    }
    

//    func setColor1(_ kProgressColor: UIColor, _ kProgressBackgroundColor: UIColor,_ kRoundColor: UIColor,
//                  _ kRoundColor1: UIColor,_ kRoundColor2: UIColor) {
//
//        progressColor = kProgressColor
//        progressBackgroundColor = kProgressBackgroundColor
//        roundColor = kRoundColor
//        roundColor1 = kRoundColor1
//        roundColor2 = kRoundColor2
//
//        progressLayer.strokeColor = kProgressColor.cgColor
//        progressBackgroundLayer.strokeColor = kProgressBackgroundColor.cgColor
//        roundLayer.strokeColor = kRoundColor.cgColor
//        roundLayer1.strokeColor = kRoundColor1.cgColor
//        roundLayer2.strokeColor = kRoundColor2.cgColor
//        roundLayer2.fillColor = kRoundColor2.cgColor
//
//    }
    
    //由外往内
    func setColor(_ kProgressColor: UIColor, _ kProgressBackgroundColor: UIColor,_ outerColor: UIColor,
                  _ mediumColor: UIColor,_ innerColr: UIColor) {

        progressColor = kProgressColor
        progressBackgroundColor = kProgressBackgroundColor
        roundColor = outerColor
        roundColor1 = mediumColor
        roundColor2 = innerColr
        
        progressLayer.strokeColor = kProgressColor.cgColor
        progressBackgroundLayer.strokeColor = kProgressBackgroundColor.cgColor
        roundLayer.strokeColor = outerColor.cgColor
        roundLayer1.strokeColor = mediumColor.cgColor
        
        //最里层
        roundLayer2.strokeColor = innerColr.cgColor
        roundLayer2.fillColor = innerColr.cgColor
        
    }
    
    func setColor1(_ kProgressColor: UIColor, _ kProgressBackgroundColor: UIColor,_ kRoundColor: UIColor) {

        progressColor = kProgressColor
        progressBackgroundColor = kProgressBackgroundColor
        roundColor = kRoundColor
        
        progressLayer.strokeColor = kProgressColor.cgColor
        progressBackgroundLayer.strokeColor = kProgressBackgroundColor.cgColor
        roundLayer.strokeColor = kRoundColor.cgColor
        roundLayer1.strokeColor = kRoundColor.cgColor
        
        //最里层
        roundLayer2.strokeColor = kRoundColor.cgColor
        roundLayer2.fillColor = kRoundColor.cgColor
        
    }


    // 动画的方法
    func animateCircle(duration t: TimeInterval) {
        // 画圆形，就是靠 `strokeEnd`
        let animation = CABasicAnimation(keyPath: "strokeEnd")

        // 指定动画时长
        animation.duration = t

        // 动画是，从没圆，到满圆
        animation.fromValue = 0
        animation.toValue = 1

        // 指定动画的时间函数，保持匀速
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)

        // 视图具体的位置，与动画结束的效果一致
        //circleLayer.strokeEnd = 1.0

        // 开始动画
        //circleLayer.add(animation, forKey: "animateCircle")
    }

}

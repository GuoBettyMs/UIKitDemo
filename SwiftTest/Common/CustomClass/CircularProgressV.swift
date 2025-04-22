//
//  CircularProgressV.swift
//  SwiftTest
//
//  Created by user on 2024/12/16.
//
//自定义带镂空指示器的环形进度条

import UIKit
import SnapKit

/*
            -90
    180  圆心  0
            90
            
    0度 = 3点钟方向
    -90度(或270度) = 12点钟方向,起点-90度,终点270度
    90度 = 6点钟方向
    180度 = 9点钟方向
*/
class CircularProgressV: UIView {
    
        // MARK: - Public Properties
    var progressColor: UIColor = .red {
        didSet { circularProgressLayer.strokeColor = progressColor.cgColor }
    }
    var bgColor: UIColor = .yellow {
        didSet { bgfillLayer.fillColor = bgColor.cgColor }
    }
    var borderColor: UIColor = .systemGreen {
        didSet { bgBorderLayer.strokeColor = borderColor.cgColor }
    }
    var indicatorColor: UIColor = .random() {
        didSet { updateIndicatorColor() }
    }
    
    // MARK: - Private Properties
    private let circleW: CGFloat //主要用于内部计算和绘制圆形进度条,不是自身 view 的宽度
    private let hollowIndicatorR: CGFloat = 7.0 //指示点半径
    private let baseAngle = -90.0 //基准(起始)角度,12点钟方向(起点-90度,终点270度)
    private let indicatoraArcOffsetAngle = -180.0 // 圆弧偏移角度,因为指示终点圆弧仅显示位于进度条内侧的部分,画图可知,指示终点圆弧的起始角度与最终进度条角度相差180度
    private let indicatoraArcEndAngle = 90.0 //圆弧结束角度,取相对值 90 度,即1/4圆弧
    
    private let bgBorderLayer = CAShapeLayer() //背景边框 layer
    private let bgfillLayer = CAShapeLayer() //背景填充 layer
    private let circularProgressLayer = CAShapeLayer() //圆形进度条 layer
    private let circlePointV = CircleView() //进度指示点
    private var showIndicatorArc: Bool = true //进度指示点是否显示镂空圆弧
    
    //MARK: - 计算属性
    private var circularProgressR: CGFloat { circleW / 2 } // 进度条半径
    //当有进度时,为确保指示点内部镂空,圆形进度条边框线条不能是个整圆,弧长 = 圆心角（弧度）× 半径
    private var progressOffsetAngle: CGFloat { //进度条偏移量弧度
        return showIndicatorArc ? (hollowIndicatorR / circularProgressR) / .pi * 180 : 0
    }

        // MARK: - Initialization
    init(width: CGFloat) { //防止 CircularProgressV 偏移,设定其宽高时,需与 circleW 一致
        self.circleW = width
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods
    private func setupViews() {
        let bgLayerView = self
        setupLayers(in: bgLayerView)
        setupIndicator(in: bgLayerView)

        // 设置初始进度
        setPer(per: 0)
    }

    private func setupLayers(in view: UIView) {
        // 配置背景边框 layer
        configureBorderLayer(in: view)
        
        // 配置背景填充 layer
        configureFillLayer(in: view)
        
        // 配置进度条 layer
        configureProgressLayer(in: view)
    }
    
    private func configureBorderLayer(in view: UIView) {
        bgBorderLayer.frame = view.bounds
        view.layer.addSublayer(bgBorderLayer)
        bgBorderLayer.strokeColor = borderColor.cgColor
        bgBorderLayer.fillColor = UIColor.clear.cgColor
        bgBorderLayer.lineWidth = 1
    }
    
    private func configureFillLayer(in view: UIView) {
        bgfillLayer.frame = view.bounds
        view.layer.addSublayer(bgfillLayer)
        bgfillLayer.strokeColor = UIColor.clear.cgColor
        bgfillLayer.fillColor = bgColor.cgColor
    }
    
    private func configureProgressLayer(in view: UIView) {
        circularProgressLayer.frame = view.bounds
        view.layer.addSublayer(circularProgressLayer)
        circularProgressLayer.lineWidth = 1
        circularProgressLayer.strokeColor = progressColor.cgColor
        circularProgressLayer.fillColor = UIColor.clear.cgColor
    }
    
    private func setupIndicator(in view: UIView) {
        view.addSubview(circlePointV)
        circlePointV.frame = CGRect(x: 0, y: 0, 
                                  width: hollowIndicatorR * 2, 
                                  height: hollowIndicatorR * 2)
        updateIndicatorColor()
        circlePointV.setWidth(kProgressWidth: 2, outerW: 0, mediumW: 0, innerW: 0)
        circlePointV.setProgress(100)
        circlePointV.center = .zero
    }
    
    private func updateIndicatorColor() {
        circlePointV.setColor(indicatorColor, .clear, .clear, .clear, .clear)
    }
    // MARK: - Public Methods
    func setPer(per: CGFloat, showIndicator: Bool = true) {
        self.showIndicatorArc = showIndicator
        
        // 清除现有路径
        clearExistingPaths()
       
        // 计算必要的角度和位置
        let angles = calculateAngles(for: per)
        let indicatorCenter = calculateIndicatorCenter(with: angles.endRadian)
        
        // 绘制各个部分
        let bgPath = createBackgroundPath(per: per,
                                        angles: angles,
                                        indicatorCenter: indicatorCenter)
        let progressPath = createProgressPath(per: per,
                                              angles: angles)
        let borderPath = createBorderPath(per: per,
                                          angles: angles)
        
        // 更新层的路径
        updateLayerPaths(bgPath: per == 0 ? UIBezierPath().cgPath : bgPath,
                         progressPath: per == 0 ? UIBezierPath().cgPath : progressPath,
                        borderPath: borderPath)
        
        // 更新指示器位置
        circlePointV.isHidden = per == 0
        circlePointV.center = indicatorCenter
        
    }

        // MARK: - Helper Methods
    private func clearExistingPaths() {
        bgfillLayer.path = nil
        circularProgressLayer.path = nil
        bgBorderLayer.path = nil
    }
    
    private func calculateAngles(for per: CGFloat) -> (endRadian: CGFloat, 
                                                      endAngle: CGFloat, 
                                                      indicatorStart: CGFloat, 
                                                      indicatorEnd: CGFloat) {
        let endRadian = 2 * .pi * (per/100) - 0.5 * .pi
        let endAngle = 3.6 * per + baseAngle - progressOffsetAngle
        let indicatorStart = endAngle + indicatoraArcOffsetAngle
        let indicatorEnd = indicatorStart + indicatoraArcEndAngle > 360 ? indicatorStart + indicatoraArcEndAngle - 360 : indicatorStart + indicatoraArcEndAngle
        return (endRadian, endAngle, indicatorStart, indicatorEnd)
    }
    
    private func calculateIndicatorCenter(with endRadian: CGFloat) -> CGPoint {
        return CGPoint(x: circularProgressR * cos(endRadian) + circleW/2,
                      y: circularProgressR * sin(endRadian) + circleW/2)
    }

    private func createBackgroundPath(per: CGFloat,
                                      angles: (endRadian: CGFloat,
                                               endAngle: CGFloat,
                                               indicatorStart: CGFloat,
                                               indicatorEnd: CGFloat),
                                      indicatorCenter: CGPoint) -> CGPath{
        let bgMissingCornerLayerPath = UIBezierPath()
         if per == 100.0{
             //起点,指示点上的圆弧
             bgMissingCornerLayerPath.addArc(
                 withCenter: CGPoint(x: circleW/2, y: 0),
                 radius: hollowIndicatorR,
                 startAngle: angleToRadian(0),
                 endAngle: angleToRadian(90),
                 clockwise: true //顺时针
             )
         }else{
             bgMissingCornerLayerPath.move(to: CGPoint(x: circleW/2, y: 0))
         }

         //指示点圆心到进度条圆心
         bgMissingCornerLayerPath.addLine(to: CGPoint(x: circleW/2, y:  circleW/2))

         if showIndicatorArc{
             //终点,指示点上的圆弧
             bgMissingCornerLayerPath.addArc(
                 withCenter: indicatorCenter,
                 radius: hollowIndicatorR,
                 startAngle: angleToRadian(angles.indicatorStart),
                 endAngle: angleToRadian(angles.indicatorEnd),
                 clockwise: true//顺时针
             )
         }

         //圆形进度条上的圆弧
         bgMissingCornerLayerPath.addArc(
             withCenter: CGPoint(x: circleW/2, y: circleW/2),
             radius: circularProgressR,
             startAngle: angleToRadian(angles.endAngle),
             endAngle: angleToRadian(baseAngle),
             clockwise: false)//反向画弧,形成填充 layer
        
         //重新赋值背景填充 layer 路径
         bgMissingCornerLayerPath.close()// 闭合曲线
         
        return bgMissingCornerLayerPath.cgPath
    }
    
    private func createProgressPath(per: CGFloat,
                                    angles: (endRadian: CGFloat,
                                               endAngle: CGFloat,
                                               indicatorStart: CGFloat,
                                               indicatorEnd: CGFloat)) -> CGPath{
        return UIBezierPath(
            arcCenter: CGPoint(x: circleW/2, y: circleW/2),
            radius: circularProgressR,
            startAngle: angleToRadian(angles.endAngle),
            endAngle: angleToRadian(baseAngle + (per == 100.0 ? progressOffsetAngle : 0)),
            clockwise: false
        ).cgPath
    }
    
    private func createBorderPath(per: CGFloat,
                                  angles: (endRadian: CGFloat,
                                           endAngle: CGFloat,
                                           indicatorStart: CGFloat,
                                           indicatorEnd: CGFloat)) -> CGPath{
        return UIBezierPath(
            arcCenter: CGPoint(x: circleW/2, y: circleW/2),
            radius: circularProgressR,
            startAngle: angleToRadian(angles.endAngle + (per == 0.0 ? 0 : progressOffsetAngle * 2)),
            endAngle: angleToRadian(angles.endAngle),
            clockwise: true
        ).cgPath
    }
    
    func updateLayerPaths(bgPath: CGPath,
                          progressPath: CGPath,
                          borderPath: CGPath){
        bgfillLayer.path = bgPath
        circularProgressLayer.path = progressPath
        bgBorderLayer.path = borderPath
    }

}
// MARK: - Usage Example
extension CircularProgressV {
    static func example(in parent: UIView, width: CGFloat){
        let v = CircularProgressV(width: width)
        parent.addSubview(v)
        v.snp.makeConstraints { make in
            make.width.height.equalTo(width)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(20)
        }
        v.progressColor = .red
        v.borderColor = .green
        v.indicatorColor = .blue
        v.setPer(per: 10, showIndicator: true)
        
        let bgV = UIView()
        parent.addSubview(bgV)
        bgV.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.centerX.equalToSuperview()
            make.top.equalTo(v.snp.bottom).offset(20)
            make.bottom.equalTo(-20)
        }
        
        let configs = [
            CustomSliderConfig(
                title: "Slider 1",
                min: 0,
                max: 100,
                initialValue: 10,
                handler: { value, label in
                    label.text = String(format: "当前进度: %.1f", value)
                    v.setPer(per: CGFloat(value))
                }
            )
        ]
        let _ = CustomSlider.addMultiSlider(in: bgV, configs).0
        
    }
    
    static func example(width: CGFloat) -> CircularProgressV{
        let progressView = CircularProgressV(width: width)
        progressView.progressColor = .red
        progressView.borderColor = .green
        progressView.indicatorColor = .blue
        progressView.setPer(per: 75, showIndicator: true)
        return progressView
    }
}

//
//  CustomRectView.swift
//  SwiftTest
//
//  Created by user on 2024/8/2.
//

import UIKit

class CustomRectView: UIView {
    var animator: UIViewPropertyAnimator?
    var visualEffectView:UIVisualEffectView?
    
    var fillColor: UIColor? = UIColor(named: "top")!//UIColor.blue//
    var h: CGFloat = 100.0
    var offset = 0.0
    var display: CADisplayLink? = nil
    let topShapLayer = CAShapeLayer()
    
    deinit {
        print("CustomRectView deinit")
        display?.invalidate()
    }
    
    // MARK: 增加波浪
    @objc func drawWaveLine(){
        
        offset += 0.02
        if offset > 60 * .pi {
            offset = 0
        }
        
        var topY: CGFloat = 45
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: 100, y: 45))
        // 从左向右画
        for x in Int(100)...Int(363) {//
            /*标准正弦波浪曲线函数f(x) = Asin(ωx + ψ) + D
            A表示振幅决定峰值，A越大波浪越陡，A为0时无波浪为直线。
            ω决定周期，周期T= 2π/ω。ω越大周期越小波浪越密集
            ψ控制正弦波浪曲线在x轴方向上的平移
            D控制波浪曲线在y轴方向上的平移
             */
            
            topY = 2 * cos((0.1) * Double(x) + offset + 23) - 0.16 * Double(x) + 60
            //电量小于3%时保持最小波浪振幅
//            let progressRatio = eletricQuanInt < 3 ? 3 : eletricQuanInt
            
            //将点连成线
            path.addLine(to: CGPoint(x: CGFloat(x) , y: topY))
        }

        path.addLine(to: CGPoint(x: 421, y: 40))
        // 从右向左画
        for x in stride(from: 421, to: 163, by: -1) {
            let topY = 2 * cos((0.1) * Double(x) + offset + 23) - 0.16 * Double(x) + 112
            path.addLine(to: CGPoint(x: CGFloat(x), y: topY))
        }
        path.addLine(to: CGPoint(x: 100, y: 45))
        path.close()
        
        topShapLayer.frame = CGRectMake(0, 0, UIScreen.main.bounds.width, 80)
        topShapLayer.lineWidth = 0
        topShapLayer.backgroundColor = UIColor.clear.cgColor
        topShapLayer.fillColor = fillColor?.cgColor
        topShapLayer.path = path.cgPath
        layer.addSublayer(topShapLayer)
    }

    override func draw(_ rect: CGRect) {
        
        guard UIGraphicsGetCurrentContext() != nil else {return }
        
        display = CADisplayLink(target: self, selector: #selector(drawWaveLine))
        display!.add(to: .current, forMode: .common)

//        context.move(to: CGPoint(x: 100, y: 45))
//        context.addLine(to: CGPoint(x: 363, y: 2))
//        context.addLine(to: CGPoint(x: 421, y: 40))
//        context.addLine(to: CGPoint(x: 163, y: 80))
//        context.addLine(to: CGPoint(x: 100, y: 45))
//        context.setFillColor(UIColor(named: "top")!.cgColor)
//        context.fillPath()
    
        let path1 = UIBezierPath()
        path1.move(to: CGPoint(x: 100, y: 45))
        path1.addLine(to: CGPoint(x: 100, y: 45+h))
        path1.addLine(to: CGPoint(x: 163, y: 80+h))
        path1.addLine(to: CGPoint(x: 163, y: 80))
        
        path1.close()
        UIColor(named: "left")!.setFill()
        path1.fill()
        
        
        let path3 = UIBezierPath()
        path3.move(to: CGPoint(x: 163, y: 80))
        path3.addLine(to: CGPoint(x: 367, y: 49))
        path3.addLine(to: CGPoint(x: 367, y: 126))
        path3.addLine(to: CGPoint(x: 163, y: 162))
        
        path3.close()
        UIColor(named: "inner")!.setFill()
        path3.fill()
        
        let path2 = UIBezierPath()
        path2.move(to: CGPoint(x: 421, y: 40))
        path2.addLine(to: CGPoint(x: 421, y: 40+h))
        path2.addLine(to: CGPoint(x: 163, y: 80+h))
        path2.addLine(to: CGPoint(x: 163, y: 80))
        
        path2.close()
        UIColor(named: "front")!.setFill()
        path2.fill()

    }
}


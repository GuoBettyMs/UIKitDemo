//
//  DemoV.swift
//  SwiftTest
//
//  Created by user on 2024/11/29.
//

import UIKit
import SnapKit
import AAInfographics

class DemoV: BaseV {
    //表格数据
    let adaptiveSizeV = UIView()
    let adaptiveSizeL = UILabel()
    
    //表格数据
    let shareExcelBtn = UIButton()
    
    //线性表, 重新更改 class, AAChartView、AASeriesElement、AAOptions、AAChartModel
    //AAChart、 AAYAxis、 AAXAxis、 AADataLabels、 AAStyle、 AALabels、 AAPlotLinesElement、
    var aaOptions = AAOptions()
    let chartModel = AAChartModel()
    let chartView = AAChartView()
    
    //时区
    var timeZoneL = UILabel()
    var timeZoneData:[String] = []
    
    //扩大点击范围
    let customExpandedTapView = CustomExpandedTapView()
    
    //view 的 frame 和 bounds 区别
    let viewA = UIView()
    var btns: [UIButton] = []
    

    /// - Returns:
    /// 纯代码加载UIView
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        
        contentView.backgroundColor = .white
        adaptiveV()
        
    }
    
    func adaptiveV(){
        let size1 = ViewSizeCalculator.calculateAdaptiveSize(
            designWidth: 621.052,
            designHeight: 203.829,
            designFontSize: 30.909,
            designCornerRadius: 68.367
        )

        contentView.addSubview(adaptiveSizeV)
        adaptiveSizeV.snp.makeConstraints { make in
            make.width.equalTo(size1.width)
            make.height.equalTo(size1.height)
            make.top.equalToSuperview().offset(20)
            make.bottom.equalTo(-20)
            make.centerX.equalToSuperview()
        }
        adaptiveSizeV.layer.cornerRadius = size1.cornerRadius
        adaptiveSizeV.backgroundColor = .random()
        
        adaptiveSizeV.addSubview(adaptiveSizeL)
        adaptiveSizeL.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        adaptiveSizeL.font = UIFont.systemFont(ofSize: size1.fontSize)//字体高度
        adaptiveSizeL.adjustsFontSizeToFitWidth = true
        adaptiveSizeL.text = "输出 1 "

        Log.debug("print size1: \(size1), ")
    }
    
    //MARK: 圆形进度条
    func demo_circularProgressV(){
        let circleW = (devicePageContentW+40)*0.59
        let v = CircularProgressV.example(width: circleW)
        contentView.addSubview(v)
        v.snp.makeConstraints { make in
            make.width.height.equalTo(circleW)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(20)
            make.bottom.equalTo(-20)
        }
    }
    
    //MARK: 扩大点击范围
    /// - Returns:
    /// - 扩大点击范围
    func demo_expandClickedV(){

        let labelBGV = UIView()
        contentView.addSubview(labelBGV)
        labelBGV.snp.remakeConstraints{ make in
            make.width.equalTo(100)
            make.height.equalTo(200)
            make.left.top.bottom.equalToSuperview()//确定 contentView 范围
        }
        labelBGV.backgroundColor = .random()
        labelBGV.addSubview(customExpandedTapView)
        
        customExpandedTapView.frame = CGRect(x: 0, y: 0, width: 50, height: 200)
//        customExpandedTapView.inset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
//        customExpandedTapView.setLabeltext(text: "label")
        
    }

    //MARK: frame与Bounds的区别
    /// - Returns:
    /// -  frame与Bounds的区别
    func demo_frameAndBouonds(){

        contentView.snp.remakeConstraints{ make in
            make.width.equalTo(200)
            make.center.equalToSuperview()
            make.height.equalTo(200) // 确定的宽度，因为垂直滚动
        }
        
        let bgV = UIView()
        contentView.addSubview(bgV)
        bgV.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        bgV.bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
        bgV.backgroundColor = .gray

        contentView.addSubview(viewA)
        viewA.bounds = CGRect(x: 0, y: 0, width: 100, height:100)
        viewA.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        viewA.backgroundColor = .random()
        
        let childL = UILabel()
        viewA.addSubview(childL)
        childL.backgroundColor = .random()
        childL.frame = CGRect(x: 0, y: 0, width: 50, height: 20)
        childL.text = "子视图"
        
        let bottomStackV = UIStackView()
        addSubview(bottomStackV)
        bottomStackV.snp.makeConstraints { make in
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
            make.width.centerX.equalToSuperview()
            make.height.equalTo(80)
        }
        bottomStackV.axis = .horizontal
        bottomStackV.alignment = .fill//调整子视图以适应空间变化
        bottomStackV.distribution = .fillEqually//子控件在排列方向上的填充大小相同
        bottomStackV.spacing = 5
        
        let bottomMenuVStrs = ["修改 frame size", "修改 frame xy", "修改 bounds size", "修改 bounds xy", "position " , "anchorPoint","复原"]
        for i in 0..<bottomMenuVStrs.count{
            let bottomMenuV = UIButton()
            bottomStackV.addArrangedSubview(bottomMenuV)
            bottomMenuV.backgroundColor = .random()
            bottomMenuV.isUserInteractionEnabled = true
            bottomMenuV.setTitle(bottomMenuVStrs[i], for: .normal)
            bottomMenuV.titleLabel?.numberOfLines = 0
            bottomMenuV.titleLabel?.lineBreakMode = .byWordWrapping
            bottomMenuV.titleLabel?.textAlignment = .center
            btns.append(bottomMenuV)
        }

    }

}


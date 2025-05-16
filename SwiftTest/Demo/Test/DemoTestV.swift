//
//  DemoTestV.swift
//  SwiftTest
//
//  Created by user on 2025/4/16.
//

import UIKit
import SnapKit

class DemoTestV: BaseV {

    // MARK: - Public Properties
    //frame 和 bounds 的区别
    var parentV = UIView()
    var childV = UIView()
    let resetBtn = UIButton()
    var sliders: [UISlider] = []
    var sliderValueLs: [UILabel] = []

    //扩大点击范围
    let customExpandedTapView = CustomExpandedTapView()
    var sheetAddBtns: [UIButton] = []
    let xlsxTextView = UITextView()
    
    //时区
    let timeZonePicker = UIPickerView()
    
    // MARK: - Private Properties
    private let rectResultL = UILabel()
    private var timeZoneL = UILabel()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        additionalSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    private func additionalSetup(){
        
    }
    // MARK: - Public Methods
    
    //MARK: frameAndBouonds
    func demo_frameAndBouonds(){

        let initWidth = 100.0
        let initHeight = 100.0
        
        parentV = UIView()
        contentView.addSubview(parentV)
        parentV.frame = CGRect(x: 0, y: 0, width: initWidth, height: initHeight)
        parentV.bounds = CGRect(x: 0, y: 0, width: initWidth, height: initHeight)
        parentV.backgroundColor = .random().withAlphaComponent(0.5)
        parentV.addCorner(corners: .topRight, radius: 20)

        childV = UIView()
        contentView.addSubview(childV)
        childV.bounds = CGRect(x: 0, y: 0, width: initWidth, height: initHeight)
        childV.frame = CGRect(x: 0, y: 0, width: initWidth, height: initHeight)
        childV.backgroundColor = .random().withAlphaComponent(0.5)
        childV.addCorner(corners: .bottomRight, radius: 20)
        
        contentView.addSubview(rectResultL)
        rectResultL.textColor = .black
        rectResultL.numberOfLines = 0
        rectResultL.text = "result"
        rectResultL.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview().offset(50)
        }

        contentView.addSubview(resetBtn)
        resetBtn.setTitle("复原childV", for: .normal)
        resetBtn.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.height.equalTo(50)
            make.top.equalTo(rectResultL.snp.bottom)
            make.centerX.equalTo(rectResultL.snp.centerX)
        }

    }
    
    func setupSliderArr(_ sliderConfigs: [CustomSliderConfig]){
        
        // 添加 UIScrollView
        let scrollView = UIScrollView()
        contentView.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(resetBtn.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom) //scrollView 的约束
            make.bottom.equalToSuperview() //完善 contentView 高度约束
        }
        
        let sliderBGV = UIView()
        // 添加内容容器
        scrollView.addSubview(sliderBGV)
        sliderBGV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview() // 内容宽度等于屏幕宽度
        }
        
        (sliders, sliderValueLs) = CustomSlider.addMultiSlider(in: sliderBGV, sliderConfigs)

    }
    
    func setupResultText(_ text: String) {
        rectResultL.text = text
    }

    func setupSliderValueLabel(for sliderValueL: UILabel, _ text: String){
        sliderValueL.text = text
    }

    //MARK: shareSheet
    func demo_expandClickedV(){

        let size1 = ViewSizeCalculator.calculateAdaptiveSize(
            designWidth: 621.052,
            designHeight: 203.829,
            designFontSize: 30.909, //字体高度
            designCornerRadius: 68.367
        )
    
        let btnStackV = UIStackView()
        contentView.addSubview(btnStackV)
        btnStackV.snp.remakeConstraints{ make in
            make.height.equalTo(50)
            make.top.equalToSuperview()
            make.left.right.equalToSuperview().inset(20)
        }
        btnStackV.axis = .horizontal
        btnStackV.alignment = .center
        btnStackV.distribution = .fillEqually
        btnStackV.spacing = 0
        
        for i in 0...2{
            let addRandomBtn = UIButton()
            btnStackV.addArrangedSubview(addRandomBtn)
            addRandomBtn.snp.remakeConstraints{ make in
                make.top.equalToSuperview()
                make.bottom.equalToSuperview()
            }
            addRandomBtn.setTitle("表\(i+1)随机添加", for: .normal)
            sheetAddBtns.append(addRandomBtn)
        }
        
        let labelBGV = UIView()
        contentView.addSubview(labelBGV)
        labelBGV.snp.makeConstraints{ make in
            make.width.equalTo(size1.width)
            make.height.equalTo(size1.height)
            make.top.equalTo(btnStackV.snp.bottom).offset(30)//确定 contentView 范围
            make.centerX.equalToSuperview()
        }
        labelBGV.backgroundColor = .green
        labelBGV.layer.cornerRadius = size1.cornerRadius

        labelBGV.addSubview(customExpandedTapView)
        customExpandedTapView.snp.remakeConstraints{ make in
            make.width.equalTo(100)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        customExpandedTapView.backgroundColor = .blue
        customExpandedTapView.tapAreaInsets = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
        customExpandedTapView.setLabelText("分享表格 parentview", fontSize: 14)
        
        let btn = UIButton()
        customExpandedTapView.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.width.equalTo(80)
            make.height.equalTo(30)
            make.center.equalToSuperview()
        }
        btn.backgroundColor = .yellow
        btn.setTitle("subview", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self, action: #selector(expandedSubviewClick), for: .touchUpInside)
        
        
        let label = UILabel()
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.top.equalTo(labelBGV.snp.bottom).offset(50)
        }
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.text = "parentV: greenColor\ncustomExpandedTapView: blueColor\nsubview: yellowColor"
        
        contentView.addSubview(xlsxTextView)
        xlsxTextView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(10)
            make.top.equalTo(label.snp.bottom).offset(10)
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom) //textView 底部与安全区域底部对齐
            make.bottom.equalToSuperview() //textView 底部约束与 contentView 底部对齐,确定 contenView 高度
        }
        xlsxTextView.translatesAutoresizingMaskIntoConstraints = false
        xlsxTextView.layer.borderColor = UIColor.red.cgColor
        xlsxTextView.layer.borderWidth = 2
        xlsxTextView.font = .systemFont(ofSize: 14)
        xlsxTextView.textColor = .black
        xlsxTextView.isEditable = true
        xlsxTextView.text = "formattedDisplayText"
        
    }
    
    @objc func expandedSubviewClick(){
        print("分享表格按钮的子 view")
    }
    
    func setupXlsxTextViewText(_ text: String){
        xlsxTextView.text = "\(text)"
    }

    
    //MARK: circularProgressV
    func demo_circularProgressV(){
        
        let circleW = (devicePageContentW+40)*0.59
        CircularProgressV.example(in: contentView, width: circleW)

    }
    
    //MARK: timeZonePicker
    func demo_timeZonePicker(){

        contentView.addSubview(timeZonePicker)
        timeZonePicker.snp.remakeConstraints{ make in
            make.height.equalTo(200)
            make.left.top.right.equalToSuperview()
        }

        contentView.addSubview(timeZoneL)
        timeZoneL.snp.makeConstraints { make in
            make.top.equalTo(timeZonePicker.snp.bottom).offset(8)
            make.width.right.bottom.equalToSuperview()
        }
        timeZoneL.numberOfLines = 0
        timeZoneL.lineBreakMode = .byWordWrapping
        timeZoneL.textAlignment = .center
        timeZoneL.text = "timeZoneL"
        
    }
    
    func setupTimeZoneLabel(_ text: String){
        timeZoneL.text = text
    }

    
    // MARK: - Helper Methods

    
}




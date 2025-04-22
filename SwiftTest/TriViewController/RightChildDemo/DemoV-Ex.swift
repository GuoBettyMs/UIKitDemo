//
//  DemoV-Ex.swift
//  SwiftTest
//
//  Created by user on 12/4/24.
//

import Foundation
import UIKit
import SnapKit
import AAInfographics


extension DemoV{
    
    
    //MARK: 存储表格数据
    func demo_shareExcelData(){
        
        contentView.snp.remakeConstraints{ make in
            make.width.equalTo(200)
            make.center.equalToSuperview()
            make.height.equalTo(200) // 确定的宽度，因为垂直滚动
        }
        
        contentView.addSubview(shareExcelBtn)
        shareExcelBtn.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.center.equalToSuperview()
        }
        shareExcelBtn.setTitle("saveExcel", for: .normal)
        shareExcelBtn.backgroundColor = .random()
        
    }
    
    //MARK: 线性表
    func demo_chartV(){
        contentView.addSubview(chartView)
        chartView.snp.makeConstraints { make in
            make.height.equalTo((devicePageContentW+40)*0.522)
            make.left.equalTo(8)
            make.right.equalTo(-8)
            make.top.equalTo(8)
            make.bottom.equalToSuperview()
        }
        chartView.isClearBackgroundColor = true
        
        chartModel
            .chartType(.column)
            .stacking(.normal)
            .borderRadius(2.5)
            .legendEnabled(false)//是否启用图表的图例(图表底部的可点击的小圆点)
            .tooltipEnabled(false)
            .series([0])

        aaOptions = chartModel.aa_toAAOptions()
        
        aaOptions.yAxis?
            .tickPositions([0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0])//设置量程
            .gridLineDashStyle(.shortDot)
            .gridLineWidth(0.3)
            .gridLineColor("#E6E6E6")
            .labels?
            .align("center")//标签居中对齐
            .formatter("""
            function () {
                let yValue = this.value;
                if (yValue > 5){
                    return '';
                }
                return yValue == 0 ? yValue : yValue.toFixed(1);
            }
            """)
            .style(AAStyle(color: "#B3B3B3", fontSize: 9, weight: .thin))
            .x(-6)//y 轴标签在水平方向上的位移
        
        aaOptions.xAxis?
            .min(-0.3)//修改0值,同时修改 plotLines 的 value, 将第0根柱子与第一根柱子的间距增大
            .max(15.3)
            .categories({
                var categoriesArr:[String] = []
                for i in 0...15{
                    let str = i >= 9 ? "\(i+1)" : "0\(i+1)"
                    categoriesArr.append(str)
                }
                return categoriesArr
            }())
            .plotLines([
                AAPlotLinesElement() //设置x轴最左侧的指定网格线
                    .color("#E6E6E6")
                    .width(0.3)
                    .value(-0.8) //代表线的位置,其位置不能超过 x 轴最小值左侧的0.5个单位(即-0.3-0.5=-0.8)
                    .dashStyle(.shortDot)
                ,
                AAPlotLinesElement()
                    .color("#E6E6E6")
                    .width(0.3)
                    .value(15.8)
                    .dashStyle(.shortDot)
            ])
            .lineColor(AAColor.clear)//x轴轴线颜色
            .gridLineWidth(0)//隐藏网格线
            .tickInterval(0)
            .labels?
            .rotation(0)
            .formatter("""
            function () {
                return this.value < 0 || this.value > 16 ? '' : this.value;
            }
            """)//this.value 标签的显示
            .style(AAStyle(color: "#B3B3B3", fontSize: 9, weight: .thin))
            .y(15)
 
        chartView.aa_drawChartWithChartOptions(aaOptions)
        
        
        let seriesDataArr = [4000,3800,3900,3000,3900,2000,3800,3900,4000,3800,3090,3490,2000,3580,3090,3900]
        updateChartVSeries(0, seriesDataArr)

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3, execute: {
            
            updateChartVSeries(0, [2000,3800,3900,3000,3900,2000,3800,3900,4000,3800,3090,3490,2000,3580,3090,3900])
        })
        
        //仅更新线性表数据
        func updateChartVSeries(_ battType: Int, _ dataArr: [Int], _ tvd: Int = 15){
     
            let overVoltage = battType == 0 ? 4200 : 3600
            let underVoltage = battType == 0 ? 2500 : 2700
            let maxVol = Float(dataArr.max() ?? 0)
            
            chartView.aa_onlyRefreshTheChartDataWithChartModelSeries([
                AASeriesElement()
                    .data({
                        var newseriesDataArr = [[String: Any]]()
                        dataArr.forEach { dataElement in
                            let dataElementValue = Float(dataElement)
                            if dataElementValue > Float(overVoltage) || dataElementValue < Float(underVoltage){
                                let underVolDataEle = AADataElement()
                                    .y((dataElementValue/1000))
                                    .color("#FF605F")
                                newseriesDataArr.append(underVolDataEle.toDic()!)
                            }else if dataElementValue < Float(overVoltage) && Int(maxVol-dataElementValue) > tvd{
                                let balanceDataEle = AADataElement()
                                    .y((dataElementValue/1000))
                                    .color("#FF9137")
                                newseriesDataArr.append(balanceDataEle.toDic()!)
                            }else{
                                let normalDataEle = AADataElement()
                                    .y((dataElementValue/1000))
                                    .color("#24C883")
                                newseriesDataArr.append(normalDataEle.toDic()!)
                            }
                        }
                        return newseriesDataArr
                    }()),
            ])

        }
    }
    
    //MARK: 时区选择器
    func demo_timeZonePicker(){
        
        timeZoneData = TimeZone.knownTimeZoneIdentifiers
        
        let pickerV = UIPickerView()
        contentView.addSubview(pickerV)
        pickerV.snp.remakeConstraints{ make in
            make.height.equalTo(200)
            make.left.top.right.equalToSuperview()
        }
        pickerV.dataSource = self
        pickerV.delegate = self

        contentView.addSubview(timeZoneL)
        timeZoneL.snp.makeConstraints { make in
            make.top.equalTo(pickerV.snp.bottom).offset(8)
            make.width.right.bottom.equalToSuperview()
        }
        timeZoneL.numberOfLines = 0
        timeZoneL.lineBreakMode = .byWordWrapping
        timeZoneL.textAlignment = .center
        timeZoneL.text = "timeZoneL"
        
    }
}


extension DemoV: UIPickerViewDelegate{
    //MARK: 时区选择器-UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return timeZoneData[row]
    }
}
//MARK: 时区选择器-UIPickerViewDataSource
extension DemoV: UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timeZoneData.count
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        let timeAPIURL = URL(string: "https://www.isdt.co/ota/newbleTest.json")!
        // 安全检查
        guard timeZoneData.indices.contains(row) else { return }
        
        let selectedTimeZone = timeZoneData[row]
        print("Selected: \(row), \(selectedTimeZone), \(TimeZone.current.identifier)")
        
        getNetWorkTime(
            urlString: timeAPIURL.absoluteString,
            isFollowSystem: false ,
            timeZoneIden: timeZoneData[row]
        ) { times in
            self.timeZoneL.text = """
            所选时区当前时间: \(times.selectedTime)
            设备的系统当前时间: \(times.systemTime)
            服务器时间: \(times.serverTime)
            服务器时间转换后: \(times.convertedTime)
            """
        }
    }
}

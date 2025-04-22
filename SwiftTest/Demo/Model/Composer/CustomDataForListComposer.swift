//
//  CustomDataForListComposer.swift
//  SwiftTest
//
//  Created by user on 2025/4/11.
//
/**
    列表编辑器的自定义数据
**/

class CustomDataForListComposer {

    static private func baseData() -> BaseModel {
        BaseModel()
            .sectionTitleArr([
                "Basic Type Chart | 基础类型图表",
                "Special Type Chart | 特殊类型图表",
                "Custom Style Chart| 一些自定义风格样式图表",
                "Mixed Chart | 混合图形",
                "Pie Chart With Custom Style | 一些自定义风格样式饼图",
                "Column Chart With Custom Style | 一些自定义风格样式柱状图",
                "Bar Chart With Custom Style | 一些自定义风格样式条形图",
                "Line Chart With Custom Style | 一些自定义风格样式折线图",
                "Spine Chart With Custom Style | 一些自定义风格样式曲线图",
                "Area Chart With Custom Style | 一些自定义风格样式折线填充图",
                "Areaspline Chart With Custom Style | 一些自定义风格样式曲线填充图",
                "Scatter Chart With Custom Style | 一些自定义风格样式散点图",
                "Bubble Chart With Custom Style | 一些自定义风格样式气泡图",
            ])
            .cellTitleArr([
                [
                    "Column Chart---柱状图",
                    "Bar Chart---条形图",
                    "Area Chart---折线填充图",
                    "Areaspline Chart---曲线填充图",
                    "Step Area Chart---直方折线填充图",
                    "Step Line Chart---直方折线图",
                    "Line Chart---折线图",
                    "Spline Chart---曲线图",
                ],
                [
                    "Polar Column Chart---玫瑰图",
                    "Polar Bar Chart---径向条形图",
                    "Polar Line Chart---蜘蛛图",
                    "Polar Area Chart---雷达图",
                    "Step Line Chart---直方折线图",
                    "Step Area Chart---直方折线填充图",
                    "Pie Chart---扇形图",
                    "Bubble Chart---气泡图",
                    "Scatter Chart---散点图",
                    "Arearange Chart---折线区域范围图",
                    "Area Spline range Chart--曲线区域范围图",
                    "Columnrange Chart---柱形范围图",
                    "Boxplot Chart---箱线图",
                    "Waterfall Chart---瀑布图",
                    "Pyramid Chart---金字塔图",
                    "Funnel Chart---漏斗图",
                    "Error Bar Chart---误差图",
                    "Gauge Chart---仪表图",
                    "Polygon Chart---多边形图"
                ],
            [],[],[],[],[],[],[],[],[],[],[]])
       
    }
    
    static func table() -> BaseModel {
        baseData().listType(.table)
    }
    
    static func collection() -> BaseModel {
        baseData().listType(.collection)
    }
    
    static func none() -> BaseModel {
        baseData().listType(.none)
    }
}

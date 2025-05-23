//
//  AAChartModel.swift
//  AAChartKit-Swift
//
//  Created by An An  on 17/4/19.
//  Copyright © 2017年 An An . All rights reserved.
//*************** ...... SOURCE CODE ...... ***************
//***...................................................***
//*** https://github.com/AAChartModel/AAChartKit        ***
//*** https://github.com/AAChartModel/AAChartKit-Swift  ***
//***...................................................***
//*************** ...... SOURCE CODE ...... ***************

/*
 
 * -------------------------------------------------------------------------------
 *
 *  🌕 🌖 🌗 🌘  ❀❀❀   WARM TIPS!!!   ❀❀❀ 🌑 🌒 🌓 🌔
 *
 * Please contact me on GitHub,if there are any problems encountered in use.
 * GitHub Issues : https://github.com/AAChartModel/AAChartKit-Swift/issues
 * -------------------------------------------------------------------------------
 * And if you want to contribute for self project, please contact me as well
 * GitHub        : https://github.com/AAChartModel
 * StackOverflow : https://stackoverflow.com/users/12302132/codeforu
 * JianShu       : https://www.jianshu.com/u/f1e6753d4254
 * SegmentFault  : https://segmentfault.com/u/huanghunbieguan
 *
 * -------------------------------------------------------------------------------
 
 */

 public enum AAChartAnimationType: Int {
    case linear
    case easeInQuad
    case easeOutQuad
    case easeInOutQuad
    case easeInCubic
    case easeOutCubic
    case easeInOutCubic
    case easeInQuart
    case easeOutQuart
    case easeInOutQuart
    case easeInQuint
    case easeOutQuint
    case easeInOutQuint
    case easeInSine
    case easeOutSine
    case easeInOutSine
    case easeInExpo
    case easeOutExpo
    case easeInOutExpo
    case easeInCirc
    case easeOutCirc
    case easeInOutCirc
    case easeOutBounce
    case easeInBack
    case easeOutBack
    case easeInOutBack
    case elastic
    case swingFromTo
    case swingFrom
    case swingTo
    case bounce
    case bouncePast
    case easeFromTo
    case easeFrom
    case easeTo
}

public enum AAChartType: String {
    case column
    case bar
    case area
    case areaspline
    case line
    case spline
    case scatter
    case pie
    case bubble
    case pyramid
    case funnel
    case columnrange
    case arearange
    case areasplinerange
    case boxplot
    case waterfall
    case polygon
    case gauge
    case errorbar
}

public enum AAChartLayoutType: String {
    case horizontal, vertical
}

public enum AAChartAlignType: String {
    case left, center, right
}

public enum AAChartVerticalAlignType: String {
    case top, middle, bottom
}

public enum AAChartZoomType: String {
    case none, x, y, xy
}

public enum AAChartStackingType: String {
    case none = "", normal, percent
}

public enum AAChartSymbolType: String {
    case circle, square, diamond, triangle, triangleDown  = "triangle-down"
}

public enum AAChartSymbolStyleType: String {
    case normal, innerBlank, borderBlank
}

public enum AAChartFontWeightType: String {
    case thin, regular, bold
}

public enum AAChartLineDashStyleType: String {
    case solid
    case shortDash
    case shortDot
    case shortDashDot
    case shortDashDotDot
    case dot
    case dash
    case longDash
    case dashDot
    case longDashDot
    case longDashDotDot
}


public class AAChartModel: AAObject {
    public var animationType: AAChartAnimationType? //The type of chart animation
    public var animationDuration: Int?      //The chart rendering animation duration
    public var title: String?               //The chart title
    public var titleStyle: AAStyle?         //The chart title style
    public var subtitle: String?            //The chart subtitle
    public var subtitleAlign: AAChartAlignType?//The chart subtitle text align style
    public var subtitleStyle: AAStyle?      //The chart subtitle style
    public var chartType: AAChartType?      //The default series type for the chart. Can be any of the chart types listed under `AAChartType`. Defaults to line
    public var stacking: AAChartStackingType? //Whether to stack the values of each series on top of each other. Possible values are null to disable, "normal" to stack by value or "percent". When stacking is enabled, data must be sorted in ascending X order
    public var markerSymbol: AAChartSymbolType?   //A predefined shape or symbol for the marker. When null, the symbol is pulled from options.symbols. Other possible values are "circle", "square", "diamond", "triangle" and "triangle-down"
    public var markerSymbolStyle: AAChartSymbolStyleType?
    public var zoomType: AAChartZoomType?   //Decides in what dimensions the user can zoom by dragging the mouse. Can be one of x, y or xy
    public var inverted: Bool?              //Whether to invert the axes so that the x axis is vertical and y axis is horizontal. When true, the x axis is reversed by default. If a bar series is present in the chart, it will be inverted automatically.Inverting the chart doesn't have an effect if there are no cartesian series in the chart, or if the chart is polar.Defaults to false
    public var xAxisReversed: Bool?         //Whether to reverse the axis so that the highest number is closest to the origin. If the chart is inverted, the x axis is reversed by default. Defaults to false
    public var yAxisReversed: Bool?         //Whether to reverse the axis so that the highest number is closest to the origin. If the chart is inverted, the x axis is reversed by default. Defaults to false
    public var polar: Bool?                 //When true, cartesian charts like line, spline, area and column are transformed into the polar coordinate system. Requires `AAHighchartsMore.js`. Defaults to false
    public var margin: [Any]?
    public var dataLabelsEnabled: Bool?     //Enable or disable the data labels. Defaults to false
    public var dataLabelsStyle: AAStyle?    //The data labels style
    public var xAxisLabelsEnabled: Bool?    //Enable or disable the axis labels. Defaults to true
    public var xAxisLabelsStyle: AAStyle?   //The x axis labels style
    public var categories: [String]?        //Set new categories for the axis
    public var xAxisGridLineWidth: Float?   //The width of the grid lines extending the ticks across the plot area.Defaults to 0
    public var xAxisVisible: Bool?          //Show the x axis or not
    public var xAxisTickInterval: Float?    //Custom x axis tick interval,It is useful when the x categories array is too long to show all of them
    public var yAxisVisible: Bool?          //Show the y axis or not
    public var yAxisLabelsEnabled: Bool?    //Enable or disable the axis labels. Defaults to true
    public var yAxisLabelsStyle: AAStyle?   //The y axis labels style
    public var yAxisTitle: String?          //The actual text of the axis title
    public var xAxisTitle: String?          //The actual text of the axis title
    public var yAxisLineWidth: Float?       //The width of y axis line
    public var yAxisGridLineWidth: Float?   //The width of the grid lines extending the ticks across the plot area. Defaults to 1
    public var yAxisMin: Double?            //The y axis mini value
    public var yAxisMax: Double?            //The y axis max value
    public var yAxisTickPositions:[Any]?    //An array defining where the ticks are laid out on the axis. This overrides the default behaviour of tickPixelInterval and tickInterval.
    public var yAxisAllowDecimals: Bool?    //The y axis values label allow decimals or not
    public var tooltipEnabled: Bool?        //Show the tooltip or not
    public var tooltipValueSuffix: String?  //Custom tooltip value unit suffix
    public var colorsTheme: [Any]?          //An array containing the default colors for the chart's series. When all colors are used, new colors are pulled from the start again. Defaults to: ["#bb250c","#f67210","#fde680","#257679","#f1c6c5"]
    public var series: [Any]?               //An array of all the chart's series
    public var legendEnabled: Bool?         //Enable or disable the legend. Defaults to true
    public var backgroundColor: Any?        //The background color or gradient for the outer chart area. Defaults to #FFFFFF
    public var borderRadius: Float?         //The corner radius of the outer chart border. Defaults to 0
    public var markerRadius: Float?         //The radius of the point marker. Defaults to 4
    public var touchEventEnabled: Bool?     //Support touch event call back or not
    public var scrollablePlotArea: AAScrollablePlotArea?    //Scroll properties if supported
    

    @discardableResult
    public func animationType(_ prop: AAChartAnimationType) -> AAChartModel {
        animationType = prop
        return self
    }
    
    @discardableResult
    public func animationDuration(_ prop: Int) -> AAChartModel {
        animationDuration = prop
        return self
    }
    
    @discardableResult
    public func title(_ prop: String) -> AAChartModel {
        title = prop
        return self
    }
    
    @discardableResult
    public func titleStyle(_ prop: AAStyle) -> AAChartModel {
        titleStyle = prop
        return self
    }
    
    @discardableResult
    public func subtitle(_ prop: String) -> AAChartModel {
        subtitle = prop
        return self
    }
    
    @discardableResult
    public func subtitleAlign(_ prop: AAChartAlignType) -> AAChartModel {
        subtitleAlign = prop
        return self
    }
    
    @discardableResult
    public func subtitleStyle(_ prop: AAStyle) -> AAChartModel {
        subtitleStyle = prop
        return self
    }
    
    @discardableResult
    public func chartType(_ prop: AAChartType) -> AAChartModel {
        chartType = prop
        return self
    }
    
    @discardableResult
    public func stacking(_ prop: AAChartStackingType) -> AAChartModel {
        stacking = prop
        return self
    }
    
    @discardableResult
    public func markerRadius(_ prop: Float) -> AAChartModel {
        markerRadius = prop
        return self
    }
    
    @discardableResult
    public func markerSymbol(_ prop: AAChartSymbolType) -> AAChartModel {
        markerSymbol = prop
        return self
    }
    
    @discardableResult
    public func markerSymbolStyle(_ prop: AAChartSymbolStyleType) -> AAChartModel {
        markerSymbolStyle = prop
        return self
    }
    
    @discardableResult
    public func zoomType(_ prop: AAChartZoomType) -> AAChartModel {
        zoomType = prop
        return self
    }
    
    @discardableResult
    public func inverted(_ prop: Bool) -> AAChartModel {
        inverted = prop
        return self
    }
    
    @discardableResult
    public func xAxisReversed(_ prop: Bool) -> AAChartModel {
        xAxisReversed = prop
        return self
    }
    
    @discardableResult
    public func yAxisReversed(_ prop: Bool) -> AAChartModel {
        yAxisReversed = prop
        return self
    }
    
    @discardableResult
    public func tooltipEnabled(_ prop: Bool) -> AAChartModel {
        tooltipEnabled = prop
        return self
    }
    
    @discardableResult
    public func tooltipValueSuffix(_ prop: String) -> AAChartModel {
        tooltipValueSuffix = prop
        return self
    }
    
    @discardableResult
    public func polar(_ prop: Bool) -> AAChartModel {
        polar = prop
        return self
    }
    
    @discardableResult
    public func margin(_ prop: [Any]?) -> AAChartModel {
        margin = prop
        return self
    }
    
    @discardableResult
    public func margin(
        top: Any = NSNull(),
        right: Any = NSNull(),
        bottom: Any = NSNull(),
        left: Any = NSNull()
    ) -> AAChartModel {
        margin = [
            top,
            right,
            bottom,
            left
        ]
        return self
    }
    
    @discardableResult
    public func dataLabelsEnabled(_ prop: Bool) -> AAChartModel {
        dataLabelsEnabled = prop
        return self
    }
    
    @discardableResult
    public func dataLabelsStyle(_ prop: AAStyle) -> AAChartModel {
        dataLabelsStyle = prop
        return self
    }
    
    @discardableResult
    public func xAxisLabelsEnabled(_ prop: Bool) -> AAChartModel {
        xAxisLabelsEnabled = prop
        return self
    }
    
    @discardableResult
    public func xAxisLabelsStyle(_ prop: AAStyle) -> AAChartModel {
        xAxisLabelsStyle = prop
        return self
    }
    
    @discardableResult
    public func categories(_ prop: [String]) -> AAChartModel {
        categories = prop
        return self
    }
    
    @discardableResult
    public func xAxisGridLineWidth(_ prop: Float) -> AAChartModel {
        xAxisGridLineWidth = prop
        return self
    }
    
    @discardableResult
    public func xAxisVisible(_ prop: Bool) -> AAChartModel {
        xAxisVisible = prop
        return self
    }
    
    @discardableResult
    public func xAxisTickInterval(_ prop: Float) -> AAChartModel {
        xAxisTickInterval = prop
        return self
    }
    
    @discardableResult
    public func yAxisVisible(_ prop: Bool) -> AAChartModel {
        yAxisVisible = prop
        return self
    }
    
    @discardableResult
    public func yAxisLabelsEnabled(_ prop: Bool) -> AAChartModel {
        yAxisLabelsEnabled = prop
        return self
    }
    
    @discardableResult
    public func yAxisLabelsStyle(_ prop: AAStyle) -> AAChartModel {
        yAxisLabelsStyle = prop
        return self
    }
    
    @discardableResult
    public func yAxisTitle(_ prop: String) -> AAChartModel {
        yAxisTitle = prop
        return self
    }

    @discardableResult
    public func xAxisTitle(_ prop: String) -> AAChartModel {
        xAxisTitle = prop
        return self
    }
    
    @discardableResult
    public func yAxisLineWidth(_ prop: Float) -> AAChartModel {
        yAxisLineWidth = prop
        return self
    }
    
    @discardableResult
    public func yAxisMin(_ prop: Double) -> AAChartModel {
        yAxisMin = prop
        return self
    }
    
    @discardableResult
    public func yAxisMax(_ prop: Double) -> AAChartModel {
        yAxisMax = prop
        return self
    }
    
    @discardableResult
    public func yAxisTickPositions(_ prop: [Any]) -> AAChartModel {
        yAxisTickPositions = prop
        return self
    }
    
    @discardableResult
    public func yAxisAllowDecimals(_ prop: Bool) -> AAChartModel {
        yAxisAllowDecimals = prop
        return self
    }
    
    @discardableResult
    public func yAxisGridLineWidth(_ prop: Float) -> AAChartModel {
        yAxisGridLineWidth = prop
        return self
    }
    
    @discardableResult
    public func colorsTheme(_ prop: [Any]) -> AAChartModel {
        colorsTheme = prop
        return self
    }
    
    @discardableResult
    public func series(_ prop: [Any]) -> AAChartModel {
        series = prop
        return self
    }
    
    @discardableResult
    public func legendEnabled(_ prop: Bool) -> AAChartModel {
        legendEnabled = prop
        return self
    }
    
    @discardableResult
    public func backgroundColor(_ prop: Any) -> AAChartModel {
        backgroundColor = prop
        return self
    }
    
    @discardableResult
    public func borderRadius(_ prop: Float) -> AAChartModel {
        borderRadius = prop
        return self
    }
    
    @discardableResult
    public func touchEventEnabled(_ prop: Bool) -> AAChartModel {
        touchEventEnabled = prop
        return self
    }
    
    @discardableResult
    public func scrollablePlotArea(_ prop: AAScrollablePlotArea) -> AAChartModel {
        scrollablePlotArea = prop
        return self
    }
    

    public override init() {
        title                  = ""
        subtitle               = ""
        animationType          = .linear
        animationDuration      = 800 //In milliseconds
        chartType              = .line
        stacking               = AAChartStackingType.none
        zoomType               = AAChartZoomType.none //Disable gesture zoom by default
        colorsTheme            = ["#1e90ff","#ef476f","#ffd066","#04d69f","#25547c",]
        tooltipEnabled         = true
        xAxisLabelsEnabled     = true
        xAxisVisible           = true
        yAxisVisible           = true
        yAxisLabelsEnabled     = true
        yAxisLineWidth         = 0
        yAxisGridLineWidth     = 0.6
        yAxisTitle             = ""
        xAxisTitle             = ""
        legendEnabled          = true
        borderRadius           = 0
        markerRadius           = 5 //The radius of the polyline connection point. If the default value is set to 0, then this is equivalent to not displaying.
    }
    
    

//    @available(*, unavailable, message: "please use titleStyle instead of it")
    public var titleFontColor: String?      //The chart title font color
//    @available(*, unavailable, message: "please use titleStyle instead of it")
    public var titleFontSize: Float?        //The chart title font size
//    @available(*, unavailable, message: "please use titleStyle instead of it")
    public var titleFontWeight: AAChartFontWeightType? //The chart font weight

//    @available(*, unavailable, message: "please use subtitleStyle instead of it")
    public var subtitleFontColor: String?   //The chart subtitle font color
//    @available(*, unavailable, message: "please use subtitleStyle instead of it")
    public var subtitleFontSize: Float?     //The chart subtitle font size
//    @available(*, unavailable, message: "please use subtitleStyle instead of it")
    public var subtitleFontWeight: AAChartFontWeightType?   //The chart subtitle font weight

//    @available(*, unavailable, message: "please use dataLabelsStyle instead of it")
    public var dataLabelsFontColor: String? //The data labels font color
//    @available(*, unavailable, message: "please use dataLabelsStyle instead of it")
    public var dataLabelsFontSize: Float?   //The data labels font size
//    @available(*, unavailable, message: "please use dataLabelsStyle instead of it")
    public var dataLabelsFontWeight: AAChartFontWeightType?//The data labels font weight
    
//    @available(*, unavailable, message: "please use xAxisLabelsStyle or yAxisLabelsStyle instead of it")
    public var axesTextColor: String?       //The labels font color of chart x axis and y axis

    
    
    @available(*, unavailable, message: "please use titleStyle instead of it")
    public func titleFontColor(_ prop: String) -> AAChartModel {
//        titleFontColor = prop
        return self
    }
    
    @available(*, unavailable, message: "please use titleStyle instead of it")
    public func titleFontSize(_ prop: Float?) -> AAChartModel {
//        titleFontSize = prop
        return self
    }
    
    @available(*, unavailable, message: "please use titleStyle instead of it")
    public func titleFontWeight(_ prop: AAChartFontWeightType) -> AAChartModel {
//        titleFontWeight = prop
        return self
    }
    
    
    @available(*, unavailable, message: "please use subtitleStyle instead of it")
    public func subtitleFontColor(_ prop: String) -> AAChartModel {
//        subtitleFontColor = prop
        return self
    }
    
    @available(*, unavailable, message: "please use subtitleStyle instead of it")
    public func subtitleFontSize(_ prop: Float?) -> AAChartModel {
//        subtitleFontSize = prop
        return self
    }
    
    @available(*, unavailable, message: "please use subtitleStyle instead of it")
    public func subtitleFontWeight(_ prop: AAChartFontWeightType) -> AAChartModel {
//        subtitleFontWeight = prop
        return self
    }
    
    
    @available(*, unavailable, message: "please use dataLabelsStyle instead of it")
    public func dataLabelsFontColor(_ prop: String) -> AAChartModel {
//        dataLabelsFontColor = prop
        return self
    }
    
    @available(*, unavailable, message: "please use dataLabelsStyle instead of it")
    public func dataLabelsFontSize(_ prop: Float?) -> AAChartModel {
//        dataLabelsFontSize = prop
        return self
    }
    
    @available(*, unavailable, message: "please use dataLabelsStyle instead of it")
    public func dataLabelsFontWeight(_ prop: AAChartFontWeightType) -> AAChartModel {
//        dataLabelsFontWeight = prop
        return self
    }
    
    @available(*, unavailable, message: "please use xAxisLabelsStyle or yAxisLabelsStyle instead of it")
    public func axesTextColor(_ prop: String) -> AAChartModel {
//        axesTextColor = prop
        return self
    }

    
}

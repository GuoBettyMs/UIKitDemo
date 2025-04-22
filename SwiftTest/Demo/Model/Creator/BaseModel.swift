//
//  BaseModel.swift
//  SwiftTest
//
//  Created by user on 2025/4/10.
//
/**
    创建基本对象模型
**/

import UIKit

public enum ListType: String {
    case table
    case collection
    case none
}

public class BaseModel: CustomObject {
    public var cellTitleArr = [[String]]()
    public var sectionTitleArr = [String]()
    public var listType = ListType.none
    public var colorsArr = [
        "#5470c6",
        "#91cc75",
        "#fac858",
        "#ee6666",
        "#73c0de",
        "#3ba272",
        "#fc8452",
        "#9a60b4",
        "#ea7ccc",

        "#5470c6",
        "#91cc75",
        "#fac858",
        "#ee6666",
        "#73c0de",
        "#3ba272",
        "#fc8452",
        "#9a60b4",
        "#ea7ccc",
    ]


    @discardableResult
    public func listType(_ prop: ListType) -> BaseModel {
        listType = prop
        return self
    }
    
    @discardableResult
    public func sectionTitleArr(_ prop: [String]) -> BaseModel {
        sectionTitleArr = prop
        return self
    }
    
    @discardableResult
    public func cellTitleArr(_ prop: [[String]]) -> BaseModel {
        cellTitleArr = prop
        return self
    }
    
    public override init() {
        listType = ListType.none
        sectionTitleArr = []
        cellTitleArr = [[]]

    }
}

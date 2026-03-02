//
//  SectionItem.swift
//  SwiftTest
//
//  Created by user on 2026/2/6.
//
// 模型和数据结构

import UIKit

struct SectionItem {
    let id: UUID
    let title: String
    let color: UIColor
    let items: [String] //分区子项
    var isExpanded: Bool //分区是否展开
    let decorationImage: String? // 装饰图片
    let decorationColor: UIColor // 装饰背景色
    
    init(title: String,
         color: UIColor,
         items: [String],
         isExpanded: Bool = true,
         decorationImage: String? = nil,
         decorationColor: UIColor = .clear) {
        self.id = UUID()
        self.title = title
        self.color = color
        self.items = items
        self.isExpanded = isExpanded
        self.decorationImage = decorationImage
        self.decorationColor = decorationColor
    }
}

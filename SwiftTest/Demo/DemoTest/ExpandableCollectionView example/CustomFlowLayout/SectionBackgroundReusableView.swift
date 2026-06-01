//
//  SectionBackgroundReusableView.swift
//  SwiftTest
//
//  Created by user on 2024/8/1.
//
/*
 section装饰背景注册类
*/

import UIKit
import Kingfisher


class SectionBackgroundReusableView: UICollectionReusableView {

    static let BACKGAROUND_CID = "BACKGAROUND_CID"
    // 记录当前的布局属性，避免重复渲染
    private var currentAttrs: SectionDecorationViewCollectionViewLayoutAttributes?
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.alpha = 0.1
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        addSubview(backgroundImageView)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        layer.shouldRasterize = true // 开启光栅化，减少重绘（优化性能）
                layer.rasterizationScale = UIScreen.main.scale
                layer.masksToBounds = true
                isHidden = false // 强制显示，避免复用后被隐藏
    }
    
    // MARK: - Apply Layout Attributes

    // 核心：应用布局属性（读取自定义属性并渲染）
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        // 转换为自定义布局属性
        guard let attrs = layoutAttributes as? SectionDecorationViewCollectionViewLayoutAttributes else { return }
        
        // 直接赋值
        backgroundColor = attrs.backgroundColor
        layer.cornerRadius = attrs.cornerRadius ?? 0
        
        if let imageName = attrs.imageName, !imageName.isEmpty {
            backgroundImageView.image = UIImage(named: imageName)
            backgroundImageView.isHidden = false
        } else {
            backgroundImageView.isHidden = true
        }
        
        // 关键：不要调用 setNeedsDisplay 或 performBatchUpdates
        // Layout 系统会自动处理
    }
    
    // 布局变化时强制刷新
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let attrs = currentAttrs {
                    // 不重复调用apply，避免循环渲染
            layer.cornerRadius = attrs.cornerRadius ?? 12
            backgroundColor = attrs.backgroundColor
        }

    }
    
}




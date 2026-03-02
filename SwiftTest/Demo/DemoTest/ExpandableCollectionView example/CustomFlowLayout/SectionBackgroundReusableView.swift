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
    
   
    // MARK: - Reuse
    
    // 复用前重置
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // 重置时保留基础样式，避免复用后空白
        currentAttrs = nil
        backgroundImageView.image = nil
        backgroundColor = .clear
        layer.cornerRadius = 0
        isHidden = false // 关键：不能隐藏，否则恢复时无法显示

    }
    
    // MARK: - Apply Layout Attributes

    // 核心：应用布局属性（读取自定义属性并渲染）
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)

        // 转换为自定义布局属性
        guard let attrs = layoutAttributes as? SectionDecorationViewCollectionViewLayoutAttributes else {
            // 兜底：如果属性转换失败，强制显示默认背景
                        self.backgroundColor = .lightGray.withAlphaComponent(0.5)
                        self.layer.cornerRadius = 12
            return
        }
        
        // 避免重复渲染，但属性变化时必须重绘
        if currentAttrs?.isEqual(attrs) == true {
            return
        }
        currentAttrs = attrs
        
        
        // 优化：使用动画过渡，减少闪烁感
        UIView.animate(withDuration: 0.1) {
            self.frame = attrs.frame
            self.backgroundColor = attrs.backgroundColor
            self.layer.cornerRadius = attrs.cornerRadius ?? 12
            
            if let imageName = attrs.imageName, !imageName.isEmpty {
                self.backgroundImageView.image = UIImage(named: imageName)
                self.backgroundImageView.isHidden = false
            } else {
                self.backgroundImageView.image = nil
                self.backgroundImageView.isHidden = true
            }
        }
        
        self.setNeedsDisplay()
       
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




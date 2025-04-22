//
//  CustomExpandedTapView.swift
//  SwiftTest
//
//  Created by user on 2025/4/17.
//
// 扩大 view 的响应范围,但是若扩大范围超出父级 frame 是无法响应事件的

import UIKit
import SnapKit
import RxSwift

class CustomExpandedTapView: UIView {
    
    // MARK: - Properties
    
    /// Insets to expand the tap area
    var tapAreaInsets = UIEdgeInsets.zero {
        didSet {
            setNeedsLayout()
        }
    }
    var isVisible: Bool = true //是否可视化扩大的范围
    
    private let label = UILabel()
    private let imageView = UIImageView()
    private var expandedTapView: UIView?
    private let disposeBag = DisposeBag()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        isUserInteractionEnabled = true
        setupLabel()
        setupImageView()
    }
    
    // MARK: - View Lifecycle
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        //使用场景: 带可点击子视图的容器（如卡片按钮组）
        /// 假设原始 bounds = CGRect(x: 0, y: 0, width: W, height: H), tapAreaInsets = UIEdgeInsets(top: T, left: L, bottom: B, right: R)
        /// - Returns: 返回矩形, 原点：(-L, -T) 大小：(W + L + R, H + T + B)
        let expandedBounds = bounds.inset(by: tapAreaInsets.inverted)
        
        // 1. Check if point is within expanded bounds
        if !expandedBounds.contains(point) {
            return super.hitTest(point, with: event) // Fallback to default behavior
        }

        // 2. Iterate through subviews
        for subview in subviews {
            //✖️ 不能返回 subview.hitTest, 返回 subview.hitTest 表示直接返回第一个位于扩展边界内的子视图 hitTest 的结果,即使触摸点位于其他 subview的扩展边界内，它也不会有机会处理该事件
//            return subview.hitTest(convertedPoint, with: event)
            
            // 3. Convert point to subview's coordinate system
            let convertedPoint = convert(point, to: subview)

            if subview.hitTest(convertedPoint, with: event) != nil {
                return subview // Return the subview that handles the event
            }
        }

        // 4. No ClickableLabel found within expanded bounds
        return self // Default to customStackV itself
        
//        //使用场景: 单纯需要扩大点击区域的独立视图
//        let expandedBounds = bounds.inset(by: tapAreaInsets.inverted)
//        return expandedBounds.contains(point) ? self : super.hitTest(point, with: event)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isVisible{
            updateExpandedTapView()
        }

    }
    
    // MARK: - Public Methods
    
    static func example(in par: UIView){
        let v = CustomExpandedTapView()
        par.addSubview(v)
        v.snp.remakeConstraints{ make in
            make.width.equalTo(100)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        v.backgroundColor = .blue
        v.tapAreaInsets = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
        v.setLabelText("分享表格 parentview", fontSize: 14)
    }
    
    func setImage(_ image: UIImage?, contentMode: UIView.ContentMode = .scaleAspectFit) {
        imageView.image = image
        imageView.contentMode = contentMode
    }
    
    func setLabelText(_ text: String, fontSize: CGFloat? = nil, alignment: NSTextAlignment = .center) {
        label.text = text
        label.textAlignment = alignment
        
        if let fontSize = fontSize {
            label.font = UIFont.systemFont(ofSize: fontSize)
            label.adjustsFontSizeToFitWidth = true
        }
    }
    
    // MARK: - Private Methods
    
    private func setupLabel() {
        addSubview(label)
        label.backgroundColor = .random()
        label.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
        }
    }
    
    private func setupImageView() {
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }
    }
    
    private func updateExpandedTapView() {
        if expandedTapView == nil {
            expandedTapView = UIView()
            expandedTapView?.layer.borderColor = UIColor.random().cgColor
            expandedTapView?.layer.borderWidth = 2
            expandedTapView?.isUserInteractionEnabled = false // Don't interfere with hitTest
            addSubview(expandedTapView!)
        }
        
        expandedTapView?.frame = bounds.inset(by: tapAreaInsets.inverted)
    }
}

// MARK: - Helper Extension

private extension UIEdgeInsets {
    /// Returns insets with inverted values (for expanding bounds)
    var inverted: UIEdgeInsets {
        return UIEdgeInsets(top: -top, left: -left, bottom: -bottom, right: -right)
    }
}


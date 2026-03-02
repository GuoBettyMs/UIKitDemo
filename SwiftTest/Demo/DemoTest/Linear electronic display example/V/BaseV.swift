//
//  BaseV.swift
//  SwiftTest
//
//  Created by user on 2026/2/6.
//

import UIKit
import SnapKit

class BaseV: UIView {

    let scrollView = UIScrollView()
    let contentView = UIView()
    let versionL = UILabel()
    let debugB = UIButton()
    lazy var debugUITV = UITextView()
    var isDebugUITVAdded = false
    
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

        addSubview(scrollView)
        scrollView.snp.makeConstraints{ make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
        }
        scrollView.showsVerticalScrollIndicator = false
//        scrollView.delaysContentTouches = false  //当scrollView滑动时, 不执行touch-down 手势
        
        //拖入一个 contentView 作为ScrollView的子控件，这个控件就是作为容纳真正布局中控件的父控件
        //contentView 最后一个子视图的底部约束一定要添加 make.bottom.equalToSuperview() ，用于告诉contentView在哪里，不然不能够确定contentSize。
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints{ make in
            make.top.bottom.equalTo(scrollView)
            make.left.right.equalTo(self) // 确定的宽度，因为垂直滚动
        }
        
//        scrollView.backgroundColor = .red
//        contentView.backgroundColor = .green
//        versionL.backgroundColor = .random()
//        debugB.backgroundColor = .green
 
    }
 
}

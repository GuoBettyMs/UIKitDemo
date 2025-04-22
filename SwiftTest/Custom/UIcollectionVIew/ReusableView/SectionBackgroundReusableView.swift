//
//  SectionBackgroundReusableView.swift
//  SwiftTest
//
//  Created by user on 2024/8/1.
//

import UIKit
import Kingfisher

/*
 section装饰背景注册类
*/
class SectionBackgroundReusableView: UICollectionReusableView {

    static let BACKGAROUND_CID = "BACKGAROUND_CID"
    
    private lazy var bg_imageView: UIImageView = {
        let imgV = UIImageView()
        addSubview(imgV)
        return imgV
    }()
//    private lazy var bg_imageView = UIImageView().then {
//        addSubview($0)
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        bg_imageView.frame = bounds
        guard let att = layoutAttributes as? SectionDecorationViewCollectionViewLayoutAttributes else {
            return
        }
        self.backgroundColor = UIColor.clear
        bg_imageView.layer.cornerRadius = 5
        bg_imageView.clipsToBounds = true
        bg_imageView.backgroundColor = att.backgroundColor
        guard let imageName = att.imageName else {
            self.bg_imageView.image = nil
            return
        }
        guard let image_url = URL(string: imageName) else {
            return
        }
        self.bg_imageView.kf.setImage(with: image_url)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}




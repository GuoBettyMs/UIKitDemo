//
//  LeftV.swift
//  SwiftTest
//
//  Created by user on 2024/10/24.
//

import UIKit
import SnapKit
import RxSwift

class LeftV: UIView {
    
    var itemList_UI: [[DeviceDBModel]] = [[], [], [], []] {
        didSet{
            addHintL.isHidden = itemList_UI[3].count == 0 ? false : true
        }
    }
    var sectionlists_UI: [[DeviceDBModel]] = [[], [], [], []] //由于 headerBtn 操作 itemList 发生改变,为不改变原数据,单独存储
    var headerBtnBool = [false,false,false,false]
    
    var selectedCellIndexPath: IndexPath?
    var longpressVisualEffectView: UIVisualEffectView?
    var menuView: MenuView?
    var animator: UIViewPropertyAnimator?

    weak var leftVdelegate: LeftVDelegate?
    
    var itemW = 169.0
    var itemH = 135.0
    var collectionV: UICollectionView!
    var bottomMenuVs: [UIButton] = []
    let privacyBtn = UIButton()
    private let bottomMenuVStrs: [String] = ["classify", "removeAll", "addRandomItem", "deleteRandomItem"]
    private var addHintL: UILabel = {
        let label = UILabel()
        label.text = "addHintL"
        label.textColor = .black
        label.isHidden = true
        return label
    }()

    /// - Returns:
    /// 纯代码加载UIView
    override init(frame: CGRect) {
        super.init(frame: frame)

        initUI()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initUI(){
        
        let bottomStackV = UIStackView()
        addSubview(bottomStackV)
        bottomStackV.snp.makeConstraints { make in
            make.width.bottom.centerX.equalToSuperview()
            make.height.equalTo(80)
        }
        bottomStackV.axis = .horizontal
        bottomStackV.alignment = .fill//调整子视图以适应空间变化
        bottomStackV.distribution = .fillEqually//子控件在排列方向上的填充大小相同
        bottomStackV.spacing = 5
        
        for i in 0...3{
            let bottomMenuV = UIButton()
            bottomStackV.addArrangedSubview(bottomMenuV)
            bottomMenuV.backgroundColor = .random()
            bottomMenuV.isUserInteractionEnabled = true
            bottomMenuV.setTitle(bottomMenuVStrs[i], for: .normal)
            bottomMenuV.titleLabel?.numberOfLines = 0
            bottomMenuV.titleLabel?.lineBreakMode = .byWordWrapping
            bottomMenuV.titleLabel?.textAlignment = .center
            bottomMenuVs.append(bottomMenuV)
        }
        
        let flowLayoutSectionInsetLeft = UIDevice.current.userInterfaceIdiom == .pad ? (isPortraitBool ? (UIScreen.main.bounds.width - itemW*3)/4 : (UIScreen.main.bounds.width-itemW*4)/5) : (UIScreen.main.bounds.width - itemW*2)/3
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: itemW, height: itemH)
        flowLayout.minimumLineSpacing = 20
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = flowLayoutSectionInsetLeft/2
        flowLayout.sectionInset = UIEdgeInsets(top: 20, left: flowLayoutSectionInsetLeft, bottom: 20, right: flowLayoutSectionInsetLeft) //每个分区的内边距
        
        collectionV = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)//初始化
        addSubview(collectionV)
        collectionV.snp.makeConstraints{ make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(bottomStackV.snp.top)
        }
        collectionV.backgroundColor = .clear
        collectionV.showsHorizontalScrollIndicator = false
        collectionV.showsVerticalScrollIndicator = false
        collectionV.translatesAutoresizingMaskIntoConstraints = false
        collectionV.register(Home_CollectionViewCell.self, forCellWithReuseIdentifier: "Home_CollectionViewCell")
        collectionV.register(Home_CollectionViewCellHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Home_CollectionViewHeader")
        collectionV.delegate = self
        collectionV.dataSource = self
        //当只有一个分区的时候, collectionV 的底部总内边距为 contentInset.bottom ; 当有多个分区时,collectionV 的底部总内边距为 contentInset.bottom + flowLayout.sectionInset.bottom
        //privacyBtn 父级不是 collectionV,为 collectionV 增加底部内边距后,可确保 collectionV 滚动范围有包含到 privacyBtn,令视觉上 privacyBtn 能正常显示不会被遮挡(实际 privacyBtn 的显示区域是在 collectionV的 底部内边距), collectionV 底部总内边距(40) = privacyBtn 底部约束(5) + privacyBtn 高度(25) + privacyBtn 顶部与 collectionV 增加一定约束效果(10)
        //所以, flowLayout.sectionInset.bottom(20) + contentInset.bottom(20) 搭配得到 collectionV 底部总内边距(40)
        collectionV.contentInset.bottom = 20 //整个 CollectionView 的底部内边距

        collectionV.addSubview(addHintL)
        addHintL.snp.makeConstraints{ make in
            make.center.equalToSuperview()
        }
        
        //隐私按钮
        addSubview(privacyBtn)
        privacyBtn.snp.makeConstraints{ make in
            make.height.equalTo(25)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(collectionV.snp.bottom).offset(-5)
        }
        privacyBtn.backgroundColor = UIColor(named: "Main-CollectionVBG")
        privacyBtn.layer.cornerRadius = 12
        privacyBtn.layer.borderWidth = 0.5
        privacyBtn.layer.borderColor = UIColor(named: "Main-PrivacyBtn")?.cgColor
        privacyBtn.setInsetTitle(title: "privacyBtn")
        
    }

}


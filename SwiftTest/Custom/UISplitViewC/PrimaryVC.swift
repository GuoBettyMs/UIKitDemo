//
//  PrimaryVC.swift
//  SwiftTest
//
//  Created by user on 2024/9/20.
//

import UIKit
import RxSwift

class PrimaryVC: UIViewController {
    
    var textfiled  = UITextField()
    let addbtn = UIButton()
    let label = UILabel()
    var background_imgs = ["https://img2.baidu.com/it/u=1361506290,4036378790&fm=253&fmt=auto&app=138&f=JPEG?w=800&h=500",
                                   "https://img0.baidu.com/it/u=1626237702,720888304&fm=253&fmt=auto&app=138&f=JPEG?w=800&h=500",
                                   "https://img2.baidu.com/it/u=2048195462,703560066&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=333"]
    var totallists: [Int] = []
    var sectionlists: [Int] = []
    var headerBtnBool = [true,true,true]
    
    var vcdelegate: ViewControllerDelegate?
    var collectionV: UICollectionView!
    let privatebtn = UIButton()
    let disposeBag = DisposeBag()//DisposeBag指清除包,清除包内部所有可被清除的资（Disposable）都将被清除
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(named: GetUIColor(colorArr: .navig).getcolorValue())
        self.navigationItem.title = "ViewController"
        
        self.view.addSubview(addbtn)
        addbtn.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.width.equalTo(50)
            make.centerX.equalToSuperview().offset(-50)
            make.bottom.equalTo(-20)
        }
        addbtn.backgroundColor = .red
        addbtn.setTitle("分类", for: .normal)
        
        addbtn.rx.tap.subscribe(onNext: { [weak self]
            in//onNext等闭包构建出来的内容都是观察者,对addbtn的tap事件做出响应

            self?.collectionV.tag = self?.collectionV.tag == 0 ? 1 : 0
            self?.collectionV.reloadData() //异步操作,会重新加载表格中的每个单元格，并显示最新的数据,结束后会更新其布局

        }).disposed(by: disposeBag)

        let resetbtn = UIButton()
        self.view.addSubview(resetbtn)
        resetbtn.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.width.equalTo(50)
            make.centerX.equalToSuperview().offset(50)
            make.bottom.equalTo(-20)
        }
        resetbtn.backgroundColor = .blue
        resetbtn.setTitle("恢复", for: .normal)
        
        resetbtn.rx.tap.subscribe(onNext: { [weak self] in
            guard self != nil else {return }
            print("resetbtnresetbtnresetbtn")

        }).disposed(by: disposeBag)
        
        
        
        var flowLayoutSectionInsetLeft = (UIScreen.main.bounds.width-169*2)/3
        if UIDevice.current.userInterfaceIdiom == .pad{
            // 获取当前窗口的尺寸
            if #available(iOS 13.0, *) {
                if UIApplication.shared.connectedScenes.first is UIWindowScene {
                    let newPor = UIScreen.main.bounds.width > UIScreen.main.bounds.height ? false : true
                    flowLayoutSectionInsetLeft = newPor ? (UIScreen.main.bounds.width-169*3)/4 : (UIScreen.main.bounds.width-169*4)/5
                }
            } else {
                let newPor = UIScreen.main.bounds.width > UIScreen.main.bounds.height ? false : true
                flowLayoutSectionInsetLeft = newPor ? (UIScreen.main.bounds.width-169*3)/4 : (UIScreen.main.bounds.width-169*4)/5
            }
        }

        //自定义flowlayout
        let flowLayout = SectionDecorationLayout()
        flowLayout.decorationDelegate = self
        flowLayout.itemSize = CGSize(width: 169, height: 135)
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 20
        flowLayout.minimumInteritemSpacing = flowLayoutSectionInsetLeft/2
        flowLayout.sectionInset = UIEdgeInsets(top: 20, left: flowLayoutSectionInsetLeft, bottom: 20, right: flowLayoutSectionInsetLeft)
        
        self.collectionV = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)//初始化
        self.view.addSubview(self.collectionV)
        self.collectionV.snp.makeConstraints{ make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(kStatusBarH+kNavigBarH)
            make.bottom.equalTo(addbtn.snp.top).offset(-20)
        }
        self.collectionV.backgroundColor = .clear
        self.collectionV.showsVerticalScrollIndicator = false
        self.collectionV.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Home_CollectionViewCell")
        self.collectionV.register(Home_CollectionViewCellHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Home_CollectionViewHeader")
        self.collectionV.dataSource = self
        self.collectionV.delegate = self
        self.collectionV.tag = 0
        
        self.view?.addSubview(privatebtn)
        privatebtn.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(addbtn.snp.top).offset(-20)
        }
        privatebtn.backgroundColor = .white//优先级最高
        privatebtn.layer.cornerRadius = 12
        privatebtn.layer.borderWidth = 1
        privatebtn.layer.borderColor = UIColor.red.cgColor
        privatebtn.setInsetTitle(title: "隐私政策")
        privatebtn.rx.tap.subscribe(onNext: { [weak self] in
            guard self != nil else {return }
            print("privatebtn is tap")
        }).disposed(by: disposeBag)

        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification).subscribe(onNext: { (noti) in
            self.keyboardWillShow(notification: noti as NSNotification)
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification).subscribe(onNext: {(noti)  in
            self.keyboardWillDisappear(notification: noti as NSNotification)
        }).disposed(by: disposeBag)
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        var flowLayoutSectionInsetLeft = (UIScreen.main.bounds.width-169*2)/3
        if UIDevice.current.userInterfaceIdiom == .pad{
            // 获取当前窗口的尺寸
            if #available(iOS 13.0, *) {
                if UIApplication.shared.connectedScenes.first is UIWindowScene {
                    let newPor = UIScreen.main.bounds.width > UIScreen.main.bounds.height ? false : true
                    flowLayoutSectionInsetLeft = newPor ? (UIScreen.main.bounds.width-169*3)/4 : (UIScreen.main.bounds.width-169*4)/5
                }
            } else {
                let newPor = UIScreen.main.bounds.width > UIScreen.main.bounds.height ? false : true
                flowLayoutSectionInsetLeft = newPor ? (UIScreen.main.bounds.width-169*3)/4 : (UIScreen.main.bounds.width-169*4)/5
            }
        }
        
        let layout = collectionV.collectionViewLayout as! SectionDecorationLayout
        layout.minimumInteritemSpacing = flowLayoutSectionInsetLeft/2
        layout.sectionInset = UIEdgeInsets(top: 20, left: flowLayoutSectionInsetLeft, bottom: 20, right: flowLayoutSectionInsetLeft)
        
    }
    
    //MARK: -
    
    /// - Returns:
    /// 隐私按钮进行重新约束
    func remakePrivatebtn(isPrivatebtnHidden: Bool){
        DispatchQueue.main.async {
//            print("privatebtn.height: ",self.privatebtn.frame.size.height)
            self.collectionV.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: isPrivatebtnHidden ? self.privatebtn.frame.size.height+15 : 0, right: 0)
        }
    }
    
    /// - Returns:
    /// 设置集合视图的数据源
    func show(listCount: [Int]) {
        
        self.totallists = listCount
        self.sectionlists = listCount
        
    }
    
    //MARK: -
    // MARK: 监听键盘弹出
    @objc func keyboardWillShow(notification: NSNotification){
        let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue// 获取键盘最后的Frame值
        let editingTextField = self.textfiled.convert(self.textfiled.bounds, to: self.view)// 获取当前编辑的文本框在当前 view 的坐标
        
        if let keyboardSize = keyboardSize{
            let textFieldBottomHeight = self.view.bounds.height - (editingTextField.origin.y + editingTextField.size.height)// 获取当前编辑的文本框到当前 view 底部的高度
            let deltaHeight = keyboardSize.height - textFieldBottomHeight// 获取当前编辑的文本框到当前 view 底部的高度与软键盘高度的交叉偏移量

            if deltaHeight >= 0 {
                print("editingTextField invisible, \(textFieldBottomHeight), \(deltaHeight)")
                self.collectionV.transform = CGAffineTransform(translationX: 0, y: -deltaHeight )//scrollV 移动 deltaHeight(交叉偏移量) 个单位
            }else{
                print("editingTextField visible")
            }
            
        }
        
//        let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue// 获取键盘最后的Frame值
//        let editingTextField = self.textfiled.convert(self.textfiled.bounds, to: self.view)// 获取当前编辑的文本框在当前 view 的坐标
//
//        if let keyboardSize = keyboardSize{
//
//            let deltaHeight = editingTextField.origin.y + editingTextField.height - keyboardSize.origin.y// 获取当前编辑的文本框的 y 值与软键盘的 y 值的交叉偏移量
//
//            if deltaHeight >= 0 {
//                print("editingTextField invisible, deltaHeight: \(deltaHeight), \(editingTextField.origin.y), \(keyboardSize.origin.y)")
//
//                self.collectionV.transform = CGAffineTransform(translationX: 0, y: -deltaHeight )//scrollV 移动 deltaHeight(交叉偏移量) 个单位
//            }else{
//                print("editingTextField visible")
//            }
//        }

    }
    
    // MARK: 监听键盘收起
    @objc func keyboardWillDisappear(notification: NSNotification){
        // 软键盘收起的时候恢复原始偏移
        self.collectionV.transform = CGAffineTransform.identity
    }
}

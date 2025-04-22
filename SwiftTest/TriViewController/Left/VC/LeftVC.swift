//
//  LeftVC.swift
//  SwiftTest
//
//  Created by user on 2024/10/23.
//

import UIKit
import SnapKit
import RxSwift

class LeftVC: UIViewController ,LeftVDelegate{

    let leftV = LeftV()
    let leftM = LeftM()
    private var disposedBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .systemGreen
        
        initUI()
        updateData()
        
    }
    
    /// - Returns:
    /// 将参数 view 的 视图控制器设置为 self
    func viewDidRequestViewController(_ view: UIView) -> UIViewController? {
        return self
    }
    
    deinit{
        print("LeftVC 销毁")
    }

    //MARK: -
    func initUI(){
        
        let navilogoL = UILabel()
        navilogoL.tintColor = UIColor.red
        navilogoL.font = UIFont.systemFont(ofSize: UIDevice.current.userInterfaceIdiom == .pad ? 29 : 26)
        navilogoL.text = "testtesttesttesttesttesttesttestesttesttesttesttestttestesttesttesttesttest"
        navigationItem.titleView = navilogoL
        
        let button = UIButton()
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "plus")?.withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            button.setImage(UIImage(named: "AddIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        button.tintColor = .black
        button.frame = CGRect(x: 0, y: 0, width: 80, height: 44)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        button.rx.tap.subscribe(onNext: { [weak self] in
            guard self != nil else{ return }
            print("scanButton")
        }).disposed(by: disposedBag)
        
        
        let backButton = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        if #available(iOS 13.0, *) {
            backButton.image = UIImage(systemName: "plus")?.withRenderingMode(.alwaysTemplate)
        } else {
            backButton.image = UIImage(named: "BackIcon")?.withRenderingMode(.alwaysTemplate)
        }

//        backButton.imageInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        backButton.tintColor = .black
        backButton.accessibilityLabel = NSLocalizedString("Back", comment: "Back")
        navigationItem.leftBarButtonItem = backButton
        
        self.view.addSubview(leftV)
        leftV.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
        }
        leftV.leftVdelegate = self //委托代理,传递 LeftVC 作为 leftV 的视图控制器
        
        for bottomI in 0...3{
            leftV.bottomMenuVs[bottomI].rx.tap.subscribe(onNext: { [weak self] in
                guard self != nil else{ return }
                
                switch bottomI {
                case 0:
                    self?.leftV.collectionV.tag = self?.leftV.collectionV.tag == 0 ? 1 : 0
                    self?.updateData()
                    self?.leftV.collectionV.reloadData()
                case 1:
                    self?.leftM.clearLists()
                    self?.updateData()
                    self?.leftV.collectionV.reloadData()
                case 2:
                    self?.leftM.addRandomItem(completion: {(randomIndex, sectionIndex, sectionI) in
                       
                        self?.updateData()
                        
                        DispatchQueue.main.async {
                            self?.leftV.insertItem(index:  self?.leftV.collectionV.tag == 0 ? randomIndex : sectionIndex, sectionI: self?.leftV.collectionV.tag == 0 ? 0 : sectionI)
                        }
                    })
                case 3:
                    self?.leftM.deleteRandomItem(completion: {(randomIndex, sectionIndex, sectionI) in
                       
                        self?.updateData()
                        
                        DispatchQueue.main.async {
                            self?.leftV.insertItem(index:  self?.leftV.collectionV.tag == 0 ? randomIndex : sectionIndex, sectionI: self?.leftV.collectionV.tag == 0 ? 0 : sectionI)
                        }
                    })
                default:
                    break
                }
            }).disposed(by: disposedBag)
        }

        leftV.privacyBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                guard self != nil else {return }
                print("privacyBtn")
            }).disposed(by: disposedBag)
        
    }
    //MARK: -
    func addAlertController(_ string: String){
        let alert = UIAlertController(title: string, message: "", preferredStyle: .alert)
        alert.modalPresentationStyle = .formSheet
        present(alert, animated: true)
 
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    func longpressEvent(cellIden: String, cellI: IndexPath){
        
        let tap = UITapGestureRecognizer()
        leftV.longpressVisualEffectView?.addGestureRecognizer(tap)
        tap.rx.event
            .subscribe(onNext: { [weak self] recognizzer in

                self?.leftV.removeMenuUI()
                
            }).disposed(by: disposedBag)
        
        for i in 0...2{
            leftV.menuView!.menuBtns[i].rx.tap.subscribe(onNext: { [weak self] in
                guard self != nil else{ return }
                switch i {
                case 0:
                    self?.leftM.moveToUpSelectedItem(cellIden, cellI, blk: {(index, sectionIndex, sectionI) in
                        
                        self?.updateData()
                        
                        self?.leftV.moveItem(index:  self?.leftV.collectionV.tag == 0 ? index : sectionIndex, sectionI: self?.leftV.collectionV.tag == 0 ? 0 : sectionI)
                    })
                case 1:
                    var newitem = DeviceDBModel(cellIden, true, false)
                    newitem.username = "改名\(Int.random(in: 0...9))"
                    self?.leftM.reloadSelectedItem(cellIden, newitem, blk: { (index, sectionIndex, sectionI) in
                        
                        self?.updateData()
                        
                        self?.leftV.relaodItem(index: self?.leftV.collectionV.tag == 0 ? index : sectionIndex, sectionI: self?.leftV.collectionV.tag == 0 ? 0 : sectionI)
                        self?.leftV.removeMenuUI()
                        
                    })
                case 2:
                    self?.leftM.deleteSeletedItem(cellIden, cellI ,blk: { (index, sectionIndex, sectionI) in

                        self?.updateData()
                        
                        self?.leftV.deleteItem(index: self?.leftV.collectionV.tag == 0 ? index : sectionIndex, sectionI: self?.leftV.collectionV.tag == 0 ? 0 : sectionI)
                        self?.leftV.removeMenuUI()
                    })
                default:
                    break
                }
            }).disposed(by: disposedBag)
        }

    }
    
    func updateData(){
        
        for i in 0...3{
            leftV.itemList_UI[i] = leftM.itemList[i]
            
            if !leftV.headerBtnBool[i]{
                leftV.sectionlists_UI[i] = leftV.itemList_UI[i]
            }else{
                leftV.sectionlists_UI[i].removeAll()
            }
//            print("updateData-\(i): \(leftV.itemList_UI[i].count), \(leftV.sectionlists_UI[i].count)")
        }
    }
}


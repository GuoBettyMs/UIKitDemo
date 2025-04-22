//
//  HomePageCollectionViewController.swift
//  SwiftTest
//
//  Created by user on 2025/1/13.
//

import UIKit
import SnapKit

private let reuseIdentifier = "Cell"

class HomePageCollectionViewController: UICollectionViewController {
    
    private var model = LeftM()
    private var deviceList = [DeviceDBModel]()
    private let privacyBtn = UIButton()
    var rightNaC: NavigationController!
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        deviceList = model.itemList[3]
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBarConfig()
        setupViews()
        
    }
    

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visibleH = self.view.safeAreaLayoutGuide.layoutFrame.height//安全区域
        let actualH = scrollView.contentSize.height+scrollView.contentInset.bottom//contentSize 只表示内容本身的大小,不考虑内边距
        let contentOffsetY = scrollView.contentOffset.y//获取 scrollView 当前偏移量
//        Log.debug("scrollViewDidScroll, actualH: \(actualH), visibleH: \(contentOffsetY + visibleH), contentOffsetY: \(contentOffsetY)")
        self.privacyBtn.alpha = contentOffsetY + visibleH < actualH ? 0.01 : 1
    }
    
    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.deviceList.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! DeviceStatusBehaveCell 
        // Configure the cell
        cell.backgroundColor = .random()
        cell.label.text = "1122"
        cell.tapAction = {
            print("didDeselectItemAt, \(indexPath.row)")
            
            if UIDevice.current.userInterfaceIdiom == .phone{
                let rightNaC = NavigationController(rootViewController: DemoVC())
                rightNaC.modalPresentationStyle = .fullScreen
                self.present(rightNaC, animated: true)
            }else{
                let leftVCW = isPortraitBool ? kWidth*0.4 : kWidth*0.6
                collectionView.snp.remakeConstraints { make in
                    make.left.top.bottom.equalToSuperview()
                    make.width.equalTo(leftVCW)
                }
                
                if self.rightNaC != nil {
                    self.rightNaC.removeFromParent()
                    self.rightNaC.view.removeFromSuperview()
                }
                
                self.rightNaC = NavigationController(rootViewController: DemoVC())
                self.addChild(self.rightNaC)
                self.view.addSubview(self.rightNaC.view)
                
                self.rightNaC.view.snp.makeConstraints {  make in
                    make.right.equalToSuperview()
                    make.top.equalTo(collectionView.snp.top)
                    make.bottom.equalTo(collectionView.snp.bottom)
                    make.left.equalTo(collectionView.snp.right)
                }
                
                self.rightNaC.view.backgroundColor = .random()
                isShowRightNaC = true
            }
        }
        
        return cell
    }

    // MARK: - private methods
    private func navigationBarConfig(){
  
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground() // Key step: Removes default background/blur
            appearance.backgroundColor = .clear
            appearance.shadowColor = .clear // Removes the bottom separator line
            appearance.titleTextAttributes = [
                .font: UIFont.systemFont(ofSize: 18, weight: .medium),
                .foregroundColor: UIColor.black
            ]//导航栏标题的文本字体色
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        } else {
            // Legacy iOS (< 13)
            navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.isTranslucent = true
            navigationController?.navigationBar.titleTextAttributes = [
                .font: UIFont.systemFont(ofSize: 18, weight: .medium),
                .foregroundColor: UIColor.black
            ]
        }
        
        navigationItem.title = "Home Page"
    }
    
    private func setupViews(){
        
        //提示: 若无使用故事版,需要在使用之前注册，1. 以便系统知道如何创建和配置该类型的 Cell; 2.便于使用 UICollectionView 的复用机制,即当 Cell 滑出屏幕时，并不会立即销毁，而是会被放入一个复用池中,当需要展示新的 Cell 时，会从复用池中取出一个可复用的 Cell，并重新配置其内容
//        self.collectionView.register(DeviceStatusBehaveCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        self.view.backgroundColor = .random()
        self.collectionView.backgroundColor = .random()
        self.collectionView.snp.makeConstraints{ make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide.snp.edges)
        }
        
        addBottomDynamicBtn()
    }
    
    private func addBottomDynamicBtn(){
        
        self.view.addSubview(privacyBtn)
        privacyBtn.snp.makeConstraints{ make in
            make.height.equalTo(25)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-5)
        }
        privacyBtn.backgroundColor = UIColor(named: "Main-CollectionVBG")
        privacyBtn.layer.cornerRadius = 12
        privacyBtn.layer.borderWidth = 0.5
        privacyBtn.layer.borderColor = UIColor(named: "Main-PrivacyBtn")?.cgColor
        privacyBtn.setInsetTitle(title: "Btn")
        
        DispatchQueue.main.async {
            self.collectionView.contentInset.bottom = self.view.safeAreaInsets.bottom == 0 ? 34 : self.view.safeAreaInsets.bottom

            let visibleH = self.view.safeAreaLayoutGuide.layoutFrame.height
            let actualH = self.collectionView.frame.size.height+self.collectionView.contentInset.bottom//contentSize 只表示内容本身的大小,不考虑内边距
            
            //isHidden 为 true 或者 alpha = 0.0 时,VoiceOver 不可访问
//            self.versionL.isHidden = actualH > visibleH
            self.privacyBtn.alpha = actualH > visibleH ? 0.01 : 1

            Log.debug("addVerBtn, actualH: \(actualH), visibleH: \(visibleH)")
        }
    }

}

extension HomePageCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return CGSize(width: 100, height: 100) // 默认值
        }
        
        var columnCount = 2.0
        if UIDevice.current.userInterfaceIdiom == .phone {
            columnCount = isShowRightNaC ? 1.0 : 2.0
        }else{
            columnCount = isShowRightNaC ? 3.0 : 4.0
        }
        
        // 读取 Storyboard 中设置的 sectionInsets
        let sectionInsets = flowLayout.sectionInset
        let leftRightInset = sectionInsets.left + sectionInsets.right
        
        // 计算总间距（假设 cell 间距是 10）
        let totalSpacing: CGFloat = 10 * (columnCount + 1) // (列数 + 1) * 间距
        let availableWidth = collectionView.bounds.width - leftRightInset - totalSpacing
        let width = availableWidth / columnCount // 2 列
        
//        print("Cell width: \(width), Section Insets: \(sectionInsets)")
        return CGSize(width: width, height: width)
    }
}

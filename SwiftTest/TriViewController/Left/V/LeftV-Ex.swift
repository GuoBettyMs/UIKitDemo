//
//  LeftV-Ex.swift
//  SwiftTest
//
//  Created by user on 2024/11/8.
//

import UIKit

extension LeftV {
    /// - Returns:
    /// 移动时 Privatebtn 重新约束
    func adjustPrivatebtnByOffset(){
        DispatchQueue.main.async {
            let contentOffsetY = self.collectionV.contentOffset.y
            
            if self.collectionV.collectionViewLayout is UICollectionViewFlowLayout {
                //collectionViewContentSize 已含 sectionInset
                let actualH = self.collectionV.collectionViewLayout.collectionViewContentSize.height+self.collectionV.contentInset.bottom
                let visibleH = self.collectionV.frame.height
                
                self.privacyBtn.isHidden = contentOffsetY + visibleH < actualH// 判断是否滚动到底部
                
//                print("adjustPrivatebtnByOffset, actualH: \(actualH)-\(layout.sectionInset.bottom+layout.sectionInset.top+self.collectionV.contentInset.bottom), visibleH: \(visibleH), \(contentOffsetY)")
            }
        }
    }
    
    /// - Returns:
    /// 初始时根据 collectionV 高度 Privatebtn 重新约束
    func adjustPrivatebtnByHeight(){
        DispatchQueue.main.async {
 
//            self.collectionV.contentSize.height
//            不仅包含了 CollectionView 内容本身的高度，还包括了 CollectionView.collectionViewLayout.sectionInset,不包含 CollectionView.contentInset
//            动态变化: 随着 CollectionView 的内容变化或布局调整，这个值也会动态变化。
//            用于滚动计算: 这个值通常用于计算 CollectionView 的滚动范围和偏移量。
//
//            self.collectionV.collectionViewLayout.collectionViewContentSize.height
//            不仅包含了 CollectionView 内容本身的高度，还包括了 collectionViewLayout.sectionInset, 不包含 CollectionView.contentInset
//            依赖布局: 这个值取决于 CollectionView 的布局方式和 Cell 的大小。
//            用于布局计算: 这个值通常用于计算 CollectionView 的布局和 Cell 的布局。

            if self.collectionV.collectionViewLayout is UICollectionViewFlowLayout {
                self.collectionV.contentInset.top = self.collectionV.tag == 0 ? 0 : 20 //当存在多个分区时,需额外增加 CollectionView 整体顶部内边距
                
                //contentSize.height 已含 collectionViewLayout.sectionInset
                let actualH = self.collectionV.contentSize.height+self.collectionV.contentInset.bottom
                let visibleH = self.collectionV.frame.height//等同 self.frame.height - bottomStackV.frame.height
                self.privacyBtn.isHidden = actualH > visibleH
                
//                print("adjustPrivatebtnByHeight, actualH: \(actualH), visibleH: \(visibleH), inset: \(self.collectionV.contentInset)--\(layout.sectionInset)")
            }
        }
    }
 
    /// - Returns:
    /// 菜单栏初始化
    func addMenuUI(cell: UIView){

        self.longpressVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light)) as UIVisualEffectView
        self.longpressVisualEffectView!.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: kHeight)
        self.animator = UIViewPropertyAnimator(duration: 1, curve: .linear) {
            self.longpressVisualEffectView!.effect = nil
        }
        self.animator?.fractionComplete = 0.8
        
        // 创建自定义菜单视图,cell.frame 计算不涉及状态栏导航栏,而 menuView 添加在 longpressVisualEffectView 上,longpressVisualEffectView 是面向整个 window 的,所以计算 menuView 位置时需要考虑状态栏导航栏
        //leftV 自身顶部底部与父级 leftVC 安全区域的顶部底部对齐,所以计算 menuView 位置考虑的状态栏高度+导航栏高度就是 leftVC 的状态栏高度+导航栏高度,即 leftVC.view 的 安全区域顶部内边距
        
        guard let fatherVC = leftVdelegate?.viewDidRequestViewController(self) as? LeftVC else { return }
        
        let y = cell.frame.origin.y+fatherVC.view.safeAreaInsets.top+fatherVC.view.safeAreaInsets.bottom-self.collectionV.contentOffset.y //旋转时可能发生没有状态栏的情况,所以不使用 kNavigBarH+kStatusBarH
        self.menuView = MenuView(frame: CGRect(x: cell.frame.origin.x, y: y+(cell.frame.height-30) , width: cell.bounds.width, height: cell.bounds.height))
        
        print("addMenuUI  ,\(y)")
        
        keyWindowAdd(self.longpressVisualEffectView!)
        self.longpressVisualEffectView!.contentView.addSubview(self.menuView!)
    }
    
    func removeMenuUI(){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: {
            self.menuView?.removeFromSuperview()
            self.menuView = nil
            self.longpressVisualEffectView?.removeFromSuperview()
            self.longpressVisualEffectView = nil

            self.selectedCellIndexPath = nil
        })
    }

    func moveItem(index: Int, sectionI: Int){
        DispatchQueue.main.async {
            self.collectionV.moveItem(at: IndexPath(row: index, section: sectionI), to: IndexPath(row: 0, section: sectionI))
            self.removeMenuUI()
        }
    }
    
    func insertItem(index: Int, sectionI: Int){
        DispatchQueue.main.async {
            self.collectionV.insertItems(at: [IndexPath(item: index, section: sectionI)])
        }
    }

    func deleteItem(index: Int, sectionI: Int){
        DispatchQueue.main.async {
            self.collectionV.deleteItems(at: [IndexPath(item: index, section: sectionI)])
        }
    }

    func relaodItem(index: Int, sectionI: Int){
        DispatchQueue.main.async {
            self.collectionV.reloadItems(at: [IndexPath(item: index, section: sectionI)])
        }
    }
}

extension LeftV: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        return collectionView.tag == 0 ? .zero : CGSize(width: UIScreen.main.bounds.width-40, height: 40)
    }
}

extension LeftV: UICollectionViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        adjustPrivatebtnByOffset()
    }
}

extension LeftV: UICollectionViewDataSource{

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return collectionView.tag == 0 ? 1 : itemList_UI.count-1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        adjustPrivatebtnByHeight()
        return collectionView.tag == 0 ? itemList_UI[3].count : sectionlists_UI[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerV = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Home_CollectionViewHeader", for: indexPath) as! Home_CollectionViewCellHeader

        headerV.headertitle.text = headerV.headertitleStrs[indexPath.section]
        headerV.isheaderClosed = headerBtnBool[indexPath.section]
        
        let tapGestureRecognizer = IndexedTapGestureRecognizer(target: self, action: #selector(headclick))
        tapGestureRecognizer.indexPath = indexPath
        headerV.addGestureRecognizer(tapGestureRecognizer)

        return headerV
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Home_CollectionViewCell", for: indexPath) as! Home_CollectionViewCell
        let item = collectionView.tag == 0 ? itemList_UI[3][indexPath.row] : itemList_UI[indexPath.section][indexPath.row]
        cell.deviceL.text = "\(item.identifier)(\(indexPath))"
        cell.usenameL.text = "\(item.username)"
        
        // 在这里为 cell 添加点击和长按手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped(_:)))
        cell.addGestureRecognizer(tapGesture)

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(cellLongPressed(_:)))
        cell.addGestureRecognizer(longPressGesture)
        
        return cell
    }

    @objc func cellLongPressed(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let location = sender.location(in: collectionV)
            
            guard let cell = sender.view as? Home_CollectionViewCell , let indexPath = collectionV.indexPathForItem(at: location), let vc = leftVdelegate?.viewDidRequestViewController(self) as? LeftVC else { return }
            
            let offsetY = cell.frame.origin.y-collectionV.contentOffset.y
            
    //            print("\(cell.frame.origin.y)-\(leftV.collectionV.contentOffset.y),offsetY: \(offsetY), \(leftV.collectionV.frame.height-cell.bounds.height)")

            if  offsetY > collectionV.frame.height-cell.bounds.height {
                vc.addAlertController("cell 被遮挡")
            }else{
                selectedCellIndexPath = indexPath
                addMenuUI(cell: cell)
//                print("cellLongPressed indexPath: \(indexPath)")
                vc.longpressEvent(cellIden: itemList_UI[collectionV.tag == 0 ? 3 : indexPath.section ][indexPath.row].identifier, cellI: indexPath)
            }
        }
    }
    
    @objc func cellTapped(_ sender: UITapGestureRecognizer) {

        //将处理委托给父视图控制器, LeftVC 的父级是 UINavigationController, UINavigationController 的父级是 FatherViewController
        guard let fatherVC = leftVdelegate?.viewDidRequestViewController(self) as? LeftVC, let rootVC = fatherVC.parent?.parent as? FatherViewController else {
            return
        }
        rootVC.cellTapped(sender)
        
    }

    @objc func headclick(_ sender: IndexedTapGestureRecognizer){

        if let indexPath = sender.indexPath{
            headerBtnBool[indexPath.section] = !headerBtnBool[indexPath.section]

            if headerBtnBool[indexPath.section] {
                sectionlists_UI[indexPath.section].removeAll()
            }else{
                sectionlists_UI[indexPath.section] = itemList_UI[indexPath.section]
            }
            
            collectionV.reloadSections(IndexSet(integer: indexPath.section))
            print("headerBtn headclick [\(indexPath.section)] clickEvent, \(headerBtnBool[indexPath.section])")
        }
    }
}

/// - Returns:
/// 自定义代理, 由 view 可获取 ViewController
protocol LeftVDelegate: AnyObject {
    func viewDidRequestViewController(_ view: UIView) -> UIViewController?
}


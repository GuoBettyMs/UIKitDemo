//
//  PrimaryVC-Ex.swift
//  SwiftTest
//
//  Created by user on 2024/9/14.
//

import UIKit

extension PrimaryVC: UICollectionViewDelegate{

    func scrollViewDidScroll(_ scrollView: UIScrollView){
        DispatchQueue.main.async {
            let contentOffset = (self.collectionV.collectionViewLayout.collectionViewContentSize.height+self.privatebtn.frame.size.height+15) - (self.collectionV.frame.height)//privatebtn隐藏时,collectionV底部内边距由0增加为self.privatebtn.frame.size.height+15,所以collectionV滚动到底部的可移动距离为contentOffset
            
//            print("scrollViewDidScroll, contentOffset.y: ", self.collectionV.contentOffset.y,", contentOffset: ", contentOffset)
            
            self.privatebtn.isHidden = self.collectionV.contentOffset.y >= contentOffset-5 ? false : true//为了privatebtn在collectionV滚动到差不多到底部时就显示,将contentOffset降低点
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let str = "点击了 \(indexPath)"
        self.vcdelegate?.didSelect(str)

    }
     
}

extension PrimaryVC: UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        DispatchQueue.main.async {
//            print("numberOfSections, collectionViewContentSize.height: ",self.collectionV.collectionViewLayout.collectionViewContentSize.height,"frame.height: ", self.collectionV.frame.height, "privatebtn.height: ",self.privatebtn.frame.size.height)
            let bool = self.collectionV.collectionViewLayout.collectionViewContentSize.height+self.privatebtn.frame.size.height+15 > self.collectionV.frame.height//self.privatebtn.frame.size.height+15为collectionV的内边上间距
            self.privatebtn.isHidden = bool ? true : false
            self.remakePrivatebtn(isPrivatebtnHidden: self.privatebtn.isHidden)
        }
        return collectionView.tag == 0 ? 1 : totallists.count-1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  collectionView.tag == 0 ? totallists[3] : sectionlists[section]
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Home_CollectionViewCell", for: indexPath)
        cell.backgroundColor = .random()
        
        
        let filed = UITextField()
        filed.frame = CGRect(x: 0, y: 0, width: 50, height: 30)
        filed.placeholder = "请输入"
        filed.returnKeyType = .done
        filed.delegate = self
        cell.addSubview(filed)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        let headerV = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Home_CollectionViewHeader", for: indexPath) as! Home_CollectionViewCellHeader

//        print("viewForSupplementaryElementOfKind ",indexPath,indexPath.section)
        headerV.backgroundColor = .random()
        headerV.headertitle.text = headerV.headertitleStrs[indexPath.section]
        headerV.isheaderClosed = headerBtnBool[indexPath.section]
        
        let tapGestureRecognizer = IndexedTapGestureRecognizer(target: self, action: #selector(headclick))
        tapGestureRecognizer.indexPath = indexPath
        headerV.addGestureRecognizer(tapGestureRecognizer)

        return headerV
    }
    
    
    @objc func headclick(_ sender: IndexedTapGestureRecognizer){

        if let indexPath = sender.indexPath {
            headerBtnBool[indexPath.section] = !headerBtnBool[indexPath.section]
            sectionlists[indexPath.section] = headerBtnBool[indexPath.section] ? totallists[indexPath.section] : 0
            
            self.collectionV.reloadSections(IndexSet(integer: indexPath.section))
            print("headerBtn headclick [\(indexPath.section)] clickEvent)")
        }
    }
    
}


extension PrimaryVC: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        return collectionView.tag == 0 ? .zero : CGSize(width: UIScreen.main.bounds.width-40, height: 40)
    }

}

/// - Returns:
///  设置分区背景
extension PrimaryVC: SectionDecorationLayoutDelegate {
//    /// SectionDecorationLayoutDelegate
//    /// 是否显示单独设置 Section 背景颜色
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: SectionDecorationLayout, decorationColorForSectionAt section: Int) -> UIColor {
//        switch section {
//        case 0:
//            return UIColor.systemPink
//        case 1:
//            return UIColor.init(red: 196/255.0, green: 26/255.0, blue: 187/255.0, alpha: 1)
//        case 2:
//            return UIColor.systemIndigo
//        case 3:
//            return UIColor.cyan
//        case 4:
//            return UIColor.lightGray
//        default:
//            return UIColor.systemBlue
//        }
//    }
    
    /// 是否显示 Section 背景图
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: SectionDecorationLayout,
                        decorationImgaeDisplayedForSectionAt section: Int) -> Bool {
        return true
    }
    
    /// 获取 Section 背景图
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: SectionDecorationLayout,
                        decorationImageForSectionAt section: Int) -> String? {
        if collectionView.tag == 0 {
            return nil
        }else{
            switch section {
            case 0:
                return background_imgs[0]
            case 1:
                return background_imgs[1]
            case 2:
                return background_imgs[2]
            default:
                return nil
            }
        }

    }
    
    /// 设置Section 背景图 的内边距
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: SectionDecorationLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        print("SectionDecorationLayoutDelegate 设置\(section)背景图的内边距")
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

}
//MARK: -
extension PrimaryVC: UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textfiled = textField
        textfiled.addKeyboardDoneToolbar(target: self, action: #selector(doneButtonAction))
    }

    /// - Returns:
    /// textField 失去焦点后执行
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditing text,", textfiled.text as Any)
    }
    
    /// - Returns:
    /// textfiled 移除焦点,用于隐藏键盘,用户当前无法再输入
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textfiled.resignFirstResponder()
        return true
    }
    
    /// - Returns:
    /// 完成按钮事件
    ///  textfiled 移除焦点,用于隐藏键盘,用户当前无法再输入
    @objc func doneButtonAction() {
        
        print("收起软键盘, editingText: \(textfiled.text!) ")
        textfiled.resignFirstResponder()
        
    }
}

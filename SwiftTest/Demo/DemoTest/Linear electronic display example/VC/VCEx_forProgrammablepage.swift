//
//  VCEx_forProgrammablepage.swift
//  SwiftTest
//
//  Created by user on 2026/1/28.
//


import UIKit

//MARK: - 页面处理扩展
extension CustomPickViewVC: ProgrammablePageVDelegate {
    func programmablePageV(_ view: ProgrammablePageV, didInsertItem data: ProgramDataModel, at position: Int) {
        model.initialProgrammablePageDatas.insert(data, at: 0)
    }
    
    func programmablePageV(_ view: ProgrammablePageV, didDeleteItemAt position: Int) {
        model.initialProgrammablePageDatas.remove(at: position)
    }
    
    //MARK: 可编程页面非标题文本框

    func setActiveTextField(_ textField: UITextField) {
        activeTextField = textField
//        Log.debug("设置当前编辑的单元格: \(textField.text ?? "-")")
    }

    
    //MARK: 可编程页面控制块

    func loadProgrammablePageDataArr(){
        var dClistArr:[ProgramDataModel] = []
        for dataI in 0..<12 {
            let data = ProgramDataModel(
                index: dataI,
                voltageMin: 3000,
                current: 1000,
                time: dataI*10
            )
            
            dClistArr.append(data)
        }
        
        model.initialProgrammablePageDatas.append(contentsOf: dClistArr)
        container.programmablePageV.createProgrammablePagelist1(with: model.initialProgrammablePageDatas)
        
        container.programmablePageV.updateRowBgColor1(0)
        container.programmablePageV.changeProgramControlBtnTintcolr(isRemoteConnect: true, isPlay: false)
    }
    
    func programmablepageListControlEvent1(){
        
        container.programmablePageV.programmablePageVDelegate = self
        
        // 分别设置每个按钮，避免循环中的闭包问题
        // Previous 按钮 (index 0)
        container.programmablePageV.programControlBtns[0].rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }

                
                Log.debug("Previous 按钮 (ui index 0), 旧行索引(从1开始)= \(self.model.dCcurrentWorkRow), count= \(model.initialProgrammablePageDatas.count)")
                
                if self.model.dCcurrentWorkRow <= 1 {
                    self.model.dCcurrentWorkRow = 1
                    return
                }
                
                self.model.dCcurrentWorkRow -= 1
                self.container.programmablePageV.updateRowBgColor1(self.model.dCcurrentWorkRow-1)

                self.container.programmablePageV.scrollToRow(self.model.dCcurrentWorkRow-1)
                
            }).disposed(by: disposedBag)

        
        // Next 按钮 (index 2)
        container.programmablePageV.programControlBtns[2].rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                Log.debug("Next 按钮 (ui index 2), 旧行索引(从1开始)= \(self.model.dCcurrentWorkRow), count= \(model.initialProgrammablePageDatas.count)")
                
                if self.model.dCcurrentWorkRow >= model.initialProgrammablePageDatas.count {
                    self.model.dCcurrentWorkRow = model.initialProgrammablePageDatas.count
                    return
                }
                
                
                self.model.dCcurrentWorkRow += 1
                self.container.programmablePageV.updateRowBgColor1(self.model.dCcurrentWorkRow-1)

                self.container.programmablePageV.scrollToRow(self.model.dCcurrentWorkRow-1)
                
            }).disposed(by: disposedBag)
        
        
        // Play 按钮 (index 1)
        container.programmablePageV.programControlBtns[1].rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.container.programmablePageV.scrollToRow(self.model.dCcurrentWorkRow-1)
                
                let playButton = self.container.programmablePageV.programControlBtns[1]
                playButton.isSelected = !playButton.isSelected
                let data = playButton.isSelected
                
                if #available(iOS 13.0, *) {
                    playButton.setImage(UIImage(named: data ? "DP_ProgrammableStop" : "DP_ProgrammablePlay")?.withTintColor(UIColor(named: "DP_ffffffff")!), for: .normal)
                } else {
                    playButton.setImage(UIImage(named: data ? "DP_ProgrammableStop" : "DP_ProgrammablePlay"), for: .normal)
                }
                
            }).disposed(by: disposedBag)
        
    }

    
    
}

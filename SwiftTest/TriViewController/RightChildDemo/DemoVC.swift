//
//  DemoVC.swift
//  SwiftTest
//
//  Created by user on 2024/11/29.
//

import UIKit
import SnapKit
import RxSwift

extension DemoVC{
    
    func updateUI(data: Demo){
        //温度
        if data.temperature.isDifferent(from: model.workData.temperature) {
            let str = model.updateTempStr(UInt8(data.temperature), validRange: -40...120)
            print("temperature: \(str)")
        }
        
        //电量
        if data.per.isDifferent(from: model.workData.per) {
            print("per: \(data.per)")
        }
        
        

        //usb 1.低电量 2.充电完成 3.其他
        //切换 usb 口
        if data.typeState.isDifferent(from: model.workData.typeState) {
            print("usb: \(data.typeState)")
        }
        
        //循环次数
        if data.cycleCount.isDifferent(from: model.workData.cycleCount) {
            print("cycleCount: \(data.cycleCount)")
        }
        
        if data.tempSign != 0 {
            
        }else{
            //0无,1输出,2输入
            switch data.typeState{
            case 0:
                switch data.per{
                case 0...10:
                    print("低电量")
                default:
                    break
                }
            case 1:
                if data.voltages.isDifferent(from: data.voltages) {
                    print("data.typeState == 1 ,voltages: \(data.voltages)")
                }
            case 2:
                if CustomBitTool.isNegative(byte: UInt8(data.per)) {
                    print("充电完成")
                }else{
                    if data.voltages.isDifferent(from: model.workData.voltages) {
                        print("data.typeState == 2 , voltages: \(data.voltages)")
                    }
                }
            default:
                break
            }
        }
        model.workData = data
        
    }
    
}



class DemoVC: RightVC<DemoV> {

    let model = DemoM()


    override func viewDidLoad() {
        super.viewDidLoad()

        container.backgroundColor = .green
        container.isUserInteractionEnabled = true
 
    }
    
    //MARK: 保存表格数据并分享
    func demo_generateXlsx(){
        
        let fileName = "demo"
        let tableTitle = ["Time(s)","Vbus(V)","Ibus(A)","Power(W)"]
        let dataArr = PortData(times: ["00:00","00:01"], voltages: [9,8], currents: [2,1], powers: [18,8])

        let tableTitle1 = ["name","num", "other"]
        let dataArr1 = Student(name: ["Ming", "Hong"], num: [1,2])

        container.shareExcelBtn.rx.tap
            .subscribe(onNext: { [weak self] _ in
            guard let selfs = self else { return}

//                //一张表一种表格格式
//                var csvString = "-- \(fileName) --\n"
//                csvString += dataArr.toCSVString(withHeaders: tableTitle)
//                
//                selfs.shareFile(fileName: fileName, csvString: csvString)
                
            //一张表两种表格格式
            var csvString = "-- \(fileName) --\n"
            csvString += dataArr.toCSVString(withHeaders: tableTitle)
            csvString += dataArr1.toCSVString(withHeaders: tableTitle1)
            
//            shareFile(fileName: fileName, csvString: csvString, completion: { fileURL in
//                //使用 UIActivityViewController 将保存的文件分享出去
//                let controller = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
//        
//                selfs.showDetailViewController(controller, sender: nil)
//        
//                controller.completionWithItemsHandler = { (type, completed, items, error) in
//                    if completed {
//                        Log.debug("分享成功")
//                    } else {
//                        Log.debug("分享失败")
//                    }
//                }
//            })
        }).disposed(by: disposedBag)
    }
    //MARK: 扩大点击区域事件
    func demo_expandClickedV_event(){
        let tap = UITapGestureRecognizer()
        container.customExpandedTapView.addGestureRecognizer(tap)
            tap.rx.event.subscribe(onNext: {[weak self] recognizzer in
                guard self != nil else{ return }

                print("label")

            }).disposed(by: disposedBag)
    }
    
    //MARK: frame、Bouonds 事件
    func demo_frameAndBouonds_event(){
        for i in 0..<container.btns.count{
            container.btns[i].rx.tap
                 .subscribe(onNext: { [weak self] _ in
                     guard let selfs = self else { return}
                    
                     switch i {
                     case 0:
                         selfs.container.viewA.frame = CGRect(x: 0, y: 0, width: 80, height: 100)
                         
                     case 1:
                         selfs.container.viewA.frame = CGRect(x: 0, y: 50, width: 100, height: 100)
                         
                     case 2:
                         selfs.container.viewA.bounds = CGRect(x: 0, y: 0, width: 40, height: 100)

                     case 3:
                         selfs.container.viewA.bounds = CGRect(x: 0, y: 50, width: 100, height: 100)
                         
                     case 4:
                         selfs.container.viewA.layer.position = CGPoint(x: 50, y: 20)
                         
                     case 5:
                         selfs.container.viewA.layer.anchorPoint = CGPoint(x: 0.5, y: 0.2)
                         
                     default:
                         selfs.container.viewA.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
                         selfs.container.viewA.bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
                         selfs.container.viewA.layer.position = CGPoint(x: 50, y: 50)
                         selfs.container.viewA.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                        
                     }
                     selfs.container.setNeedsLayout()
                     
                     DispatchQueue.main.async(execute: {
                         print("\(selfs.container.viewA.frame), \(selfs.container.viewA.bounds), subview:  \(selfs.container.viewA.subviews[0].frame),\(selfs.container.viewA.subviews[0].bounds), positon: \(selfs.container.viewA.layer.position),anchorPoint: \(selfs.container.viewA.layer.anchorPoint)")
                     })
                 }).disposed(by: disposedBag)
        }

    }
    
}


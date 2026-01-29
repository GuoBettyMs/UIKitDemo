//
//  DemoTestVC.swift
//  SwiftTest
//
//  Created by user on 2025/4/11.
//

import UIKit
import SnapKit
import RxSwift

class DemoTestVC: TestBaseVC<DemoTestV>, UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var selectedIndex: Int = 0
    var navigationItemTitle: String?
    
    var model = DemoTestM()
    
    //MARK: -
    
    // 在 viewWillAppear 中恢复状态
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if selectedIndex == 5 {
            Log.debug("DemoTestVC viewWillAppear 中恢复状态")
            // 当从 CustomPickViewVC 返回时，显示导航栏
            navigationController?.navigationBar.isHidden = false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        Log.debug("DemoTestVC viewDidLoad, [\(selectedIndex)]title= \(String(describing: navigationItemTitle))")
        
        view.backgroundColor = .systemGreen
        title = navigationItemTitle

        switch selectedIndex{
        case 0:
            setupSliderHandlers()
            setupResetBtnEvent()
            
        case 1:
            setupSheetData()
            demo_expandClickedV_event()
            
        case 2:
            container.demo_circularProgressV()
            
        case 3:
            break

        case 4:
            setuptimeZonePickerData()
            
        case 5:
            //隐藏 DemoTestVC 导航栏
            navigationController?.navigationBar.isHidden = true
            container.scrollView.isHidden = true
           
            
            let vc = CustomPickViewVC()
            // 添加回调
            vc.onDismiss = { [weak self] in
                Log.debug("CustomPickViewVC 已关闭，自动返回")
                self?.navigationController?.popViewController(animated: true)
            }
            
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.present(nav, animated: true)
            }

            
        default: break
        }
        
    }
    
    let referenceStyle: (UILabel) -> Void = { label in
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular) // 确保字号/字重一致
        label.backgroundColor = .clear
    }
    
    private func removePickerSelectionIndicator(_ pickerView: UIPickerView) {
//        // 方法1：遍历并隐藏所有 UIImageView（选择指示器通常是 UIImageView）
//        for subview in pickerView.subviews {
//            if let imageView = subview as? UIImageView {
//                imageView.isHidden = true
//                imageView.alpha = 0
//            }
//        }
        
//        // 方法2：使用 KVC 移除选择指示器（如果上面方法无效）
//        pickerView.subviews.forEach { subview in
//            if subview.bounds.height <= 1.0 || subview.bounds.height >= pickerView.bounds.height - 2 {
//                // 这很可能是选择指示器（高度很小或很大）
//                subview.isHidden = true
//                subview.alpha = 0
//            }
//        }
//
        // 方法3：iOS 14+ 的特殊处理
        if #available(iOS 14.0, *) {
            // 移除 selection overlay
            pickerView.subviews.forEach { view in
                if view.description.contains("UIPickerColumnView") {
                    view.subviews.forEach { subview in
                        if subview.description.contains("UIPickerColumnHeader") {
                            subview.isHidden = true
                        }
                    }
                }
            }
        }
        
        
    }
    // 递归查找并移除所有不需要的背景色
    private func removePickerViewBackground(_ pickerView: UIPickerView) {

//        // 递归设置所有视图为透明
//        func makeTransparent(view: UIView) {
//            view.backgroundColor = .clear
//            view.isOpaque = false
//            view.subviews.forEach { makeTransparent(view: $0) }
//        }
//
//        makeTransparent(view: pickerView)
        
        func recursiveClearBackground(view: UIView) {
            view.backgroundColor = .clear
            view.subviews.forEach { recursiveClearBackground(view: $0) }
        }
        
        pickerView.subviews.forEach { recursiveClearBackground(view: $0) }
        
        // 特殊处理：iOS 14+ 的 UIPickerView 结构
        if #available(iOS 14.0, *) {
            for subview in pickerView.subviews {
                // 移除UIPickerColumnView的背景
                if let columnView = subview as? UICollectionView {
                    columnView.backgroundColor = .clear
                }
                
                // 移除UITableView的背景
                if let tableView = subview as? UITableView {
                    tableView.backgroundColor = .clear
                    tableView.separatorStyle = .none
                }
            }
        }
    }

    //MARK: - Actions
    //MARK: frameAndBouonds
    private func setupResetBtnEvent(){
        container.resetBtn.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.resetAllViews()
            })
            .disposed(by: disposedBag)
    }
    
    private func setupSliderHandlers() {
        container.demo_frameAndBouonds()
        
        for sliderI in 0..<model.sliderConfigs.count {
            model.sliderConfigs[sliderI].handler = { value, _ in
                self.updateChildViewLayout(for: sliderI, value: value)
                self.updateSliderValueLabel(sliderI, value: value)
                self.updateResultLabel()
            }
        }
        container.setupSliderArr(model.sliderConfigs)
    }

    private func resetAllViews() {
        for i in 0..<model.sliderInit.count {
            updateChildViewLayout(for: i, value: Float(model.sliderInit[i]))
            container.sliders[i].value = Float(model.sliderInit[i])
            
            container.setupSliderValueLabel(for: container.sliderValueLs[i], model.sliderTitles[i]+": \(Float(model.sliderInit[i]))")
            updateResultLabel()
        }
    }
    
    private func updateChildViewLayout(for tag: Int, value: Float) {
        switch tag {
        case 0:
            container.childV.frame = CGRect(x: 0, y: 0, width: Int(value), height: 100)
        case 1:
            container.childV.frame = CGRect(x: 0, y: Int(value), width: 100, height: 100)
        case 2:
            container.childV.bounds = CGRect(x: 0, y: 0, width: Int(value), height: 100)
        case 3:
            container.childV.bounds = CGRect(x: 0, y: Int(value), width: 100, height: 100)
        case 4:
            container.childV.layer.position = CGPoint(x: 50, y: Int(value))
        case 5:
            container.childV.layer.anchorPoint = CGPoint(x: 0.5, y: Double(value)/100)
        default: break
        }
    }
    
    
    //MARK: shareSheet
    func setupSheetData(){
        container.demo_expandClickedV()
        container.setupXlsxTextViewText("\(model.csvContent)")
        container.xlsxTextView.delegate = self
    }
   
    func textViewDidChange(_ textView: UITextView) {
        // 实时更新模型（如果需要）
        model.csvContent = textView.text
    }

    func demo_expandClickedV_event(){
        // 示例: 添加带随机值的新行
        for i in 0...2{
            container.sheetAddBtns[i].rx.tap.subscribe(onNext: { [weak self] _ in
                guard let selfs = self else {return}
                switch i{
                case 0:
                    let newTime = String(format: "%02d:%02d", Int.random(in: 10..<24), Int.random(in: 10..<60))
                    let newVoltage = Double.random(in: 8...12)
                    let newCurrent = Double.random(in: 1...5)
                    selfs.model.addPowerDataRow(
                        to: .powerData,
                        time: newTime,
                        voltage: newVoltage,
                        current: newCurrent,
                        power: newVoltage * newCurrent
                    )
                    
                case 1:
                    let num = Double.random(in: 8...12)
                    selfs.model.addStudentRow(to: .studentData, name: "NewStudent", num: num)
                    
                case 2:
                    let num = Double.random(in: 8...12)
                    selfs.model.addStudentRow(to: .frameData, name: "NewFrame", num: num)
                    
                default: break
                }
                selfs.container.setupXlsxTextViewText(selfs.model.csvContent)
            }).disposed(by: disposedBag)
        }
        
        let tap = UITapGestureRecognizer()
        container.customExpandedTapView.addGestureRecognizer(tap)
            tap.rx.event.subscribe(onNext: {[weak self] recognizzer in
                guard let selfs = self else { return}

                selfs.shareGeneratedFile()  // Share the generated file

            }).disposed(by: disposedBag)
    }
    
    //MARK: timeZonePicker
    private func setuptimeZonePickerData(){
        container.demo_timeZonePicker()
        container.timeZonePicker.dataSource = self
        container.timeZonePicker.delegate = self
    }
    
    // MARK: - Private Methods
    //MARK: frameAndBouonds
    private func updateResultLabel() {

        var str = "childV.frame: \(container.childV.frame.formatted(decimalPlaces: 0)) \nchildV.bounds: \(container.childV.bounds.formatted(decimalPlaces: 0))\n"
        str += "childV.layer.position: \(container.childV.layer.position.formatted(decimalPlaces: 0)) \nchildV.layer.anchorPoint: \( container.childV.layer.anchorPoint.formatted(decimalPlaces: 0)) \n"
        str += "----------------\n"
        str += "parentV.frame: \(container.parentV.frame.formatted(decimalPlaces: 0)) \nparentV.bounds: \(container.parentV.bounds.formatted(decimalPlaces: 0))\n"
        str += "parentV.layer.position: \(container.parentV.layer.position.formatted(decimalPlaces: 0)) \nparentV.layer.anchorPoint: \(container.parentV.layer.anchorPoint.formatted(decimalPlaces: 0)) \n"
        container.setupResultText(str)
    }
    
    private func updateSliderValueLabel(_ sliderIndex: Int, value: Float){
        let initWidth = model.sliderInit[0]
        let initValue = model.sliderInit[sliderIndex]
        var str = ""
        
        switch sliderIndex{
        case 0:
            let frameWOffset = initValue - Int(value)
            let orientation = Int(value) == initValue ? "" : (Int(value)>initValue ? "右扩大" : "左缩小")
            let positionX = Float(value) / Float(initValue) * Float(initWidth / 2)
            str = "视觉上 childV frame width 由 \(initValue) 向"+orientation+"\(abs(frameWOffset))直至 \(Int(value))"
            + ", childV bounds width 变化为 \(Int(value)), childV layer position x 变化为 (currentW / initW) * (initW/2) = \(Int(positionX))"
            //childV frame width:100->80,视觉上 childV 向左缩小直至 width=80,此时 childV bounds width 为 80,childV layer position x 为 (80/frame Oldwidth)*(frame Oldwidth/2)=40
            //childV frame width:100->110,视觉上 childV 向右扩大直至 width=110,此时 childV bounds width 为 110,childV layer position x 为 (110/frame Oldwidth)*(frame Oldwidth/2)=55
            
        case 1:
            let frameYOffset = Int(value) - initValue
            let positionY = frameYOffset + (initWidth / 2)
            let orientation = Int(value) == initValue ? "" : (Int(value)>initValue ? "下移动" : "上移动")
            str = "视觉上 childV frame y 由 \(initValue) 向"+orientation+"\(abs(frameYOffset)) 直至 \(Int(value))"
            + ", childV layer position y 变化为 frameYOffset + (initH/2) = \(positionY)"
            //childV frame y:0->50,视觉上 childV 向下移动 50,此时 childV layer position y 为 (frame Oldwidth/2)+(frame y Offset)=100
            //childV frame y:0->-50,视觉上 childV 向上移动 50,此时 childV layer position y 为 (frame Oldwidth/2)+(frame y Offset)=0
            
        case 2:
            let frameXOffset = initValue - Int(value)
            let orientation = Int(value) == initValue ? "" : (Int(value)>initValue ? "外扩大" : "内缩小")
            str = "视觉上 childV 以中心点为准, bounds width 由 \(initValue) 向"+orientation+"\(abs(frameXOffset)) 直至 \(Int(value))"
            + ", childV frame x 变化为 frameXOffset/2 = \(frameXOffset/2)"
            //childV bounds width:100->110,视觉上 childV 以中心点为准,向外扩大直至 width=110,此时 childV frame x 为 (100-110)/2=-5
            //childV bounds width:100->50,视觉上 childV 以中心点为准,向内缩小直至 width=50,此时 childV frame x 为 (100-40)/2=25
            
        case 3:
            str = "视觉上 childV 未发生改变, childV bounds y 由 \(initValue) 变化为 \(Int(value))"
            //childV bounds y:0->50,视觉上 childV 未发生改变
        
        case 4:
            let positionYOffset = Int(value) - initValue
            let orientation = Int(value) == initValue ? "" : (Int(value)>initValue ? "下移动" : "上移动")
            str = "视觉上 childV position y 由 \(initValue) 向"+orientation+"\(abs(positionYOffset)) 直至 \(Int(value))"
            + ", childV frame y 变化为 positionYOffset = \(positionYOffset)"
            //childV position y: 50->20,视觉上 childV 向上移动 (50-20),此时 childV frame y 为 -30
            //childV position y: 50->60,视觉上 childV 向下移动 (60-50),此时 childV frame y 为 10
            
        case 5:
            let anchorPointY = Float(initValue - Int(value))/100
            let anchorPointYOffset = Int(Float(initWidth) * anchorPointY)
            let orientation = Int(value) == initValue ? "" : (Int(value)>initValue ? "向上移动\(abs(anchorPointYOffset))" : "向下移动\(abs(anchorPointYOffset))")
            str = "视觉上 childV anchorPoint y 由 \(Float(initValue)/100) "+orientation+" 直至 \(value/100)"
            + ", childV frame y 变化为 \(anchorPointYOffset)"
            //childV anchorPoint y: 0.5->0.2,视觉上 childV 向下移动 frame.height*(0.5-0.2)=30 ,此时 childV frame y 为 30
            //childV anchorPoint y: 0.5->0.6,视觉上 childV 向上移动 frame.height*(0.6-0.5)=10 ,此时 childV frame y 为 -10

        default: break
        }

        container.setupSliderValueLabel(for: container.sliderValueLs[sliderIndex], model.sliderTitles[sliderIndex]+"\n"+str)
    }

    // MARK:  shareSheet
    private func shareGeneratedFile(){
        do {
            // 调用Model层方法获取文件URL
            let fileURL = try FileManager.default.saveCSVToTempFile(
                content: model.csvContent,
                fileName: model.fileName
            )
            presentShareSheet(for: fileURL)
        } catch {
            print("Error sharing file: \(error.localizedDescription)")
            container.setupXlsxTextViewText("\(error.localizedDescription)")
        }
    }
    
    private func presentShareSheet(for fileURL: URL) {
        // Verify file exists
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("File not found at path: \(fileURL.path)")
            return
        }
        
        let activityVC = UIActivityViewController(activityItems: [fileURL],
                                                applicationActivities: nil)
        
        // iPad specific presentation configuration
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: self.view.bounds.midX,
                                      y: self.view.bounds.midY,
                                      width: 0,
                                      height: 0)
            popover.permittedArrowDirections = []
        }
        
        activityVC.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            if let error = error {
                print("Sharing failed with error: \(error.localizedDescription)")
                return
            }
            
            if completed {
                print("Sharing succeeded")
                CustomAlert.showToast(title: "Sharing succeeded", vc: self)
            } else {
                print("Sharing was cancelled")
                CustomAlert.showAdaptiveAlert(
                    on: self,
                    with: "Sharing was cancelled",
                    actions: [
                        UIAlertAction(title: "确认", style: .default) { _ in },
                        UIAlertAction(title: "知道了", style: .destructive)
                    ]
                )
            }
        }
        
        present(activityVC, animated: true)
    }
    
    //MARK: timeZonePicker
    //MARK: 时区选择器-UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return model.timeZoneData[row]
    }
    
    //MARK: 时区选择器-UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return model.timeZoneData.count
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        let timeAPIURL = URL(string: "https://www.isdt.co/ota/newbleTest.json")!
        // 安全检查
        guard model.timeZoneData.indices.contains(row) else { return }
        
        let selectedTimeZone = model.timeZoneData[row]//"America/Los_Angeles"/
        print("Selected: \(row), \(selectedTimeZone), \(TimeZone.current.identifier)")
        
        CustomSystemTime.getNetWorkTime(
            urlString: timeAPIURL.absoluteString,
            isFollowSystem: false ,
            timeZoneIden: selectedTimeZone
        ) { times in
            let str = """
            所选时区当前时间: \(times.selectedTime)
            本地系统当前时间: \(times.systemTime)
            服务器时间: \(times.serverTime)
            服务器时间转换成所选时区后: \(times.convertedTime)
            """
            self.container.setupTimeZoneLabel(str)
            
            //  解析系统时间到CustomSystemTime
            if let systemTime = CustomSystemTime.create(from: .dateSring(times.systemTime, .current)){
                print("解析后的时间对象：")
//                print(systemTime.description)
                print("本地时间：\(systemTime.year)-\(systemTime.month)-\(systemTime.day),\(systemTime.hour):\(systemTime.minute)")//本地时间：2025-5-16,15:9
                print("formattedDateTime: ",systemTime.formattedDateTime)//2025-05-16 15:09:39.000
                print("时区偏移",systemTime.timezoneOffset) //时区偏移 8
                // 格式转换
                let intArray = systemTime.toIntArray()  //[1, 15, 9, 39, 0, 2025, 5, 16, 5, 8]
                print("\(intArray)")
                
            } else {
                print("无法解析时间字符串")
            }

            
            if let nyTime = CustomSystemTime.create(from: .now("America/New_York")){
                print("纽约当前时间：\(nyTime.hour):\(nyTime.minute)")//纽约当前时间：15:9
                print("时区偏移：GMT\(nyTime.timezoneOffset)")//时区偏移：GMT-4
            }
            if let localTime = CustomSystemTime.create(from: .dateSring(times.systemTime, TimeZone(identifier: "GMT")!)){
                print("GMT 时间：\(localTime.year)-\(localTime.month)-\(localTime.day),\(localTime.hour):\(localTime.minute)")//GMT 时间：2025-5-16,23:9
                print("formattedDateTime: ",localTime.formattedDateTime)//2025-05-16 23:09:39.000
                print("时区偏移: ",localTime.timezoneOffset)// 时区偏移 0
            }
            
            
            // 时间格式化
            let t = TimeFormatter.string(from: 3665)          // "01:01:05"
            let t1 = TimeFormatter.string(from: 125, style: .hoursMinutes)  // "02:05"
            print(t)
            print(t1)
        }
    }

}



//
//  VCEx_forPresetpage.swift
//  SwiftTest
//
//  Created by user on 2026/1/28.
//


import UIKit

//MARK: - 预设值页面处理扩展
extension CustomPickViewVC: PresetPageViewDelegate {

    func presetPageView(_ view: PresetPageV, didInsertSublistItem data: ProgramDataModel, at position: Int, inRowAt rowIndex: Int) {
        
//        Log.debug("didInsertSublistItem")
        model.initialPresetListDatas[rowIndex].dataModel.insert(data, at: position)
    }
    
    func presetPageView(_ view: PresetPageV, didDeleteSublistItemAt position: Int, inRowAt rowIndex: Int) {
        
//        Log.debug("didDeleteSublistItemAt")
        model.initialPresetListDatas[rowIndex].dataModel.remove(at: position)
    }
    
    func presetPageView(_ view: PresetPageV, didSelectPowerValue value: Int, forRowAt rowIndex: Int) {
        
//        Log.debug("更新 pDOPower 值, \(value)")
        model.initialPresetListDatas[rowIndex].pDOPower = value
        savePresetEditSign()
        
    }
    
    func presetPageView(_ view: PresetPageV, didUpdateItems datas: [ProgramDataModel], forRowAt rowIndex: Int) {
        
        model.initialPresetListDatas[rowIndex].dataModel = datas
    }
    
    
    //MARK: -

    // 通过 UI 索引获取原始 ProgramFileModel.index
    func presetOriginalIndexForUIIndex(_ uiIndex: Int) -> Int? {
        guard uiIndex >= 0 && uiIndex < model.presetlistDisplayOrder.count else {
            Log.debug("映射关系错误: UI索引 \(uiIndex) 超出范围")
            return nil
        }
        let dataIndex = model.presetlistDisplayOrder[uiIndex]
        guard dataIndex >= 0 && dataIndex < model.initialPresetListDatas.count else {
            Log.debug("映射关系错误: 数据索引 \(dataIndex) 超出范围")
            return nil
        }
        return model.initialPresetListDatas[dataIndex].index
    }

    
    func setPresetSublistActiveTextField(_ textField: UITextField){
        presetSublistActiveTextField = textField
//        Log.debug("设置当前编辑的单元格: \(textField.text ?? "-")")
    }
    
    //MARK: 存储编辑记录
    //监听列表行的 power 编辑状态变化, 存储编辑记录
    private func savePresetEditSign(){
        guard container.presetPageV.selectedRowI >= 0 && container.presetPageV.selectedRowI < container.presetPageV.presetPageRows.count else {
            Log.debug("setInitialPickerVValue, selectedRowI error")
            return }
        
        if let originalIndex = presetOriginalIndexForUIIndex(container.presetPageV.selectedRowI) {
            // 检查是否已存在相同的操作
            if model.presetWriteCommandIArr.contains(where: { $0 == originalIndex }) {
//                Log.debug("跳过重复操作: 索引 \(originalIndex) 的编辑操作已存在")
            }else{
                model.presetWriteCommandIArr.append(originalIndex)
                
//                Log.debug("添加编辑记录: \(model.presetWriteCommandIArr)")
            }
        }
    }
    
    //监听列表行的标题文本框编辑状态变化
    func setupPresetListEditStateObservation() {

        let observer = NotificationCenter.default.addObserver(
            forName: .presetlistCellEditStateChanged,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleListCellEditStateChange(notification)
        }
        model.presetEditstateObservers.append(observer)
    }
    
    //监听次列表所有单元格的编辑状态变化
    func setupPresetSubListEditStateObservation() {

        let observer = NotificationCenter.default.addObserver(
            forName: .presetSublistcellEditStateChanged,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleSublistCellEditStateChange(notification)
        }
        model.presetEditstateObservers.append(observer)
    }
    
    //MARK: -
    
    //列表行的标题文本框发生编辑,存储记录, 归类于 RowOperation.rowAdd
    @objc private func handleListCellEditStateChange(_ notification: Notification) {
        
        guard container.presetPageV.selectedRowI >= 0 && container.presetPageV.selectedRowI < container.presetPageV.presetPageRows.count else {
        Log.debug("存储编辑记录, selectedRowI \(container.presetPageV.selectedRowI) error")
        return }
        
        //存储编辑记号
        if let originalIndex = presetOriginalIndexForUIIndex(container.presetPageV.selectedRowI) {
            // 创建操作,originalIndex 是新值则属于列表新增行、否则列表行标题修改
            let operation = RowOperation.rowAdd(index: originalIndex)
            
            //先编辑 existingIndex 的次列表,保存编辑记录 celldataEdit, 再编辑 existingIndex 的标题, 则《不保存》编辑记录 rowAdd,因为 .celldataEdit(let existingIndex) 会发 06,已包含标题的新数据
            // 检查是否已存在相同的操作
            if !model.pendingOperations.contains(where: { existingOperation in
                switch existingOperation {
                case .rowAdd(let existingIndex),
                        .celldataEdit(let existingIndex):
                    return existingIndex == originalIndex //同一行,若之前的操作已存在 rowAdd 、celldataEdit,视为相同
                case .rowDelete(_):
                    // rowDelete 不视为重复，因为删除后可能重新编辑
                    return false
                }
            }) {
                model.pendingOperations.append(operation)
                model.presetWriteCommandIArr.append(originalIndex)
                
//                Log.debug("添加编辑记录: \(model.presetWriteCommandIArr), 当前操作数量: \(model.pendingOperations.count): \(model.pendingOperations)")
            } else {
//                Log.debug("跳过重复操作: 索引 \(originalIndex) 的编辑操作已存在")
            }
        }
    }
    
    //次列表行的文本框发生编辑,存储记录, 归类于 RowOperation.celldataEdit
    @objc private func handleSublistCellEditStateChange(_ notification: Notification) {

        guard container.presetPageV.selectedRowI >= 0 && container.presetPageV.selectedRowI < container.presetPageV.presetPageRows.count else {
        Log.debug("存储编辑记录, selectedRowI \(container.presetPageV.selectedRowI) error")
        return }
        
        //存储编辑记号
        if let originalIndex = presetOriginalIndexForUIIndex(container.presetPageV.selectedRowI) {
            // 创建操作
            let operation = RowOperation.celldataEdit(index: originalIndex)
            
            
            // 检查是否已存在相同的 celldataEdit 操作
            if model.pendingOperations.contains(where: {
                if case .celldataEdit(index: let existingIndex) = $0 {
                    return existingIndex == originalIndex
                }
                return false
            }) {
//                Log.debug("跳过重复操作: 索引 \(originalIndex) 的 celldataEdit 操作已存在")
                return
            }
            
            // 检查已有的记录中是否有 rowAdd 操作，如果有则替换,因为 celldataEdit 会发 06 与 da,而 rowAdd 只发 06
            if let rowAddIndex = model.pendingOperations.firstIndex(where: {
                if case .rowAdd(index: let existingIndex) = $0 {
                    return existingIndex == originalIndex
                }
                return false
            }) {
                //rowAddIndex 不为空, 有 rowAdd 操作, 替换 rowAdd 为 celldataEdit
                model.pendingOperations[rowAddIndex] = operation
//                Log.debug("✅ 替换 rowAdd 为 celldataEdit: 索引 \(originalIndex)")
            } else {
                // rowAddIndex 为空, 没有 rowAdd，直接添加 celldataEdit
                model.pendingOperations.append(operation)
                
                // 添加到命令数组
                if !model.presetWriteCommandIArr.contains(originalIndex) {
                    model.presetWriteCommandIArr.append(originalIndex)
                }
                
//                Log.debug("✅ 添加 celldataEdit 操作: 索引 \(originalIndex)")
            }
            
        }
        
    }
    
    //MARK: 上传
    func presetPageUpLoadEvent(){
        
        container.presetPageV.presetPageViewDelegate = self
       
        container.presetPageV.upLoadBtn.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let selfs = self else { return }
                
                selfs.model.isupLoadBtnClick = true
                
                if selfs.currentPage == .programHomepage_presetvalue {
                    selfs.executeOperations()
   
                }else if selfs.currentPage == .usbHomepage_presetvalue {
//                    Log.debug("PDO 列表编辑过的记录 ,  \(selfs.pDOWriteCommandIArr_ForPresetvalues)\n")
                }
            }).disposed(by: disposedBag)
    }
   
    
    //列表执行操作
    private func executeOperations() {
        
        guard !model.pendingOperations.isEmpty else { return }
            
        model.uploadContext.pendingOperations = model.pendingOperations
        model.uploadContext.commandIndex = 0
        
        Log.debug("开始执行 \(model.pendingOperations.count) 个操作: \( model.pendingOperations)")
        processNextOperation()
        
    }

    //统一操作处理入口
    private func processNextOperation() {
        guard model.uploadContext.commandIndex < model.uploadContext.pendingOperations.count else {
            finishUpload()
            return
        }
        
        let operation = model.uploadContext.pendingOperations[model.uploadContext.commandIndex]
        
        switch operation {
        case .rowAdd(let index), .celldataEdit(let index):
            handleRowOrSublistEdit(index: index, isRowAdd: operation.isRowAdd)
            
        case .rowDelete(let index):
            handleRowDelete(index: index)
        }
    }
    
    //MARK: -
    
    //完成上传后清理 & 重排序
    private func finishUpload() {
        Log.debug("✅ 所有操作上传完成")
        
//        kBleManager.packUser = nil
        
        // 清理状态
        model.pendingOperations.removeAll()
        model.presetWriteCommandIArr.removeAll()
        
        // 重置索引（避免后续操作错乱）
        for i in 0..<model.initialPresetListDatas.count {
            model.initialPresetListDatas[i].index = i
        }
        
        model.uploadContext = UploadContext() // 重置上下文
    }
    
    // 可编程页面发送写入请求
    /// - Parameters:
    ///   - index: 原始数据索引, 即 ProgramFileModel.index
    ///   - isRowAdd: 是否列表新增行
    private func handleRowOrSublistEdit(index: Int, isRowAdd: Bool) {
        // 找到要编辑的数据在数组中的实际位置
        guard let dataIndex = model.initialPresetListDatas.firstIndex(where: {  $0.index == index }) else {
            Log.debug("⚠️ 数据不存在，index= \(index)")
            model.uploadContext.advanceToNextCommand()
            processNextOperation()
            return
        }
        
        let data = model.initialPresetListDatas[dataIndex]
        let isEmptySublist = data.dataModel.isEmpty
       
        // 判断是否需要上传次列表
        if isRowAdd || isEmptySublist {
            // 只上传主行（06 命令中“删除”位代表值,当次列表为空,将次列表全部清空,修改 row 标题, deleteFlag = 0）
            sendMainRowRequest(dataIndex: dataIndex)
        } else {
            // 需要上传次列表（06 命令中“删除”位代表值,次列表数据发生修改(如新增、删除、修改数据), deleteFlag = 2）
            model.uploadContext.sublistTotalCount = data.dataModel.count
            model.uploadContext.sublistCurrentPage = 0
            sendSublistPage(for: index, dataIndex: dataIndex)
        }
 
    }
    
    // 可编程页面发送删除请求
    /// - Parameters:
    ///   - index: 原始数据索引, 即 ProgramFileModel.index
    private func handleRowDelete(index: Int) {
        // 找到要删除的数据在数组中的实际位置
        if let dataIndex = model.initialPresetListDatas.firstIndex(where: {  $0.index == index }) {
            model.initialPresetListDatas.remove(at: dataIndex)
            Log.debug("🗑️ 删除行 index=  \(index), dataIndex=  \(dataIndex)")
        }
        
        // 发送删除请求（deleteFlag = 1）
        // TODO: kBleManager.packUser = deleteRequest(
        //        let writeRequest = DCListSingleDataWriteRequest_ForPresetvalues()
        //        writeRequest.listIndex = dataIndex + 1
        //        writeRequest.titlename = ""
        //        writeRequest.sublistTotalCount = 0
        //        writeRequest.modifyDataFlag = isLastCommand ? 1 : 0
        //        writeRequest.deleteFlag = 1
        //        kBleManager.packUser = writeRequest)
        
        model.uploadContext.advanceToNextCommand()
        processNextOperation()

        
    }
    
    //写入列表行
    private func sendMainRowRequest(dataIndex: Int) {
//        Log.debug("不涉及次列表,继续写入列表行")
        
        // 发送写入请求（deleteFlag = 0）
        // TODO: kBleManager.packUser = listWriteRequest(
        //        let writeRequest = DCListSingleDataWriteRequest_ForPresetvalues()
        //        writeRequest.listIndex = dataIndex + 1
        //        writeRequest.titlename = model.initialPresetListDatas[dataIndex].title
        //        writeRequest.sublistTotalCount = model.initialPresetListDatas[dataIndex].dataModel.count
        //        writeRequest.modifyDataFlag = isLastCommand ? 1 : 0
        //        writeRequest.deleteFlag = 0 )
        
        model.uploadContext.advanceToNextCommand()
        processNextOperation()
        
    }
    
    //写入次列表行
    private func sendSublistPage(for index: Int, dataIndex: Int) {
        
        guard model.uploadContext.sublistCurrentPage < model.uploadContext.sublistPages else {
            // 次列表传完，继续下一个命令
//            Log.debug("次列表传完，继续下一个命令")
            model.uploadContext.advanceToNextCommand()
            processNextOperation()
            return
        }
        
        let data = model.initialPresetListDatas[dataIndex]
        
        //次列表数据每次最多发送10条,若总数量超过10条,如共13条,需发送2次命令,第一次发送10条数据[0...9],第二次发送3条数据[10...12]
        let start = model.uploadContext.sublistCurrentPage * model.uploadContext.sublistTakeoverMaxCount
        let end = min(start + model.uploadContext.sublistTakeoverMaxCount, data.dataModel.count)
        let sublistChunk = Array(data.dataModel[start..<end])
        
        Log.debug("📤 第 \(dataIndex + 1) 行发送次列表: page  \(model.uploadContext.sublistCurrentPage + 1)/ \( model.uploadContext.sublistPages), count: \(sublistChunk.count), range= \(start)..<\(end)")
        
        // 发送写入请求（deleteFlag = 2）
        // TODO: kBleManager.packUser = sublistWriteRequest(
        //        let writeRequest = DCListSingleDataWriteRequest_ForPresetvalues()
        //        writeRequest.listIndex = dataIndex + 1
        //        writeRequest.titlename = model.initialPresetListDatas[dataIndex].title
        //        writeRequest.sublistTotalCount = model.initialPresetListDatas[dataIndex].dataModel.count
        //        writeRequest.modifyDataFlag = isLastCommand ? 1 : 0
        //        writeRequest.deleteFlag = 2
        
        if model.uploadContext.isLastSublistPage {
            // 最后一页，继续下一个主命令
            model.uploadContext.advanceToNextCommand()
            processNextOperation()
        } else {
            // 继续下一页
            model.uploadContext.advanceSublistPage()
            sendSublistPage(for: index, dataIndex: dataIndex)
        }
    }
    
    
    //MARK: 初始值

    // 初始化显示顺序,用于后续添加删除操作后可查找正确的 ProgramFileModel.index
    private func setupDisplayOrder() {
        model.presetlistDisplayOrder = Array(0..<model.initialPresetListDatas.count)
    //        Log.debug("displayOrder 初始化显示顺序: \(displayOrder)")
    }

    func loadPresetPageDataArr(){

        var initialSublistDatas: [ProgramDataModel] = []

        for i in 0..<8 {
           switch i{
           case 0...4:
               let cell = ProgramDataModel(index: i, voltageMin: 60, current: 100, isSelected: false )
               initialSublistDatas.append(cell)
               
           case 5:
               let cell = ProgramDataModel(index: i, voltageMin: 10, voltageMax: 20, current: 20, isSelected: false)
               initialSublistDatas.append(cell)
               
           case 6:
               let cell = ProgramDataModel(index: i, current: 100, max_current20V_10ma: 100, isSelected: false)
               initialSublistDatas.append(cell)
               
           default:
               let cell = ProgramDataModel(index: i, voltageMin: 20, current: 100, isSelected: false)
               initialSublistDatas.append(cell)
           }
        }

        for dataI in 0..<1 {
           let test = ProgramFileModel(index: dataI, title: "titlename\(dataI)", pDOPower: 12, dataModel: initialSublistDatas)
           model.initialPresetListDatas.append(test)
        }

        container.presetPageV.showPresetlist(with: model.initialPresetListDatas)
        setupDisplayOrder()
    }
}


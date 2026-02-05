//
//  NumberKeyboardView.swift
//  SwiftTest
//
//  Created by user on 2026/1/15.
//

// 自定义数字键盘

import UIKit
import SnapKit

protocol NumberKeyboardDelegate: AnyObject {
    func numberKeyPressed(_ number: Int)
    func decimalPointPressed()
    func iconButtonPressed()
    func backspacePressed()
    func clearPressed()
    func confirmPressed()
}

struct NumberInputConfig {
    let maxValue: Double
    let integerDigits: Int      // 整数位数
    let decimalDigits: Int      // 小数位数
    let totalDigits: Int        // 总位数
    
    init(maxValue: Double) {
        self.maxValue = maxValue
        
        // 根据最大值自动计算位数
        if maxValue >= 10.0 {
            // 如 30.50: 2位整数 + 2位小数
            self.integerDigits = 2
            self.decimalDigits = 2
        } else if maxValue >= 1.0 {
            // 如 5.100: 1位整数 + 3位小数
            self.integerDigits = 1
            self.decimalDigits = 3
        } else {
            // 如 0.99: 0位整数 + 2位小数
            self.integerDigits = 0
            self.decimalDigits = 2
        }
        
        self.totalDigits = integerDigits + decimalDigits
    }
    
    // 获取小数部分最大值
    func getMaxDecimalValue() -> Double {
        let stringValue = String(maxValue)
        
        // 如果有小数点
        if let dotRange = stringValue.range(of: ".") {
            let decimalPartStr = String(stringValue[dotRange.upperBound...])
            
            // 如果有小数部分
            if !decimalPartStr.isEmpty {
                // 转换为 0.xxx 格式
                let decimalStr = "0." + decimalPartStr
                return Double(decimalStr) ?? 0.0
            }
        }
        
        return 0.0
//        return maxValue - Double(Int(maxValue))
    }
    
    // 获取整数部分最大值
    func getMaxIntegerValue() -> Int {
        return Int(floor(maxValue))
    }
    
    // 是否为特殊边界值（如30.50, 5.100）
    var isBoundaryValue: Bool {
        let integerPart = Int(floor(maxValue))
        let decimalPart = maxValue - Double(integerPart)
        return decimalPart > 0 && decimalPart < 1.0
    }
}

class NumberKeyboardView: UIView {
    weak var delegate: NumberKeyboardDelegate?
    private let keyboardManager = NumberKeyboardManager()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 5
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.register(NumberKeyCell.self, forCellWithReuseIdentifier: NumberKeyCell.identifier)
        return collectionView
    }()
    
    //退格
    private let backspaceButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "DP_keyboardBackspace"), for: .normal)
        button.tintColor = .black
        button.backgroundColor = UIColor(named: "DP_d9d9d9ff")
        button.layer.cornerRadius = 5
        return button
    }()
    
    //清空
    private let clearBtn: UIButton = {
        let button = UIButton()
//        button.setTitle("C", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.tintColor = .black
        button.backgroundColor = UIColor(named: "DP_d9d9d9ff")
        button.layer.cornerRadius = 5
        return button
    }()
    
    //确认
    private let confirmBtn: UIButton = {
        let button = UIButton()
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(named: "DP_pickConfirm")?.withTintColor(UIColor(named: "DP_ffffffff") ?? .white), for: .normal)
        } else {
            button.setImage(UIImage(named: "DP_pickConfirm"), for: .normal)
        }
        button.backgroundColor = UIColor(named: "DP_0B8CE8ff")
        button.layer.cornerRadius = 5
        return button
    }()
    
    //MARK: - Initialization
    //监听 collectionView bounds 变化, 防止旋转或尺寸变化时布局错乱
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        
        addSubview(collectionView)
        addSubview(backspaceButton)
        addSubview(clearBtn)
        addSubview(confirmBtn)

        
        backspaceButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.2) //66/331
            make.height.equalTo(36)
        }
        
        clearBtn.snp.makeConstraints { make in
            make.left.right.equalTo(backspaceButton)
            make.top.equalTo(backspaceButton.snp.bottom).offset(5)
            make.height.equalTo(backspaceButton.snp.height)
        }
        clearBtn.setAttributedTitle(bahnschrift_formatted("C"), for: .normal)
        
        confirmBtn.snp.makeConstraints { make in
            make.left.right.equalTo(backspaceButton)
            make.height.equalTo(77)
            make.top.equalTo(clearBtn.snp.bottom).offset(5)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
            make.right.equalTo(backspaceButton.snp.left).offset(-8)
            make.bottom.equalTo(confirmBtn.snp.bottom)
        }

        collectionView.dataSource = self
        collectionView.delegate = self
        
        backspaceButton.addTarget(self, action: #selector(backspaceTapped), for: .touchUpInside)
        clearBtn.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        confirmBtn.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        
    }
    
    //MARK: -

    @objc private func backspaceTapped() {
        delegate?.backspacePressed()
    }
    
    
    @objc private func clearTapped() {
        delegate?.clearPressed()
    }

    
    @objc private func confirmTapped() {
        delegate?.confirmPressed()
    }
    
    // MARK: - Public Methods
    
    func disableKey(at index: Int) {
        keyboardManager.disableKey(at: index)
        collectionView.reloadData()
    }
    
    func enableKey(at index: Int) {
        keyboardManager.enableKey(at: index)
        collectionView.reloadData()
    }
    
    func disableKeys(at indices: [Int]) {
        keyboardManager.disableKeys(at: indices)
        collectionView.reloadData()
    }
    
    func enableKeys(at indices: [Int]) {
        keyboardManager.enableKeys(at: indices)
        collectionView.reloadData()
    }
    
    func isKeyEnabled(at index: Int) -> Bool {
        return keyboardManager.isKeyEnabled(at: index)
    }
    
    // 按数字控制的方法
    func disableNumberKey(_ number: Int) {
        for (index, key) in keyboardManager.numberKeys.enumerated() {
            if case .number(let keyNumber) = key.type, keyNumber == number {
//                Log.debug("numberKeys[\(number)] disable")
                keyboardManager.disableKey(at: index)
                break
            }
        }
        collectionView.reloadData()
    }
    
    func enableNumberKey(_ number: Int) {
        for (index, key) in keyboardManager.numberKeys.enumerated() {
            if case .number(let keyNumber) = key.type, keyNumber == number {
//                Log.debug("numberKeys[\(number)] enable")
                keyboardManager.enableKey(at: index)
                break
            }
        }
        collectionView.reloadData()
    }
    
    func disableAllNumberKeys() {
        keyboardManager.enableAllKeys() // 先启用所有
        for i in 0..<keyboardManager.numberKeys.count {
            if case .number = keyboardManager.numberKeys[i].type {
                keyboardManager.disableKey(at: i)
            }
        }
        collectionView.reloadData()
    }
    
    func enableAllNumberKeys() {
        keyboardManager.enableAllKeys()
        collectionView.reloadData()
    }
    
    func disableDecimalPoint() {
        for (index, key) in keyboardManager.numberKeys.enumerated() {
            if case .decimalPoint = key.type {
                keyboardManager.disableKey(at: index)
                break
            }
        }
        collectionView.reloadData()
    }
    
    func enableDecimalPoint() {
        for (index, key) in keyboardManager.numberKeys.enumerated() {
            if case .decimalPoint = key.type {
                keyboardManager.enableKey(at: index)
                break
            }
        }
        collectionView.reloadData()
    }
    
}

extension NumberKeyboardView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return keyboardManager.numberKeys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NumberKeyCell.identifier, for: indexPath) as! NumberKeyCell
        let numberKey = keyboardManager.numberKeys[indexPath.item]
        cell.configure(with: numberKey)
        return cell
    }
}

extension NumberKeyboardView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let numberKey = keyboardManager.numberKeys[indexPath.item]
        guard numberKey.isEnabled else { return }
        
        switch numberKey.type {
        case .number(let num):
            delegate?.numberKeyPressed(num)
            
        case .decimalPoint:
            delegate?.decimalPointPressed()
            
        case .icon:
            delegate?.iconButtonPressed()
        }
    }
}

extension NumberKeyboardView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // 固定布局：3列 x 4行
        let columns: CGFloat = 3
        let rows: CGFloat = 4
        
        let interitemSpacing: CGFloat = 8  // 列间距
        let lineSpacing: CGFloat = 5       // 行间距
        
        // 计算总间隙
        let totalInteritemSpacing = (columns - 1) * interitemSpacing   // 2 * 8 = 16
        let totalLineSpacing = (rows - 1) * lineSpacing               // 3 * 5 = 15
        
        // 可用空间
        let availableWidth = collectionView.bounds.width - totalInteritemSpacing
        let availableHeight = collectionView.bounds.height - totalLineSpacing
        
        // 每个 item 尺寸
        let itemWidth = availableWidth / columns
        let itemHeight = availableHeight / rows
        
        return CGSize(width: max(0, itemWidth), height: max(0, itemHeight))

    }
        
    // 确保间距一致
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        // 可以根据需要添加内边距
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
}

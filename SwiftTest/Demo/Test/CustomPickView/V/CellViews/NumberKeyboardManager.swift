//
//  NumberKeyboardManager.swift
//  SwiftTest
//
//  Created by user on 2026/1/15.
//

// 自定义数字键盘数据模型

enum KeyType {
    case number(Int)      // 数字键
    case decimalPoint     // 小数点
    case icon(String)     // 图标（系统名称）
}

struct NumberKey {
    let type: KeyType
    var isEnabled: Bool
    
    var displayValue: String {
        switch type {
        case .number(let num):
            return "\(num)"
        case .decimalPoint:
            return "."
        case .icon(let systemName):
            return systemName
        }
    }
    
    init(type: KeyType, isEnabled: Bool = true) {
        self.type = type
        self.isEnabled = isEnabled
    }
}

class NumberKeyboardManager {
    
    var numberKeys: [NumberKey] = [
        NumberKey(type: .number(1)),
        NumberKey(type: .number(2)),
        NumberKey(type: .number(3)),
        NumberKey(type: .number(4)),
        NumberKey(type: .number(5)),
        NumberKey(type: .number(6)),
        NumberKey(type: .number(7)),
        NumberKey(type: .number(8)),
        NumberKey(type: .number(9)),
        NumberKey(type: .icon("arrow.left.to.line.compact")), // 第4行第1个：图标按钮
        NumberKey(type: .number(0)),
        NumberKey(type: .decimalPoint) // 第4行第3个：小数点
    ]
    
    func enableAllKeys() {
        for i in 0..<numberKeys.count {
            numberKeys[i].isEnabled = true
        }
    }
    
    func disableKey(at index: Int) {
        guard index < numberKeys.count else { return }
        numberKeys[index].isEnabled = false
    }
    
    func enableKey(at index: Int) {
        guard index < numberKeys.count else { return }
        numberKeys[index].isEnabled = true
    }
    
    func disableKeys(at indices: [Int]) {
        indices.forEach { disableKey(at: $0) }
    }
    
    func enableKeys(at indices: [Int]) {
        indices.forEach { enableKey(at: $0) }
    }
    
    func isKeyEnabled(at index: Int) -> Bool {
        guard index < numberKeys.count else { return false }
        return numberKeys[index].isEnabled
    }
    
    // 按类型查找键的方法
    func disableKey(with number: Int) {
        if let index = numberKeys.firstIndex(where: {
            if case .number(let num) = $0.type, num == number {
                return true
            }
            return false
        }) {
            numberKeys[index].isEnabled = false
        }
    }
    
    func enableKey(with number: Int) {
        if let index = numberKeys.firstIndex(where: {
            if case .number(let num) = $0.type, num == number {
                return true
            }
            return false
        }) {
            numberKeys[index].isEnabled = true
        }
    }
}

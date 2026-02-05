//
//  Serializable.swift
//  SwiftTest
//
//  Created by user on 2025/4/10.
//
/**
    自定义对象
**/

import Foundation

public class CustomObject { }

public extension CustomObject {
    var classNameString: String {
        let nameClass: AnyClass! = object_getClass(self)
        return NSStringFromClass(nameClass)
    }
}

public extension CustomObject{
    fileprivate func loopForMirrorChildren(
        _ mirrorChildren: Mirror.Children, // 对象的反射属性集合
        _ representation: inout [String: Any] // 输出的字典（引用传递）
    ) {
        // 遍历所有属性（过滤掉无label的属性）
        for case let (label?, value) in mirrorChildren {
            switch value {
                
            // 情况1：属性是 CustomObject 类型
            case let value as CustomObject:
                representation[label] = value.toDic() // 递归调用 toDic()
                
            // 情况2：属性是 CustomObject 数组
            case let value as [CustomObject]:
                var aaObjectArr = [Any]()
                for aaObject in value { // 遍历数组元素
                    aaObjectArr.append(aaObject.toDic() ?? [String: Any]()) // 递归转换
                }
                representation[label] = aaObjectArr
                
            // 情况3：属性是 NSObject 类型
            case let value as NSObject:
                representation[label] = value // 直接存储
                
            case let value as String:
                representation[label] = value
                
            case let value as Int:
                representation[label] = value
                
            case let value as Bool:
                representation[label] = value
                
            // 其他基础类型...
            // 其他类型忽略
            default:
                break
            }
        }
    }
    
    func toDic() -> [String: Any]? {
        var representation = [String: Any]()
        
        let mirrorChildren = Mirror(reflecting: self).children
        loopForMirrorChildren(mirrorChildren, &representation)
        
        let superMirrorChildren = Mirror(reflecting: self).superclassMirror?.children
        if superMirrorChildren?.count ?? 0 > 0 {
            loopForMirrorChildren(superMirrorChildren!, &representation)
        }
        
        return representation as [String: Any]?
    }
    
    
    func toJSON() -> String? {
        do {
            let data = try JSONSerialization.data(withJSONObject: toDic() as Any, options: [])
            let jsonStr = String(data: data, encoding: String.Encoding.utf8)
            return jsonStr
        } catch {
            return nil
        }
    }
    
}

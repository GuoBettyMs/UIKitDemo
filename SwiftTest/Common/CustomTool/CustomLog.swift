//
//  CustomLog.swift
//  SwiftTest
//
//  Created by user on 2025/4/22.
//

import Foundation

/// 打印信息
struct Log {
    static func debug(_ s:String, _ file: String = #file, _ line: Int = #line) {
        #if DEBUG
        let file = (file as NSString).lastPathComponent
        NSLog(file + "[\(line)]:" + s)
        #endif
    }
}

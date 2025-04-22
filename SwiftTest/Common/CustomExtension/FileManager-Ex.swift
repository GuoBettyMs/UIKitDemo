//
//  FileManager-Ex.swift
//  SwiftTest
//
//  Created by user on 2025/4/22.
//

import Foundation

// MARK: - 文件保存
extension FileManager{
    /// save a CSV file with the given content
    /// FileManager.default 文件系统的类的单例,是全局唯一实例, urls(for:::) 方法可能返回多个 URL,通常情况下，文档目录只有一个; .documentDirectory 表示要获取应用程序的文档目录,该目录存储应用程序产生的数据; .userDomainMask, 指用户域,是用户专属的存储空间
    /// - Parameters:
    ///   - fileName: Name of the file (without extension)
    ///   - content: CSV content string
    ///   - isPersistentStorage: 是否持久存储
    ///   - completion: Completion handler with Result<URL, Error>
    func saveCSVToTempFile(content: String, fileName: String, isPersistentStorage: Bool = false) throws -> URL {
        var fileURL: URL //当文件名带有.csv扩展名, 应用程序通常会默认使用 UTF-8 或其他 Unicode 编码来处理这些文件,从而正确显示汉字
        if isPersistentStorage {
            //文档目录 (documentDirectory)    文件会持久化保存，占用用户存储空间
            let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            fileURL = directory.appendingPathComponent("\(fileName).csv")
        }else{
            let fileManager = FileManager.default
            let tempDir = fileManager.temporaryDirectory //临时目录,文件可能被系统自动清理，适合临时分享
            fileURL = tempDir.appendingPathComponent("\(fileName).csv")
        }

        // 添加UTF-8 BOM头确保中文兼容
        let bom = "\u{FEFF}"
        let fullContent = bom + content
        
        try fullContent.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }
}

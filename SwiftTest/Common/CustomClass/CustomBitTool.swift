//
//  CustomBitTool.swift
//  SwiftTest
//
//  Created by user on 2025/4/22.
//
//  自定义位操作工具

class CustomBitTool{
    // MARK: - 位操作工具集
    /// 将位数组组合成整数
    /// - Parameters:
    ///   - bits: 位数组（从低位到高位排列）
    ///   - byteCount: 字节数（默认1字节=8位）
    /// - Returns: 组合后的整数
    /// - Note: 如果 bits.count 小于 byteCount*8，高位补0；如果超出，截断处理
    static func combineBits(_ bits: [Int], byteCount: Int = 1) -> Int{
        let bitCount = 8 * byteCount
        var result = 0  // 初始化结果变量
        
        //添加边界检查（min(bits.count, bitCount)）; 位操作只影响最低位（bits[i] & 0x01）
        for i in 0..<min(bits.count, bitCount) {
            result |= (bits[i] & 0x01) << i  //将 bits[i] 左移 i 位,再与 byte 进行位或赋值运算
        }
        return result
        
    //    // 初始化结果变量
    //    var result = 0
    //
    //    // 使用 stride 清晰表达循环范围,确保不会越界
    //    /*
    //        1.将 bits[i] 左移 i 位
    //        假设 bits[0] = 1    左移0位：  00000001
    //        假设 bits[1] = 1    左移1位：  00000010
    //        2.按位或运算(|)的规则是：有1则1，全0为0. 位或赋值运算(|=)的规则是：将新的位值与现有值合并.
    //        假设 result = 0x01, bits[2] = 1, 则 result |= 1 << 2
    //        00000001 |= 00000100 = 00000101
    //    */
    //    注:  bits 数组必须给足8位
    //    for i in stride(from: 0, through: (bitCount - 1), by: 1) {
    //        // 使用位运算合并位
    //        result |= (bits[i] << i) //将 bits[i] 左移 i 位,再与 byte 进行位或赋值运算
    //    }
    //    return result
    }

    /// 将整数拆分为位数组
    /// - Parameters:
    ///   - value: 要拆分的整数值
    ///   - byteCount: 字节数（默认1字节=8位）
    /// - Returns: 位数组（从低位到高位排列）
    static func splitToBits(_ value: Int, byteCount: Int = 1) -> [Int]{
        let bitCount = 8 * byteCount
        return (0..<bitCount).map { (value >> $0) & 0x01 }
        
    //    // 预分配数组容量以提高性能
    //    var bits = Array(repeating: 0, count: bitCount)
    //
    //    // 使用 stride(from:through:by:) ,确保不会越界
    //    /*
    //        1.当对一个数进行右移 i 位操作 (byte >> i) 时,会将目标( bit )位移动到最右边（即最低位）
    //        假设 byte = 0xA5 (10100101)：
    //        右移1位：   01010010
    //        右移2位：   00101001
    //        2.按位与运算(&)的规则是：两个位都为1时结果为1，否则为0,而 0x01 只在最低位是1，其他位都是0.
    //        将右移后的结果与 0x01 进行位与运算会"屏蔽"掉除最低位以外的所有位,最终结果要么是0要么是1，正好代表了原始数字第i位的值
    //        假设右移2位后：  00101001
    //        与 0x01:       00000001
    //        结果：          00000001
    //    */
    //    for i in stride(from: 0, through: (bitCount - 1), by: 1) {
    //        bits[i] = (value >> i) & 0x01 //byte 右移到第 i 位,再与 0x01 进行位与运算,获得第 i 位的值
    //    }
    //
    //    return bits
    }


    // MARK: - 字节最高位操作

    /// 检查字节最高位是否为1（通常表示负数）
    /// - Parameter byte: 要检查的字节
    /// - Returns: 最高位是否为1
    static func isNegative(byte: UInt8) -> Bool {
        byte & 0x80 != 0 //0x80 是二进制 10000000（直接定位最高位）,& 操作直接检查最高位是否为1
    }

    /// 获得字节指定位的值
    /// - Parameter byte: 要检查的字节
    /// - Parameter bitIndex: 指定位的索引
    /// - Returns: 指定位是的值（0或1）
    static func isNegative(_ byte: UInt8, bitIndex: Int) -> UInt8 {
        /* 假设 byte >> 7
         右移7位后，最高位会移到最低位，其他位都是0,如果最高位是1，其他位都是1
         (byte >> 7) & 0x01 右移7位后位与(&),只获取最后一位，清除其他位,确保在任何整数类型下都只获取最高位
         */
        return (byte >> bitIndex) & 0x01
    }

    /// 切换字节最高位（0变1，1变0）
    /// - Parameter byte: 输入字节
    /// - Returns: 修改后的字节（8位）
    static func toggleHighBit(of byte: UInt8) -> UInt8 {
        return byte ^ 0x80
    }

    /// 获取字节最高位的值
    /// - Parameter byte: 输入字节
    /// - Returns: 最高位的值（0或1）
    static func highBitValue(of byte: UInt8) -> UInt8 {
        return (byte >> 7) & 0x01
    }


    /// 设置字节最高位为1（不管原来是0还是1）
    /// - Parameter byte: 输入字节
    /// - Returns: 修改后的字节（8位）
    static func setHighBit(of byte: UInt8) -> UInt8 {
        return byte | 0x80
    }


    /// 一个无符号字节的最高位清零（设为0），其他位保持不变
    /// - Parameter rawValue: 无符号字节,原始值范围：0-255 (8位)
    /// - Returns: 修改后的完整字节（8位）,有效数值范围变成了0-127
    static func clearHighBit(of byte: UInt8) -> UInt8 {
        return byte & 0x7F
    }

    //MARK: - Usage Example
    static func example(){
        // 位组合/拆分
        let bits = [1, 0, 1, 1]  // 低位到高位
        let byte = 13
        let combined = combineBits(bits)
        let split = splitToBits(byte)
        
        print("\n位组合(低到高):", combined) // 13 (1101)
        print("\n位拆分:", split) //低位到高位, [1, 0, 1, 1, 0, 0, 0, 0]
        print("\n获取最高位的值:",highBitValue(of: UInt8(byte)))  // 0
        
        // 字节操作
        let testByte: UInt8 = 0b1010_1010 //高位到低位
        print("\n位拆分(低到高):", splitToBits(Int(testByte))) //低位到高位, [0, 1, 0, 1, 0, 1, 0, 1]
        print("\n最高位是否为1:",isNegative(byte: testByte)) // true
        for i in 0...7{
            print("-指定第\(i)位的值:",isNegative(testByte, bitIndex: i))
        }
       
        print("\n清除最高位后:",clearHighBit(of: testByte))// 返回42 (高位到低位: 0b0010_1010)
        print("\n切换字节最高位后:",toggleHighBit(of: testByte))// 返回42 (高位到低位: 0b0010_1010)
        
    }
}


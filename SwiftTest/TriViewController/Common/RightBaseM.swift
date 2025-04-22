//
//  RightBaseM.swift
//  SwiftTest
//
//  Created by user on 2024/11/21.
//

import Foundation
import RxRelay

class RightBaseM{
    
    var click = 5
    var outTime = 0
    var buttonClick = 0
    var isDebugcilcked = false

    //MARK: 增加调试事件
    /// - Returns:
    /// 增加调试事件,  在3秒内的多次点击会累加 buttonClick，但只会在3秒后执行一次判断和重置操作。事件执行后返回一个闭包
    func addDebugEvent(uIBlk: @escaping () -> Void){

        isShockOrBeep()

       if self.outTime == 0 {
           self.outTime = Date().secondTime
       }
       
       if 5 > (Date().secondTime - self.outTime) {
           self.buttonClick += 1
//            print("buttonClick: \(self.buttonClick), \(Date().secondTime - self.outTime)")
           if self.buttonClick >= self.click {
            //    if isRunningTestFlightBeta {
                    DispatchQueue.main.async {
                        if !self.isDebugcilcked {
                            self.isDebugcilcked = true
                            
                            uIBlk()
                        }
                    }
//                }
               self.buttonClick = 0
               self.outTime = 0
           }
       }else {
           self.outTime = 0
           self.buttonClick = 0
       }

    }
    
    //MARK: -
    //MARK: 转换为有符号温度值
    /// 将8位无符号整数转换为有符号温度值
    /// - Parameter rawValue: 8位无符号温度值 (0-255)
    /// - Returns: 温度值
    func updateTempStr(_ temperature: UInt8, validRange: ClosedRange<Int8> = -128...127) -> String{
        let temp = convertToSignedTemperature(temperature, validRange: validRange)
        switch temp{
        case .success(let temp):
            return "\(temp)"
        case .failure(let error):
            Log.debug("\(error.description)")
            return "error"
        }
    }
    
    // 定义温度相关的错误类型
    enum TemperatureError: Error {
        case outOfRange(value: Int8, range: ClosedRange<Int8>)
        
        var description: String {
            switch self {
            case .outOfRange(let value, let range):
                return "温度值 \(value)°C 超出有效范围 \(range.lowerBound)°C 到 \(range.upperBound)°C"
            }
        }
    }

    /// 将8位无符号整数转换为有符号温度值
    /// - Parameter rawValue: 8位无符号温度值 (0-255)
    /// - Returns: Result<>
    func convertToSignedTemperature(_ rawValue: UInt8, validRange: ClosedRange<Int8> = -128...127) -> Result<Int8, TemperatureError> {

        // 转换为有符号值
        let signedTemp: Int8 = {
            // 如果最高位是1（负数）
            if CustomBitTool.isNegative(byte: rawValue) {
                // 对于负数，需要进行二进制补码转换
                //取反,通过与 0xff 进行按位与操作(&)只保留最低位，将结果限制在8位无符号整数范围内
                let inverted = ~rawValue & 0xFF
                //加1得到补码,补码表示法表示取反加1获得一个数的相反数的过程,不加1会导致存在两个零（+0和-0）
                let magnitude = (inverted + 1) & 0xFF
                return -Int8(magnitude)
            } else {
                // 对于正数，直接返回
                return Int8(rawValue)
            }
        }()
        // 检查温度是否在有效范围内
        if validRange.contains(signedTemp) {
            return .success(signedTemp)
        } else {
            return .failure(.outOfRange(value: signedTemp, range: validRange))
        }
    }
    /*
        ~temperature 和 ~temperature & 0xff 代表意思不同,
        temperature 的值是 0xfe (254),二进制表示为 0000...1111 1110 (64位)

    < ~temperature >: 返回结果为 -255
    1.由于没有明确指定类型，Swift 默认使用有符号整数类型 (Int),在补码表示法中，最高位为符号位，1表示负数, 所以 0xfe 表示一个负数
    2.反码: 1111...0000 0001
        对 0000...1111 1110 取反，得到 1111...0000 0001, 已知最高位为1,所以 0000 0001 表示为一个负数
    3.补码: 反码+1得: 1111...0000 0010, 在补码表示下是 -127
        对于8位有符号整数，补码表示的范围是 -2^7~(2^7-1) = -128~127, 所以，1000 0000 表示最小的负数，即 -128,当反码+1:
        1000 0000 + 1 = 1000 0001 (129),比最小的负数的绝对值(128)溢出1,所以最小负数回退1, 综上,在补码表示法中, 0000 0001 代表负数 -127(不是-1)
    4.模运算: ~0xfe = -255
        因为计算结果超出表示范围(十六进制范围 0-255),所以计算结果会自动经过模运算（取余运算）将一个数限制在一个特定的范围内.对于8位有符号整数，表示范围是 -128 ~ 127，数学上，-127 模 256 的结果是 -127。
        为了保持符号位的一致性，Swift 将 -127 向负数方向调整，使其成为离 -127 最近的、符号位为1的数，也就是 -255。

    < ~(temperature & 0xff) >: 返回结果为 255
    1.只考虑 temperature 的最低 8 位。由于 temperature 为 0xfe，因此此操作不会改变其值。
    2.在非操作后变为 0x01（二进制为 0000 0001）。
    3.由于没有明确指定类型，Swift 默认使用有符号整数类型，因此在考虑整个整数范围时，0xfe 的按位非结果为 -255。
    4.由于操作限制为 8 位，因此由于二进制补码表示，结果为 255

    */
}

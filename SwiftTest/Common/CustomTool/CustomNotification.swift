//
//  CustomNotification.swift
//  SwiftTest
//
//  Created by user on 2025/5/16.
//
// 自定义系统通知
//✅ 适合改为 struct 的情况：
//无实例属性：当前类仅包含静态方法，无存储属性。
//
//无继承需求：工具类通常不需要继承。
//
//性能优先：值类型在栈上分配，减少内存开销。
//
//⚠️ 需要保持 class 的情况：
//未来可能扩展实例状态：例如添加 var soundEnabled: Bool 属性。
//
//需要继承多态：例如允许子类自定义通知声音。

import Foundation
import UserNotifications
import AudioToolbox

let soundMiddle = SystemSoundID(1519)

//纯静态工具
struct CustomNotification {
    private init() {} // 防止意外实例化
    
    public static func notification(
        title: String,
        body: String,
        sound: SystemSoundID? = soundMiddle // 参数化声音
    ) {
        let random = Int.random(in: 100...600)
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.userInfo = ["userName": "Polylink", "articleId": random]
        
        // 播放声音（可选）
        sound.map { AudioServicesPlaySystemSound($0) }
        
//            var soundID:SystemSoundID = 0
//            //获取声音地址
//            let path = Bundle.main.path(forResource: "beep", ofType: "mp3")
//            //地址转换
//            let baseURL = NSURL(fileURLWithPath: path!)
//            //赋值
//            AudioServicesCreateSystemSoundID(baseURL, &soundID)
//            AudioServicesPlaySystemSound (soundID)
        

        //设置通知触发器
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        //设置请求标识符
        let requestIdentifier = "testNotification\(random)"
        //设置一个通知请求
        let request = UNNotificationRequest(identifier: requestIdentifier,
                                            content: content, trigger: trigger)
        //将通知请求添加到发送中心
        UNUserNotificationCenter.current().add(request) { error in
            error.map { print("Error scheduling notification: \($0)") }
        }
        //删除全部已发送通知
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

}

////实例配置
//// 使用：
////let notifier = CustomNotification()
////notifier.send(title: "Hi", body: "Message")
//final class CustomNotification {
//    let defaultSound: SystemSoundID
//    
//    init(defaultSound: SystemSoundID = soundMiddle) {
//        self.defaultSound = defaultSound
//    }
//    
//    func send(title: String, body: String) {
//        AudioServicesPlaySystemSound(defaultSound)
//        
//        let random = Int.random(in: 100...600)
//        let content = UNMutableNotificationContent()
//        content.title = title
//        content.body = body
//        content.userInfo = ["userName": "Polylink", "articleId": random]
//        
//        //设置通知触发器
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//        //设置请求标识符
//        let requestIdentifier = "testNotification\(random)"
//        //设置一个通知请求
//        let request = UNNotificationRequest(identifier: requestIdentifier,
//                                            content: content, trigger: trigger)
//        //将通知请求添加到发送中心
//        UNUserNotificationCenter.current().add(request) { error in
//            error.map { print("Error scheduling notification: \($0)") }
//        }
//        //删除全部已发送通知
//        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
//    }
//}



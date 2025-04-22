//
//  AppDelegate.swift
//  SwiftTest
//
//  Created by user on 2024/6/3.
//
//主要处理应用级别的生命周期事件，如应用启动、后台运行、应用即将退出等

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //如果是ios13以上,不变; ios13以下,Appdelegate中只是需要增加window的创建，应用程序的UI生命周期依然还是放在SceneDelegate中管理，不可能AppDelegate和SceneDelegate同时来管理。    
        
        if #available(iOS 13.0, *) {
            //跳转到 SceneDelegate 执行
            return true
        }else{
            window = UIWindow(frame: UIScreen.main.bounds)
            guard let window = window  else{
                return true
            }
            window.backgroundColor = .clear
            window.rootViewController = NavigationController(rootViewController: ViewController())
            window.makeKeyAndVisible()
            
            setupConstant(application)
            
            return true
        }
        
    }
    
    private func setupConstant(_ application: UIApplication) {
        kHeight = UIScreen.main.bounds.height
        kWidth = UIScreen.main.bounds.width
        kStatusBarH = application.statusBarFrame.size.height
        kNavigBarH = UINavigationController().navigationBar.frame.size.height
        kTabBarHeight = UITabBarController().tabBar.frame.size.height
        kBottomInsetsSafeArea = window!.safeAreaInsets.bottom
        kTopInsetsSafeArea = window!.safeAreaInsets.top
        kTopSafeArea = kStatusBarH + kNavigBarH
    }
    
    // MARK: - UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "SwiftTest")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}


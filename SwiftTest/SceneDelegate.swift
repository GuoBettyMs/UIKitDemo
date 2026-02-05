//
//  SceneDelegate.swift
//  SwiftTest
//
//  Created by user on 2024/6/3.
//
//处理场景级别的生命周期事件，如场景创建、显示、隐藏等。
//为了使应用支持分屏,可在 iPad 上设置多个 scene


import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?//如果将 window 实例化放在 scene(_:willConnectTo:options:) 方法内，这个局部变量只在这个方法的作用域内可用。当这个方法结束时，window 变量将会被销毁，导致应用无法正确显示界面

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard (scene is UIWindowScene) else { return }
        window = UIWindow(windowScene: scene as! UIWindowScene )
        window?.backgroundColor = .clear
        
        let application = UIApplication.shared
        setupConstant(application)
         

        // 使用 createTabBarController 方法创建 UITabBarController
        let tabBarController = self.createTabBarController()
        // 将 UITabBarController 设置为根视图控制器
        self.window?.rootViewController = tabBarController
        self.window?.makeKeyAndVisible()

    }
    
    // MARK: - TabBar Controller 创建与配置
    func createTabBarController() -> UITabBarController {
        
        let tabBarController = UITabBarController()
        
        // 1. 定义Tab页数据
        struct TabConfig {
            let viewController: UIViewController
            let title: String
            let systemImageName: String
            let tag: Int
        }
        let tabs: [TabConfig] = [
            TabConfig(
                viewController: MailSplitViewController(),
                title: "邮件应用风格的 SplitViewController",
                systemImageName: "clock",
                tag: 0
            ),
            TabConfig(
                viewController: createSecondViewController(),
                title: "列表视图(纯代码版)",
                systemImageName: "clock",
                tag: 0
            ),
            TabConfig(
                viewController: createFirstViewController(),
                title: "列表视图(故事版)",
                systemImageName: "bookmark",
                tag: 1
            )
        ]
        
        // 2. 构建 NavigationController 包装的 VC
        let viewControllers = tabs.map { config in
            if config.viewController is UISplitViewController {
                // SplitVC 不能包在 Nav 里，直接设置 tabBarItem
                if let image = UIImage(systemName: config.systemImageName) {
                    config.viewController.tabBarItem = UITabBarItem(
                        title: config.title,
                        image: image,
                        tag: config.tag
                    )
                }else{
                    config.viewController.tabBarItem = UITabBarItem(
                        title: config.title,
                        image: nil,
                        tag: config.tag
                    )
                }
                return config.viewController // 直接返回 SplitVC
            } else {
                let nav = UINavigationController(rootViewController: config.viewController)
                // 确保 image 存在
                if let image = UIImage(systemName: config.systemImageName) {
                    // 设置 tabBarItem（注意：要设在 nav 上！）
                    nav.tabBarItem = UITabBarItem(
                                title: config.title,
                                image: image,
                                tag: config.tag
                            )
                } else {
                    nav.tabBarItem = UITabBarItem(
                                title: config.title,
                                image: nil,
                                tag: config.tag
                            )
                }

                // 同步导航栏标题
                config.viewController.navigationItem.title = config.title
                configureGlobalNavigationBarAppearance(navi: nav)
                return nav
            }
        }
        tabBarController.viewControllers = viewControllers

        // 3. 全局TabBar样式配置
        configureGlobalTabBarAppearance()

        return tabBarController
    }

    // MARK: - 子控制器创建
    private func createFirstViewController() -> UIViewController {
        
        let storyboardString = "DemoHomepage"//"HomePage"//"DemoHomepage"

        // 更安全地获取初始 VC
        guard let initialVC = UIStoryboard(name: storyboardString, bundle: nil).instantiateInitialViewController() else {
            fatalError("❌ \(storyboardString).storyboard 缺少 Initial View Controller")
        }
        
        // 如果是 UINavigationController，取其 root
        if let nav = initialVC as? UINavigationController {
            guard let root = nav.viewControllers.first else {
                fatalError("❌ UINavigationController 在 \(storyboardString).storyboard 中没有 root view controller")
            }
            return root
        }
        return initialVC
    }

    private func createSecondViewController() -> UIViewController {
        let vc = DemoSelectedListTypeVC()
        return vc
    }
    
    private func setupConstant(_ application: UIApplication) {
        kHeight = UIScreen.main.bounds.height
        kWidth = UIScreen.main.bounds.width
        
        guard let windowScene = (UIApplication.shared.connectedScenes.first as? UIWindowScene) else { return }
        kStatusBarH = windowScene.statusBarManager!.statusBarFrame.height
        kNavigBarH = UINavigationController().navigationBar.frame.size.height
        kTabBarHeight = UITabBarController().tabBar.frame.size.height
        kBottomInsetsSafeArea = window!.safeAreaInsets.bottom
        kTopInsetsSafeArea = window!.safeAreaInsets.top
        kTopSafeArea = kStatusBarH + kNavigBarH
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}


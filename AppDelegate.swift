import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
    var mainViewController: RootViewController?
    // 加载配置文件
    let settingsUtils = SettingsUtils.instance
    // 用于存储启动时的快捷方式
    var pendingQuickAction: UIApplicationShortcutItem?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		window = UIWindow(frame: UIScreen.main.bounds)
        mainViewController = RootViewController()
        guard let mainVC = mainViewController else {
            fatalError("Failed to initialize RootViewController")
        }
        window!.rootViewController = UINavigationController(rootViewController: mainVC)
		window!.makeKeyAndVisible()
        settingsUtils.configQuickActions(application: application)
        
        // 检查是否通过快捷方式启动
        if let shortcutItem = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem {
            pendingQuickAction = shortcutItem // 保存快捷方式
        }

        
		return true
	}
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // 处理启动时的快捷方式
        if let shortcutItem = pendingQuickAction {
            handleQuickActionFromLaunch(shortcutItem)
            pendingQuickAction = nil // 清除状态
        }
    }
    
    func application(
        _ application: UIApplication,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        guard let navController = window?.rootViewController as? UINavigationController else {
            completionHandler(false)
            return
        }

        // 检查是否有模态视图被显示 主要用来处理设置界面打开的时候返回桌面再按快捷方式无效的问题
        if let presentedVC = navController.presentedViewController {
            print("Modal view detected. Dismissing before executing quick action.")
            presentedVC.dismiss(animated: true) { [weak self] in
                self?.handleQuickAction(shortcutItem.type, navController: navController, completionHandler: completionHandler)
            }
        } else {
            // 没有模态视图，直接执行快捷方式逻辑 在主界面 直接执行快捷操作
            handleQuickAction(shortcutItem.type, navController: navController, completionHandler: completionHandler)
        }
    }
    
    private func handleQuickActionFromLaunch(_ shortcutItem: UIApplicationShortcutItem) {
        guard let navController = window?.rootViewController as? UINavigationController else {
            print("Failed to handle quick action: NavigationController not found.")
            return
        }

        handleQuickAction(shortcutItem.type, navController: navController) { success in
            print("Quick action from launch handled: \(success)")
        }
    }

    private func handleQuickAction(_ actionType: String, navController: UINavigationController, completionHandler: @escaping (Bool) -> Void) {
        guard let quickAction = SettingsUtils.QuickActionType(rawValue: actionType) else {
            completionHandler(false)
            return
        }
        
        // 优先处理 CancelTimer 快捷方式 不然就没办法从桌面快捷方式取消计时器了
        if quickAction == .CancelTimer {
            SettingsUtils.instance.setEnableAction(value: false)
            SettingsUtils.instance.configQuickActions(application: UIApplication.shared)
        }

        // 找到 RootViewController 并执行快捷方式
        if let rootVC = navController.topViewController as? RootViewController {
            rootVC.onClickQuickAction?(actionType)
            completionHandler(true)
        } else {
            completionHandler(false)
        }
    }



}

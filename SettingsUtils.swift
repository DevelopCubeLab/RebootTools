import UIKit

class SettingsUtils {
	// 单例实例
    static let instance = SettingsUtils()

    // 私有的 PlistManagerUtils 实例，用于管理特定的 plist 文件
    private let plistManager: PlistManagerUtils
    
    // 操作的枚举
    enum ActionType: Int { // 0=重启 1=注销
        case Reboot = 0
        case Respring = 1
    }
    
    enum QuickActionType: String {
        case Reboot = "com.developLab.RebootTools.Reboot"
        case Respring = "com.developLab.RebootTools.Respring"
        case CancelTimer = "com.developLab.RebootTools.CancelTimer"
    }

    // 私有初始化方法
    private init() {
        // 使用 PlistManagerUtils 管理 "settings.plist"
        NSLog("Reboot Tools----> SettingsUtils initialized")
        self.plistManager = PlistManagerUtils.instance(for: "Settings")
        if !self.plistManager.isPlistExist() {// 检查配置文件是否存在，不存在的话则创建默认配置
            setDefaultSettings()
        }
    }

    private func setDefaultSettings() {

        if self.plistManager.isPlistExist() {
            return
        }

        self.plistManager.setBool(key: "ShowAlertBeforeAction", value: true)
        self.plistManager.setBool(key: "ShowRootText", value: true)
        self.plistManager.setBool(key: "RespringFunction", value: true)
        self.plistManager.setBool(key: "HomeQuickAction", value: true)
        self.plistManager.setBool(key: "EnableAction", value: false)
        self.plistManager.setInt(key: "Time", value: 5)
        self.plistManager.setInt(key: "Action", value: ActionType.Reboot.rawValue)
        self.plistManager.setBool(key: "OpenApplicationAction", value: false)
        NSLog("Reboot Tools----> 写入默认设置")
        //保存
        self.plistManager.apply()

    }

    // 给外界的get和set方法
    func getShowAlertBeforeAction() -> Bool {
        return self.plistManager.getBool(key: "ShowAlertBeforeAction", defaultValue: true)
    }

    func setShowAlertBeforeAction(value: Bool) {
        self.plistManager.setBool(key: "ShowAlertBeforeAction", value: value)
        self.plistManager.apply()
    }
    
    func getShowRootText() -> Bool {
        return self.plistManager.getBool(key: "ShowRootText", defaultValue: true)
    }

    func setShowRootText(value: Bool) {
        self.plistManager.setBool(key: "ShowRootText", value: value)
        self.plistManager.apply()
    }
    
    func getEnableRespringFunction() -> Bool {
        return self.plistManager.getBool(key: "RespringFunction", defaultValue: true)
    }

    func setEnableRespringFunction(value: Bool) {
        self.plistManager.setBool(key: "RespringFunction", value: value)
        self.plistManager.apply()
    }
    
    func getHomeQuickAction() -> Bool {
        return self.plistManager.getBool(key: "HomeQuickAction", defaultValue: true)
    }

    func setHomeQuickAction(value: Bool) {
        self.plistManager.setBool(key: "HomeQuickAction", value: value)
        self.plistManager.apply()
    }
    
    func getEnableAction() -> Bool {
        return self.plistManager.getBool(key: "EnableAction", defaultValue: false)
    }

    func setEnableAction(value: Bool) {
        self.plistManager.setBool(key: "EnableAction", value: value)
        self.plistManager.apply()
    }
    
    func getTime() -> Int {
        var value = self.plistManager.getInt(key: "Time", defaultValue: 5)
        if value < 0 {
            value = 0
        }
        if value > 15 {
            value = 15
        }
        return value
    }

    func setTime(value: Int) {
        var time = value
        if time < 0 {
            time = 0
        }
        if time > 15 {
            time = 15
        }
        self.plistManager.setInt(key: "Time", value: time)
        self.plistManager.apply()
    }
    
    func getAction() -> ActionType {
        let action = self.plistManager.getInt(key: "Action", defaultValue: ActionType.Reboot.rawValue)
        return ActionType(rawValue: action) ?? .Reboot
    }

    func setAction(value: ActionType) {
        self.plistManager.setInt(key: "Action", value: value.rawValue)
        self.plistManager.apply()
    }
    
    func getOpenApplicationAction() -> Bool {
        return self.plistManager.getBool(key: "OpenApplicationAction", defaultValue: true)
    }

    func setOpenApplicationAction(value: Bool) {
        self.plistManager.setBool(key: "OpenApplicationAction", value: value)
        self.plistManager.apply()
    }
    
    // 检查Root权限的方法
    func checkInstallPermission() -> Bool {
        let path = "/var/mobile/Library/Preferences"
        let writeable = access(path, W_OK) == 0
        return writeable
    }

    // 配置桌面快捷方式
    func configQuickActions(application: UIApplication) {
        
        // Action的数组
        var currentShortcuts: [UIApplicationShortcutItem] = []
        if getHomeQuickAction() {
            
            let rebootAction = UIApplicationShortcutItem(
                type: SettingsUtils.QuickActionType.Reboot.rawValue,
                localizedTitle: NSLocalizedString("Reboot_Device_text", comment: ""),
                localizedSubtitle: nil,
                icon: UIApplicationShortcutIcon(systemImageName: "arrow.clockwise"),
                userInfo: nil
            )
            currentShortcuts.append(rebootAction)
            
            if getEnableRespringFunction() {
                let respringAction = UIApplicationShortcutItem(
                    type: SettingsUtils.QuickActionType.Respring.rawValue,
                    localizedTitle: NSLocalizedString("Respring_text", comment: ""),
                    localizedSubtitle: nil,
                    icon: UIApplicationShortcutIcon(systemImageName: "r.square.on.square"),
                    userInfo: nil
                )
                currentShortcuts.append(respringAction)
            }
            
        }
        
        if getEnableAction() && getOpenApplicationAction() {
            let cancelTimerAction = UIApplicationShortcutItem(
                type: SettingsUtils.QuickActionType.CancelTimer.rawValue,
                localizedTitle: NSLocalizedString("Cancel_Timer_text", comment: ""),
                localizedSubtitle: nil,
                icon: UIApplicationShortcutIcon(systemImageName: "xmark.circle"),
                userInfo: nil
            )
            currentShortcuts.append(cancelTimerAction)
        }
        
        UIApplication.shared.shortcutItems = currentShortcuts
        
    }

}

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	let versionCode = "1.2"
    var onSettingsChanged: (() -> Void)? // 一个回调
    
    var tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let settingsUtils = SettingsUtils.instance
    private var hasRootPermission = false //用于存储是否是有Root权限

    // 每个分组的小标题
    let sectionTitles = [
        NSLocalizedString("General_text", comment: ""),
        NSLocalizedString("Enable_Function_text", comment: ""),
        NSLocalizedString("Timer_text", comment: ""),
        NSLocalizedString("About_text", comment: "")
    ]

    // 存储设置项
    let sections = [
        [NSLocalizedString("Show_Alert_Before_Starting_text", comment: ""), NSLocalizedString("Display_Root_Permission_text", comment: "")],
        [NSLocalizedString("Respring_text", comment: ""), NSLocalizedString("Home_Screen_Quick_Actions_text", comment: "")],
        [NSLocalizedString("Enable_text", comment: ""), NSLocalizedString("Time_text", comment: ""), NSLocalizedString("When_Open_Application_To_Action_text", comment: ""), NSLocalizedString("Action_text", comment: "")],
//        [String(localized: "Version_text"),"Github"]
        [NSLocalizedString("Version_text", comment: ""),"GitHub", NSLocalizedString("Special_Thanks_text", comment: "")]
    ]
    
    enum SwitchTag: Int {
        case ShowAlertBeforeAction = 0
        case ShowRootText = 1
        case RespringFunction = 2
        case HomeQuickAction = 3
        case EnableAction = 4
        case OpenApplicationAction = 5
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // 设置视图标题
        self.title = NSLocalizedString("Settings_text", comment: "")
        // 检查Root权限
        hasRootPermission = settingsUtils.checkInstallPermission()

		// iOS 15 之后的版本使用新的UITableView样式
		if #available(iOS 15.0, *) {
			tableView = UITableView(frame: .zero, style: .insetGrouped)
		} else {
			tableView = UITableView(frame: .zero, style: .grouped)
		}

        // 设置表格视图的代理和数据源
        tableView.delegate = self
        tableView.dataSource = self

        // 注册表格单元格
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        // 将表格视图添加到主视图
        view.addSubview(tableView)

        // 设置表格视图的布局
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        // 2. 重置 Cell 状态 解决经典列表复用bug
        cell.textLabel?.text = nil
        cell.detailTextLabel?.text = nil
        cell.textLabel?.textColor = .label
        cell.accessoryView = nil
        cell.accessoryType = .none
        cell.selectionStyle = .none
        cell.isUserInteractionEnabled = true
        
        // 设置单元格的文本
        cell.textLabel?.text = sections[indexPath.section][indexPath.row]
        cell.textLabel?.numberOfLines = 0 // 允许文本过长时换行
        cell.selectionStyle = .none // 禁用选中效果

        switch indexPath.section {
        	case 0, 1:
				// 创建 UISwitch 控件
                let switchView = UISwitch(frame: .zero)
                switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
                switchView.isEnabled = true
                // 根据不同的设置项初始化开关状态
                if indexPath.section == 0 {
                    if indexPath.row == 0 {
                        switchView.tag = SwitchTag.ShowAlertBeforeAction.rawValue
                        switchView.isOn = settingsUtils.getShowAlertBeforeAction()
                    } else if indexPath.row == 1 {
                        switchView.tag = SwitchTag.ShowRootText.rawValue
                        if !hasRootPermission { // 没有Root权限的用户，不允许关闭无权限的提示
                            settingsUtils.setShowRootText(value: true) // 强制显示 防止某些用户(可能只有我会这样测试)从有Root权限变成没有权限
                            cell.textLabel?.textColor = .lightGray //文本变成灰色
                            switchView.isEnabled = false // 禁用开关
                            cell.isUserInteractionEnabled = false
                        }
                        switchView.isOn = settingsUtils.getShowRootText()
                    }
                } else if indexPath.section == 1 {
                    if indexPath.row == 0 {
                        switchView.tag = SwitchTag.RespringFunction.rawValue
                        switchView.isOn = settingsUtils.getEnableRespringFunction()
                    } else if indexPath.row == 1 {
                        switchView.tag = SwitchTag.HomeQuickAction.rawValue
                        if !hasRootPermission { // 检查用户是否有Root权限
                            settingsUtils.setHomeQuickAction(value: false) // 无Root 强制关闭桌面快捷方式
                            settingsUtils.configQuickActions(application: UIApplication.shared) // 强制移除掉快捷方式 防止某些用户(可能只有我会这样测试)从有Root权限变成没有权限
                            cell.textLabel?.textColor = .lightGray //文本变成灰色
                            switchView.isEnabled = false // 禁用开关
                            cell.isUserInteractionEnabled = false
                        }
                        if settingsUtils.getEnableAction() && settingsUtils.getOpenApplicationAction() { // 检查是否与其他功能冲突
                            cell.textLabel?.textColor = .lightGray //文本变成灰色
                            switchView.isEnabled = false //Switch开关禁用
                            cell.isUserInteractionEnabled = false
                        } else {
                            cell.textLabel?.textColor = .label //文本正常
                            switchView.isEnabled = true
                            cell.isUserInteractionEnabled = true
                        }
                        
                        switchView.isOn = settingsUtils.getHomeQuickAction()

                    }
                }

                cell.accessoryView = switchView
            case 2: // 倒计时器的设置
            	if indexPath.row == 0 { // Enable
					let switchView = UISwitch(frame: .zero)
                    switchView.tag = SwitchTag.EnableAction.rawValue
					switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
					switchView.isOn = settingsUtils.getEnableAction()
					cell.accessoryView = switchView
				} else if indexPath.row == 1 { // 设置时间
					// 添加 UIStepper
					cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
					cell.textLabel?.text = sections[indexPath.section][indexPath.row]
					cell.detailTextLabel?.text = String.localizedStringWithFormat(NSLocalizedString("Seconds_text", comment: "Time in seconds"), settingsUtils.getTime()) // 默认值
                    let stepper = UIStepper()
                    stepper.minimumValue = 0 // 最小值
                    stepper.maximumValue = 15 // 最大值
                    stepper.value = Double(settingsUtils.getTime()) // 初始值
                    stepper.stepValue = 1 // 每次加减步长
                    // 添加事件监听
                    stepper.addTarget(self, action: #selector(self.timerValueChanged(_:)), for: .valueChanged)

                    // 设置 UIStepper 为 cell 的 accessoryView
                    cell.accessoryView = stepper
                    cell.selectionStyle = .none //没有点击cell的效果
				} else if indexPath.row == 2 {
                    let switchView = UISwitch(frame: .zero)
                    switchView.tag = SwitchTag.OpenApplicationAction.rawValue
                    switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
                    if !hasRootPermission {
                        settingsUtils.setOpenApplicationAction(value: false) // 无Root权限 禁止打开app就执行操作
                        cell.textLabel?.textColor = .lightGray //文本变成灰色
                        switchView.isEnabled = false // 禁用开关
                        cell.isUserInteractionEnabled = false
                    } else {
                        switchView.isOn = settingsUtils.getOpenApplicationAction()
                    }
                    if !settingsUtils.getEnableAction() { // 判断是否打开了 启用 开关
                        cell.textLabel?.textColor = .lightGray //文本变成灰色
                        switchView.isEnabled = false // 禁用开关
                        cell.isUserInteractionEnabled = false
                    } else {
                        cell.textLabel?.textColor = .label //文本变成灰色
                        switchView.isEnabled = true // 禁用开关
                        cell.isUserInteractionEnabled = true
                    }

                    cell.accessoryView = switchView
                } else if indexPath.row == 3 {
                    cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
                    if settingsUtils.getEnableRespringFunction() { // 判断是否开启了注销功能
                        cell.accessoryType = .disclosureIndicator // 添加右侧箭头
                        cell.detailTextLabel?.textColor = .secondaryLabel // 默认浅灰色
                    } else {
                        cell.selectionStyle = .none
                        cell.accessoryType = .none
                        cell.textLabel?.textColor = .lightGray //文本变成灰色
                    }
                    if !settingsUtils.getEnableAction() { // 判断是否打开了 启用 开关
                        cell.textLabel?.textColor = .lightGray //文本变成灰色
                        cell.isUserInteractionEnabled = false
                        cell.detailTextLabel?.textColor = .tertiaryLabel // 更浅的灰色
                    } else {
                        cell.textLabel?.textColor = .label //文本变成灰色
                        cell.isUserInteractionEnabled = true
                    }
                    cell.textLabel?.text = sections[indexPath.section][indexPath.row]
//                    cell.isUserInteractionEnabled = settingsUtils.getOpenApplicationAction()
                    // 设置当前选择的item
                    let action = settingsUtils.getAction()
                    switch action {
                    case .Reboot:
                        cell.detailTextLabel?.text = NSLocalizedString("Reboot_Device_text", comment: "")
                    case .Respring:
                        cell.detailTextLabel?.text = NSLocalizedString("Respring_text", comment: "")
                    }
                }
            case 3:
            	if indexPath.row == 0 {
            	    cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
            	    cell.textLabel?.text = sections[indexPath.section][indexPath.row]
					let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? NSLocalizedString("Unknown_text", comment: "")
					if version != versionCode { // 判断版本号是不是有人篡改
						cell.detailTextLabel?.text = versionCode
					} else {
						cell.detailTextLabel?.text = version
					}
                    cell.selectionStyle = .none
                    cell.accessoryType = .none
				} else if indexPath.row == 1 || indexPath.row == 2 {
					cell.accessoryType = .disclosureIndicator
					cell.selectionStyle = .default // 启用选中效果
				}

            default: break

        }

        return cell
    }
    
    

    // MARK: - UISwitch 事件处理
    @objc func switchChanged(_ sender: UISwitch) {
        
        guard let switchTag = SwitchTag(rawValue: sender.tag) else {
            return
        }
        
        switch switchTag {
        case SwitchTag.ShowAlertBeforeAction:
            settingsUtils.setShowAlertBeforeAction(value: sender.isOn)
            checkAutomaticaEnableAlert()
        case SwitchTag.ShowRootText:
            settingsUtils.setShowRootText(value: sender.isOn)
        case SwitchTag.RespringFunction:
            settingsUtils.setEnableRespringFunction(value: sender.isOn)
            // 刷新桌面快捷图标
            settingsUtils.configQuickActions(application: UIApplication.shared)
            // 判断执行的操作是否是Respring
            if !settingsUtils.getEnableRespringFunction() && settingsUtils.getAction() == .Respring {
                self.settingsUtils.setAction(value: SettingsUtils.ActionType.Reboot)// 修改默认设置
            }
            // 刷新执行的操作的item
            tableView.reloadRows(at: [IndexPath(row: 3, section: 2)], with: .none)
        case SwitchTag.HomeQuickAction:
            settingsUtils.setHomeQuickAction(value: sender.isOn)
            settingsUtils.configQuickActions(application: UIApplication.shared)
        case SwitchTag.EnableAction:
            settingsUtils.setEnableAction(value: sender.isOn)
            settingsUtils.configQuickActions(application: UIApplication.shared)
            checkFunctionConflict()
            checkAutomaticaEnableAlert()
            // 刷新子项目
            tableView.reloadRows(at: [IndexPath(row: 2, section: 2)], with: .none)
            tableView.reloadRows(at: [IndexPath(row: 3, section: 2)], with: .none)
        case SwitchTag.OpenApplicationAction:
            settingsUtils.setOpenApplicationAction(value: sender.isOn)
            settingsUtils.configQuickActions(application: UIApplication.shared)
            checkFunctionConflict()
            checkAutomaticaEnableAlert()
        }
    }

    @objc func timerValueChanged(_ sender: UIStepper) {
        // 找到 UIStepper 所在的单元格
        if let cell = sender.superview as? UITableViewCell {
            // 更新 detailTextLabel 显示当前值
            settingsUtils.setTime(value: Int(sender.value))
            checkAutomaticaEnableAlert() //检查是否是全自动化
            cell.detailTextLabel?.text = String.localizedStringWithFormat(NSLocalizedString("Seconds_text", comment: ""), Int(sender.value))
        }
    }

    // MARK: - UITableViewDelegate 点击item的事件
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 && indexPath.row == 3 {
            if settingsUtils.getEnableRespringFunction() && settingsUtils.getEnableAction() {
                let actionSheet = UIAlertController(title: NSLocalizedString("Choose_An_Action_text", comment: ""), message: nil, preferredStyle: .actionSheet)
                let options = [NSLocalizedString("Reboot_Device_text", comment: ""), NSLocalizedString("Respring_text", comment: "")]
                
                // 添加选项
                for (index, option) in options.enumerated() {
                    let action = UIAlertAction(title: option, style: .default) { _ in
                        if index == 0 {
                            self.settingsUtils.setAction(value: SettingsUtils.ActionType.Reboot)
                        } else {
                            self.settingsUtils.setAction(value: SettingsUtils.ActionType.Respring)
                        }
                        tableView.reloadRows(at: [indexPath], with: .none) // 更新单元格显示
                    }
                    actionSheet.addAction(action)
                }

                // 添加取消按钮
                let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel_text", comment: ""), style: .cancel) { _ in
                    tableView.reloadRows(at: [indexPath], with: .none) // 取消时刷新单元格 取消动画
                }
                actionSheet.addAction(cancelAction)

                // 显示弹窗
                if let popover = actionSheet.popoverPresentationController {
                    // 处理 iPad 的情况
                    popover.sourceView = tableView
                    popover.sourceRect = tableView.rectForRow(at: indexPath)
                    popover.permittedArrowDirections = .any
                }

                present(actionSheet, animated: true, completion: nil)
            }
            
		} else if indexPath.section == 3 && indexPath.row == 1 {
    		tableView.deselectRow(at: indexPath, animated: true)
    	    if let url = URL(string: "https://github.com/DevelopCubeLab/RebootTools") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
    	} else if indexPath.section == 3 && indexPath.row == 2 {
    	    tableView.deselectRow(at: indexPath, animated: true)
            if let url = URL(string: "https://m.xiaobovlog.cn/") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
    	}
    }

    // MARK: - 设置每个分组的标题
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        // 可以为分组设置尾部文本，如果没有尾部可以返回 nil
        if section == 2 {
            return String.localizedStringWithFormat(NSLocalizedString("Automatically_Action_hint", comment: ""), NSLocalizedString("When_Open_Application_To_Action_text", comment: ""),NSLocalizedString("Home_Screen_Quick_Actions_text", comment: ""))
        }
        return nil
    }
    
    // 界面关闭的时候让主界面知道设置改变了 然后更新一下对应的功能是否开启
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onSettingsChanged?()
    }
    
    private func checkFunctionConflict() {
        if settingsUtils.getEnableAction() && settingsUtils.getOpenApplicationAction() {
            settingsUtils.setHomeQuickAction(value: false)
            settingsUtils.configQuickActions(application: UIApplication.shared)
        }
        tableView.reloadRows(at: [IndexPath(row: 1, section: 1)], with: .none)
    }
    
    private func checkAutomaticaEnableAlert() {
        if !settingsUtils.getShowAlertBeforeAction() && settingsUtils.getEnableAction() &&
            settingsUtils.getOpenApplicationAction() && settingsUtils.getTime() == 0 {
            // 显示一个弹窗 提示用户当前操作的取消方法
            let alertController = UIAlertController(title: nil, message: String.localizedStringWithFormat(NSLocalizedString("Automatic_Timer_Alert_text", comment: ""), NSLocalizedString("Home_Screen_Quick_Actions_text", comment: ""),NSLocalizedString("Cancel_Timer_text", comment: "")), preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: NSLocalizedString("Dismiss_text", comment: ""), style: .cancel) { _ in
                //
            }
            // 添加按钮到 UIAlertController
            alertController.addAction(dismissAction)
            // 显示弹窗
            self.present(alertController, animated: true, completion: nil)
            settingsUtils.configQuickActions(application: UIApplication.shared)
        }
    }
}

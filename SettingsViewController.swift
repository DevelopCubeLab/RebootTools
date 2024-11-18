import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var onSettingsChanged: (() -> Void)? // 一个回调
    
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let settingsUtils = SettingsUtils.instance

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
        // 设置单元格的文本
        cell.textLabel?.text = sections[indexPath.section][indexPath.row]
        cell.textLabel?.numberOfLines = 0 // 允许文本过长时换行
        cell.selectionStyle = .none // 禁用选中效果

        switch indexPath.section {
        	case 0, 1:
				// 创建 UISwitch 控件
                let switchView = UISwitch(frame: .zero)
                switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
                // 根据不同的设置项初始化开关状态
                if indexPath.section == 0 {
                    if indexPath.row == 0 {
                        switchView.tag = SwitchTag.ShowAlertBeforeAction.rawValue
                        switchView.isOn = settingsUtils.getShowAlertBeforeAction()
                    } else if indexPath.row == 1 {
                        switchView.tag = SwitchTag.ShowRootText.rawValue
                        switchView.isOn = settingsUtils.getShowRootText()
                    }
                } else if indexPath.section == 1 {
                    if indexPath.row == 0 {
                        switchView.tag = SwitchTag.RespringFunction.rawValue
                        switchView.isOn = settingsUtils.getEnableRespringFunction()
                    } else if indexPath.row == 1 {
                        switchView.tag = SwitchTag.HomeQuickAction.rawValue
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
				} else if indexPath.row == 2 {
                    let switchView = UISwitch(frame: .zero)
                    switchView.tag = SwitchTag.OpenApplicationAction.rawValue
                    switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
                    switchView.isOn = settingsUtils.getOpenApplicationAction()
                    cell.accessoryView = switchView
                } else if indexPath.row == 3 {
                    cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
                    if settingsUtils.getEnableRespringFunction() { // 判断是否开启了注销功能
                        cell.accessoryType = .disclosureIndicator // 添加右侧箭头
                    } else {
                        cell.selectionStyle = .none
                        cell.accessoryType = .none
                    }
                    cell.textLabel?.text = sections[indexPath.section][indexPath.row]
                    cell.isUserInteractionEnabled = settingsUtils.getOpenApplicationAction()
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
                    cell.detailTextLabel?.text = version
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
        case SwitchTag.OpenApplicationAction:
            settingsUtils.setOpenApplicationAction(value: sender.isOn)
            settingsUtils.configQuickActions(application: UIApplication.shared)
        }
    }

    @objc func timerValueChanged(_ sender: UIStepper) {
        // 找到 UIStepper 所在的单元格
        if let cell = sender.superview as? UITableViewCell {
            // 更新 detailTextLabel 显示当前值
            settingsUtils.setTime(value: Int(sender.value))
            cell.detailTextLabel?.text = String.localizedStringWithFormat(NSLocalizedString("Seconds_text", comment: ""), Int(sender.value))
        }
    }

    // MARK: - UITableViewDelegate 点击item的事件
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 && indexPath.row == 3 {
            if settingsUtils.getEnableRespringFunction() {
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
                let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel_text", comment: ""), style: .cancel, handler: nil)
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
        return nil  // 可以为分组设置尾部文本，如果没有尾部可以返回 nil
    }
    
    // 界面关闭的时候让主界面知道设置改变了
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onSettingsChanged?()
    }
}

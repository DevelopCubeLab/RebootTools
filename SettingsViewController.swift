import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let tableView = UITableView(frame: .zero, style: .insetGrouped)

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
        [NSLocalizedString("Enable_text", comment: ""), NSLocalizedString("Time_text", comment: ""), NSLocalizedString("Action_text", comment: "")],
//        [String(localized: "Version_text"),"Github"]
        [NSLocalizedString("Version_text", comment: ""),"Github"]
    ]

    // UserDefaults 键
    let warningKey = "showWarningBeforeAction"
    let hidePermissionsKey = "hidePermissionReminder"

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

        switch indexPath.section {
        	case 0, 1:
				// 创建 UISwitch 控件
                let switchView = UISwitch(frame: .zero)
                switchView.tag = indexPath.section
                switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)

                // 根据不同的设置项初始化开关状态
                if indexPath.section == 0 {
                    switchView.isOn = UserDefaults.standard.bool(forKey: self.warningKey)
                } else if indexPath.section == 1 {
                    if indexPath.row == 0 {
                        switchView.isOn = UserDefaults.standard.bool(forKey: self.hidePermissionsKey)
                    }
                }

                cell.accessoryView = switchView
            case 2: // 倒计时器的设置
            	if indexPath.row == 0 { // Enable
					let switchView = UISwitch(frame: .zero)
					switchView.tag = indexPath.section
					switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
					switchView.isOn = UserDefaults.standard.bool(forKey: "enableTimer")
					cell.accessoryView = switchView
				} else if indexPath.row == 1 { // 设置时间
					// 添加 UIStepper
					cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
					cell.textLabel?.text = sections[indexPath.section][indexPath.row]
					cell.detailTextLabel?.text = "1秒" // 默认值
                    let stepper = UIStepper()
                    stepper.minimumValue = 0 // 最小值
                    stepper.maximumValue = 15 // 最大值
                    stepper.value = 1 // 初始值
                    stepper.stepValue = 1 // 每次加减步长

                    // 添加事件监听
                    stepper.addTarget(self, action: #selector(self.stepperValueChanged(_:)), for: .valueChanged)

                    // 设置 UIStepper 为 cell 的 accessoryView
                    cell.accessoryView = stepper
				} else if indexPath.row == 2 {
					//


				}
            case 3:
            	if indexPath.row == 0 {
            	    cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
            	    cell.textLabel?.text = sections[indexPath.section][indexPath.row]
					let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? NSLocalizedString("Unknown_text", comment: "")
                    cell.detailTextLabel?.text = version
                    cell.selectionStyle = .none
                    cell.accessoryType = .none
				}


            default: break

        }

        return cell
    }

    // MARK: - UISwitch 事件处理

    @objc func switchChanged(_ sender: UISwitch) {
        if sender.tag == 0 {
            // 第一个设置项：执行操作前发出警告
            UserDefaults.standard.set(sender.isOn, forKey: warningKey)
        } else if sender.tag == 1 {
            // 第二个设置项：隐藏权限提醒
            UserDefaults.standard.set(sender.isOn, forKey: hidePermissionsKey)
        }
        UserDefaults.standard.synchronize()  // 同步存储
    }

    @objc func stepperValueChanged(_ sender: UIStepper) {
        // 找到 UIStepper 所在的单元格
        if let cell = sender.superview as? UITableViewCell {
            // 更新 detailTextLabel 显示当前值
            cell.detailTextLabel?.text = "\(Int(sender.value))"
        }
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - 设置每个分组的标题
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil  // 可以为分组设置尾部文本，如果没有尾部可以返回 nil
    }
}

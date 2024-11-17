import UIKit

class RootViewController: UIViewController {

	private let settingsUtils = SettingsUtils.instance
    private let checkPermissionLabel = UILabel()
    private let respringButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("CFBundleDisplayName", comment: "")

        // 设置ViewController的背景颜色
        self.view.backgroundColor = UIColor.systemBackground

        // icon
        let iconImageView = UIImageView()

        if #available(iOS 15.0, *) {
            iconImageView.image = UIImage(systemName: "power.circle.fill")
            iconImageView.tintColor = UIColor(hex: "#32A5E7")
        } else {
            let appIcon = UIImage(named: "AppIcon")
            iconImageView.image = appIcon
        }
        // 无障碍标签
        iconImageView.isAccessibilityElement = true // 声明这是一个可访问性元素
        iconImageView.accessibilityLabel = NSLocalizedString("CFBundleDisplayName", comment: "")

        // 禁用自动调整大小
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        // 设置图片适应方式
        iconImageView.contentMode = .scaleAspectFit

        // 检查权限
        checkPermissionLabel.translatesAutoresizingMaskIntoConstraints = false
        checkPermissionLabel.textAlignment = .center  // 设置文本居中
        checkPermissionLabel.isHidden = !settingsUtils.getShowRootText()

        let enable = self.checkInstallPermission()

        if(enable) {
            checkPermissionLabel.text = NSLocalizedString("Install_With_TrollStore_text", comment: "")
            checkPermissionLabel.textColor = UIColor.green
        } else {
            checkPermissionLabel.text = NSLocalizedString("Need_Install_With_TrollStore_text", comment: "")
            checkPermissionLabel.textColor = UIColor.red
        }

        // 重启按钮
        let rebootButton = UIButton(type: .system)
        if #available(iOS 15.0, *) {
			rebootButton.configuration = .filled()
			rebootButton.setTitle(NSLocalizedString("Reboot_Device_text", comment: ""), for: .normal)
		} else {
			// iOS 14 及以下版本 没这效果只能硬凑了
			rebootButton.backgroundColor = UIColor.systemBlue
            rebootButton.layer.cornerRadius = 8
            rebootButton.clipsToBounds = true
            rebootButton.setTitle(NSLocalizedString("Reboot_Device_text", comment: ""), for: .normal)
            rebootButton.setTitleColor(.white, for: .normal)
		}

        rebootButton.translatesAutoresizingMaskIntoConstraints = false
        // 添加点击事件
        rebootButton.addTarget(self, action: #selector(onClickRebootButton), for: .touchUpInside)
        rebootButton.isEnabled = enable // 无权限的时候不允许点击

        // Respring
        respringButton.setTitle(NSLocalizedString("Respring_text", comment: ""), for: .normal)
        respringButton.translatesAutoresizingMaskIntoConstraints = false
        respringButton.addTarget(self, action: #selector(onClickRespringButton), for: .touchUpInside)
        respringButton.isEnabled = enable // 无权限的时候不允许点击
        respringButton.isHidden = !settingsUtils.getEnableRespringFunction()
        
        // 添加设置项
        let settingsButton = UIButton(type: .system)
        settingsButton.setTitle(NSLocalizedString("Settings_text", comment: ""), for: .normal)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.addTarget(self, action: #selector(onClickSettingsButton), for: .touchUpInside)
        // 设置图标
        let settingsButtonIcon = UIImage(systemName: "gearshape")
        settingsButton.setImage(settingsButtonIcon, for: .normal)
        // 调整图标和文本之间的间距
        settingsButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)

		// 向View中添加控件
        self.view.addSubview(iconImageView)
        self.view.addSubview(checkPermissionLabel)
        self.view.addSubview(rebootButton)
        self.view.addSubview(respringButton)
        self.view.addSubview(settingsButton)

        // AutoLayout
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 100),  // 设置宽度
            iconImageView.heightAnchor.constraint(equalToConstant: 100), // 设置高度
            iconImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor), // 水平居中
            iconImageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100),

            checkPermissionLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor), // 水平居中
            checkPermissionLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 30), // 在 iconImageView 底部，间隔 20 点
            checkPermissionLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20), // 左侧边距
            checkPermissionLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20), // 右侧边距

            rebootButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor), // 水平居中
            rebootButton.heightAnchor.constraint(equalToConstant: 50),
            rebootButton.topAnchor.constraint(equalTo: checkPermissionLabel.bottomAnchor, constant: 30),
            rebootButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50), // 左侧边距
            rebootButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -50), // 右侧边距

            respringButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor), // 水平居中
            respringButton.heightAnchor.constraint(equalToConstant: 50),
            respringButton.topAnchor.constraint(equalTo: rebootButton.bottomAnchor, constant: 20),
            respringButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50), // 左侧边距
            respringButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -50), // 右侧边距

			settingsButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor), // 水平居中
            settingsButton.heightAnchor.constraint(equalToConstant: 50),
            settingsButton.topAnchor.constraint(equalTo: respringButton.bottomAnchor, constant: 30),
            settingsButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50), // 左侧边距
            settingsButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -50) // 右侧边距
        ])

    }

    func checkInstallPermission() -> Bool {
        let path = "/var/mobile/Library/Preferences"
        let writeable = access(path, W_OK) == 0
        return writeable
    }

    @objc func onClickRebootButton() {
        
        if settingsUtils.getShowAlertBeforeAction() {
            // 创建 UIAlertController
            let alertController = UIAlertController(title: nil, message: String.localizedStringWithFormat(NSLocalizedString("Action_Alert", comment: ""), NSLocalizedString("Reboot_Device_text", comment: "")), preferredStyle: .alert)
            
            // 创建 "确定" 按钮（红色）
            let confirmAction = UIAlertAction(title: NSLocalizedString("Confirm_text", comment: ""), style: .destructive) { _ in
                let deviceController = DeviceController()
                deviceController.rebootDevice()
            }
            
            // 创建 "取消" 按钮
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel_text", comment: ""), style: .cancel) { _ in
                //
            }
            
            // 添加按钮到 UIAlertController
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            
            // 显示弹窗
            self.present(alertController, animated: true, completion: nil)
        } else {
            let deviceController = DeviceController()
            deviceController.rebootDevice()
        }
        
    }
    
    @objc func onClickRespringButton() {
        
        if settingsUtils.getShowAlertBeforeAction() {
            // 创建 UIAlertController
            let alertController = UIAlertController(title: nil, message: String.localizedStringWithFormat(NSLocalizedString("Action_Alert", comment: ""), NSLocalizedString("Respring_text", comment: "")), preferredStyle: .alert)
            
            // 创建 "确定" 按钮（红色）
            let confirmAction = UIAlertAction(title: NSLocalizedString("Confirm_text", comment: ""), style: .destructive) { _ in
                let deviceController = DeviceController()
                deviceController.respring()
            }
            
            // 创建 "取消" 按钮
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel_text", comment: ""), style: .cancel) { _ in
                //
            }
            
            // 添加按钮到 UIAlertController
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            
            // 显示弹窗
            self.present(alertController, animated: true, completion: nil)
        } else {
            let deviceController = DeviceController()
            deviceController.respring()
        }
        
    }

    @objc func onClickSettingsButton() {
		let settingsViewController = SettingsViewController()
        // 注册监听器
        settingsViewController.onSettingsChanged = { [weak self] in
            self?.updateUI()
        }
        // 嵌入到导航控制器
        let navController = UINavigationController(rootViewController: settingsViewController)
        // 设置导航栏完成按钮
        let doneButton = UIBarButtonItem(title: NSLocalizedString("Done_text", comment: ""), style: .done, target: self, action: #selector(onClickDoneButton))
        settingsViewController.navigationItem.rightBarButtonItem = doneButton
        // 设置模态视图的显示样式
        navController.modalPresentationStyle = .pageSheet
        navController.modalTransitionStyle = .coverVertical

        // 显示带导航栏的 SettingsViewController
        present(navController, animated: true, completion: nil)

	}

	@objc func onClickDoneButton() {
        // 关闭模态视图
        dismiss(animated: true, completion: nil)
    }
    
    private func updateUI() { // 因为设置更改 更新界面
        checkPermissionLabel.isHidden = !settingsUtils.getShowRootText()
        respringButton.isHidden = !settingsUtils.getEnableRespringFunction()
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

import UIKit

class RootViewController: UIViewController {

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

        // 禁用自动调整大小
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        // 设置图片适应方式
        iconImageView.contentMode = .scaleAspectFit

        // 检查权限
        let checkPermissionLabel = UILabel()
        checkPermissionLabel.translatesAutoresizingMaskIntoConstraints = false
        checkPermissionLabel.textAlignment = .center  // 设置文本居中

        var enable = self.checkInstallPermission()

        if(enable) {
            checkPermissionLabel.text = NSLocalizedString("Install_With_TrollStore_text", comment: "")
            checkPermissionLabel.textColor = UIColor.green
        } else {
            checkPermissionLabel.text = NSLocalizedString("Need_Install_With_TrollStore_text", comment: "")
            checkPermissionLabel.textColor = UIColor.red
        }

        // 重启按钮
        let rebootButton = UIButton()
        rebootButton.setTitle(NSLocalizedString("Reboot_Device_text", comment: ""), for: .normal)
        rebootButton.translatesAutoresizingMaskIntoConstraints = false

        // 添加设置项
        let showAlertSwitch = UISwitch()
        showAlertSwitch.translatesAutoresizingMaskIntoConstraints = false

        let showAlertLabel = UILabel()
        showAlertLabel.text = NSLocalizedString("Show_Alert_Before_Starting_text", comment: "")
        showAlertLabel.textColor = UIColor.label
        showAlertLabel.translatesAutoresizingMaskIntoConstraints = false

		// 添加子视图
        let showAlertSubView = UIView()
        showAlertSubView.translatesAutoresizingMaskIntoConstraints = false
        // 将开关和标签添加到子视图中
        showAlertSubView.addSubview(showAlertLabel)
        showAlertSubView.addSubview(showAlertSwitch)

		// 向View中添加控件
        self.view.addSubview(iconImageView)
        self.view.addSubview(checkPermissionLabel)
        self.view.addSubview(rebootButton)
        self.view.addSubview(showAlertSubView)


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
            rebootButton.topAnchor.constraint(equalTo: checkPermissionLabel.bottomAnchor, constant: 30),
            rebootButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20), // 左侧边距
            rebootButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20), // 右侧边距

			showAlertSubView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            showAlertSubView.topAnchor.constraint(equalTo: rebootButton.bottomAnchor, constant: 30),
			// 动态设置容器的宽度和高度
            showAlertSubView.leadingAnchor.constraint(equalTo: showAlertLabel.leadingAnchor),
            showAlertSubView.trailingAnchor.constraint(equalTo: showAlertSwitch.trailingAnchor),
            showAlertSubView.heightAnchor.constraint(equalTo: showAlertSwitch.heightAnchor),
            // 标签和开关在容器中水平排列
            showAlertLabel.leadingAnchor.constraint(equalTo: showAlertSubView.leadingAnchor),
            showAlertLabel.centerYAnchor.constraint(equalTo: showAlertSubView.centerYAnchor),

            showAlertSwitch.leadingAnchor.constraint(equalTo: showAlertLabel.trailingAnchor, constant: 10),
            showAlertSwitch.centerYAnchor.constraint(equalTo: showAlertSubView.centerYAnchor),
            showAlertSwitch.trailingAnchor.constraint(equalTo: showAlertSubView.trailingAnchor)
        ])
    }

    func checkInstallPermission() -> Bool {
        let path = "/var/mobile/Library/Preferences"
        let writeable = access(path, W_OK) == 0
        return writeable
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

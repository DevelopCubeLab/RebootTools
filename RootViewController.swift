import UIKit

class RootViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "RootViewController"
        // 设置背景颜色以区分
        self.view.backgroundColor = UIColor.systemBackground
        
        let appIcon = UIImage(named: "AppIcon")
//        let imageView = UIImageView(image: appIcon)
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "power.circle.fill")
        imageView.tintColor = UIColor(hex: "#32a5e7")
        // 禁用自动调整大小
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // 设置图片适应方式
        imageView.contentMode = .scaleAspectFit
        
        self.view.addSubview(imageView)
        
        // AutoLaout
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 100),  // 设置宽度
            imageView.heightAnchor.constraint(equalToConstant: 100), // 设置高度
            imageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor), // 水平居中
            imageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100)
            
        ])
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

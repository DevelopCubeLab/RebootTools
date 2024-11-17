
class SettingsUtils {
	static let shared = SettingsUtils()

	private init() {}

	var isDarkMode: Bool {
		get {
			return UserDefaults.standard.bool(forKey: "isDarkMode")
		}
		set {
			UserDefaults.standard.set(newValue, forKey: "isDarkMode")
		}
	}
}
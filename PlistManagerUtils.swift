import Foundation

class PlistManagerUtils {

    // 单例实例
    static let shared = PlistManager(plistName: "userSettings")

    private var plistFileURL: URL
    private var preferences: [String: Any]
    private var cachedChanges: [String: Any] = [:]
    private var isDirty = false

    // 初始化 PlistManager，指定 plist 文件名
    private init(plistName: String) {
        // 获取沙盒中的 Preferences 目录路径
        let preferencesDirectory = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
        self.plistFileURL = preferencesDirectory.appendingPathComponent("Preferences/\(plistName).plist")

        // 如果 plist 文件不存在，则创建一个空的文件
        if !FileManager.default.fileExists(atPath: plistFileURL.path) {
            preferences = [:]
            save()
        } else {
            preferences = loadPreferences()
        }
    }

    // 加载 plist 文件中的数据
    private func loadPreferences() -> [String: Any] {
        guard let data = try? Data(contentsOf: plistFileURL),
              let preferences = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
            return [:]
        }
        return preferences
    }

    // 保存数据到 plist 文件
    private func save() {
        do {
            let data = try PropertyListSerialization.data(fromPropertyList: preferences, format: .xml, options: 0)
            try data.write(to: plistFileURL)
        } catch {
            print("Error saving preferences to plist: \(error.localizedDescription)")
        }
    }

    // 获取指定 key 对应的 Int 值
    func getInt(forKey key: String, defaultValue: Int) -> Int {
        return preferences[key] as? Int ?? defaultValue
    }

    // 获取指定 key 对应的 Bool 值
    func getBool(forKey key: String, defaultValue: Bool) -> Bool {
        return preferences[key] as? Bool ?? defaultValue
    }

    // 获取指定 key 对应的 String 值
    func getString(forKey key: String, defaultValue: String) -> String {
        return preferences[key] as? String ?? defaultValue
    }

    // 获取指定 key 对应的 Float 值
    func getFloat(forKey key: String, defaultValue: Float) -> Float {
        return preferences[key] as? Float ?? defaultValue
    }

    // 获取指定 key 对应的 Double 值
    func getDouble(forKey key: String, defaultValue: Double) -> Double {
        return preferences[key] as? Double ?? defaultValue
    }

    // 获取指定 key 对应的 Data 值
    func getData(forKey key: String, defaultValue: Data) -> Data {
        return preferences[key] as? Data ?? defaultValue
    }

    // 获取指定 key 对应的 URL 值
    func getURL(forKey key: String, defaultValue: URL) -> URL {
        return preferences[key] as? URL ?? defaultValue
    }

    // 获取指定 key 对应的 Array 值
    func getArray(forKey key: String, defaultValue: [Any]) -> [Any] {
        return preferences[key] as? [Any] ?? defaultValue
    }

    // 获取指定 key 对应的 Dictionary 值
    func getDictionary(forKey key: String, defaultValue: [String: Any]) -> [String: Any] {
        return preferences[key] as? [String: Any] ?? defaultValue
    }

    // 设置 Int 值
    func setInt(key: String, value: Int) {
        cachedChanges[key] = value
        isDirty = true
    }

    // 设置 Bool 值
    func setBool(key: String, value: Bool) {
        cachedChanges[key] = value
        isDirty = true
    }

    // 设置 String 值
    func setString(key: String, value: String) {
        cachedChanges[key] = value
        isDirty = true
    }

    // 设置 Float 值
    func setFloat(key: String, value: Float) {
        cachedChanges[key] = value
        isDirty = true
    }

    // 设置 Double 值
    func setDouble(key: String, value: Double) {
        cachedChanges[key] = value
        isDirty = true
    }

    // 设置 Data 值
    func setData(key: String, value: Data) {
        cachedChanges[key] = value
        isDirty = true
    }

    // 设置 URL 值
    func setURL(key: String, value: URL) {
        cachedChanges[key] = value
        isDirty = true
    }

    // 设置 Array 值
    func setArray(key: String, value: [Any]) {
        cachedChanges[key] = value
        isDirty = true
    }

    // 设置 Dictionary 值
    func setDictionary(key: String, value: [String: Any]) {
        cachedChanges[key] = value
        isDirty = true
    }

    // 删除指定 key 的数据
    func remove(forKey key: String) {
        cachedChanges[key] = nil
        isDirty = true
    }

    // 清除 plist 文件（删除整个文件）
    func clear() {
        do {
            try FileManager.default.removeItem(at: plistFileURL)
            preferences = [:]
        } catch {
            print("Error clearing plist file: \(error.localizedDescription)")
        }
    }

    // 将更改保存到 plist
    func apply() {
        // 只有在有修改的情况下才进行保存
        if isDirty {
            // 将所有更改合并到 preferences 中，覆盖掉已存在的相同键
            for (key, value) in cachedChanges {
                preferences[key] = value
            }

            // 执行保存操作
            save()

            // 重置缓存和脏标记
            cachedChanges.removeAll()
            isDirty = false
        }
    }
}

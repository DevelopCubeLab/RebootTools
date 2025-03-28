# RebootTools
iOS Utils TrollStore App reboot your device  
**⚠️Need install via TrollStore.**  
Use system restart code `reboot(0);` is safe and reliable, use it with confidence.  
**Note: This project will NOT release/store files in parts other than the App sandbox, and will NOT include ANY URL Scheme. You can use it with confidence and will not be detected by third-party app on App Stores. For specific issues, please [view](https://bsky.app/profile/opa334.bsky.social/post/3ll7zkia24c2s).**  

**iOS 重启工具**  
**⚠️需要TrollStore权限**  
系统级别重启代码`reboot(0);`安全可靠，放心使用  
**注意：本项目不会在除本App沙盒以外的部分释放/存储文件，并且不会包含任何URL Scheme，您可以放心使用，而不会被第三方App Store的检测到，具体问题请[查看](https://bsky.app/profile/opa334.bsky.social/post/3ll7zkia24c2s)**  

## Testing
I installed and tested using `TrollStore` on the following iOS versions. All iOS versions that support `TrollStore` can use this tool.
1. iOS 14.3
2. iOS 15.3.1
3. iOS 15.4.1
4. iOS 15.5
5. iOS 15.6
6. iOS 16.5
7. iPadOS 15.4.1

我在以下系统版本使用`TrollStore`安装并进行测试，所有支持`TrollStore`的系统都可以使用这个工具
1. iOS 14.3
2. iOS 15.3.1
3. iOS 15.4.1
4. iOS 15.5
5. iOS 15.6
6. iOS 16.5
7. iPadOS 15.4.1

## Build
1. Download and install [Theos](https://theos.dev/)
2. Run `make package FINALPACKAGE=1 PACKAGE_FORMAT=ipa`

Full build:
1. Download and install [Theos](https://theos.dev/)
2. Enter [RebootRootHelper](https://github.com/DevelopCubeLab/RebootTools/tree/main/RebootRootHelper) directory
3. Run `make` or `run stage` to build [RebootRootHelper](https://github.com/DevelopCubeLab/RebootTools/blob/main/Resources/RebootRootHelper). This helper is core of Reboot
4. Copy `RebootRootHelper` to [Resources](https://github.com/DevelopCubeLab/RebootTools/tree/main/Resources) directory. (I have built this helper and placed it in the `Resources` directory)
5. Back to `Home directory`
6. Run `make package FINALPACKAGE=1 PACKAGE_FORMAT=ipa`(of course, you can also build deb, but I think it's not necessary)
7. You will get this `tipa` file.

## Thanks
[肖博Vlog](https://m.xiaobovlog.cn/) 提供的重启设备核心代码`reboot(0);`  
[TrollStore](https://github.com/opa334/TrollStore)  
Powered by ChatGPT 4o & 4o mini  
icon by `SF Symbols`

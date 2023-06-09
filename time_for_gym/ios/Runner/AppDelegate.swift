import UIKit
import Flutter
import device_info_plus

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // if #available(iOS 9.0, *) {
    //   // Ensure the DeviceInfoPlugin is registered
    //   if !DeviceInfoPlugin().hasPlugin() {
    //     DeviceInfoPlugin.register(with: self)
    //   }
    // }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

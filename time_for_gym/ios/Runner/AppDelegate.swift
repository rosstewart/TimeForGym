import UIKit
import Flutter
import device_info_plus
import GoogleMobileAds

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    GADMobileAds.sharedInstance().start(completionHandler: nil)
    GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ kGADSimulatorID ]
    // GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ ca-app-pub-3940256099942544/2934735716 ]
    // if #available(iOS 9.0, *) {
    //   // Ensure the DeviceInfoPlugin is registered
    //   if !DeviceInfoPlugin().hasPlugin() {
    //     DeviceInfoPlugin.register(with: self)
    //   }
    // }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

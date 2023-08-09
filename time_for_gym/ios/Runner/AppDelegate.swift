import UIKit
import Flutter
import GoogleMobileAds
import flutter_local_notifications
//import playSplitTimer // Import the playSplitTimer target so that NotificationViewController is accessible

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
          GeneratedPluginRegistrant.register(with: self)

          // Observe the custom notification from the NotificationViewController
//        NotificationCenter.default.addObserver(self, selector: #selector(handleTimerDurationUpdated(notification:)), name: NotificationViewController.timerDurationUpdatedNotification, object: nil)

    GADMobileAds.sharedInstance().start(completionHandler: nil)
    GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ GADSimulatorID] // Simulator devices are test
    // , "d8a1e829c394ae8da1bb39b2a7a483a3" ]
    // GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "0d7d7b286876f158e675c1dc763295cd" ]
    // GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ kGADSimulatorID ]
    // GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ ca-app-pub-3940256099942544/2934735716 ]
    // if #available(iOS 9.0, *) {
    //   // Ensure the DeviceInfoPlugin is registered
    //   if !DeviceInfoPlugin().hasPlugin() {
    //     DeviceInfoPlugin.register(with: self)
    //   }
    // }

//     This is required to make any communication available in the action isolate.
//    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
//        GeneratedPluginRegistrant.register(with: registry)
//    }

//    if #available(iOS 10.0, *) {
//      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
//    }
          
//          // Register the platform channel handler
//              let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
//              let channel = FlutterMethodChannel(name: "com.example.timeForGym.playSplitTimer", binaryMessenger: controller.binaryMessenger)
//              channel.setMethodCallHandler({
//                [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
//                // Handle method call from Flutter
//                if call.method == "updateTimerDuration" {
//                  if let arguments = call.arguments as? [String: Any],
//                     let seconds = arguments["seconds"] as? Int {
//                    self?.updateTimerDuration(seconds: seconds)
//                  }
//                }
//              })
//              // End of platform channel handler registration
          
          // let channel = FlutterMethodChannel(name: "com.example.timeForGym.playSplitTimer", binaryMessenger: self)
          // channel.setMethodCallHandler { [weak self] (call, result) in
          //     if call.method == "updateTimerDuration" {
          //         if let arguments = call.arguments as? [String: Any],
          //             let seconds = arguments["seconds"] as? Int {
          //             // Call the method to update the timer duration
          //             self?.updateTimerDuration(seconds: seconds)
          //         }
          //     }
          // }
          
          // Access the NotificationViewController from the Notification Content Extension target
                  // let notificationViewController = playSplitTimer.NotificationViewController()

          // Get the FlutterViewController and create the channel
//        if let controller = window?.rootViewController as? FlutterViewController {
//            let channel = FlutterMethodChannel(name: "com.example.timeForGym.playSplitTimer", binaryMessenger: controller.binaryMessenger)
//            channel.setMethodCallHandler { [weak self] (call, result) in
//                if call.method == "updateTimerDuration" {
//                    if let arguments = call.arguments as? [String: Any],
//                       let seconds = arguments["seconds"] as? Int {
//                        // Call the method to update the timer duration
//                        self?.updateTimerDuration(seconds: seconds)
//                    }
//                }
//            }
//        }
        

    

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Function to update the timer duration in the main app (AppDelegate)
//    @objc private func handleTimerDurationUpdated(notification: Notification) {
//        if let seconds = notification.userInfo?["seconds"] as? Int {
//            // Update the timer duration in the main app (AppDelegate)
//            // Do whatever you need to do with the updated timer duration
//            // For example, update the Flutter state or trigger some action
//        }
//    }
//    
//    // Function to update the timer duration in the Notification Content Extension
//    private func updateTimerDuration(seconds: Int) {
//        // Post the custom notification
//        NotificationCenter.default.post(name: NotificationViewController.timerDurationUpdatedNotification, object: nil, userInfo: ["seconds": seconds])
//    }
}

import UIKit
import UserNotifications
import UserNotificationsUI
//import Flutter

public class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var countdownLabel: UILabel!
    var countdownTimer: Timer?
    var remainingSeconds: Int = 20 // Set the initial timer duration in seconds

    // Declare a custom notification name
    public static let timerDurationUpdatedNotification = Notification.Name("com.example.timeForGym.timerDurationUpdated")

    // Function to update the timer duration in the Notification Content Extension
    public func updateTimerDuration(seconds: Int) {
        // Post the custom notification
        NotificationCenter.default.post(name: NotificationViewController.timerDurationUpdatedNotification, object: nil, userInfo: ["seconds": seconds])
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required setup here.

        // Start the countdown timer
        startTimer()

        // Add the notification observer
        // NotificationCenter.default.addObserver(self, selector: #selector(handleTimerDurationUpdated(_:)), name: NotificationViewController.timerDurationUpdatedNotification, object: nil)
    }

    // Function to start the countdown timer
    public func startTimer() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }

    // Function to update the timer and the notification content
    @objc public func updateTimer() {
        if remainingSeconds > 0 {
            remainingSeconds -= 1
            countdownLabel.text = "\(remainingSeconds) seconds left"

            // Invalidate the timer and dismiss the extension when the timer is done
            if remainingSeconds == 0 {
                countdownTimer?.invalidate()
                countdownTimer = nil
                extensionContext?.dismissNotificationContentExtension()
            }
        }
    }

    // // Function to update the timer duration received from Flutter
    // public func updateTimerDuration(seconds: Int) {
    //     remainingSeconds = seconds
    //     countdownLabel.text = "\(remainingSeconds) seconds left"
    // }

    public func didReceive(_ notification: UNNotification) {
            // Implement any additional setup you need here.
            if let userInfo = notification.request.content.userInfo as? [String: Any],
               let seconds = userInfo["timerDuration"] as? Int {
                // Call the method to update the timer duration
                updateTimerDuration(seconds: seconds)
            }
        }

    // // Function to handle the notification when timer duration is updated
    // @objc func handleTimerDurationUpdated(_ notification: Notification) {
    //     if let userInfo = notification.userInfo,
    //        let seconds = userInfo["seconds"] as? Int {
    //         // Call the method to update the timer duration
    //         updateTimerDuration(seconds: seconds)
    //     }
    // }

    // Function to update the timer duration in the Notification Content Extension
    // public func updateTimerDuration(seconds: Int) {
    //     // Post the custom notification
    //     NotificationCenter.default.post(name: NotificationViewController.timerDurationUpdatedNotification, object: nil, userInfo: ["seconds": seconds])
    // }



}

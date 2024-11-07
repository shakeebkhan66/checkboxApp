import UIKit
import Flutter
import UserNotifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  var deviceTokenString: String?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: "com.standortdigital.flexpush/deviceToken", binaryMessenger: controller.binaryMessenger)

      channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
          if call.method == "getDeviceToken" {
              if let token = self.deviceTokenString {
                  result(token)
              } else {
                  result(FlutterError(code: "UNAVAILABLE", message: "Device Token nicht verfügbar", details: nil))
              }
          } else {
              result(FlutterMethodNotImplemented)
          }
      }
    } else {
      print("FlutterViewController ist nicht verfügbar.")
    }

    // Registrierung für Push-Benachrichtigungen
    UNUserNotificationCenter.current().delegate = self
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
        if let error = error {
            print("Fehler bei der Anfrage nach Benachrichtigungen: \(error)")
            return
        }
        if granted {
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        } else {
            print("Benachrichtigungsberechtigung verweigert")
        }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    deviceTokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    print("Device Token: \(deviceTokenString ?? "kein Token")")
  }

  override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("Fehler bei der Registrierung für Remote-Benachrichtigungen: \(error)")
  }
}
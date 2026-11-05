import Flutter
import UIKit
import UniformTypeIdentifiers
import UserNotifications
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    // Lets snooze actions run in a background isolate with plugins available.
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "PlmPlatform") {
      let channel = FlutterMethodChannel(
        name: "app.plm/platform", binaryMessenger: registrar.messenger())
      channel.setMethodCallHandler(Self.handlePlatformCall)
    }
  }

  /// Keeps app data out of iCloud/iTunes backups (V1: no automatic backup).
  private static func handlePlatformCall(
    _ call: FlutterMethodCall, result: @escaping FlutterResult
  ) {
    if call.method == "copySensitive" {
      let args = call.arguments as? [String: Any]
      let text = args?["text"] as? String ?? ""
      let seconds = args?["seconds"] as? Int ?? 30
      // Expires on its own; localOnly keeps it off Universal Clipboard.
      UIPasteboard.general.setItems(
        [[UTType.plainText.identifier: text]],
        options: [
          .expirationDate: Date().addingTimeInterval(TimeInterval(seconds)),
          .localOnly: true,
        ])
      result(nil)
      return
    }
    if call.method == "openNotificationSettings" {
      if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
        UIApplication.shared.open(url)
      }
      result(nil)
      return
    }
    guard call.method == "excludeFromBackup", let path = call.arguments as? String else {
      result(FlutterMethodNotImplemented)
      return
    }
    var url = URL(fileURLWithPath: path, isDirectory: true)
    var values = URLResourceValues()
    values.isExcludedFromBackup = true
    do {
      try url.setResourceValues(values)
      result(nil)
    } catch {
      result(FlutterError(code: "exclude_failed", message: nil, details: nil))
    }
  }
}

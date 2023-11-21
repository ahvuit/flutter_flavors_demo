import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController

    let channel = FlutterMethodChannel(
        name: "channel",
        binaryMessenger: controller.binaryMessenger)

    channel.setMethodCallHandler({
          (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
          switch call.method {
          case "getStringFromNative":
            self.getStringFromNative(result: result)
          case "sendMessageToNative":
            let data = call.arguments
            print(data)
          default:
            result(FlutterMethodNotImplemented)
          }
        })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func getStringFromNative(result: FlutterResult) {
    result("Hello from ios to Flutter!")
  }
}

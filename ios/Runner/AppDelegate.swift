import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let CHANNEL = "channel"
    let EVENT_CHANNEL = "eventChannel"
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(
        name: CHANNEL,
        binaryMessenger: controller.binaryMessenger)
    let eventChannel = FlutterEventChannel(name: EVENT_CHANNEL, binaryMessenger: controller.binaryMessenger)
    eventChannel.setStreamHandler(TimeHandler())

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

   class TimeHandler: NSObject, FlutterStreamHandler {
          var timer = Timer()

          func onListen(withArguments arguments: Any?,eventSink: @escaping FlutterEventSink) -> FlutterError? {
              self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
                  let dateFormat = DateFormatter()
                  dateFormat.dateFormat = "HH:mm:ss"
                  let time = dateFormat.string(from: Date())
                  print(time)
                  eventSink(time)
              })
              return nil
          }

          func onCancel(withArguments arguments: Any?) -> FlutterError? {
              return nil
          }
      }
}

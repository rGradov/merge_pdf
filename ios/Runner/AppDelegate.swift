import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    guard
      let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "MergePdfShare")
    else {
      return
    }
    let messenger = registrar.messenger()
    let channel = FlutterMethodChannel(name: "merge_pdf/share", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      guard call.method == "shareFile",
        let args = call.arguments as? [String: Any],
        let path = args["path"] as? String
      else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard FileManager.default.fileExists(atPath: path) else {
        result(FlutterError(code: "no_file", message: "file not found", details: nil))
        return
      }
      let activity = UIActivityViewController(
        activityItems: [URL(fileURLWithPath: path)], applicationActivities: nil)
      if let popover = activity.popoverPresentationController {
        popover.sourceView = Self.topViewController()?.view
        popover.sourceRect = popover.sourceView?.bounds ?? .zero
      }
      Self.topViewController()?.present(activity, animated: true)
      result(nil)
    }
  }

  private static func topViewController() -> UIViewController? {
    for scene in UIApplication.shared.connectedScenes {
      guard let windowScene = scene as? UIWindowScene else { continue }
      for window in windowScene.windows where window.isKeyWindow {
        var top = window.rootViewController
        while let presented = top?.presentedViewController {
          top = presented
        }
        return top
      }
    }
    return nil
  }
}
